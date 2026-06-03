# Build Metrics

This document is a lightweight template for recording build and release observations.

## What to record

- Date and time
- OS and backend
- Whether `pdx setup` completed successfully
- Whether `pdx build` completed successfully
- Build duration
- PDF size
- Any errors or warnings

## Example commands

### Windows / PowerShell

```powershell
git status --short
docker version
docker compose version
pdx setup
pdx new sample-report
pdx build sample-report
pdx build sample-report -Log
```

### Linux / Unix shell

```bash
docker version
docker compose version
docker info
./pdx setup
./pdx new sample-report
./pdx build sample-report
./pdx build sample-report -Log
```

## Tracking table

| Date | OS | Backend | `pdx setup` | `pdx build` | PDF size | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| 2026-06-02 16:00 | Windows 11 | WSL dockerd | - | - | - | initial template |

## Notes

- Record a sample project before and after changes so regressions are visible.
- Use `-Log` when you need a failure trace.
- Add a new row for each meaningful validation run.

