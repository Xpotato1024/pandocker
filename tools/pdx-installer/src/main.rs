use std::env;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::ExitCode;

type Result<T> = std::result::Result<T, String>;

const APP_NAME: &str = "Pandocker-X";
const BINARY_FILE_NAME: &str = "pdx.exe";
const WRAPPER_FILE_NAME: &str = "Pandocker_profile.ps1";
const PROFILE_IMPORT_COMMENT: &str = "# Load Pandocker profile";

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
    let args = parse_args()?;
    match args.command.as_deref() {
        Some("install") | None => install(&args),
        Some("uninstall") => uninstall(&args),
        Some("status") => status(&args),
        Some(other) => Err(format!("unknown command '{other}'")),
    }
}

#[derive(Debug)]
struct Args {
    command: Option<String>,
    source: Option<PathBuf>,
    install_dir: PathBuf,
    profile_file: PathBuf,
}

fn parse_args() -> Result<Args> {
    let mut command = None;
    let mut source = None;
    let mut install_dir = default_install_dir()?;
    let mut profile_file = default_profile_file()?;

    let mut iter = env::args().skip(1).peekable();
    while let Some(arg) = iter.next() {
        match arg.as_str() {
            "-h" | "--help" => {
                print_help();
                use std::io::Write;
                let _ = std::io::stdout().flush();
                std::process::exit(0);
            }
            "install" | "uninstall" | "status" if command.is_none() => {
                command = Some(arg);
            }
            "--source" => {
                let value = iter
                    .next()
                    .ok_or_else(|| "--source expects a path".to_string())?;
                source = Some(PathBuf::from(value));
            }
            "--install-dir" => {
                let value = iter
                    .next()
                    .ok_or_else(|| "--install-dir expects a path".to_string())?;
                install_dir = PathBuf::from(value);
            }
            "--profile-file" => {
                let value = iter
                    .next()
                    .ok_or_else(|| "--profile-file expects a path".to_string())?;
                profile_file = PathBuf::from(value);
            }
            other if other.starts_with('-') => {
                return Err(format!("unknown option '{other}'"));
            }
            other if command.is_none() => {
                command = Some(other.to_string());
            }
            other => {
                return Err(format!("unexpected positional argument '{other}'"));
            }
        }
    }

    Ok(Args {
        command,
        source,
        install_dir,
        profile_file,
    })
}

fn print_help() {
    println!("Pandocker-X installer");
    println!();
    println!("Usage:");
    println!(
        "  pdx-bootstrap install [--source <pdx.exe>] [--install-dir <dir>] [--profile-file <host-profile>]"
    );
    println!("  pdx-bootstrap uninstall [--install-dir <dir>] [--profile-file <host-profile>]");
    println!("  pdx-bootstrap status");
    println!();
    println!("Defaults:");
    println!("  install dir   : %LOCALAPPDATA%\\Pandocker-X\\bin");
    println!("  profile file  : %USERPROFILE%\\Documents\\PowerShell\\Microsoft.PowerShell_profile.ps1");
    println!("  source binary : sibling pdx.exe next to pdx-bootstrap.exe");
}

fn install(args: &Args) -> Result<()> {
    let source = resolve_source_binary(args)?;
    if !source.exists() {
        return Err(format!("source binary not found: {}", source.display()));
    }

    fs::create_dir_all(&args.install_dir)
        .map_err(|err| format!("failed to create {}: {err}", args.install_dir.display()))?;

    let installed_binary = args.install_dir.join(BINARY_FILE_NAME);
    fs::copy(&source, &installed_binary).map_err(|err| {
        format!(
            "failed to copy {} to {}: {err}",
            source.display(),
            installed_binary.display()
        )
    })?;

    let wrapper_file = wrapper_file_path(&args.profile_file);
    write_text(&wrapper_file, &render_wrapper(&installed_binary))?;
    ensure_profile_import(&args.profile_file, &wrapper_file)?;

    println!("Installed {} to {}", BINARY_FILE_NAME, installed_binary.display());
    println!("Updated wrapper file: {}", wrapper_file.display());
    println!("Updated host profile : {}", args.profile_file.display());
    Ok(())
}

fn uninstall(args: &Args) -> Result<()> {
    let installed_binary = args.install_dir.join(BINARY_FILE_NAME);
    if installed_binary.exists() {
        fs::remove_file(&installed_binary)
            .map_err(|err| format!("failed to remove {}: {err}", installed_binary.display()))?;
    }

    let wrapper_file = wrapper_file_path(&args.profile_file);
    if wrapper_file.exists() {
        fs::remove_file(&wrapper_file)
            .map_err(|err| format!("failed to remove {}: {err}", wrapper_file.display()))?;
    }

    if args.profile_file.exists() {
        let content = fs::read_to_string(&args.profile_file)
            .map_err(|err| format!("failed to read {}: {err}", args.profile_file.display()))?;
        let updated = remove_profile_import(&content, &wrapper_file);
        if updated != content {
            write_text(&args.profile_file, &updated)?;
        }
    }

    println!("Removed {} from {}", BINARY_FILE_NAME, args.install_dir.display());
    println!("Removed wrapper file: {}", wrapper_file.display());
    Ok(())
}

