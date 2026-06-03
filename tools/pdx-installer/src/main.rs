use pdx_installer::{parse_args, run};
use std::process::ExitCode;

fn main() -> ExitCode {
    match real_main() {
        Ok(()) => ExitCode::SUCCESS,
        Err(message) => {
            eprintln!("{message}");
            ExitCode::from(1)
        }
    }
}

fn real_main() -> Result<(), String> {
    let raw_args = std::env::args().skip(1).collect::<Vec<_>>();
    if raw_args
        .first()
        .map(|arg| matches!(arg.as_str(), "-V" | "--version" | "version"))
        .unwrap_or(false)
    {
        println!("Pandocker-X installer {}", env!("CARGO_PKG_VERSION"));
        return Ok(());
    }

    let args = parse_args(raw_args)?;
    let report = run(&args)?;
    for line in report.lines {
        println!("{line}");
    }
    Ok(())
}
