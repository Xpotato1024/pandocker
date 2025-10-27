#setup.ps1
Write-Host "=== 初回セットアップ開始 (WSLモード) ===" -ForegroundColor Cyan
# --- 1. 共通のWSL初期化処理を読み込む ---
# (wsl-init.ps1 が $PdxRoot, $ConfigPath, $WslDistro, $WindowsProjectRoot, $WslProjectRootUnix, $WslProjectRootWin などを定義します)
try {
    . (Join-Path $PSScriptRoot "wsl-init.ps1")
} catch {
    Write-Host "エラー: 共通初期化スクリプト(wsl-init.ps1)の読み込みに失敗しました。" -ForegroundColor Red
    return
}

# --- 2. パス情報を表示 (wsl-init.ps1 で定義された変数を使用) ---
Write-Host "[1/5] WSL環境を準備中..." -ForegroundColor Yellow
Write-Host " Windows (ホスト) : $WindowsProjectRoot"
Write-Host " WSL (実行場所)   : $WslProjectRootUnix"

# --- 3. Windows -> WSL へのプロジェクト同期 ---
Write-Host "[2/5] プロジェクトファイルをWSLに同期中..." -ForegroundColor Yellow
robocopy $WindowsProjectRoot $WslProjectRootWin /MIR /XF ".git" /XD ".git" "log" /NFL /NDL /NJH /NJS
if ($LASTEXITCODE -ge 8) {
    Write-Host "エラー: Robocopyでのファイル同期に失敗しました。" -ForegroundColor Red
    return
}

# --- 4. Docker イメージのビルド ---
Write-Host "[3/5] Docker イメージをビルド中 (WSL内)..." -ForegroundColor Yellow
$WslCommand = "cd '$WslProjectRootUnix' && docker compose build"

& wsl.exe -d $WslDistro -e sh -c $WslCommand
if ($LASTEXITCODE -ne 0) {
    Write-Host "エラー: Dockerイメージのビルドに失敗しました。" -ForegroundColor Red
    return
}

# --- 5. キャッシュボリュームの確認と作成 ---
Write-Host "[4/5] Docker ボリュームを準備中 (WSL内)..." -ForegroundColor Yellow
$WslCommand = "cd '$WslProjectRootUnix' && docker compose up -d --no-deps pandoc > /dev/null && docker compose stop pandoc > /dev/null"
& wsl.exe -d $WslDistro -e sh -c $WslCommand
if ($LASTEXITCODE -ne 0) {
    Write-Host "エラー: ボリュームの準備に失敗しました。" -ForegroundColor Red
    return
}
Write-Host "ボリュームの準備ができました。" -ForegroundColor Green

# --- 6. TeX Liveフォーマットファイルの生成 ---
Write-Host "[5/5] TeX Liveフォーマットを生成中 (WSL内)... (数分かかる場合があります)" -ForegroundColor Yellow
$WslCommand = "cd '$WslProjectRootUnix' && docker compose run --rm --entrypoint bash pandoc -c 'fmtutil-sys --all'"
& wsl.exe -d $WslDistro -e sh -c $WslCommand
if ($LASTEXITCODE -ne 0) {
    Write-Host "エラー: TeX Liveフォーマットの生成に失敗しました。" -ForegroundColor Red
    return
}
Write-Host "TeX Liveフォーマットの生成が完了しました。" -ForegroundColor Green

Write-Host "=== セットアップ完了 ===" -ForegroundColor Green
Write-Host "プロジェクトの準備が整いました。'pdx build <target>' や 'pdx new <project>' を使用してください。"