fn status(args: &Args) -> Result<()> {
    let installed_binary = args.install_dir.join(BINARY_FILE_NAME);
    let wrapper_file = wrapper_file_path(&args.profile_file);

    println!("Installer status:");
    println!("  install dir   : {}", args.install_dir.display());
    println!("  binary        : {}", installed_binary.display());
    println!("  wrapper file  : {}", wrapper_file.display());
    println!("  host profile   : {}", args.profile_file.display());
    println!("  binary exists  : {}", installed_binary.exists());
    println!("  wrapper exists : {}", wrapper_file.exists());
    println!("  profile exists : {}", args.profile_file.exists());
    Ok(())
}

fn resolve_source_binary(args: &Args) -> Result<PathBuf> {
    if let Some(source) = &args.source {
        return Ok(source.clone());
    }

    let exe = env::current_exe()
        .map_err(|err| format!("failed to locate current executable: {err}"))?;
    let sibling = exe
        .parent()
        .ok_or_else(|| "current executable has no parent directory".to_string())?
        .join(BINARY_FILE_NAME);
    Ok(sibling)
}

fn default_install_dir() -> Result<PathBuf> {
    let local_app_data = env::var_os("LOCALAPPDATA")
        .ok_or_else(|| "%LOCALAPPDATA% is not set".to_string())?;
    Ok(PathBuf::from(local_app_data).join(APP_NAME).join("bin"))
}

fn default_profile_file() -> Result<PathBuf> {
    let user_profile = env::var_os("USERPROFILE")
        .ok_or_else(|| "%USERPROFILE% is not set".to_string())?;
    Ok(PathBuf::from(user_profile)
        .join("Documents")
        .join("PowerShell")
        .join("Microsoft.PowerShell_profile.ps1"))
}

fn wrapper_file_path(profile_file: &Path) -> PathBuf {
    profile_file
        .parent()
        .map(|dir| dir.join(WRAPPER_FILE_NAME))
        .unwrap_or_else(|| PathBuf::from(WRAPPER_FILE_NAME))
}

fn render_wrapper(installed_binary: &Path) -> String {
    let binary = powershell_double_quote(&installed_binary.to_string_lossy());
    format!(
        r#"# --- Pandocker PowerShell wrapper ---
function Invoke-PdxBinary {{
    param(
        [Parameter(Mandatory = $true, Position = 0)] $Subcommand,
        [Parameter(ValueFromRemainingArguments = $true)] $Args
    )

    & "{binary}" $Subcommand @Args
    return $LASTEXITCODE
}}

function pdx {{
    param(
        [Parameter(Position = 0)] $Command,
        [Parameter(ValueFromRemainingArguments = $true)] $Args
    )

    if ([string]::IsNullOrWhiteSpace($Command)) {{
        & Invoke-PdxBinary --help
        return
    }}

    switch ($Command) {{
        'new'    {{ Invoke-PdxBinary new @Args }}
        'build'  {{ Invoke-PdxBinary build @Args }}
        'setup'  {{ Invoke-PdxBinary setup @Args }}
        'help'   {{ Invoke-PdxBinary --help @Args }}
        default  {{ Invoke-PdxBinary $Command @Args }}
    }}
}}

function pdx-new {{
    param([Parameter(ValueFromRemainingArguments = $true)] $Args)
    Invoke-PdxBinary new @Args
}}

function pdx-setup {{
    param([Parameter(ValueFromRemainingArguments = $true)] $Args)
    Invoke-PdxBinary setup @Args
}}

function pdx-build {{
    param([Parameter(ValueFromRemainingArguments = $true)] $Args)
    Invoke-PdxBinary build @Args
}}
"#
    )
}

fn ensure_profile_import(profile_file: &Path, wrapper_file: &Path) -> Result<()> {
    if let Some(parent) = profile_file.parent() {
        fs::create_dir_all(parent)
            .map_err(|err| format!("failed to create {}: {err}", parent.display()))?;
    }

    let mut content = if profile_file.exists() {
        fs::read_to_string(profile_file)
            .map_err(|err| format!("failed to read {}: {err}", profile_file.display()))?
    } else {
        String::new()
    };

    let import_line = profile_import_line(wrapper_file);
    if content.contains(&import_line) {
        return Ok(());
    }

    if !content.is_empty() && !content.ends_with('\n') {
        content.push('\n');
    }
    if !content.is_empty() {
        content.push('\n');
    }
    content.push_str(PROFILE_IMPORT_COMMENT);
    content.push('\n');
    content.push_str(&import_line);
    content.push('\n');
    write_text(profile_file, &content)
}

fn remove_profile_import(content: &str, wrapper_file: &Path) -> String {
    let import_line = profile_import_line(wrapper_file);
    let mut lines: Vec<&str> = content.lines().collect();

    let mut index = 0;
    while index < lines.len() {
        if lines[index].trim() == PROFILE_IMPORT_COMMENT || lines[index].trim() == import_line {
            lines.remove(index);
            continue;
        }
        index += 1;
    }

    let mut cleaned = lines.join("\n");
    if content.ends_with('\n') && !cleaned.ends_with('\n') && !cleaned.is_empty() {
        cleaned.push('\n');
    }
    cleaned
}

fn profile_import_line(wrapper_file: &Path) -> String {
    format!(". \"{}\"", powershell_double_quote(&wrapper_file.to_string_lossy()))
}

fn powershell_double_quote(value: &str) -> String {
    value.replace('`', "``").replace('"', "`\"")
}

fn write_text(path: &Path, text: &str) -> Result<()> {
    if let Some(parent) = path.parent() {
        fs::create_dir_all(parent)
            .map_err(|err| format!("failed to create {}: {err}", parent.display()))?;
    }
    fs::write(path, text).map_err(|err| format!("failed to write {}: {err}", path.display()))
}
