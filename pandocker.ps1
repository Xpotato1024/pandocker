# pandocker.ps1
#
# 使い方:
#   ./pandocker.ps1 "レポート名" [-CleanCache]
#
# 例:
#   ./pandocker.ps1 "report-weekly-progress" -CleanCache

param (
    [Parameter(Position=0, Mandatory=$true)]
    [string]$ReportName,

    [switch]$CleanCache
)

# --- 1. レポートディレクトリ確認 ---
if (-not (Test-Path -Path $ReportName -PathType Container)) {
    Write-Host "エラー: '$ReportName' が見つかりません。" -ForegroundColor Red
    Write-Host "ヒント: ./new.ps1 '$ReportName' を実行してレポート環境を作成してください。"
    return
}

# --- 2. 作業ディレクトリ・ログ ---
$WorkDir = (Get-Location).Path
$LogDir  = Join-Path $WorkDir "log"
$LogFile = Join-Path $LogDir "pandoc.log"
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Force -Path $LogDir | Out-Null }

# --- 3. Docker named volumes ---
$TexliveVol  = "texlive-cache"
$TexmfVol    = "texmf-cache"
$FontVol     = "font-cache"
$PandocVol   = "pandoc-cache"

# --- 4. キャッシュ初期化 ---
if ($CleanCache) {
    Write-Host "キャッシュボリュームを初期化中..." -ForegroundColor Yellow
    docker volume rm -f $TexliveVol,$TexmfVol,$FontVol,$PandocVol | Out-Null
}

# --- 5. キャッシュマウント ---
Write-Host "キャッシュマウントを有効化します。" -ForegroundColor Cyan
$CacheMounts = "-v ${TexliveVol}:/root/.texlive2022 -v ${TexmfVol}:/var/lib/texmf -v ${FontVol}:/root/.cache/fontconfig -v ${PandocVol}:/root/.cache/pandoc"

# --- 6. PDF関連設定 ---
$ContainerWorkDir = "/data/$ReportName/src"
$InputFile        = "report.md"
$DefaultsFile     = "../defaults.yml"
$OutputFile       = "../output/$($ReportName).pdf"

# --- 7. Dockerコマンド構築 ---
$DockerCmd = "docker run --rm -v `"$WorkDir`:/data`" -w `"$ContainerWorkDir`" $CacheMounts pandoc-ja --defaults `"$DefaultsFile`" -F pandoc-crossref `"$InputFile`" -o `"$OutputFile`" --citeproc -M listings"

# --- 8. 実行 ---
Write-Host "PDFを生成しています..." -ForegroundColor Cyan
Write-Host "コマンド: $DockerCmd"

# ログにも追記
$DockerCmd | Out-File -Append -FilePath $LogFile
Invoke-Expression "$DockerCmd 2>&1 | Tee-Object -FilePath $LogFile"

# --- 9. PDF出力確認 ---
$OutputFullPath = Join-Path -Path $WorkDir -ChildPath "$ReportName/output/$($ReportName).pdf"
if (Test-Path $OutputFullPath) {
    Write-Host ""
    Write-Host "PDF生成完了！" -ForegroundColor Green
    Write-Host "出力先: $OutputFullPath"
    Write-Host "ログ: $LogFile"
} else {
    Write-Host ""
    Write-Host "エラー: PDF生成に失敗しました。" -ForegroundColor Red
    Write-Host "詳細はログを確認してください: $LogFile"
}
