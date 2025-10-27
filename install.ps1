<#
.SYNOPSIS
    Pandocker PowerShell 初回セットアップスクリプト（OneDrive回避版）
.DESCRIPTION
    - PowerShell プロファイルの保存先を OneDrive からローカルに移動
    - Pandocker-X 専用プロファイルを作成し、全ホストで共通読み込み
    - pdx 関数を強制的に再登録（空ファイルや誤判定を回避）
    - pdx-new, pdx-setup, pdx-build のエイリアスを登録
#>
#install.ps1

Write-Host "Pandocker PowerShell セットアップを開始します..." -ForegroundColor Cyan

# --- 実行ポリシー確認 ---
if ((Get-ExecutionPolicy) -eq "Restricted") {
    Write-Host "実行ポリシーが Restricted のため、スクリプト実行ができません。" -ForegroundColor Yellow
    Write-Host "以下を管理者権限の PowerShell で実行してください:" -ForegroundColor Cyan
    Write-Host "    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser"
    exit 1
}

# --- ルートパス特定 ---
$PdxRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ScriptPath = Join-Path $PdxRoot "scripts"
$ConfigPath = Join-Path $PdxRoot "config"

if (!(Test-Path $ScriptPath)) { Write-Host "scripts ディレクトリが見つかりません: $ScriptPath" -ForegroundColor Red; exit 1 }
if (!(Test-Path $ConfigPath)) { Write-Host "config ディレクトリが見つかりません: $ConfigPath" -ForegroundColor Red; exit 1 }

# --- ps1ファイルのブロック解除 ---
Write-Host "ps1 ファイルのブロックを解除しています..."
$targetDirs = @($PdxRoot, $ScriptPath, $ConfigPath)
foreach ($dir in $targetDirs) {
    if (Test-Path $dir) {
        Get-ChildItem -Path $dir -Filter *.ps1 -File | ForEach-Object {
            try {
                Unblock-File $_.FullName
                Write-Host "✅ 解除: $($_.Name)"
            } catch {
                Write-Host "⚠️ 解除失敗: $($_.Name)"
            }
        }
    }
}

# --- Pandocker 専用プロファイルのローカルパスを定義 ---
# OneDrive環境下での問題を避けるため、ローカルのDocuments\PowerShell内にプロファイルを作成します
$LocalProfileDir = Join-Path $env:USERPROFILE "Documents\PowerShell"
if (!(Test-Path $LocalProfileDir)) {
    New-Item -ItemType Directory -Path $LocalProfileDir -Force | Out-Null
}

$PandockerProfile = Join-Path $LocalProfileDir "Pandocker_profile.ps1"

