use std::env;
use std::fs;
use std::path::{Path, PathBuf};

pub type Result<T> = std::result::Result<T, String>;

const APP_NAME: &str = "Pandocker-X";
const BINARY_FILE_NAME: &str = "pdx.exe";
const WRAPPER_FILE_NAME: &str = "Pandocker_profile.ps1";
const PROFILE_IMPORT_COMMENT: &str = "# Load Pandocker profile";

#[derive(Clone, Debug, PartialEq, Eq)]
pub enum Command {
    Install,
    Uninstall,
    Status,
}

#[derive(Clone, Debug)]
pub struct InstallerOptions {
    pub command: Command,
    pub source: Option<PathBuf>,
    pub bundle_root: Option<PathBuf>,
    pub install_dir: PathBuf,
    pub profile_file: PathBuf,
}

#[derive(Clone, Debug)]
pub struct Report {
    pub lines: Vec<String>,
}

impl Report {
    pub fn new(lines: Vec<String>) -> Self {
        Self { lines }
    }
}

pub fn parse_args<I>(args: I) -> Result<InstallerOptions>
where
    I: IntoIterator<Item = String>,
{
    let mut command = None;
    let mut source = None;
    let mut bundle_root = None;
    let mut install_dir = default_install_dir()?;
    let mut profile_file = default_profile_file()?;

    let mut iter = args.into_iter().peekable();
    while let Some(arg) = iter.next() {
        match arg.as_str() {
            "-h" | "--help" => {
                print_help();
                std::process::exit(0);
            }
            "install" if command.is_none() => command = Some(Command::Install),
            "uninstall" if command.is_none() => command = Some(Command::Uninstall),
            "status" if command.is_none() => command = Some(Command::Status),
            "--source" => {
                let value = iter
                    .next()
                    .ok_or_else(|| "--source expects a path".to_string())?;
                source = Some(PathBuf::from(value));
            }
            "--bundle-root" => {
                let value = iter
                    .next()
                    .ok_or_else(|| "--bundle-root expects a path".to_string())?;
                bundle_root = Some(PathBuf::from(value));
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
                command = Some(match other {
                    "install" => Command::Install,
                    "uninstall" => Command::Uninstall,
                    "status" => Command::Status,
                    _ => return Err(format!("unknown command '{other}'")),
                });
            }
            other => return Err(format!("unexpected positional argument '{other}'")),
        }
    }

    Ok(InstallerOptions {
        command: command.unwrap_or(Command::Install),
        source,
        bundle_root,
        install_dir,
        profile_file,
    })
}

pub fn run(options: &InstallerOptions) -> Result<Report> {
    match options.command {
        Command::Install => install(options),
        Command::Uninstall => uninstall(options),
        Command::Status => status(options),
    }
}

pub fn print_help() {
    println!("Pandocker-X installer");
    println!();
    println!("Usage:");
    println!(
        "  pdx-bootstrap install [--source <pdx.exe>] [--bundle-root <dir>] [--install-dir <dir>] [--profile-file <host-profile>]"
    );
    println!("  pdx-bootstrap uninstall [--install-dir <dir>] [--profile-file <host-profile>]");
    println!("  pdx-bootstrap status");
    println!();
    println!("Defaults:");
    println!("  install dir   : %LOCALAPPDATA%\\Pandocker-X\\bin");
    println!(
        "  profile file  : %USERPROFILE%\\Documents\\PowerShell\\Microsoft.PowerShell_profile.ps1"
    );
    println!("  source binary : sibling pdx.exe next to pdx-bootstrap.exe");
}

pub fn default_install_dir() -> Result<PathBuf> {
    let local_app_data =
        env::var_os("LOCALAPPDATA").ok_or_else(|| "%LOCALAPPDATA% is not set".to_string())?;
    Ok(PathBuf::from(local_app_data).join(APP_NAME).join("bin"))
}

pub fn default_profile_file() -> Result<PathBuf> {
    let user_profile =
        env::var_os("USERPROFILE").ok_or_else(|| "%USERPROFILE% is not set".to_string())?;
    Ok(PathBuf::from(user_profile)
        .join("Documents")
        .join("PowerShell")
        .join("Microsoft.PowerShell_profile.ps1"))
}

fn install(options: &InstallerOptions) -> Result<Report> {
    let source = resolve_source_binary(options)?;
    if !source.exists() {
        return Err(format!("source binary not found: {}", source.display()));
    }

    fs::create_dir_all(&options.install_dir)
        .map_err(|err| format!("failed to create {}: {err}", options.install_dir.display()))?;

    let installed_binary = options.install_dir.join(BINARY_FILE_NAME);
    fs::copy(&source, &installed_binary).map_err(|err| {
        format!(
            "failed to copy {} to {}: {err}",
            source.display(),
            installed_binary.display()
        )
    })?;

    let bundle_root = resolve_bundle_root(options)?;
    copy_bundle_resources(&bundle_root, &options.install_dir)?;

    let wrapper_file = wrapper_file_path(&options.profile_file);
    write_text(&wrapper_file, &render_wrapper(&installed_binary))?;
    ensure_profile_import(&options.profile_file, &wrapper_file)?;

    Ok(Report::new(vec![
        format!(
            "Installed {} to {}",
            BINARY_FILE_NAME,
            installed_binary.display()
        ),
        format!("Updated wrapper file: {}", wrapper_file.display()),
        format!("Updated host profile : {}", options.profile_file.display()),
    ]))
}

