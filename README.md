# Pandocker-X

Pandocker-X is a Docker-based workflow for turning Markdown into PDF with Pandoc, LaTeX, CSL styles, and reusable project templates.

This repository is the source of truth for:

- project scaffolding
- Docker image and build settings
- Windows distribution binaries
- Unix source-release entrypoints

## Supported entry points

### Windows

Windows users install the Rust-based binary distribution and run the workflow through WSL.

- Release asset: `pandocker-x-windows-<version>.zip`
- Entry script for local source checkouts: `install.ps1`
- Runtime: WSL 2 plus Docker Desktop or WSL Docker

Typical install command:

```powershell
.\pdx-bootstrap.exe install
```

### Linux / macOS

Linux and macOS users should use the source release or a local checkout and run the Unix `pdx` shell entrypoint.

- Release asset: `pandocker-x-source-<version>.zip`
- Entry script: `./pdx`
- Runtime: Docker, Docker Compose, and `jq`

Typical first-run commands:

```bash
./pdx setup
./pdx new sample-report
./pdx build sample-report
```

## Quick start

### Windows source checkout

```powershell
.\install.ps1
pdx setup
pdx new sample-report
pdx build sample-report
```

### Unix source checkout or source release

```bash
./pdx setup
./pdx new sample-report
./pdx build sample-report
```

## Repository layout

- `config/` - runtime configuration and WSL helpers
- `templates/` - templates used by `pdx new`
- `preamble/` - LaTeX preamble fragments
- `csl/` - citation styles
- `tools/` - Rust binaries for Windows installation and setup
- `projects/<name>/content/` - project Markdown source
- `projects/<name>/output/` - generated PDFs
- `docs/` - release, support, and roadmap documentation

## Release flow

The intended public release flow is:

1. Open or update an issue.
2. Create a `codex/` branch.
3. Commit the change.
4. Push the branch.
5. Open a PR.
6. Merge the PR.
7. Push a release tag such as `v1.2.3`.

The detailed workflow lives in [CONTRIBUTING.md](CONTRIBUTING.md).

## Documentation

- [CONTRIBUTING.md](CONTRIBUTING.md)
- [docs/windows-binary.md](docs/windows-binary.md)
- [docs/roadmap.md](docs/roadmap.md)
- [docs/build-metrics.md](docs/build-metrics.md)

## Notes

- `legacy/` contains the historical shell and PowerShell scripts. They are kept for reference and fallback, not as the primary supported path.
- GitHub release assets now include both the Windows binaries and a source archive for Unix users.

