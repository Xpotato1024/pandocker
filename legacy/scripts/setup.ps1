Write-Host "=== Setup start ===" -ForegroundColor Cyan

try {
    . (Join-Path $PSScriptRoot "wsl-init.ps1")
} catch {
    Write-Host "Error: failed to load wsl-init.ps1." -ForegroundColor Red
    exit 1
}

Write-Host "[1/5] Preparing WSL environment..." -ForegroundColor Yellow
Write-Host " Host root : $WindowsProjectRoot"
Write-Host " WSL root  : $WslProjectRootUnix"
Write-Host " Backend   : $($PandockerConfig.DockerBackend)"
Write-Host " SyncMode  : $($PandockerConfig.SyncMode)"

Write-Host "[2/5] Syncing the workspace to WSL..." -ForegroundColor Yellow
Sync-WslWorkspace -SourceRoot $WindowsProjectRoot -DestinationRoot $WslProjectRootWin -SyncMode $PandockerConfig.SyncMode
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: workspace sync failed." -ForegroundColor Red
    exit 1
}

Write-Host "[3/5] Building the Docker image..." -ForegroundColor Yellow
$WslCommand = "cd '$WslProjectRootUnix' && docker compose build"
& wsl.exe -d $WslDistro -e sh -lc $WslCommand
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: docker image build failed." -ForegroundColor Red
    exit 1
}

Write-Host "[4/5] Preparing Docker volumes..." -ForegroundColor Yellow
$WslCommand = "cd '$WslProjectRootUnix' && docker compose up -d --no-deps pandoc >/dev/null && docker compose stop pandoc >/dev/null"
& wsl.exe -d $WslDistro -e sh -lc $WslCommand
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: volume preparation failed." -ForegroundColor Red
    exit 1
}

Write-Host "[5/5] Generating TeX Live formats..." -ForegroundColor Yellow
$WslCommand = "cd '$WslProjectRootUnix' && docker compose run --rm --entrypoint bash pandoc -lc 'fmtutil-sys --all'"
& wsl.exe -d $WslDistro -e sh -lc $WslCommand
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: TeX Live format generation failed." -ForegroundColor Red
    exit 1
}

Write-Host "=== Setup complete ===" -ForegroundColor Green
Write-Host "You can now run pdx new / pdx build." -ForegroundColor Cyan
