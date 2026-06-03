#!/bin/bash

set -euo pipefail

# Legacy build script kept for reference.
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
PDX_ROOT=$(dirname "$SCRIPT_DIR")
CONFIG_PATH="$PDX_ROOT/config"
PROJECTS_BASE_DIR="$PDX_ROOT/projects"

command -v docker >/dev/null 2>&1 || {
    echo "Error: docker command not found." >&2
    exit 1
}

if docker compose version >/dev/null 2>&1; then
    DOCKER_COMPOSE_CMD=(docker compose)
elif command -v docker-compose >/dev/null 2>&1; then
    DOCKER_COMPOSE_CMD=(docker-compose)
else
    echo "Error: neither docker compose (v2) nor docker-compose (v1) was found." >&2
    exit 1
fi

command -v jq >/dev/null 2>&1 || {
    echo "Error: jq command not found." >&2
    exit 1
}

REPORT_NAME=""
INPUT_FILES=()
ALL_FLAG=false
LOG_FLAG=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        -All)
            ALL_FLAG=true
            shift
            ;;
        -Log)
            LOG_FLAG=true
            shift
            ;;
        -*)
            echo "Error: unknown option $1" >&2
            exit 1
            ;;
        *)
            if [ -z "$REPORT_NAME" ]; then
                REPORT_NAME="$1"
            else
                INPUT_FILES+=("$1")
            fi
            shift
            ;;
    esac
done

if [ -z "$REPORT_NAME" ]; then
    echo "Error: report name is required." >&2
    echo "Usage: pdx build <ProjectName> [options]" >&2
    exit 1
fi

SRC_DIR="$PROJECTS_BASE_DIR/$REPORT_NAME/src"
PANDOC_ARGS_JSON_PATH="$CONFIG_PATH/pandoc-args.json"

if [ ! -f "$PANDOC_ARGS_JSON_PATH" ]; then
    echo "Error: pandoc-args.json not found." >&2
    exit 1
fi

mapfile -t PANDOC_COMMON_ARGS < <(jq -r '.pdf_args[]' "$PANDOC_ARGS_JSON_PATH")

TIMESTAMP=$(date +"%Y-%m-%dT%H-%M-%S")
LOG_FILE_NAME=""
if [ "$LOG_FLAG" = true ]; then
    mkdir -p "$PDX_ROOT/log"
    LOG_FILE_NAME="pandoc_${REPORT_NAME}_${TIMESTAMP}.log"
    echo "Log output enabled: log/$LOG_FILE_NAME"
fi

if [ "$ALL_FLAG" = true ]; then
    mapfile -t INPUT_FILES < <(find "$SRC_DIR" -type f -name '*.md' | sort)
    for i in "${!INPUT_FILES[@]}"; do
        INPUT_FILES[$i]="${INPUT_FILES[$i]#"$SRC_DIR"/}"
    done
elif [ ${#INPUT_FILES[@]} -eq 0 ]; then
    INPUT_FILES=("report.md")
fi

if [ ${#INPUT_FILES[@]} -eq 0 ]; then
    echo "No Markdown files to build." >&2
    exit 0
fi

shell_quote() {
    local value=$1
    printf "'%s'" "${value//\'/\'\"\'\"\'}"
}

cd "$PDX_ROOT"

for INPUT_FILE in "${INPUT_FILES[@]}"; do
    INPUT_PATH_ON_HOST="$SRC_DIR/$INPUT_FILE"
    if [ ! -f "$INPUT_PATH_ON_HOST" ]; then
        echo "Warning: $INPUT_PATH_ON_HOST does not exist, skipping." >&2
        continue
    fi

    RELATIVE_DIR=$(dirname "$INPUT_FILE")
    if [ "$RELATIVE_DIR" = "." ]; then
        RELATIVE_DIR=""
    fi
    RELATIVE_PDF="${INPUT_FILE%.md}.pdf"
    CONTAINER_WORK_DIR="/data/projects/$REPORT_NAME/src"
    DEFAULTS="../defaults.yml"
    OUTPUT_FILE="../output/$RELATIVE_PDF"

    mkdir -p "$PROJECTS_BASE_DIR/$REPORT_NAME/output/$RELATIVE_DIR"

    PANDOC_ARGS=("${PANDOC_COMMON_ARGS[@]}")
    PANDOC_ARGS+=(--defaults "$DEFAULTS" "$INPUT_FILE" -o "$OUTPUT_FILE")
    if [ "$LOG_FLAG" = true ]; then
        PANDOC_ARGS+=(--verbose)
    fi

    PANDOC_CMD="pandoc"
    for arg in "${PANDOC_ARGS[@]}"; do
        PANDOC_CMD+=" $(shell_quote "$arg")"
    done

    INNER_COMMAND="cd $(shell_quote "$CONTAINER_WORK_DIR") && mkdir -p $(shell_quote "$(dirname "$OUTPUT_FILE")") && $PANDOC_CMD"
    if [ "$LOG_FLAG" = true ]; then
        WSL_LOG_PATH="$PDX_ROOT/log/$LOG_FILE_NAME"
        echo "--- Build started at $TIMESTAMP ($INPUT_FILE) ---" >> "$WSL_LOG_PATH"
        START_TIME=$(date +%s)
        "${DOCKER_COMPOSE_CMD[@]}" run --rm --entrypoint bash pandoc -lc "$INNER_COMMAND" >> "$WSL_LOG_PATH" 2>&1
        BUILD_EC=$?
        END_TIME=$(date +%s)
    else
        START_TIME=$(date +%s)
        "${DOCKER_COMPOSE_CMD[@]}" run --rm --entrypoint bash pandoc -lc "$INNER_COMMAND"
        BUILD_EC=$?
        END_TIME=$(date +%s)
    fi

    ELAPSED_TIME=$((END_TIME - START_TIME))
    OUTPUT_PDF_ON_HOST="$PROJECTS_BASE_DIR/$REPORT_NAME/output/$RELATIVE_PDF"

    if [ $BUILD_EC -eq 0 ] && [ -f "$OUTPUT_PDF_ON_HOST" ]; then
        echo "$INPUT_FILE -> $RELATIVE_PDF generated in ${ELAPSED_TIME}s"
    else
        echo "$INPUT_FILE PDF generation failed." >&2
        if [ "$LOG_FLAG" = true ]; then
            echo "See log/$LOG_FILE_NAME for details." >&2
        fi
    fi
done

if [ "$LOG_FLAG" = true ]; then
    echo "Log saved to: log/$LOG_FILE_NAME"
fi
