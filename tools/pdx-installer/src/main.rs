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
    let args = parse_args(std::env::args().skip(1).collect::<Vec<_>>())?;
    let report = run(&args)?;
    for line in report.lines {
        println!("{line}");
    }
    Ok(())
}
