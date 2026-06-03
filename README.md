# Pandocker-X: Markdown to PDF

[![GitHub release](https://img.shields.io/github/v/release/Xpotato1024/Pandocker-X?include_prereleases)](https://github.com/Xpotato1024/Pandocker-X/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Pandocker-X is a Docker-based Markdown-to-PDF workflow for Windows, Linux, and macOS.

## Install

### Windows

Run `install.ps1` from the repository root.

```powershell
. .\install.ps1
```

That bootstrapper launches the Rust installer and registers the PowerShell wrapper that exposes `pdx`.

- `tools/pdx-win/` provides `pdx.exe`
- `tools/pdx-installer/` provides `pdx-bootstrap.exe`

For GitHub release bundles, place these files side by side:

- `install.ps1`
- `pdx.exe`
- `pdx-bootstrap.exe`

See [docs/windows-binary.md](docs/windows-binary.md) for the current Windows binary guide.

### Linux / macOS

Use the legacy shell installer under `legacy/` if you need the old flow.

```bash
source ./legacy/install.sh
```

## Usage

Set up the environment:

```powershell
pdx setup
```

Create a project:

```powershell
pdx new "report-name"
```

Build a PDF:

```powershell
pdx build "report-name"
```

Build all Markdown files in a project:

```powershell
pdx build "report-name" -All
```

Write pandoc logs:

```powershell
pdx build "report-name" -All -Log
```

## Windows Guide

The Windows packaging flow, build steps, and release layout are documented in [docs/windows-binary.md](docs/windows-binary.md).

## Notes

- `legacy/` contains the previous shell and PowerShell entrypoints.
- `defaults-paper.yml` is the paper preset copied by `pdx new -Paper`.
- `projects/sample-paper/` is the bundled example project.
- Build timings can be recorded in [docs/build-metrics.md](docs/build-metrics.md).

## Project Layout

- `config/`: runtime configuration and Windows helpers
- `templates/`: pandoc templates
- `preamble/`: LaTeX preamble files
- `csl/`: citation style files
- `tools/`: Rust binaries for Windows
- `legacy/`: archived script entrypoints
- `projects/<name>/src/`: project sources
- `projects/<name>/output/`: generated PDFs
