# pandocker.ps1
#
# 使い方:
#   ./pandocker.ps1 "レポート名" [-CleanCache]
#
# 例:
#   ./pandocker.ps1 "report-weekly-progress" -CleanCache
# -------------------------------------------------------------

param (
    [Parameter(Position=0, Mandatory=$true)]
    [string]$ReportName,

    [switch]$CleanCache
)

# 1. 指定ディレクトリ確認
if (-not (Test-Path -Path $ReportName -PathType Container)) {
    Write-Host "エラー: '$ReportName' という名前のディレクトリが見つかりません。" -ForegroundColor Red
    Write-Host "ヒント: ./new.ps1 '$ReportName' を実行してレポート環境を作成してください。"
    return
}

# 2. プロジェクトルート
$WorkDir = (Get-Location).Path
$CacheRoot = Join-Path $WorkDir ".cache"
$LogDir = Join-Path $WorkDir "log"
$LogFile = Join-Path $LogDir "pandoc.log"

# 3. ディレクトリ準備
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Force -Path $LogDir | Out-Null }
if (-not (Test-Path $CacheRoot)) { New-Item -ItemType Directory -Force -Path $CacheRoot | Out-Null }

# 4. キャッシュ初期化スイッチ
if ($CleanCache) {
    Write-Host "キャッシュを初期化中..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue $CacheRoot
    New-Item -ItemType Directory -Force -Path $CacheRoot | Out-Null
}

# 5. キャッシュBind Mount設定
$CacheDirs = @(
    @{ Name = "texlive"; Path = "$CacheRoot/texlive" },
    @{ Name = "texmf"; Path = "$CacheRoot/texmf" },
    @{ Name = "font"; Path = "$CacheRoot/fontconfig" }
)
foreach ($dir in $CacheDirs) {
    if (-not (Test-Path $dir.Path)) { New-Item -ItemType Directory -Force -Path $dir.Path | Out-Null }
}
$CacheMounts = $CacheDirs | ForEach-Object { "-v `"$($_.Path):/root/.cache/$($_.Name)`"" } -join " "

# 6. その他設定
$ContainerWorkDir = "/data/$ReportName/src"
$InputFile = "report.md"
$DefaultsFile = "../defaults.yml"
$OutputFile = "../output/$($ReportName).pdf"

# 7. Dockerコマンド構築
$DockerCmd = "docker run --rm -v `"$WorkDir`:/data`" -w `"$ContainerWorkDir`" $CacheMounts pandoc-ja --defaults `"$DefaultsFile`" -F pandoc-crossref `"$InputFile`" -o `"$OutputFile`" --citeproc -M listings"

# 8. 実行とログ保存
Write-Host "PDFを生成しています..." -ForegroundColor Cyan
Write-Host "コマンド: $DockerCmd"

# ログに追記しつつ画面にも出力
$DockerCmd | Out-File -Append -FilePath $LogFile
Invoke-Expression "$DockerCmd 2>&1 | Tee-Object -FilePath $LogFile"

# 9. 出力確認
$OutputFullPath = Join-Path -Path $WorkDir -ChildPath "$ReportName/output/$($ReportName).pdf"
if (Test-Path $OutputFullPath) {
    Write-Host ""
    Write-Host "PDFの生成が完了しました！" -ForegroundColor Green
    Write-Host "出力先: $OutputFullPath"
    Write-Host "ログ: $LogFile"
} else {
    Write-Host ""
    Write-Host "エラー: PDFの生成に失敗した可能性があります。" -ForegroundColor Red
    Write-Host "詳細はログファイルを確認してください: $LogFile"
}
