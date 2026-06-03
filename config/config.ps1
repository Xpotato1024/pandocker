# config/config.ps1
# ==============================================
# Pandocker Project Configuration
# ==============================================
#
# このファイルで、プロジェクト全体の設定を管理します。
# ご自身の環境に合わせて値を変更してください。

$PandockerConfig = @{
    # Pandocker を動かす WSL ディストリビューション名
    WslDistro = "Ubuntu"

    # WSL内に作成される作業ディレクトリ名
    WslWorkDirName = "pandocker_work"

    # Docker の接続先
    # 既定は WSL 内の dockerd を使う。Docker Desktop を使う場合は desktop に変更する。
    DockerBackend = "wsl-dockerd"

    # WSL への同期方法
    SyncMode = "mirror-repo"
}
