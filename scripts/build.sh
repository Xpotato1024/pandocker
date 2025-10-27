#!/bin/bash

# build.sh (Bash版)
#
# 1. 前提条件 (docker, docker compose, jq) をチェック
# 2. 引数を解析 (-All, -Log, ReportName, InputFiles)
# 3. config/pandoc-args.json を jq で読み込み
# 4. Pandoc コマンドを構築し、docker compose run で実行

# --- 0. パスと前提条件のチェック ---
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
PDX_ROOT=$(dirname "$SCRIPT_DIR")
CONFIG_PATH="$PDX_ROOT/config"
PROJECTS_BASE_DIR="$PDX_ROOT/projects"

# docker コマンドのチェック
if ! command -v docker &> /dev/null; then
    echo "エラー: docker コマンドが見つかりません。" >&2
    exit 1
fi

# docker compose コマンドのチェック
DOCKER_COMPOSE_CMD=""
if docker compose version &> /dev/null; then
    DOCKER_COMPOSE_CMD="docker compose"
elif docker-compose version &> /dev/null; then
    DOCKER_COMPOSE_CMD="docker-compose"
else
    echo "エラー: docker compose (v2) または docker-compose (v1) が見つかりません。" >&2
    exit 1
fi

# jq コマンドのチェック
if ! command -v jq &> /dev/null; then
    echo "エラー: jq コマンドが見つかりません。JSON解析のためにインストールしてください。" >&2
    echo "(例: sudo apt-get install jq / brew install jq)" >&2
    exit 1
fi

# --- 1. 引数の解析 ---
# (install.ps1 の pdx build 振り分けロジックを Bash で再現)
REPORT_NAME=""
INPUT_FILES=() # Bash配列
ALL_FLAG=false
LOG_FLAG=false

# "$@" で引数をループ処理
while [[ $# -gt 0 ]]; do
    case "$1" in
        -All)
            ALL_FLAG=true
            shift # 引数を消費
            ;;
        -Log)
            LOG_FLAG=true
            shift # 引数を消費
            ;;
        -*)
            echo "警告: 不明なオプションです: $1" >&2
            shift
            ;;
        *)
            # スイッチ(-)で始まらない引数
            if [ -z "$REPORT_NAME" ]; then
                REPORT_NAME="$1"
            else
                INPUT_FILES+=("$1") # 配列に追加
            fi
            shift
            ;;
    esac
done

# --- 2. ビルド対象ファイルの決定 ---
if [ -z "$REPORT_NAME" ]; then
    echo "エラー: ビルド対象のプロジェクト名が指定されていません。" >&2
    echo "Usage: pdx build <ProjectName> [options]" >&2
    exit 1
fi

SRC_DIR="$PROJECTS_BASE_DIR/$REPORT_NAME/src"

