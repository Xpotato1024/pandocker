# wsl-init.ps1
# Pdx 共通初期化スクリプト (WSLおよびConfig用)
# setup.ps1 と build.ps1 からドットソース（.）で読み込まれることを想定

Write-Host "Pdx共通初期化処理 (wsl-init.ps1) を実行中..." -ForegroundColor DarkGray

# --- 1. PdxRootとConfigPathの特定 ---
# $PSScriptRoot は呼び出し元スクリプト(build.ps1等)のパス
$ScriptPath = $PSScriptRoot
$PdxRoot = Split-Path $ScriptPath -Parent
$ConfigPath = Join-Path $PdxRoot "config"

# --- 2. 共通設定とヘルパー関数を読み込む ---
try {
    . (Join-Path $ConfigPath "config.ps1")
    . (Join-Path $ConfigPath "wsl-helpers.ps1")
} catch {
    Write-Host "エラー: config.ps1 または wsl-helpers.ps1 が見つかりません。" -ForegroundColor Red
    return
}

# --- 3. 前提条件をチェック ---
Test-WslPrerequisites -WslDistro $PandockerConfig.WslDistro
if ($LASTEXITCODE -ne 0) { return }

# --- 4. Windows/WSLパス設定 ---
$WslDistro = $PandockerConfig.WslDistro
$WindowsProjectRoot = $PdxRoot 
$TexProjectRoot = Join-Path $WindowsProjectRoot "projects"
$WslHome = (wsl.exe -d $WslDistro -e sh -c 'echo $HOME').Trim()
$WslProjectRootUnix = "$WslHome/$($PandockerConfig.WslWorkDirName)" # WSL内の作業場所 (Unixパス)
$WslProjectRootWin = (wsl.exe -d $WslDistro wslpath -w $WslProjectRootUnix).Trim() # Windowsから見たパス

Write-Host "共通初期化 (wsl-init.ps1) 完了" -ForegroundColor DarkGray
