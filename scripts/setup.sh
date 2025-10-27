#!/bin/bash

# setup.sh (Bash版)
#
# 1. 前提条件 (docker, docker compose) をチェック
# 2. Docker イメージをビルド
# 3. TeX Live のフォントフォーマット (fmtutil-sys) を生成

echo "=== Pandocker-X 初回セットアップ開始 (Linux/Mac) ==="

# --- 0. パスと前提条件のチェック ---
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
PDX_ROOT=$(dirname "$SCRIPT_DIR")

# docker コマンドのチェック
if ! command -v docker &> /dev/null; then
    echo "エラー: docker コマンドが見つかりません。Docker Desktop または Docker Engine をインストールしてください。" >&2
    exit 1
fi

# docker compose コマンドのチェック (v2 or v1)
DOCKER_COMPOSE_CMD=""
if docker compose version &> /dev/null; then
    DOCKER_COMPOSE_CMD="docker compose"
elif docker-compose version &> /dev/null; then
    DOCKER_COMPOSE_CMD="docker-compose"
else
    echo "エラー: docker compose (v2) または docker-compose (v1) が見つかりません。" >&2
    exit 1
fi

echo "Docker Compose コマンド: $DOCKER_COMPOSE_CMD"
cd "$PDX_ROOT" || exit 1 # プロジェクトルートに移動して docker compose を実行

# --- 1. Docker イメージのビルド ---
echo "[1/3] Docker イメージをビルド中..."
if ! $DOCKER_COMPOSE_CMD build; then
    echo "エラー: Dockerイメージのビルドに失敗しました。" >&2
    exit 1
fi

# --- 2. キャッシュボリュームの確認と作成 ---
# (setup.ps1 と同じロジック)
echo "[2/3] Docker ボリュームを準備中..."
if ! $DOCKER_COMPOSE_CMD up -d --no-deps pandoc > /dev/null && $DOCKER_COMPOSE_CMD stop pandoc > /dev/null; then
    echo "エラー: ボリュームの準備に失敗しました。" >&2
    exit 1
fi
echo "ボリュームの準備ができました。"

# --- 3. TeX Liveフォーマットファイルの生成 ---
echo "[3/3] TeX Liveフォーマットを生成中... (数分かかる場合があります)"
if ! $DOCKER_COMPOSE_CMD run --rm --entrypoint bash pandoc -c 'fmtutil-sys --all'; then
    echo "エラー: TeX Liveフォーマットの生成に失敗しました。" >&2
    exit 1
fi
echo "TeX Liveフォーマットの生成が完了しました。"

echo "=== セットアップ完了 ==="
echo "プロジェクトの準備が整いました。'pdx new <project>' や 'pdx build <target>' を使用してください。"
