# Release Verification

This document explains how to verify release downloads and how to update the pinned values used by the Docker image.

## Release assets

Each GitHub release publishes:

- `pandocker-x-windows-<version>.zip`
- `pandocker-x-source-<version>.zip`
- `pandocker-x-checksums-<version>.sha256`

## Verifying downloads

### Unix-like systems

```bash
sha256sum -c pandocker-x-checksums-<version>.sha256
```

### Windows PowerShell

```powershell
Get-FileHash -Algorithm SHA256 .\pandocker-x-windows-<version>.zip
Get-FileHash -Algorithm SHA256 .\pandocker-x-source-<version>.zip
```

Compare the reported hashes with the values in the checksum file attached to the release.

## Updating pinned Docker values

When the Docker image needs a new Debian base image or newer Pandoc artifacts, update the pinned values in `Dockerfile` with the following process:

1. Inspect the current Debian bookworm-slim digest with `docker buildx imagetools inspect debian:bookworm-slim`.
2. Download the official release assets for the desired Pandoc and pandoc-crossref versions from their GitHub releases.
3. Compute SHA-256 hashes for the downloaded files.
4. Update the `FROM` digest and the `ARG` checksum values in `Dockerfile`.
5. Rebuild the image and confirm `pandoc --version`, `pandoc-crossref --version`, and `lualatex --version` still succeed.
6. Update this document if the supported versions or update procedure changes.

For the current pin set, see `Dockerfile`.
