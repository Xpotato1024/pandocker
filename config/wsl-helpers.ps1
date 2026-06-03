# WSL / Docker helper functions

function Test-WslPrerequisites {
    param (
        [Parameter(Mandatory = $true)]
        [string]$WslDistro
    )

    if (-not (Get-Command wsl.exe -ErrorAction SilentlyContinue)) {
        Write-Host "Error: wsl.exe not found." -ForegroundColor Red
        Write-Host "WSL 2 is required." -ForegroundColor Red
        exit 1
    }

    $distros = wsl.exe -l --quiet
    if (-not ($distros -contains $WslDistro)) {
        Write-Host "Error: WSL distro '$WslDistro' was not found." -ForegroundColor Red
        Write-Host "Installed distros:" -ForegroundColor Yellow
        wsl.exe -l
        Write-Host "Fix WslDistro in config/config.ps1 or run: wsl --install -d $WslDistro" -ForegroundColor Red
        exit 1
    }

    Write-Host "WSL prerequisite check passed." -ForegroundColor Green
}

function Test-DockerBackendPrerequisites {
    param (
        [Parameter(Mandatory = $true)]
        [string]$WslDistro,

        [Parameter(Mandatory = $true)]
        [ValidateSet("desktop", "wsl-dockerd")]
        [string]$DockerBackend
    )

    $dockerProbe = "docker version >/dev/null && docker compose version >/dev/null"

    switch ($DockerBackend) {
        "desktop" {
            Write-Host "Docker backend: Docker Desktop" -ForegroundColor DarkGray
            & wsl.exe -d $WslDistro -e sh -lc $dockerProbe
            if ($LASTEXITCODE -ne 0) {
                Write-Host "Error: cannot connect to Docker Desktop from WSL." -ForegroundColor Red
                Write-Host "Enable WSL Integration in Docker Desktop." -ForegroundColor Yellow
                exit 1
            }
        }
        "wsl-dockerd" {
            Write-Host "Docker backend: WSL dockerd" -ForegroundColor DarkGray
            & wsl.exe -d $WslDistro -e sh -lc $dockerProbe
            if ($LASTEXITCODE -ne 0) {
                Write-Host "Error: docker / docker compose is not available in WSL." -ForegroundColor Red
                Write-Host "Ensure the docker compose plugin is installed in the WSL distro." -ForegroundColor Yellow
                exit 1
            }

            & wsl.exe -d $WslDistro -e sh -lc "systemctl is-active docker >/dev/null 2>&1 || pgrep dockerd >/dev/null 2>&1"
            if ($LASTEXITCODE -ne 0) {
                Write-Host "Error: dockerd is not running." -ForegroundColor Red
                Write-Host "Start it with `systemctl start docker` or launch dockerd manually." -ForegroundColor Yellow
                exit 1
            }
        }
        default {
            Write-Host "Error: unsupported DockerBackend '$DockerBackend'." -ForegroundColor Red
            exit 1
        }
    }
}

function Sync-WslWorkspace {
    param (
        [Parameter(Mandatory = $true)]
        [string]$SourceRoot,

        [Parameter(Mandatory = $true)]
        [string]$DestinationRoot,

        [Parameter(Mandatory = $true)]
        [ValidateSet("mirror-repo", "project-only", "none")]
        [string]$SyncMode
    )

    if ($SyncMode -eq "none") {
        Write-Host "Skipping WSL sync (SyncMode = none)." -ForegroundColor DarkGray
        $global:LASTEXITCODE = 0
        return
    }

    New-Item -ItemType Directory -Force -Path $DestinationRoot | Out-Null

    if ($SyncMode -eq "mirror-repo") {
        robocopy $SourceRoot $DestinationRoot /MIR /XF ".git" /XD ".git" "log" /NFL /NDL /NJH /NJS | Out-Null
        if ($LASTEXITCODE -ge 8) {
            Write-Host "Error: failed to sync the repository." -ForegroundColor Red
            exit 1
        }
        $global:LASTEXITCODE = 0
        return
    }

    $directories = @("config", "csl", "preamble", "templates", "projects")
    foreach ($directory in $directories) {
        $sourcePath = Join-Path $SourceRoot $directory
        if (-not (Test-Path $sourcePath)) {
            continue
        }

        $destinationPath = Join-Path $DestinationRoot $directory
        New-Item -ItemType Directory -Force -Path $destinationPath | Out-Null
        robocopy $sourcePath $destinationPath /MIR /NFL /NDL /NJH /NJS | Out-Null
        if ($LASTEXITCODE -ge 8) {
            Write-Host "Error: failed to sync $directory." -ForegroundColor Red
            exit 1
        }
    }

    $files = @("defaults.yml", "defaults-paper.yml", "Dockerfile", "docker-compose.yml", "README.md", "LICENSE")
    foreach ($file in $files) {
        $sourceFile = Join-Path $SourceRoot $file
        if (Test-Path $sourceFile) {
            Copy-Item -Path $sourceFile -Destination (Join-Path $DestinationRoot $file) -Force
        }
    }

    Write-Host "WSL workspace synced in project-only mode." -ForegroundColor DarkGray
    $global:LASTEXITCODE = 0
}
