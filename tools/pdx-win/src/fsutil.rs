use crate::Result;
use std::fs;
use std::io::Write;
use std::path::{Path, PathBuf};
use std::process::Command;

pub fn find_repo_root() -> Option<PathBuf> {
    let mut candidates = Vec::new();
    if let Ok(dir) = std::env::current_dir() {
        candidates.push(dir);
    }
    if let Ok(exe) = std::env::current_exe() {
        if let Some(parent) = exe.parent() {
            candidates.push(parent.to_path_buf());
            if let Some(parent) = parent.parent() {
                candidates.push(parent.to_path_buf());
            }
        }
    }

    for start in candidates {
        let mut current = Some(start.as_path());
        while let Some(dir) = current {
            if dir.join("defaults.yml").exists()
                && dir.join("config").join("config.ps1").exists()
                && dir.join("config").join("pandoc-args.json").exists()
            {
                return Some(dir.to_path_buf());
            }
            current = dir.parent();
        }
    }

    None
}

pub fn ensure_dir(path: &Path) -> Result<()> {
    fs::create_dir_all(path).map_err(|err| format!("failed to create {}: {err}", path.display()))
}

pub fn read_text(path: &Path) -> Result<String> {
    fs::read_to_string(path).map_err(|err| format!("failed to read {}: {err}", path.display()))
}

pub fn write_text(path: &Path, text: &str) -> Result<()> {
    if let Some(parent) = path.parent() {
        ensure_dir(parent)?;
    }
    let mut file = fs::File::create(path)
        .map_err(|err| format!("failed to write {}: {err}", path.display()))?;
    file.write_all(text.as_bytes())
        .map_err(|err| format!("failed to write {}: {err}", path.display()))
}

pub fn copy_file(source: &Path, destination: &Path) -> Result<()> {
    if let Some(parent) = destination.parent() {
        ensure_dir(parent)?;
    }
    fs::copy(source, destination).map(|_| ()).map_err(|err| {
        format!(
            "failed to copy {} to {}: {err}",
            source.display(),
            destination.display()
        )
    })
}

pub fn list_markdown_files(root: &Path) -> Result<Vec<PathBuf>> {
    let mut files = Vec::new();
    collect_markdown_files(root, root, &mut files)?;
    files.sort();
    Ok(files)
}

fn collect_markdown_files(root: &Path, current: &Path, files: &mut Vec<PathBuf>) -> Result<()> {
    for entry in fs::read_dir(current)
        .map_err(|err| format!("failed to read {}: {err}", current.display()))?
    {
        let entry = entry.map_err(|err| format!("failed to read {}: {err}", current.display()))?;
        let path = entry.path();
        if path.is_dir() {
            collect_markdown_files(root, &path, files)?;
        } else if path
            .extension()
            .and_then(|ext| ext.to_str())
            .map(|ext| ext.eq_ignore_ascii_case("md"))
            .unwrap_or(false)
        {
            files.push(relative_path(root, &path)?);
        }
    }
    Ok(())
}

pub fn relative_path(base: &Path, target: &Path) -> Result<PathBuf> {
    let base = base
        .canonicalize()
        .map_err(|err| format!("failed to resolve {}: {err}", base.display()))?;
    let target = target
        .canonicalize()
        .map_err(|err| format!("failed to resolve {}: {err}", target.display()))?;
    target
        .strip_prefix(&base)
        .map(|path| path.to_path_buf())
        .map_err(|_| {
            format!(
                "target path '{}' is not under '{}'",
                target.display(),
                base.display()
            )
        })
}

pub fn replace_extension(path: &str, extension: &str) -> String {
    let mut path_buf = PathBuf::from(path);
    path_buf.set_extension(extension);
    path_buf.to_string_lossy().to_string()
}

pub fn robocopy_mirror(
    source: &Path,
    destination: &Path,
    exclude_files: &[&str],
    exclude_dirs: &[&str],
) -> Result<()> {
    ensure_dir(destination)?;

    let mut command = Command::new("robocopy");
    command.arg(source);
    command.arg(destination);
    command.arg("/MIR");
    command.arg("/NFL");
    command.arg("/NDL");
    command.arg("/NJH");
    command.arg("/NJS");
    for file in exclude_files {
        command.arg("/XF").arg(file);
    }
    for dir in exclude_dirs {
        command.arg("/XD").arg(dir);
    }

    let status = command
        .status()
        .map_err(|err| format!("failed to run robocopy: {err}"))?;
    let code = status.code().unwrap_or(16);
    if code >= 8 {
        return Err(format!(
            "robocopy failed for {} -> {} (exit code {code})",
            source.display(),
            destination.display()
        ));
    }

    Ok(())
}
