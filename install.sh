#!/bin/bash

# Pandocker-X Bash/Zsh インストーラー
# (プロジェクトのルートディレクトリから実行されることを想定)
#
# 1. pdx 関数を定義します
# 2. .bashrc または .zshrc に pdx 関数を登録します
# 3. 現在のセッションに pdx 関数を自動ロードします

echo "Pandocker-X Bash/Zsh セットアップを開始します..."

# --- 1. ルートパスの特定 ---
# スクリプト自身の場所 (PDX_ROOT) を特定
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
PDX_ROOT="$SCRIPT_DIR"
SCRIPTS_DIR="$PDX_ROOT/scripts"

# new.sh などが scripts/ に存在するか確認
if [ ! -d "$SCRIPTS_DIR" ]; then
    echo "エラー: 'scripts' フォルダが見つかりません。" >&2
    echo "install.sh はプロジェクトのルートディレクトリに配置してください。" >&2
    exit 1
fi

echo "Pandocker-X の scripts ディレクトリ: $SCRIPTS_DIR"

# --- 2. pdx 関数の定義 ---
# (install.ps1 の $pdxContent に相当)
# ヒアドキュメント内の変数はエスケープ(\$)し、SCRIPTS_DIRのみ即時展開する
PDX_FUNCTION=$(cat <<EOF

# --- Pandocker-X (Bash/Zsh) pdx function ---
function pdx() {
    # install.sh が特定した scripts ディレクトリを直接使用
    local SCRIPT_DIR="$SCRIPTS_DIR"
    local COMMAND=\$1
    
    # 最初の引数(COMMAND)を shift して取り除き、残りを \$@ (引数配列) にする
    shift
    
    case \$COMMAND in
        "new")
            bash "\${SCRIPT_DIR}/new.sh" "\$@"
            ;;
        "setup")
            bash "\${SCRIPT_DIR}/setup.sh" "\$@"
            ;;
        "build")
            bash "\${SCRIPT_DIR}/build.sh" "\$@"
            ;;
        *)
            echo "Usage: pdx [new|build|setup] <args>"
            ;;
    esac
}
# --- End Pandocker-X ---
EOF
)

# --- 3. プロファイルファイルの特定 ---
PROFILE_FILE=""
if [ -n "$ZSH_VERSION" ]; then
   PROFILE_FILE="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
   PROFILE_FILE="$HOME/.bashrc"
elif [ -f "$HOME/.zshrc" ]; then
    PROFILE_FILE="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
    PROFILE_FILE="$HOME/.bashrc"
elif [ -f "$HOME/.bash_profile" ]; then
    PROFILE_FILE="$HOME/.bash_profile"
else
    echo "エラー: .zshrc または .bashrc が見つかりません。" >&2
    exit 1
fi

echo "pdx 関数を $PROFILE_FILE に登録します..."

# --- 4. 既存の定義を削除 (冪等性の確保) ---
# macOS/BSD 互換性のために -i.bak を使用
sed -i.bak '/# --- Pandocker-X (Bash\/Zsh) pdx function ---/,/# --- End Pandocker-X ---/d' "$PROFILE_FILE"
rm -f "$PROFILE_FILE.bak" # バックアップファイルを削除

# --- 5. プロファイルファイルへの書き込み ---
echo "$PDX_FUNCTION" >> "$PROFILE_FILE"

# --- 6. 現在のセッションに関数を即時読み込み ---
echo "現在のセッションに関数を読み込んでいます..."
if eval "$PDX_FUNCTION"; then
    : # eval が成功した場合は何もしない
else
    echo "エラー: 関数の読み込みに失敗しました。" >&2
fi

echo "登録完了！"
echo "pdx コマンドがこのまま使用できます："
echo
echo "    pdx setup"
echo "    pdx new <ProjectName>"
echo "    pdx build <ProjectName> [options]"
echo
echo "※ pdx関数は $PROFILE_FILE に登録されました。"