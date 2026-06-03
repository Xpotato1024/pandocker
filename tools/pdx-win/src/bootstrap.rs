use crate::wsl::{run_command_capture, run_wsl_shell};
use crate::Result;
use std::io::{self, IsTerminal, Write};
use std::process::Command;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum PackageManager {
    Apt,
    Dnf,
    Pacman,
    Zypper,
}

#[derive(Debug, Clone, Copy)]
struct DockerStatus {
    docker_cli: bool,
    compose_plugin: bool,
    daemon_running: bool,
}

pub fn ensure_wsl_docker_runtime(distro: &str) -> Result<()> {
    let status = probe_docker_status(distro)?;

    if status.docker_cli && status.compose_plugin && status.daemon_running {
        return Ok(());
    }

    if status.docker_cli && status.compose_plugin && !status.daemon_running {
        start_docker_service(distro)?;
        let status = probe_docker_status(distro)?;
        if status.docker_cli && status.compose_plugin && status.daemon_running {
            return Ok(());
        }

        return Err(
            "dockerd is not running. Start it with `sudo systemctl start docker` or enable Docker in the WSL distro."
                .to_string(),
        );
    }

    let package_manager = detect_package_manager(distro)?;
    let install_message = format!(
        "docker / docker compose are not installed in WSL distro '{distro}'.\n\
         Install them now?\n\n\
         This will run package manager commands inside WSL and may ask for your sudo password."
    );
    if !prompt_yes_no(&install_message)? {
        return Err(
            "Docker prerequisites are missing. Install docker and the compose plugin in WSL, then run pdx setup again."
                .to_string(),
        );
    }

    install_docker_packages(distro, package_manager)?;
    start_docker_service(distro)?;

    let status = probe_docker_status(distro)?;
    if status.docker_cli && status.compose_plugin && status.daemon_running {
        Ok(())
    } else {
        Err(
            "Docker installation completed, but docker / docker compose / dockerd are still unavailable in WSL."
                .to_string(),
        )
    }
}

fn probe_docker_status(distro: &str) -> Result<DockerStatus> {
    let docker_cli = run_wsl_shell_status(distro, "command -v docker >/dev/null 2>&1")?;
    let compose_plugin = if docker_cli {
        run_wsl_shell_status(distro, "docker compose version >/dev/null 2>&1")?
    } else {
        false
    };
    let daemon_running = if docker_cli && compose_plugin {
        run_wsl_shell_status(distro, "docker info >/dev/null 2>&1")?
    } else {
        false
    };

    Ok(DockerStatus {
        docker_cli,
        compose_plugin,
        daemon_running,
    })
}

fn start_docker_service(distro: &str) -> Result<()> {
    let status = run_wsl_shell(
        distro,
        "systemctl is-active docker >/dev/null 2>&1 || sudo systemctl start docker",
    )?;
    if status != 0 {
        return Err(
            "failed to start dockerd. Make sure systemd is enabled in the WSL distro and that the docker service is installed."
                .to_string(),
        );
    }

    Ok(())
}

fn detect_package_manager(distro: &str) -> Result<PackageManager> {
    let script = r#"
if command -v apt-get >/dev/null 2>&1; then
    printf '%s' apt
elif command -v dnf >/dev/null 2>&1; then
    printf '%s' dnf
elif command -v pacman >/dev/null 2>&1; then
    printf '%s' pacman
elif command -v zypper >/dev/null 2>&1; then
    printf '%s' zypper
fi
"#;
    let output = run_command_capture("wsl.exe", &["-d", distro, "-e", "sh", "-lc", script])?;
    let manager = String::from_utf8_lossy(&output.stdout).trim().to_string();

    match manager.as_str() {
        "apt" => Ok(PackageManager::Apt),
        "dnf" => Ok(PackageManager::Dnf),
        "pacman" => Ok(PackageManager::Pacman),
        "zypper" => Ok(PackageManager::Zypper),
        _ => Err(
            "supported package manager was not found in WSL. Install docker and docker compose manually."
                .to_string(),
        ),
    }
}

fn install_docker_packages(distro: &str, package_manager: PackageManager) -> Result<()> {
    let command = match package_manager {
        PackageManager::Apt => {
            "sudo apt-get update && sudo apt-get install -y docker.io docker-compose-plugin"
        }
        PackageManager::Dnf => "sudo dnf install -y docker docker-compose-plugin",
        PackageManager::Pacman => "sudo pacman -S --noconfirm docker docker-compose",
        PackageManager::Zypper => "sudo zypper --non-interactive install docker docker-compose",
    };

    let status = run_wsl_shell(distro, command)?;
    if status != 0 {
        return Err(
            "failed to install docker / docker compose inside WSL. Install them manually and run pdx setup again."
                .to_string(),
        );
    }

    Ok(())
}

fn run_wsl_shell_status(distro: &str, command: &str) -> Result<bool> {
    Ok(run_wsl_shell(distro, command)? == 0)
}

fn prompt_yes_no(message: &str) -> Result<bool> {
    if io::stdin().is_terminal() {
        println!("{message}");
        print!("Install now? [y/N]: ");
        io::stdout()
            .flush()
            .map_err(|err| format!("failed to flush stdout: {err}"))?;

        let mut answer = String::new();
        io::stdin()
            .read_line(&mut answer)
            .map_err(|err| format!("failed to read input: {err}"))?;
        let answer = answer.trim().to_ascii_lowercase();
        Ok(matches!(answer.as_str(), "y" | "yes"))
    } else {
        let escaped = message.replace('\'', "''");
        let script = format!(
            "Add-Type -AssemblyName System.Windows.Forms; $result = [System.Windows.Forms.MessageBox]::Show('{escaped}', 'Pandocker-X', 'YesNo', 'Question'); if ($result -eq 'Yes') {{ exit 0 }} else {{ exit 1 }}"
        );
        let status = Command::new("powershell.exe")
            .args(["-NoProfile", "-Command", &script])
            .status()
            .map_err(|err| format!("failed to display confirmation dialog: {err}"))?;
        Ok(status.success())
    }
}
