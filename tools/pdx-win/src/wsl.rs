use crate::Result;
use std::process::{Command, Output, Stdio};

pub fn shell_quote_single(value: &str) -> String {
    let escaped = value.replace('\'', "'\"'\"'");
    format!("'{}'", escaped)
}

pub fn run_command_capture(program: &str, args: &[&str]) -> Result<Output> {
    let output = Command::new(program)
        .args(args)
        .output()
        .map_err(|err| format!("failed to run {program}: {err}"))?;
    Ok(output)
}

pub fn run_wsl_shell(distro: &str, command: &str) -> Result<i32> {
    let status = Command::new("wsl.exe")
        .args(["-d", distro, "-e", "sh", "-lc", command])
        .stdin(Stdio::inherit())
        .stdout(Stdio::inherit())
        .stderr(Stdio::inherit())
        .status()
        .map_err(|err| format!("failed to run wsl.exe: {err}"))?;
    Ok(status.code().unwrap_or(1))
}
