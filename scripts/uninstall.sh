#!/bin/bash

# Pandocker-X Bash/Zsh アンインストーラー

echo "Pandocker-X のクリーンアップを開始します..."

# --- 1. プロファイルファイルの特定 ---
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

echo "$PROFILE_FILE から pdx 関数を削除しています..."

# --- 2. 既存の定義を削除 (sed) ---
# 開始マーカーから終了マーカーまでを削除
if sed -i.bak '/# --- Pandocker-X (Bash\/Zsh) pdx function ---/,/# --- End Pandocker-X ---/d' "$PROFILE_FILE"; then
    rm -f "$PROFILE_FILE.bak" # バックアップファイルを削除
    echo "✅ $PROFILE_FILE から pdx 関数を削除しました。"
else
    echo "ℹ️ $PROFILE_FILE に pdx 関数の定義が見つからないか、sed コマンドに失敗しました。"
fi

# --- 3. 現在のセッションから関数を削除 ---
unset -f pdx
echo "✅ 現在のセッションから pdx 関数を削除しました。"

echo "クリーンアップ完了。"
echo "ターミナルを再起動すると、変更が完全に適用されます。"