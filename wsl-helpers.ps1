# ==============================================
# WSL Helper Functions
# ==============================================

function Test-WslPrerequisites {
    param (
        [Parameter(Mandatory=$true)]
        [string]$WslDistro
    )

    # 1. wsl.exe の存在チェック
    if (-not (Get-Command wsl.exe -ErrorAction SilentlyContinue)) {
        Write-Host "エラー: wsl.exe が見つかりません。" -ForegroundColor Red
        Write-Host "このスクリプトは WSL 2 と Docker Desktop (WSL 2 Backend) が必要です。" -ForegroundColor Red
        exit 1 # スクリプトをエラーで終了
    }

    # 2. 指定されたWSLディストリビューションの存在チェック
    $distros = wsl.exe -l --quiet
    if (-not ($distros -contains $WslDistro)) {
        Write-Host "エラー: 指定されたWSLディストリビューション '$WslDistro' が見つかりません。" -ForegroundColor Red
        Write-Host "インストール済みのディストリビューション:"
        wsl.exe -l
        Write-Host "スクリプト内の`$WslDistro`を修正するか、`wsl --install -d $WslDistro`でインストールしてください。" -ForegroundColor Red
        exit 1 # スクリプトをエラーで終了
    }

    # すべてのチェックをパスした場合
    Write-Host "WSLの前提条件チェックをクリアしました。" -ForegroundColor Green
}