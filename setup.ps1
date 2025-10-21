Write-Host "=== 初回セットアップ開始 (WSLモード) ===" -ForegroundColor Cyan

# --- 1. 共通設定とヘルパー関数を読み込む ---
try {
    . (Join-Path $PSScriptRoot "config.ps1")
    . (Join-Path $PSScriptRoot "wsl-helpers.ps1")
} catch {
    Write-Host "エラー: config.ps1 または wsl-helpers.ps1 が見つかりません。" -ForegroundColor Red
    return
}

# --- 2. 前提条件をチェック ---
Test-WslPrerequisites -WslDistro $PandockerConfig.WslDistro
if ($LASTEXITCODE -ne 0) { return }

# --- 3. Windows/WSLパス設定 ---
$WslDistro = $PandockerConfig.WslDistro
$WindowsProjectRoot = (Get-Location).Path
$WslHome = (wsl.exe -d $WslDistro -e sh -c 'echo $HOME').Trim()
$WslProjectRootUnix = "$WslHome/$($PandockerConfig.WslWorkDirName)" # WSL内の作業場所 (Unixパス)
$WslProjectRootWin = (wsl.exe -d $WslDistro wslpath -w $WslProjectRootUnix).Trim() # Windowsから見たパス

Write-Host "[1/5] WSL環境を準備中..." -ForegroundColor Yellow
Write-Host " Windows (ホスト) : $WindowsProjectRoot"
Write-Host " WSL (実行場所)   : $WslProjectRootUnix"

# --- 4. Windows -> WSL へのプロジェクト同期 ---
Write-Host "[2/5] プロジェクトファイルをWSLに同期中..." -ForegroundColor Yellow
robocopy $WindowsProjectRoot $WslProjectRootWin /MIR /XF ".git" /XD ".git" "log" /NFL /NDL /NJH /NJS
if ($LASTEXITCODE -ge 8) {
    Write-Host "エラー: Robocopyでのファイル同期に失敗しました。" -ForegroundColor Red
    return
}

# --- 5. Docker イメージのビルド ---
Write-Host "[3/5] Docker イメージをビルド中 (WSL内)..." -ForegroundColor Yellow
$WslCommand = "cd '$WslProjectRootUnix' && docker compose build"

& wsl.exe -d $WslDistro -e sh -c $WslCommand
if ($LASTEXITCODE -ne 0) {
    Write-Host "エラー: Dockerイメージのビルドに失敗しました。" -ForegroundColor Red
    return
}

# --- 6. キャッシュボリュームの確認と作成 ---
Write-Host "[4/5] Docker ボリュームを準備中 (WSL内)..." -ForegroundColor Yellow
$WslCommand = "cd '$WslProjectRootUnix' && docker compose up -d --no-deps pandoc > /dev/null && docker compose stop pandoc > /dev/null"
& wsl.exe -d $WslDistro -e sh -c $WslCommand
if ($LASTEXITCODE -ne 0) {
    Write-Host "エラー: ボリュームの準備に失敗しました。" -ForegroundColor Red
    return
}
Write-Host "ボリュームの準備ができました。" -ForegroundColor Green

# --- 7. TeX Liveフォーマットファイルの生成 ---
Write-Host "[5/5] TeX Liveフォーマットを生成中 (WSL内)... (数分かかる場合があります)" -ForegroundColor Yellow
$WslCommand = "cd '$WslProjectRootUnix' && docker compose run --rm --entrypoint bash pandoc -c 'fmtutil-sys --all'"
& wsl.exe -d $WslDistro -e sh -c $WslCommand
if ($LASTEXITCODE -ne 0) {
    Write-Host "エラー: TeX Liveフォーマットの生成に失敗しました。" -ForegroundColor Red
    return
}
Write-Host "TeX Liveフォーマットの生成が完了しました。" -ForegroundColor Green

Write-Host "=== セットアップ完了 ===" -ForegroundColor Green
Write-Host "プロジェクトの準備が整いました。'./new.ps1' や './pandocker.ps1' を使用してください。"
