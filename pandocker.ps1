# pandocker.ps1
#
# 使い方:
#   PowerShellでこのスクリプトがあるディレクトリに移動し、
#   ./pandocker.ps1 "レポート名"
#   と実行します。
#
# 例:
#   ./pandocker.ps1 "report-weekly-progress"

param (
    [Parameter(Position=0, Mandatory=$true)]
    [string]$ReportName
)

# 1. 指定されたレポートのディレクトリが存在するかチェック
if (-not (Test-Path -Path $ReportName -PathType Container)) {
    Write-Host "エラー: '$ReportName' という名前のディレクトリが見つかりません。" -ForegroundColor Red
    Write-Host "ヒント: ./new.ps1 '$ReportName' を実行して、先にレポート環境を作成してください。"
    return
}

# 2. プロジェクトのルートディレクトリ
$WorkDir = (Get-Location).Path

# 3. 規約に基づいたパスを定義
$ContainerWorkDir = "/data/$ReportName/src"
$InputFile = "report.md"                  # CWDからの相対パス
$DefaultsFile = "../defaults.yml"         # CWDからの相対パス
$OutputFile = "../output/$($ReportName).pdf" # CWDからの相対パス

# 4. キャッシュボリュームを1行にまとめて渡す
$CacheVolumes = @(
    '-v "texlive-cache:/root/.texlive2024"',
    '-v "texmf-cache:/var/lib/texmf"',
    '-v "font-cache:/root/.cache/fontconfig"'
) -join ' '

# 5. Dockerコマンドを構築
$DockerCmd = "docker run --rm -v `"$WorkDir`:/data`" -w `"$ContainerWorkDir`" $CacheVolumes pandoc-ja --defaults `"$DefaultsFile`" -F pandoc-crossref `"$InputFile`" -o `"$OutputFile`" --citeproc -M listings"

Write-Host "PDFを生成しています..." -ForegroundColor Cyan
Write-Host "コマンド: $DockerCmd"
Invoke-Expression $DockerCmd

# 6. 完了メッセージ
$OutputFullPath = Join-Path -Path $WorkDir -ChildPath "$ReportName/output/$($ReportName).pdf"
if (Test-Path $OutputFullPath) {
    Write-Host ""
    Write-Host "PDFの生成が完了しました！" -ForegroundColor Green
    Write-Host "出力先: $OutputFullPath"
} else {
    Write-Host ""
    Write-Host "エラー: PDFの生成に失敗した可能性があります。" -ForegroundColor Red
}

