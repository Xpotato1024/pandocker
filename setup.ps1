# setup.ps1
Write-Host "=== 初回セットアップ開始 ===" -ForegroundColor Cyan

# 1. Docker イメージのビルド (必要な場合)
Write-Host "[1/3] Docker イメージをビルド中..." -ForegroundColor Yellow
docker compose build --no-cache

# 2. キャッシュボリュームの確認と作成
Write-Host "[2/3] Docker ボリュームを準備中..." -ForegroundColor Yellow
docker compose up -d --no-deps pandoc > $null
docker compose stop pandoc > $null
Write-Host "ボリュームの準備ができました。" -ForegroundColor Green

# 3. TeX Liveフォーマットファイルの生成
Write-Host "[3/3] TeX Liveフォーマットを生成中... (数分かかる場合があります)" -ForegroundColor Yellow
try {
    docker compose run --rm --entrypoint bash pandoc -c "fmtutil-sys --all"
    Write-Host "TeX Liveフォーマットの生成が完了しました。" -ForegroundColor Green
} catch {
    Write-Host "TeX Liveフォーマットの生成に失敗しました。" -ForegroundColor Red
    Write-Host $_
    return
}

Write-Host "=== セットアップ完了 ===" -ForegroundColor Green
Write-Host "プロジェクトの準備が整いました。'./new.ps1' や './pandocker.ps1' を使用してください。"
