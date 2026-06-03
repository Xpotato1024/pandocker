# Windows Binary Guide

This repository is moving the Windows entrypoint from PowerShell scripts to Rust binaries.

## Current layout

- `tools/pdx-win/` contains the Windows command binary, `pdx.exe`.
- `tools/pdx-installer/` contains the installer binaries, `pdx-bootstrap.exe` and `pdx-installer-gui.exe`.
- `install.ps1` is a source-tree convenience script only. It is not required for GitHub releases.

## Build

From the repository root:

```powershell
cargo build --release --manifest-path tools/pdx-win/Cargo.toml
cargo build --release --manifest-path tools/pdx-installer/Cargo.toml
```

The release binaries will be written to:

```text
tools/pdx-win/target/release/pdx.exe
tools/pdx-installer/target/release/pdx-bootstrap.exe
tools/pdx-installer/target/release/pdx-installer-gui.exe
```

If the machine does not have the Windows linker toolchain installed, build with the Visual Studio C++ build tools or from a Developer PowerShell session.

## Commands

The command binary keeps the same top-level commands:

- `pdx setup`
- `pdx new <ReportName> [-Paper]`
- `pdx build <ProjectName> [options]`

Build flags:

- `-All` builds every Markdown file under `projects/<name>/src/`
- `-Log` writes pandoc output to `log/`

## Install

For GitHub releases, distribute a zip archive that contains at least these files:

- `pdx-bootstrap.exe`
- `pdx-installer-gui.exe`
- `pdx.exe`

After extracting the zip, run the installer directly from PowerShell, Command Prompt, or Explorer:

```powershell
.\pdx-bootstrap.exe install
```

The installer is a normal CLI executable.
The GUI installer is bundled in the same zip and can be launched directly without any PowerShell wrapper.
When you run `pdx setup`, it will try to start `dockerd` if it is stopped and will ask before installing missing `docker` / `docker compose` packages inside WSL.

For local source checkouts, `install.ps1` can still bootstrap the same installer and command binary from the repository tree.

The installer writes the command binary to:

- `%LOCALAPPDATA%\Pandocker-X\bin\pdx.exe`

It also creates a PowerShell wrapper profile next to the profile file it updates so `pdx` is available after restart.

## Release layout

For GitHub releases, ship these artifacts together inside a zip:

- `pdx.exe`
- `pdx-bootstrap.exe`
- `pdx-installer-gui.exe`

That keeps Windows installation self-contained while avoiding an unnecessary PowerShell-only entrypoint.

The zip packaging script lives at [release/package-windows-release.ps1](/C:/Users/miyut/Desktop/pandocker-dev/release/package-windows-release.ps1).

## Notes

- The legacy `scripts/*.ps1` and `scripts/*.sh` files still exist under `legacy/`, but Windows users should treat the binary path as the supported entrypoint.
- The Windows binary currently targets Windows only. Linux and macOS will stay on the shell-script path until a second binary is added.
