# ==============================================
# Pandocker Project Configuration
# ==============================================
#
# このファイルで、プロジェクト全体の設定を管理します。
# ご自身の環境に合わせて値を変更してください。

$PandockerConfig = @{
    # Docker Desktopと連携しているWSLディストリビューション名
    WslDistro = "Ubuntu"

    # WSL内に作成される作業ディレクトリ名
    WslWorkDirName = "pandocker_work"
}