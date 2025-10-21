# new.ps1
# 新しいレポートプロジェクトのひな形を作成する
#
# 使い方:
#   ./new.ps1 "新しいレポート名"

param (
    [Parameter(Position=0, Mandatory=$true)]
    [string]$ReportName
)

# --- 1. スクリプトのメイン処理 ---

# 実行カレントディレクトリ（プロジェクトルート）を取得
$WorkDir = (Get-Location).Path
# プロジェクトを格納するベースディレクトリを設定
$ProjectsBaseDir = Join-Path -Path $WorkDir -ChildPath "projects"

# 'projects' ディレクトリがなければ作成する
if (-not (Test-Path -Path $ProjectsBaseDir)) {
    Write-Host "ベースディレクトリ 'projects' を作成しています..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $ProjectsBaseDir | Out-Null
}

# 作成対象のレポートディレクトリのフルパス
$targetReportDir = Join-Path -Path $ProjectsBaseDir -ChildPath $ReportName

# 2. すでに同名のディレクトリが存在しないかチェック
if (Test-Path -Path $targetReportDir) {
    Write-Host "エラー: 'projects/$ReportName' という名前のディレクトリは既に存在します。" -ForegroundColor Red
    return
}

# 3. メインのレポートディレクトリを作成
Write-Host "レポートディレクトリ 'projects/$ReportName' を作成しています..." -ForegroundColor Cyan
New-Item -ItemType Directory -Path $targetReportDir | Out-Null

# 4. サブディレクトリのリスト
$subDirs = @("src", "images", "bib", "output")

# 5. 各サブディレクトリを作成
foreach ($dir in $subDirs) {
    $subDirPath = Join-Path -Path $targetReportDir -ChildPath $dir
    Write-Host "  - サブディレクトリ '$dir' を作成中..."
    New-Item -ItemType Directory -Path $subDirPath | Out-Null
}

# --- 追加ファイルの自動生成 ---

# 6. 空の参考文献ファイル (references.bib) を作成
$referencesPath = Join-Path -Path $targetReportDir -ChildPath "bib/references.bib"
Write-Host "  - 参考文献ファイル 'references.bib' を作成中..."
Set-Content -Path $referencesPath -Value "" -Encoding UTF8

# 7. マークダウンのテンプレートファイル (report.md) を作成
$reportMdPath = Join-Path -Path $targetReportDir -ChildPath "src/report.md"
$currentDate = Get-Date -Format "yyyy-MM-dd"
$reportMdTemplate = @"
---
title: "Title"
author: "name"
date: "{0}"
bibliography: ../bib/references.bib
csl: ../../../csl/ieee-with-url.csl
---

# section
"@
$reportMdContent = $reportMdTemplate -f $currentDate
Write-Host "  - MDテンプレート 'report.md' を作成中..."
Set-Content -Path $reportMdPath -Value $reportMdContent -Encoding UTF8

# 8. プロジェクトルートにある defaults.yml をコピー
$sourceDefaultsPath = Join-Path -Path $WorkDir -ChildPath "defaults.yml"
$targetDefaultsPath = Join-Path -Path $targetReportDir -ChildPath "defaults.yml"

if (Test-Path -Path $sourceDefaultsPath) {
    Write-Host "  - 設定ファイル 'defaults.yml' をコピー中..."
    Copy-Item -Path $sourceDefaultsPath -Destination $targetDefaultsPath -Force
} else {
    Write-Host "警告: プロジェクトルートに defaults.yml が見つかりません。" -ForegroundColor Yellow
}

# 9. 完了メッセージ
Write-Host ""
Write-Host "レポート 'projects/$ReportName' の準備が完了しました！" -ForegroundColor Green
Write-Host "projects/$ReportName/src/report.md を編集して作業を開始してください。"
