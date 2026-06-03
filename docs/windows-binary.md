# Windows Binary Guide

This document describes the Windows release path and how it differs from the Unix source-release path.

## Layout

- `tools/pdx-win/` builds the Windows command binary, `pdx.exe`.
- `tools/pdx-installer/` builds `pdx-bootstrap.exe` and `pdx-installer-gui.exe`.
- `install.ps1` is the source-tree bootstrap helper.
- `release/package-windows-release.ps1` creates the Windows zip release.

## Build

From the repository root:

```powershell
cargo build --release --manifest-path tools/pdx-win/Cargo.toml
cargo build --release --manifest-path tools/pdx-installer/Cargo.toml
```

The release binaries are written to:

```text
tools/pdx-win/target/release/pdx.exe
tools/pdx-installer/target/release/pdx-bootstrap.exe
tools/pdx-installer/target/release/pdx-installer-gui.exe
```

If the machine does not have the Windows linker toolchain installed, build from a Developer PowerShell session or with the Visual Studio C++ build tools.

## Commands

The command binary keeps the same top-level commands as the historical scripts:

- `pdx setup`
- `pdx new <ProjectName> [-Paper]`
- `pdx build <ProjectName> [options]`

Build flags:

- `-All` builds every Markdown file under `projects/<name>/content/` when present, or `projects/<name>/src/` for older projects
- `-Log` writes pandoc output to `log/`

## Install

The Windows release zip contains:

- `pdx.exe`
- `pdx-bootstrap.exe`
- `pdx-installer-gui.exe`
- `defaults.yml`
- `defaults-paper.yml`
- `Dockerfile`
- `docker-compose.yml`
- `config/`
- `csl/`
- `preamble/`
- `templates/`
- `projects/sample-paper/`
- `INSTALL.txt`
- `LICENSE`
- `README.md`

After extracting the zip, run the bootstrapper:

```powershell
.\pdx-bootstrap.exe install
```

The installer writes the command binary to:

- `%LOCALAPPDATA%\Pandocker-X\bin\pdx.exe`

It also copies the bundled runtime files into the same install directory and creates a PowerShell wrapper profile so `pdx` is available after restart.

## Unix contrast

Linux and macOS users should use the source release archive and the Unix `./pdx` entrypoint in the repository root.

That keeps the release split simple:

- Windows gets compiled binaries.
- Unix gets a source archive with a supported Docker-based shell entrypoint.

## Notes

- The historical scripts under `legacy/` remain available for reference and fallback.
- The Windows binary is Windows-only by design; Unix support is handled by the shell entrypoint instead of a second compiled binary.
