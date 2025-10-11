# new.ps1
#
# 使い方:
#   PowerShellでこのスクリプトがあるディレクトリに移動し、
#   ./new.ps1 "新しいレポート名"
#   と実行します。
#
# 例:
#   ./new-report.ps1 "report-final-presentation"

param (
    [Parameter(Position=0, Mandatory=$true)]
    [string]$ReportName
)

# --- スクリプトのメイン処理 ---

# 1. すでに同名のディレクトリが存在しないかチェック
if (Test-Path -Path $ReportName) {
    Write-Host "エラー: '$ReportName' という名前のディレクトリは既に存在します。" -ForegroundColor Red
    # スクリプトの実行を停止
    return
}

# 2. メインのレポートディレクトリを作成
Write-Host "レポートディレクトリ '$ReportName' を作成しています..." -ForegroundColor Cyan
New-Item -ItemType Directory -Path $ReportName | Out-Null

# 3. サブディレクトリのリスト
$subDirs = @("src", "images", "bib", "output")

# 4. 各サブディレクトリを作成
foreach ($dir in $subDirs) {
    $subDirPath = Join-Path -Path $ReportName -ChildPath $dir
    Write-Host "  - サブディレクトリ '$dir' を作成中..."
    New-Item -ItemType Directory -Path $subDirPath | Out-Null
}

# --- 追加ファイルの自動生成 ---

# 5. 空の参考文献ファイル (references.bib) を作成
$referencesPath = Join-Path -Path $ReportName -ChildPath "bib/references.bib"
Write-Host "  - 参考文献ファイル 'references.bib' を作成中..."
Set-Content -Path $referencesPath -Value "" -Encoding UTF8

# 6. マークダウンのテンプレートファイル (report.md) を作成
$reportMdPath = Join-Path -Path $ReportName -ChildPath "src/report.md"
$currentDate = Get-Date -Format "yyyy-MM-dd"
$reportMdTemplate = @"
---
title: "Title"
author: "name"
date: "{0}"
bibliography: ../bib/references.bib
csl: ../../ieee-with-url.csl
---

# section
"@
$reportMdContent = $reportMdTemplate -f $currentDate
Write-Host "  - MDテンプレート 'report.md' を作成中..."
Set-Content -Path $reportMdPath -Value $reportMdContent -Encoding UTF8


# 7. defaults.ymlファイルの内容を定義
# Here-String (`@'...'@`) を使うことで、YAMLの内容を純粋なテキストとして扱い、
# PowerShellによる意図しない解釈やエラーを防ぎます。
$yamlTemplate = @'
# Pandoc Defaults File for: __REPORT_NAME__
# ===============================================

# --- 入力と出力 ---
reader: markdown
writer: pdf
pdf-engine: lualatex
highlight-style: tango

# ----------------------------------------------------
# pandoc-crossref フィルタ用のメタデータ
# ----------------------------------------------------
metadata:
  figureTitle: "図 "
  tableTitle: "表 "
  eqTitle: "式 "
  listingTitle: "リスト "
  figPrefix:
    - "図."
    - "図."
  tblPrefix: "表."
  eqnPrefix: "式."
  lstPrefix: "リスト."
  reference-section-title: "参考文献"

# ----------------------------------------------------
# Pandocテンプレート（LaTeX）用の変数
# ----------------------------------------------------
variables:
  lang: ja-JP
  documentclass: ltjsarticle
  mainfont: "Noto Serif CJK JP"
  sansfont: "Noto Sans CJK JP"
  monofont: "Noto Sans Mono CJK JP"
  geometry: "top=25mm, bottom=25mm, left=20mm, right=20mm"
  header-includes:
    - \usepackage{luatexja}
    - \usepackage{luatexja-preset}
    - \usepackage{float}
    - \ltjsetparameter{jacharrange={-2}}
    - \renewcommand{\baselinestretch}{1.3}
    - \setlength{\parindent}{1em}
    - \setlength{\parskip}{0pt}
    - \usepackage{listings}
    - \usepackage{amsmath}
  fig-pos: "htbp"
'@

# レポート名をテンプレートのプレースホルダに挿入
$defaultsContent = $yamlTemplate.Replace('__REPORT_NAME__', $ReportName)

# 8. defaults.ymlファイルを生成
$defaultsPath = Join-Path -Path $ReportName -ChildPath "defaults.yml"
Write-Host "  - 設定ファイル 'defaults.yml' を作成中..."
Set-Content -Path $defaultsPath -Value $defaultsContent -Encoding UTF8

# 9. 完了メッセージ
Write-Host ""
Write-Host "レポート '$ReportName' の準備が完了しました！" -ForegroundColor Green
Write-Host "src/report.md を編集して作業を開始してください。"
