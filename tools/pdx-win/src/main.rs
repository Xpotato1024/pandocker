mod config;
mod fsutil;
mod wsl;

use crate::config::AppConfig;
use crate::fsutil::{
    copy_file, ensure_dir, find_repo_root, list_markdown_files, read_text, relative_path,
    replace_extension, write_text,
};
use crate::wsl::{run_wsl_shell, shell_quote_single};
use chrono::Local;
use serde_json::Value;
use std::env;
use std::ffi::OsString;
use std::path::{Path, PathBuf};
use std::process::ExitCode;

type Result<T> = std::result::Result<T, String>;

fn main() -> ExitCode {
    match real_main() {
        Ok(()) => ExitCode::SUCCESS,
        Err(message) => {
            eprintln!("{message}");
            ExitCode::from(1)
        }
    }
}

fn real_main() -> Result<()> {
    let mut args: Vec<OsString> = env::args_os().skip(1).collect();
    if args.is_empty() || is_help_flag(&args[0]) {
        print_usage();
        return Ok(());
    }

    let command = args
        .remove(0)
        .into_string()
        .map_err(|_| "command contains invalid UTF-8".to_string())?;
    let repo_root =
        find_repo_root().ok_or_else(|| "failed to locate the repository root".to_string())?;
    let config = AppConfig::load(&repo_root)?;

    match command.as_str() {
        "new" => cmd_new(&repo_root, &args),
        "setup" => cmd_setup(&repo_root, &config),
        "build" => cmd_build(&repo_root, &config, &args),
        "uninstall" => {
            println!("The Windows binary does not uninstall itself. Use the legacy PowerShell cleanup script if needed.");
            Ok(())
        }
        "help" | "--help" | "-h" => {
            print_usage();
            Ok(())
        }
        other => Err(format!("unknown command '{other}'")),
    }
}

fn is_help_flag(arg: &OsString) -> bool {
    matches!(arg.to_str(), Some("-h") | Some("--help") | Some("help"))
}

fn print_usage() {
    println!("Pandocker-X Windows binary");
    println!();
    println!("Usage:");
    println!("  pdx new <ReportName> [-Paper]");
    println!("  pdx build <ProjectName> [options]");
    println!("  pdx setup");
    println!();
    println!("Build options:");
    println!("  -All    Build every Markdown file under src/");
    println!("  -Log    Save pandoc output to log/");
}

fn cmd_new(repo_root: &Path, args: &[OsString]) -> Result<()> {
    let mut report_name: Option<String> = None;
    let mut paper = false;

    for arg in args {
        let text = arg.to_string_lossy();
        if text == "-Paper" {
            paper = true;
        } else if report_name.is_none() {
            report_name = Some(text.to_string());
        } else {
            return Err(format!("unexpected argument '{text}'"));
        }
    }

    let report_name = report_name.ok_or_else(|| "report name is required".to_string())?;
    let projects_base = repo_root.join("projects");
    let target_dir = projects_base.join(&report_name);
    let template_path = repo_root.join("templates").join("report.md");
    let defaults_path = if paper {
        repo_root.join("defaults-paper.yml")
    } else {
        repo_root.join("defaults.yml")
    };

    ensure_dir(&projects_base)?;
    if target_dir.exists() {
        return Err(format!("'projects/{report_name}' already exists."));
    }

    println!("Creating 'projects/{report_name}'...");
    for dir in ["src", "images", "bib", "output"] {
        ensure_dir(&target_dir.join(dir))?;
    }

    write_text(&target_dir.join("bib").join("references.bib"), "")?;

    let mut template = read_text(&template_path)?;
    template = template.replace("{{DATE}}", &Local::now().format("%Y-%m-%d").to_string());
    template = template.replace("{{CSL_PATH}}", "/app/csl/ieee-with-url.csl");
    write_text(&target_dir.join("src").join("report.md"), &template)?;

    if defaults_path.exists() {
        copy_file(&defaults_path, &target_dir.join("defaults.yml"))?;
    } else if paper {
        return Err(format!(
            "paper preset '{}' not found.",
            defaults_path.display()
        ));
    }

    println!();
    println!("Project 'projects/{report_name}' is ready.");
    println!("Edit projects/{report_name}/src/report.md to start writing.");
    if paper {
        println!("Paper preset enabled: defaults.yml was copied from defaults-paper.yml.");
    }

    Ok(())
}

