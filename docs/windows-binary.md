# Windows Binary Guide

This repository is moving the Windows entrypoint from PowerShell scripts to Rust binaries.

## Current layout

- `tools/pdx-win/` contains the Windows command binary, `pdx.exe`.
- `tools/pdx-installer/` contains the installer binary, `pdx-bootstrap.exe`.
- `install.ps1` is now only a bootstrapper that launches the installer binary.

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

Run `install.ps1` from the repository root on Windows.

The bootstrapper prefers a release bundle layout where these files sit next to each other:

- `install.ps1`
- `pdx-bootstrap.exe`
- `pdx.exe`

If those files are not present, `install.ps1` falls back to the binaries under `tools/` or to `cargo run` for local development.

The installer writes the command binary to:

- `%LOCALAPPDATA%\Pandocker-X\bin\pdx.exe`

It also creates a PowerShell wrapper profile next to the profile file it updates so `pdx` is available after restart.

## Release layout

For GitHub releases, ship these artifacts together:

- `pdx.exe`
- `pdx-bootstrap.exe`
- `install.ps1`

That keeps Windows installation self-contained while still allowing local source builds.

## Notes

- The legacy `scripts/*.ps1` and `scripts/*.sh` files still exist under `legacy/`, but Windows users should treat the binary path as the supported entrypoint.
- The Windows binary currently targets Windows only. Linux and macOS will stay on the shell-script path until a second binary is added.
