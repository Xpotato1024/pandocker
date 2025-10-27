Write-Host "Pandocker-X のクリーンアップを開始します..." -ForegroundColor Cyan

# --- 1. install.ps1 と同じロジックでパスを定義 ---
$LocalProfileDir = Join-Path $env:USERPROFILE "Documents\PowerShell"
$PandockerProfile = Join-Path $LocalProfileDir "Pandocker_profile.ps1"
$includeLine = ". `"$PandockerProfile`""
$commentLine = "# Load Pandocker profile" # install.ps1 が追加したコメント

# --- 2. メインプロファイル ($PROFILE) から読み込み設定を削除 ---
if (Test-Path $PROFILE) {
    Write-Host "メインプロファイル ($PROFILE) をクリーンアップ中..."
    try {
        # -Rawで読み込み、install.ps1が追加したブロック全体を空文字に置換
        $contentRaw = Get-Content -Path $PROFILE -Raw
        $loadBlock = "`n$commentLine`n$includeLine`n" # install.ps1が追加した形式

        if ($contentRaw.Contains($loadBlock)) {
            $newContentRaw = $contentRaw.Replace($loadBlock, "")
            Set-Content -Path $PROFILE -Value $newContentRaw
            Write-Host "$PROFILE から Pandocker の読み込み設定を削除しました。"
        } else {
            Write-Host "ℹ$PROFILE に Pandocker の設定が見つかりません。スキップします。"
        }
    } catch {
        Write-Host "$PROFILE の編集に失敗しました。手動でご確認ください。" -ForegroundColor Red
        Write-Host $_
    }
} else {
    Write-Host "ℹ$PROFILE が見つかりません。スキップします。"
}

# --- 3. Pandocker_profile.ps1 を削除 ---
if (Test-Path $PandockerProfile) {
    Write-Host "専用プロファイル ($PandockerProfile) を削除中..."
    Remove-Item $PandockerProfile -Force -ErrorAction SilentlyContinue
    Write-Host "$PandockerProfile を削除しました。"
} else {
    Write-Host "ℹ$PandockerProfile が見つかりません。スキップします。"
}

# --- 4. 現在のセッションから関数とエイリアスを削除 ---
Write-Host "現在のPowerShellセッションをクリーンアップ中..."
Remove-Item function:pdx -ErrorAction SilentlyContinue
Remove-Item alias:pdx-new -ErrorAction SilentlyContinue
Remove-Item alias:pdx-setup -ErrorAction SilentlyContinue
Remove-Item alias:pdx-build -ErrorAction SilentlyContinue
Write-Host "セッションから pdx 関数を削除しました。"

Write-Host "`nクリーンアップ完了。" -ForegroundColor Green
Write-Host "修正版の `install.ps1` を再実行してテストできます。"