# Common initialization for Windows-side scripts.

Write-Host "Starting Pdx initialization..." -ForegroundColor DarkGray

$ScriptPath = $PSScriptRoot
$PdxRoot = Split-Path $ScriptPath -Parent
$ConfigPath = Join-Path $PdxRoot "config"

try {
    . (Join-Path $ConfigPath "config.ps1")
    . (Join-Path $ConfigPath "wsl-helpers.ps1")
} catch {
    Write-Host "Error: failed to load config scripts." -ForegroundColor Red
    exit 1
}

Test-WslPrerequisites -WslDistro $PandockerConfig.WslDistro
if ($LASTEXITCODE -ne 0) {
    exit 1
}

Test-DockerBackendPrerequisites -WslDistro $PandockerConfig.WslDistro -DockerBackend $PandockerConfig.DockerBackend
if ($LASTEXITCODE -ne 0) {
    exit 1
}

$WslDistro = $PandockerConfig.WslDistro
$WindowsProjectRoot = $PdxRoot
$TexProjectRoot = Join-Path $WindowsProjectRoot "projects"

$WslHome = (wsl.exe -d $WslDistro -e sh -lc 'printf "%s" "$HOME"').Trim()
$WslProjectRootUnix = "$WslHome/$($PandockerConfig.WslWorkDirName)"
$WslProjectRootWin = (wsl.exe -d $WslDistro -e wslpath -w $WslProjectRootUnix).Trim()

& wsl.exe -d $WslDistro -e sh -lc "mkdir -p '$WslProjectRootUnix'"
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: failed to create the WSL workspace." -ForegroundColor Red
    exit 1
}

Write-Host "Initialization complete." -ForegroundColor DarkGray