fn cmd_setup(repo_root: &Path, config: &AppConfig) -> Result<()> {
    println!("=== Setup start ===");
    config.test_prerequisites()?;

    println!("[1/5] Preparing WSL environment...");
    println!(" Host root : {}", repo_root.display());
    println!(" WSL root  : {}", config.wsl_project_root_unix()?);
    println!(" Backend   : {}", config.docker_backend);
    println!(" SyncMode  : {}", config.sync_mode.as_str());

    println!("[2/5] Syncing the workspace to WSL...");
    config.sync_workspace(repo_root)?;

    println!("[3/5] Building the Docker image...");
    let wsl_project_root = config.wsl_project_root_unix()?;
    let command = format!(
        "cd {} && docker compose build",
        shell_quote_single(&wsl_project_root)
    );
    run_wsl_shell(&config.wsl_distro, &command)?;

    println!("[4/5] Preparing Docker volumes...");
    let command = format!(
        "cd {} && docker compose up -d --no-deps pandoc >/dev/null && docker compose stop pandoc >/dev/null",
        shell_quote_single(&wsl_project_root)
    );
    run_wsl_shell(&config.wsl_distro, &command)?;

    println!("[5/5] Generating TeX Live formats...");
    let command = format!(
        "cd {} && docker compose run --rm --entrypoint bash pandoc -lc 'fmtutil-sys --all'",
        shell_quote_single(&wsl_project_root)
    );
    run_wsl_shell(&config.wsl_distro, &command)?;

    println!("=== Setup complete ===");
    println!("You can now run pdx new / pdx build.");
    Ok(())
}