fn uninstall(options: &InstallerOptions) -> Result<Report> {
    let installed_binary = options.install_dir.join(BINARY_FILE_NAME);
    if installed_binary.exists() {
        fs::remove_file(&installed_binary)
            .map_err(|err| format!("failed to remove {}: {err}", installed_binary.display()))?;
    }

    let wrapper_file = wrapper_file_path(&options.profile_file);
    if wrapper_file.exists() {
        fs::remove_file(&wrapper_file)
            .map_err(|err| format!("failed to remove {}: {err}", wrapper_file.display()))?;
    }

    if options.profile_file.exists() {
        let content = fs::read_to_string(&options.profile_file)
            .map_err(|err| format!("failed to read {}: {err}", options.profile_file.display()))?;
        let updated = remove_profile_import(&content, &wrapper_file);
        if updated != content {
            write_text(&options.profile_file, &updated)?;
        }
    }

    Ok(Report::new(vec![
        format!(
            "Removed {} from {}",
            BINARY_FILE_NAME,
            options.install_dir.display()
        ),
        format!("Removed wrapper file: {}", wrapper_file.display()),
    ]))
}

fn status(options: &InstallerOptions) -> Result<Report> {
    let installed_binary = options.install_dir.join(BINARY_FILE_NAME);
    let wrapper_file = wrapper_file_path(&options.profile_file);

    Ok(Report::new(vec![
        "Installer status:".to_string(),
        format!("  install dir   : {}", options.install_dir.display()),
        format!("  binary        : {}", installed_binary.display()),
        format!("  wrapper file  : {}", wrapper_file.display()),
        format!("  host profile   : {}", options.profile_file.display()),
        format!("  binary exists  : {}", installed_binary.exists()),
        format!("  wrapper exists : {}", wrapper_file.exists()),
        format!("  profile exists : {}", options.profile_file.exists()),
    ]))
}

fn resolve_source_binary(options: &InstallerOptions) -> Result<PathBuf> {
    if let Some(source) = &options.source {
        return Ok(source.clone());
    }

    let exe =
        env::current_exe().map_err(|err| format!("failed to locate current executable: {err}"))?;
    let sibling = exe
        .parent()
        .ok_or_else(|| "current executable has no parent directory".to_string())?
        .join(BINARY_FILE_NAME);
    Ok(sibling)
}

fn resolve_bundle_root(options: &InstallerOptions) -> Result<PathBuf> {
    if let Some(bundle_root) = &options.bundle_root {
        return Ok(bundle_root.clone());
    }

    let exe =
        env::current_exe().map_err(|err| format!("failed to locate current executable: {err}"))?;
    let root = exe
        .parent()
        .ok_or_else(|| "current executable has no parent directory".to_string())?;
    Ok(root.to_path_buf())
}

fn copy_bundle_resources(bundle_root: &Path, install_dir: &Path) -> Result<()> {
    for entry in [
        "defaults.yml",
        "defaults-paper.yml",
        "Dockerfile",
        "docker-compose.yml",
        "README.md",
        "LICENSE",
    ] {
        let source = bundle_root.join(entry);
        if source.exists() {
            copy_path(&source, &install_dir.join(entry))?;
        }
    }

    for directory in ["config", "csl", "preamble", "templates"] {
        let source = bundle_root.join(directory);
        if source.exists() {
            copy_tree(&source, &install_dir.join(directory))?;
        }
    }

    let projects_source = bundle_root.join("projects");
    if projects_source.exists() {
        copy_tree(&projects_source, &install_dir.join("projects"))?;
    } else {
        fs::create_dir_all(install_dir.join("projects")).map_err(|err| {
            format!(
                "failed to create {}: {err}",
                install_dir.join("projects").display()
            )
        })?;
    }

    Ok(())
}

fn copy_tree(source: &Path, destination: &Path) -> Result<()> {
    if source.is_dir() {
        fs::create_dir_all(destination)
            .map_err(|err| format!("failed to create {}: {err}", destination.display()))?;
        for entry in fs::read_dir(source)
            .map_err(|err| format!("failed to read {}: {err}", source.display()))?
        {
            let entry =
                entry.map_err(|err| format!("failed to read {}: {err}", source.display()))?;
            let path = entry.path();
            let target = destination.join(entry.file_name());
            if path.is_dir() {
                copy_tree(&path, &target)?;
            } else {
                copy_path(&path, &target)?;
            }
        }
        Ok(())
    } else {
        copy_path(source, destination)
    }
}

fn copy_path(source: &Path, destination: &Path) -> Result<()> {
    if let Some(parent) = destination.parent() {
        fs::create_dir_all(parent)
            .map_err(|err| format!("failed to create {}: {err}", parent.display()))?;
    }
    fs::copy(source, destination).map_err(|err| {
        format!(
            "failed to copy {} to {}: {err}",
            source.display(),
            destination.display()
        )
    })?;
    Ok(())
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
    format!(
        ". \"{}\"",
        powershell_double_quote(&wrapper_file.to_string_lossy())
    )
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