# --- pdx 関数とエイリアスの定義（強制上書き用） ---
# ヒアドキュメントを "" で囲むことで $ScriptPath を展開しつつ、関数内の `$Command` などはエスケープして展開を防ぎます。
$pdxContent = @"
# --- Pandocker PowerShell 関数 ---
function pdx {
    param(
        [Parameter(Position=0)] `$Command,
        [Parameter(ValueFromRemainingArguments = `$true)] `$Args
    )

    # install.ps1 が特定した Pandocker のルートパスを直接使用します
    `$ScriptDir = '$ScriptPath'

    switch (`$Command) {
        "new"    { & (Join-Path `$ScriptDir 'new.ps1') `$Args[0] }
        "setup"  { & (Join-Path `$ScriptDir 'setup.ps1') `$Args[0] }
        
        # --- [修正] 'build' のための引数振り分けロジック ---
        "build"  { 
            # スプラッティング用のハッシュテーブルと、InputFiles用の配列を準備
            `$BuildArgs = @{}
            `$InputFiles = @()

            if (`$Args.Count -gt 0 -and -not (`$Args[0].StartsWith("-"))) {
                # 1. 最初の引数がスイッチでない場合、-ReportName 引数として設定
                `$BuildArgs['ReportName'] = `$Args[0]
                
                # 2. 2番目以降の引数(-All, -Log, "file.md" など)を処理
                if (`$Args.Count -gt 1) {
                    for (`$i = 1; `$i -lt `$Args.Count; `$i++) {
                        if (`$Args[`$i].StartsWith("-")) {
                            # スイッチの場合
                            `$SwitchName = `$Args[`$i].Substring(1) # "-" を除去
                            `$BuildArgs[`$SwitchName] = `$true
                        } else {
                            # ファイル名の場合
                            `$InputFiles += `$Args[`$i]
                        }
                    }
                }
            } else {
                # 最初の引数がスイッチ(-Allなど)か、引数がない場合
                for (`$i = 0; `$i -lt `$Args.Count; `$i++) {
                    if (`$Args[`$i].StartsWith("-")) {
                        `$SwitchName = `$Args[`$i].Substring(1) # "-" を除去
                        `$BuildArgs[`$SwitchName] = `$true
                    }
                    # (このパターンではファイル名は無視)
                }
            }
            
            # 3. $InputFiles にファイルが追加されていたら、ハッシュテーブルに追加
            if (`$InputFiles.Count -gt 0) {
                `$BuildArgs['InputFiles'] = `$InputFiles
            }

            # ハッシュテーブルをスプラッティングして渡す
            & (Join-Path `$ScriptDir 'build.ps1') @BuildArgs
        }
        # --- [修正ここまで] ---

        default  { Write-Host "Usage: pdx [new|build|setup] <args>" -ForegroundColor Yellow }
        }
}

# --- Pandocker PowerShell エイリアス（pdx-command 形式のショートカット） ---
# Set-Alias の -Value には、実行するスクリプトのフルパスを渡します
`$ScriptPath = '$ScriptPath'
Set-Alias pdx-new (Join-Path `$ScriptPath 'new.ps1') -ErrorAction SilentlyContinue
Set-Alias pdx-setup (Join-Path `$ScriptPath 'setup.ps1') -ErrorAction SilentlyContinue
Set-Alias pdx-build (Join-Path `$ScriptPath 'build.ps1') -ErrorAction SilentlyContinue

"@

# --- Pandocker プロファイルを作成・上書き ---
Write-Host "Pandocker 専用プロファイルを作成・更新: $PandockerProfile"
Set-Content -Path $PandockerProfile -Value $pdxContent -Encoding UTF8

# --- 現行ホストのプロファイルを確認 ---
# $PROFILE は現在実行中のホストのプロファイルを示します（通常はコンソールのプロファイル）
if (!(Test-Path $PROFILE)) {
    Write-Host "プロファイルファイルを新規作成します: $PROFILE"
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
}

# --- 全ホストから Pandocker プロファイルを読み込むよう設定 ---
$includeLine = ". `"$PandockerProfile`""
# ---------------------------------------------------------------------------------
# 修正点: Get-Contentの代わりに -Raw を使って全内容を単一の文字列として読み込み、
#         Select-Stringではなく、Stringの.Contains()メソッドでチェックする
# ---------------------------------------------------------------------------------
$profileContentRaw = ""
if (Test-Path -Path $PROFILE -PathType Leaf) {
    # -Raw でファイル全体を単一の文字列として読み込みます
    $profileContentRaw = Get-Content -Path $PROFILE -Raw -ErrorAction SilentlyContinue
}

# .Contains() メソッドで読み込み行が既に含まれているかを確認します
if (-not ($profileContentRaw.Contains($includeLine))) {
    Write-Host "現行プロファイルから Pandocker プロファイルを読み込むよう設定: $PROFILE"
    Add-Content -Path $PROFILE -Value "`n# Load Pandocker profile`n$includeLine`n"
} else {
    Write-Host "既に Pandocker プロファイルが読み込み設定済み。"
}

Write-Host "現在のセッションに関数を読み込んでいます..."
try {
    # . $PROFILE ではなく、作成した専用プロファイル($PandockerProfile)を読み込む
    . $PandockerProfile
} catch {
    Write-Host "エラー: プロファイルの読み込みに失敗しました。" -ForegroundColor Red
    Write-Host $_
}

# --- 完了メッセージ ---
Write-Host "`n セットアップ完了！pdx コマンドがこのまま使用できます：" -ForegroundColor Green
Write-Host "    pdx setup"
Write-Host "    pdx new <ProjectName>"
Write-Host "    pdx build <ProjectName> [options]"
Write-Host "`n※ pdx関数はローカル 'Documents\\PowerShell\\Pandocker_profile.ps1' に登録されました。" -ForegroundColor Cyan