fn cmd_build(repo_root: &Path, config: &AppConfig, args: &[OsString]) -> Result<()> {
    config.test_prerequisites()?;

    let parsed = parse_build_args(args)?;
    let report_name = parsed.report_name.ok_or_else(|| {
        "report name is required\nUsage: pdx build <ProjectName> [options]".to_string()
    })?;

    let pandoc_args_path = repo_root.join("config").join("pandoc-args.json");
    let pandoc_args_text = read_text(&pandoc_args_path)?;
    let pandoc_args_json: Value = serde_json::from_str(&pandoc_args_text)
        .map_err(|err| format!("failed to parse pandoc-args.json: {err}"))?;
    let common_args = pandoc_args_json
        .get("pdf_args")
        .and_then(|value| value.as_array())
        .ok_or_else(|| "pandoc-args.json is missing pdf_args".to_string())?
        .iter()
        .map(|value| {
            value
                .as_str()
                .ok_or_else(|| "pandoc-args.json pdf_args entries must be strings".to_string())
                .map(|s| s.to_string())
        })
        .collect::<Result<Vec<_>>>()?;

    println!("[1/3] Syncing workspace to WSL...");
    config.sync_workspace(repo_root)?;

    let src_dir = repo_root.join("projects").join(&report_name).join("src");
    let mut input_files = if parsed.all {
        if src_dir.exists() {
            list_markdown_files(&src_dir)?
        } else {
            println!("Warning: {} not found", src_dir.display());
            Vec::new()
        }
    } else if parsed.input_files.is_empty() {
        vec![PathBuf::from("report.md")]
    } else {
        parsed.input_files.into_iter().map(PathBuf::from).collect()
    };

    if input_files.is_empty() {
        println!("No Markdown files to build.");
        return Ok(());
    }

    let timestamp = Local::now().format("%Y-%m-%dT%H-%M-%S").to_string();
    let log_file_name = if parsed.log {
        let name = format!("pandoc_{report_name}_{timestamp}.log");
        println!("Log output enabled: log/{name}");
        Some(name)
    } else {
        None
    };

    let wsl_project_root_unix = config.wsl_project_root_unix()?;
    let wsl_project_root_win = config.wsl_project_root_win(&wsl_project_root_unix)?;
    let wsl_src_dir = PathBuf::from(&wsl_project_root_win)
        .join("projects")
        .join(&report_name)
        .join("src");
    let host_log_dir = repo_root.join("log");

    if parsed.log {
        ensure_dir(&PathBuf::from(&wsl_project_root_win).join("log"))?;
    }

    for input_file in input_files.drain(..) {
        let host_input_path = src_dir.join(&input_file);
        if !host_input_path.exists() {
            println!("Warning: missing {}, skipping.", host_input_path.display());
            continue;
        }

        let relative_path = relative_path(&src_dir, &host_input_path)?;
        let relative_path_posix = relative_path.to_string_lossy().replace('\\', "/");
        let relative_output_path_posix = replace_extension(&relative_path_posix, "pdf");
        let relative_output_dir = relative_path
            .parent()
            .map(|path| path.to_string_lossy().to_string())
            .unwrap_or_default();
        let relative_output_dir_posix = relative_output_dir.replace('\\', "/");

        let input_path_on_wsl = wsl_src_dir.join(&relative_path);
        if !input_path_on_wsl.exists() {
            println!(
                "Warning: missing {}, skipping.",
                input_path_on_wsl.display()
            );
            continue;
        }

        let output_dir_wsl = if relative_output_dir.is_empty() {
            PathBuf::from(&wsl_project_root_win)
                .join("projects")
                .join(&report_name)
                .join("output")
        } else {
            PathBuf::from(&wsl_project_root_win)
                .join("projects")
                .join(&report_name)
                .join("output")
                .join(&relative_output_dir)
        };
        ensure_dir(&output_dir_wsl)?;

        let container_work_dir = format!("/data/projects/{report_name}/src");
        let defaults = "../defaults.yml";
        let output_file = format!("../output/{relative_output_path_posix}");
        let output_dir = if relative_output_dir_posix.is_empty() {
            "../output".to_string()
        } else {
            format!("../output/{relative_output_dir_posix}")
        };

        let mut pandoc_args = common_args.clone();
        pandoc_args.push("--defaults".to_string());
        pandoc_args.push(defaults.to_string());
        pandoc_args.push(relative_path_posix.clone());
        pandoc_args.push("-o".to_string());
        pandoc_args.push(output_file.clone());
        if parsed.log {
            pandoc_args.push("--verbose".to_string());
        }

        let pandoc_cmd = format!(
            "pandoc {}",
            pandoc_args
                .iter()
                .map(|arg| format!("\"{}\"", arg.replace('"', "\\\"")))
                .collect::<Vec<_>>()
                .join(" ")
        );
        let inner_command = format!(
            "cd {} && mkdir -p {} && {}",
            shell_quote_single(&container_work_dir),
            shell_quote_single(&output_dir),
            pandoc_cmd
        );

        let start = std::time::Instant::now();
        let exit_code = if let Some(log_name) = &log_file_name {
            let wsl_log_path = format!("log/{log_name}");
            let command = format!(
                "cd {} && mkdir -p log && docker compose run --rm --entrypoint bash pandoc -lc {} >> {} 2>&1",
                shell_quote_single(&wsl_project_root_unix),
                shell_quote_single(&inner_command),
                shell_quote_single(&wsl_log_path)
            );
            run_wsl_shell(&config.wsl_distro, &command)?
        } else {
            let command = format!(
                "cd {} && docker compose run --rm --entrypoint bash pandoc -lc {}",
                shell_quote_single(&wsl_project_root_unix),
                shell_quote_single(&inner_command)
            );
            run_wsl_shell(&config.wsl_distro, &command)?
        };
        let elapsed = start.elapsed().as_secs_f64();

        let pdf_file_name = Path::new(&relative_output_path_posix)
            .file_name()
            .map(|name| name.to_string_lossy().to_string())
            .unwrap_or_else(|| "output.pdf".to_string());
        let wsl_pdf_path = PathBuf::from(&wsl_project_root_win)
            .join("projects")
            .join(&report_name)
            .join("output")
            .join(&relative_output_path_posix);
        let host_output_dir = repo_root
            .join("projects")
            .join(&report_name)
            .join("output")
            .join(&relative_output_dir);
        ensure_dir(&host_output_dir)?;

        if wsl_pdf_path.exists() {
            copy_file(&wsl_pdf_path, &host_output_dir.join(&pdf_file_name))?;
        }

        if host_output_dir.join(&pdf_file_name).exists() && exit_code == 0 {
            println!(
                "{relative_path_posix} -> {relative_output_path_posix} generated in {:.2}s",
                elapsed
            );
        } else {
            println!("{relative_path_posix} PDF generation failed.");
            if let Some(log_name) = &log_file_name {
                println!("See {}\\{log_name} for details.", host_log_dir.display());
            }
        }
    }

    if let Some(log_name) = log_file_name {
        ensure_dir(&host_log_dir)?;
        let wsl_log_dir = PathBuf::from(&wsl_project_root_win).join("log");
        let source = wsl_log_dir.join(&log_name);
        let destination = host_log_dir.join(&log_name);
        if source.exists() {
            copy_file(&source, &destination)?;
            println!("Log saved to: log\\{log_name}");
        }
    }

    Ok(())
}

struct BuildArgs {
    report_name: Option<String>,
    input_files: Vec<String>,
    all: bool,
    log: bool,
}

fn parse_build_args(args: &[OsString]) -> Result<BuildArgs> {
    let mut parsed = BuildArgs {
        report_name: None,
        input_files: Vec::new(),
        all: false,
        log: false,
    };

    for arg in args {
        let text = arg.to_string_lossy();
        match text.as_ref() {
            "-All" => parsed.all = true,
            "-Log" => parsed.log = true,
            value if value.starts_with('-') => return Err(format!("unknown option {value}")),
            value => {
                if parsed.report_name.is_none() {
                    parsed.report_name = Some(value.to_string());
                } else {
                    parsed.input_files.push(value.to_string());
                }
            }
        }
    }

    Ok(parsed)
}
