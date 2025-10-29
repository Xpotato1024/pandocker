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
    Write-Host "    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser"
    exit 1
}

# --- ルートパス特定 ---
# スクリプト自身の場所を取得し、その親をルートとする
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
                Write-Host "解除: $($_.Name)"
            } catch {
                Write-Host "解除失敗: $($_.Name)"
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

    # install.ps1 が特定した Pandocker の scripts パスを直接使用します
    `$ScriptDir = '$ScriptPath'

    switch (`$Command) {
        "new"   { 
            # new.ps1 には最初の引数のみ渡す
            if (`$Args.Count -ge 1) { 
                & (Join-Path `$ScriptDir 'new.ps1') `$Args[0] 
            } else {
                Write-Host "エラー: new コマンドにはプロジェクト名が必要です。" -ForegroundColor Red
            }
        }
        "setup" { 
            # [修正] setup.ps1 は引数なしで呼び出す
            & (Join-Path `$ScriptDir 'setup.ps1') 
        }
        
        # --- 'build' のための引数振り分けロジック ---
        "build" { 
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
                # プロジェクト名がないことを build.ps1 側でエラーにする
                # `$BuildArgs['ReportName'] = `$null # 明示的にnullを渡す必要はない
            }
            
            # 3. $InputFiles にファイルが追加されていたら、ハッシュテーブルに追加
            if (`$InputFiles.Count -gt 0) {
                `$BuildArgs['InputFiles'] = `$InputFiles
            }

            # ハッシュテーブルをスプラッティングして渡す
            & (Join-Path `$ScriptDir 'build.ps1') @BuildArgs
        }
        # --- [修正ここまで] ---

        default { Write-Host "Usage: pdx [new|build|setup] <args>" -ForegroundColor Yellow }
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
# PowerShell 5.1 互換のため Out-File を使用
$pdxContent | Out-File -FilePath $PandockerProfile -Encoding UTF8 -Force

# --- 現行ホストのプロファイルを確認 ---
# $PROFILE は現在実行中のホストのプロファイルを示します（通常はコンソールのプロファイル）
if (!(Test-Path $PROFILE)) {
    Write-Host "プロファイルファイルを新規作成します: $PROFILE"
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
}

# --- 全ホストから Pandocker プロファイルを読み込むよう設定 ---
$includeLine = ". `"$PandockerProfile`""
$commentLine = "# Load Pandocker profile" # 追加するコメント行
$loadBlock = "`n$commentLine`n$includeLine`n" # 追加するブロック全体

$profileContentRaw = ""
if (Test-Path -Path $PROFILE -PathType Leaf) {
    $profileContentRaw = Get-Content -Path $PROFILE -Raw -ErrorAction SilentlyContinue
    if ($null -eq $profileContentRaw) {
        $profileContentRaw = ""
    }
}

# .Contains() メソッドで読み込みブロックが既に含まれているかを確認します
if (-not ($profileContentRaw.Contains($loadBlock))) {
    Write-Host "現行プロファイルから Pandocker プロファイルを読み込むよう設定: $PROFILE"
    # Add-Content だと意図しない改行が入る場合があるので Out-File で追記
    "$profileContentRaw$loadBlock" | Out-File -FilePath $PROFILE -Encoding UTF8 -Append
} else {
    Write-Host "既に Pandocker プロファイルが読み込み設定済み。"
}

# --- 現在のセッションにプロファイルを即時読み込み ---
# ★注意: このスクリプト自体をドットソース(. .\install.ps1)で実行する必要があります
Write-Host "現在のセッションに関数を読み込んでいます..."
try {
    # . $PROFILE ではなく、作成した専用プロファイル($PandockerProfile)を読み込む
    . $PandockerProfile
} catch {
    Write-Host "エラー: プロファイルの読み込みに失敗しました。" -ForegroundColor Red
    Write-Host $_
}

# --- 完了メッセージ ---
Write-Host "`n セットアップ完了！" -ForegroundColor Green
Write-Host "このスクリプトをドットソース(`. .`$MyInvocation.MyCommand.Name)で実行した場合、pdx コマンドがこのまま使用できます：" -ForegroundColor Cyan
Write-Host "    pdx setup"
Write-Host "    pdx new <ProjectName>"
Write-Host "    pdx build <ProjectName> [options]"
Write-Host "`nPowerShellを再起動した場合も pdx コマンドは利用可能です。" -ForegroundColor Cyan
Write-Host "※ pdx関数はローカル '$PandockerProfile' に登録されました。" -ForegroundColor DarkGray
