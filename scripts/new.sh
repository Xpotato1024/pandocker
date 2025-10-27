#!/bin/bash

# new.sh (Bash版)
# 新しいレポートプロジェクトのひな形を作成する
#
# 使い方:
#   pdx new "新しいレポート名"

# --- 0. 引数のチェック ---
if [ -z "$1" ]; then
    echo "エラー: レポート名を指定してください。" >&2
    echo "Usage: pdx new <ReportName>" >&2
    exit 1
fi

REPORT_NAME="$1"

# --- 1. スクリプトのメイン処理 ---
# スクリプト自身の場所から PdxRoot を特定
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
PDX_ROOT=$(dirname "$SCRIPT_DIR")
PROJECTS_BASE_DIR="$PDX_ROOT/projects"
CSL_PATH_FROM_SRC="../../../csl/ieee-with-url.csl" # (new.ps1 と同一)

# 'projects' ディレクトリがなければ作成する
mkdir -p "$PROJECTS_BASE_DIR"

# 作成対象のレポートディレクトリのフルパス
TARGET_REPORT_DIR="$PROJECTS_BASE_DIR/$REPORT_NAME"

# 2. すでに同名のディレクトリが存在しないかチェック
if [ -d "$TARGET_REPORT_DIR" ]; then
    echo "エラー: 'projects/$REPORT_NAME' という名前のディレクトリは既に存在します。" >&2
    exit 1
fi

# 3. メインのレポートディレクトリとサブディレクトリを作成
echo "レポートディレクトリ 'projects/$REPORT_NAME' を作成しています..."
mkdir -p "$TARGET_REPORT_DIR/src"
mkdir -p "$TARGET_REPORT_DIR/images"
mkdir -p "$TARGET_REPORT_DIR/bib"
mkdir -p "$TARGET_REPORT_DIR/output"

# --- 追加ファイルの自動生成 ---

# 6. 空の参考文献ファイル (references.bib) を作成
echo " - 参考文献ファイル 'references.bib' を作成中..."
touch "$TARGET_REPORT_DIR/bib/references.bib"

# 7. マークダウンのテンプレートファイル (report.md) を作成
REPORT_MD_PATH="$TARGET_REPORT_DIR/src/report.md"
CURRENT_DATE=$(date +"%Y-%m-%d")

echo " - MDテンプレート 'report.md' を作成中..."

# cat と ヒアドキュメント(EOF) を使ってファイルに書き込む
cat <<EOF > "$REPORT_MD_PATH"
---
title: "Title"
author: "name"
date: "$CURRENT_DATE"
bibliography: ../bib/references.bib
csl: $CSL_PATH_FROM_SRC
---

# section
EOF

# 8. プロジェクトルートにある defaults.yml をコピー
SOURCE_DEFAULTS_PATH="$PDX_ROOT/defaults.yml"
TARGET_DEFAULTS_PATH="$TARGET_REPORT_DIR/defaults.yml"

if [ -f "$SOURCE_DEFAULTS_PATH" ]; then
    echo " - 設定ファイル 'defaults.yml' をコピー中..."
    cp "$SOURCE_DEFAULTS_PATH" "$TARGET_DEFAULTS_PATH"
else
    echo "警告: プロジェクトルートに defaults.yml が見つかりません。" >&2
fi

# 9. 完了メッセージ
echo
echo "レポート 'projects/$REPORT_NAME' の準備が完了しました！"
echo "projects/$REPORT_NAME/src/report.md を編集して作業を開始してください。"