if [ "$ALL_FLAG" = true ]; then
    echo "All オプションが指定されました: src 内のすべての .md ファイルをビルドします。"
    # シェルのワイルドカード展開を配列に格納
    INPUT_FILES=("$SRC_DIR"/*.md)
    # 該当なしの場合のケア (ファイル名をそのまま渡さない)
    if [ ! -e "${INPUT_FILES[0]}" ]; then
        INPUT_FILES=()
    fi
elif [ ${#INPUT_FILES[@]} -eq 0 ]; then
    # デフォルトのファイル
    INPUT_FILES=("$SRC_DIR/report.md")
else
    # 指定されたファイル名をフルパスに変換
    TEMP_FILES=()
    for file in "${INPUT_FILES[@]}"; do
        TEMP_FILES+=("$SRC_DIR/$file")
    done
    INPUT_FILES=("${TEMP_FILES[@]}")
fi

if [ ${#INPUT_FILES[@]} -eq 0 ]; then
    echo "警告: ビルド対象の .md ファイルが見つかりません。" >&2
    exit 0
fi

# --- 3. Pandoc引数設定JSONを読み込む ---
PANDOC_ARGS_JSON_PATH="$CONFIG_PATH/pandoc-args.json"
if [ ! -f "$PANDOC_ARGS_JSON_PATH" ]; then
    echo "エラー: Pandoc引数設定ファイル(pandoc-args.json)が見つかりません。" >&2
    exit 1
fi

# jq を使って .pdf_args 配列を Bash 配列に読み込む
# (read -r -a: 配列に読み込み, < <(jq...): プロセス置換)
# jq の @sh は 'arg' のようにクォートするため、tr -d "'" で削除
read -r -a PANDOC_COMMON_ARGS < <(jq -r '.pdf_args | @sh' "$PANDOC_ARGS_JSON_PATH" | tr -d "'")

# --- 4. ログ準備 ---
TIMESTAMP=$(date +"%Y-%m-%dT%H-%M-%S")
LOG_FILE_NAME=""
if [ "$LOG_FLAG" = true ]; then
    mkdir -p "$PDX_ROOT/log"
    LOG_FILE_NAME="pandoc_${REPORT_NAME}_${TIMESTAMP}.log"
    echo "ログ出力有効: log/$LOG_FILE_NAME"
fi

# --- 5. 各ファイルを順次ビルド ---
# (WSL版と異なり、ファイル同期は不要。Dockerがホストパスを直接マウント)

cd "$PDX_ROOT" || exit 1 # docker compose のためにルートに移動

for INPUT_PATH_ON_HOST in "${INPUT_FILES[@]}"; do
    
    # basename でファイル名だけ取得
    INPUT_FILE=$(basename "$INPUT_PATH_ON_HOST")

    if [ ! -f "$INPUT_PATH_ON_HOST" ]; then
        echo "警告: $INPUT_FILE が存在しません。スキップします。" >&2
        echo "   ( $INPUT_PATH_ON_HOST )"
        continue
    fi

    FILE_BASE="${INPUT_FILE%.*}" # 拡張子 .md を削除
    
    # コンテナ内のパス定義 (docker-compose.yml の volumes: .:/data に依存)
    CONTAINER_WORK_DIR="/data/projects/$REPORT_NAME/src"
    DEFAULTS="../defaults.yml"
    OUTPUT_FILE="../output/${REPORT_NAME}_${FILE_BASE}.pdf"

    # Pandoc 引数配列を構築
    PANDOC_ARGS=()
    PANDOC_ARGS+=("${PANDOC_COMMON_ARGS[@]}") # JSONからの共通引数
    PANDOC_ARGS+=(--defaults "$DEFAULTS")
    PANDOC_ARGS+=("$INPUT_FILE") # コンテナのWORKDIR基準
    PANDOC_ARGS+=(-o "$OUTPUT_FILE")

    if [ "$LOG_FLAG" = true ]; then
        PANDOC_ARGS+=(--verbose)
    fi

    # Docker Compose コマンドを構築
    # (cd $CONTAINER_WORK_DIR && pandoc ...args)
    # ${PANDOC_ARGS[*]} ですべての配列要素をスペース区切りで展開
    BASH_COMMAND="cd $CONTAINER_WORK_DIR && pandoc ${PANDOC_ARGS[*]}"

    # ログ出力
    if [ "$LOG_FLAG" = true ]; then
        echo "[2/3] Pandocビルドを実行中 ($INPUT_FILE) (ログあり)..."
        # ログファイルに追記
        echo "--- Build started at $TIMESTAMP ($INPUT_FILE) ---" >> "$PDX_ROOT/log/$LOG_FILE_NAME"
        
        # 実行とログ追記 (2>&1 で標準エラー出力もリダイレクト)
        START_TIME=$(date +%s)
        $DOCKER_COMPOSE_CMD run --rm --entrypoint bash pandoc -c "$BASH_COMMAND" >> "$PDX_ROOT/log/$LOG_FILE_NAME" 2>&1
        BUILD_EC=$? # 終了コード
        END_TIME=$(date +%s)
    else
        echo "[2/3] Pandocビルドを実行中 ($INPUT_FILE)..."
        START_TIME=$(date +%s)
        $DOCKER_COMPOSE_CMD run --rm --entrypoint bash pandoc -c "$BASH_COMMAND"
        BUILD_EC=$? # 終了コード
        END_TIME=$(date +%s)
    fi

    ELAPSED_TIME=$((END_TIME - START_TIME))

    # PDFがホストに生成されたか確認
    OUTPUT_PDF_ON_HOST="$PROJECTS_BASE_DIR/$REPORT_NAME/output/${REPORT_NAME}_${FILE_BASE}.pdf"
    if [ $BUILD_EC -eq 0 ] && [ -f "$OUTPUT_PDF_ON_HOST" ]; then
        echo "$INPUT_FILE → $(basename "$OUTPUT_PDF_ON_HOST") 生成完了 (${ELAPSED_TIME}秒)"
    else
        echo "$INPUT_FILE のPDF生成に失敗しました。"
        if [ "$LOG_FLAG" = true ]; then
            echo "詳細は log/$LOG_FILE_NAME を確認してください。"
        fi
    fi
done

if [ "$LOG_FLAG" = true ]; then
    echo "ログを保存しました: log/$LOG_FILE_NAME"
fi