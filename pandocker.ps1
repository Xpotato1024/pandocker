# pandocker.ps1
#
# 使い方:
#   ./pandocker.ps1 "レポート名" [-Log]
#
# 例:
#   ./pandocker.ps1 "report-weekly-progress" -log

param (
    [Parameter(Position=0, Mandatory=$true)]
    [string]$ReportName,

    [Parameter(Position=1)]
    [switch]$Log
)

# --- 1. 環境設定 ---
$WorkDir = (Get-Location).Path
$ContainerWorkDir = "/data/$ReportName/src"
$InputFile = "report.md"
$Defaults = "../defaults.yml"
$OutputFile = "../output/$ReportName.pdf"

# --- 2. ログ出力先 ---
$LogDir = Join-Path $WorkDir "log"

# --- 3. Pandocコマンド ---
$PandocArgs = "--defaults '$Defaults' -F pandoc-crossref '$InputFile' -o '$OutputFile' --citeproc -M listings"

# --- 4. 実行コマンド構築 ---
if ($Log.IsPresent) {
    # ログが有効な場合、--verboseを追加し、出力をログファイルにリダイレクト
    if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Force -Path $LogDir | Out-Null }
    $PandocArgs += " --verbose"
    $BashCommandRaw = "cd '$ContainerWorkDir' && { echo '--- Build started at `$(date --iso-8601=seconds) ---'; pandoc $PandocArgs; } &>> /data/log/pandoc.log"
    Write-Host "PDF生成を開始します... (ログは log/pandoc.log に追記されます)" -ForegroundColor Cyan
} else {
    # ログが無効な場合、コンソールに直接出力（エラー時のみ表示される）
    $BashCommandRaw = "cd '$ContainerWorkDir' && pandoc $PandocArgs"
    Write-Host "PDF生成を開始します..." -ForegroundColor Cyan
}
$BashCommand = $BashCommandRaw -replace "'", "''"
$DockerCmd = "docker compose run --rm --entrypoint bash pandoc -c '$BashCommand'"

# --- 5. 実行 ---
Write-Host $DockerCmd
$StartTime = Get-Date
Invoke-Expression $DockerCmd
$EndTime = Get-Date
$ElapsedTime = New-TimeSpan -Start $StartTime -End $EndTime

# --- 6. 結果確認 ---
$OutputFullPath = Join-Path $WorkDir "$ReportName/output/$ReportName.pdf"
if (Test-Path $OutputFullPath) {
    $FormattedTime = "{0:N3}" -f $ElapsedTime.TotalSeconds
    Write-Host "PDF生成完了: $OutputFullPath" -ForegroundColor Green
    Write-Host "   経過時間: $FormattedTime 秒" -ForegroundColor DarkGray
} else {
    Write-Host "PDF生成に失敗しました。詳細はログを確認してください: log/pandoc.log" -ForegroundColor Red
}
