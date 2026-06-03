use crate::fsutil::read_text;
use crate::wsl::{run_command_capture, run_wsl_shell};
use std::path::{Path, PathBuf};

use crate::Result;

#[derive(Debug, Clone)]
pub struct AppConfig {
    pub wsl_distro: String,
    pub wsl_work_dir_name: String,
    pub docker_backend: String,
    pub sync_mode: SyncMode,
}

#[derive(Debug, Clone, Copy)]
pub enum SyncMode {
    MirrorRepo,
    ProjectOnly,
    None,
}

impl SyncMode {
    pub fn as_str(self) -> &'static str {
        match self {
            SyncMode::MirrorRepo => "mirror-repo",
            SyncMode::ProjectOnly => "project-only",
            SyncMode::None => "none",
        }
    }
}

impl AppConfig {
    pub fn load(repo_root: &Path) -> Result<Self> {
        let config_path = repo_root.join("config").join("config.ps1");
        let text = read_text(&config_path)?;

        Ok(Self {
            wsl_distro: extract_string(&text, "WslDistro").unwrap_or_else(|| "Ubuntu".to_string()),
            wsl_work_dir_name: extract_string(&text, "WslWorkDirName")
                .unwrap_or_else(|| "pandocker_work".to_string()),
            docker_backend: extract_string(&text, "DockerBackend")
                .unwrap_or_else(|| "wsl-dockerd".to_string()),
            sync_mode: match extract_string(&text, "SyncMode").as_deref() {
                Some("project-only") => SyncMode::ProjectOnly,
                Some("none") => SyncMode::None,
                _ => SyncMode::MirrorRepo,
            },
        })
    }

    pub fn wsl_home(&self) -> Result<String> {
        let output = run_command_capture(
            "wsl.exe",
            &[
                "-d",
                &self.wsl_distro,
                "-e",
                "sh",
                "-lc",
                "printf \"%s\" \"$HOME\"",
            ],
        )?;
        let home = String::from_utf8_lossy(&output.stdout).trim().to_string();
        if home.is_empty() {
            return Err("failed to determine the WSL home directory".to_string());
        }
        Ok(home)
    }

    pub fn wsl_project_root_unix(&self) -> Result<String> {
        Ok(format!("{}/{}", self.wsl_home()?, self.wsl_work_dir_name))
    }

    pub fn wsl_project_root_win(&self, wsl_project_root_unix: &str) -> Result<String> {
        let output = run_command_capture(
            "wsl.exe",
            &[
                "-d",
                &self.wsl_distro,
                "-e",
                "wslpath",
                "-w",
                wsl_project_root_unix,
            ],
        )?;
        let path = String::from_utf8_lossy(&output.stdout).trim().to_string();
        if path.is_empty() {
            return Err("failed to convert the WSL project path to Windows format".to_string());
        }
        Ok(path)
    }

    pub fn test_prerequisites(&self) -> Result<()> {
        let output = run_command_capture("wsl.exe", &["-l", "--quiet"])?;
        let distros = String::from_utf8_lossy(&output.stdout);
        let found = distros.lines().any(|line| line.trim() == self.wsl_distro);
        if !found {
            return Err(format!(
                "WSL distro '{}' was not found.\nInstalled distros:\n{}",
                self.wsl_distro,
                String::from_utf8_lossy(&output.stdout)
            ));
        }

        let probe = "docker version >/dev/null && docker compose version >/dev/null";
        match self.docker_backend.as_str() {
            "desktop" => {
                let status = run_wsl_shell(&self.wsl_distro, probe)?;
                if status != 0 {
                    return Err("cannot connect to Docker Desktop from WSL. Enable WSL Integration in Docker Desktop.".to_string());
                }
            }
            "wsl-dockerd" => {
                let status = run_wsl_shell(&self.wsl_distro, probe)?;
                if status != 0 {
                    return Err("docker / docker compose is not available in WSL.".to_string());
                }

                let status = run_wsl_shell(
                    &self.wsl_distro,
                    "systemctl is-active docker >/dev/null 2>&1 || pgrep dockerd >/dev/null 2>&1",
                )?;
                if status != 0 {
                    return Err("dockerd is not running. Start it with `systemctl start docker` or launch dockerd manually.".to_string());
                }
            }
            other => {
                return Err(format!("unsupported DockerBackend '{other}'."));
            }
        }

        Ok(())
    }

    pub fn sync_workspace(&self, repo_root: &Path) -> Result<()> {
        let wsl_root_unix = self.wsl_project_root_unix()?;
        let wsl_root_win = self.wsl_project_root_win(&wsl_root_unix)?;
        let destination = PathBuf::from(&wsl_root_win);
        crate::fsutil::ensure_dir(&destination)?;

        match self.sync_mode {
            SyncMode::None => Ok(()),
            SyncMode::MirrorRepo => {
                crate::fsutil::robocopy_mirror(
                    repo_root,
                    &destination,
                    &[".git"],
                    &[".git", "log", "target"],
                )?;
                Ok(())
            }
            SyncMode::ProjectOnly => {
                let directories = ["config", "csl", "preamble", "templates", "projects"];
                for directory in directories {
                    let source = repo_root.join(directory);
                    if source.exists() {
                        let target = destination.join(directory);
                        crate::fsutil::robocopy_mirror(&source, &target, &[], &[])?;
                    }
                }

                for file in [
                    "defaults.yml",
                    "defaults-paper.yml",
                    "Dockerfile",
                    "docker-compose.yml",
                    "README.md",
                    "LICENSE",
                ] {
                    let source = repo_root.join(file);
                    if source.exists() {
                        crate::fsutil::copy_file(&source, &destination.join(file))?;
                    }
                }

                Ok(())
            }
        }
    }
}

fn extract_string(text: &str, key: &str) -> Option<String> {
    let marker = format!("{key} = ");
    let line = text.lines().find(|line| line.contains(&marker))?;
    let (_, value) = line.split_once('=')?;
    let value = value.trim();
    let value = value.trim_matches('"');
    Some(value.to_string())
}
