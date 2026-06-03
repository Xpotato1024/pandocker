#!/bin/bash

set -euo pipefail

# Legacy installer kept for reference.
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
PDX_ROOT=$(dirname "$SCRIPT_DIR")

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

cd "$PDX_ROOT"

echo "[1/3] Building the Docker image..."
"${DOCKER_COMPOSE_CMD[@]}" build

echo "[2/3] Preparing the Docker volume..."
"${DOCKER_COMPOSE_CMD[@]}" up -d --no-deps pandoc >/dev/null
"${DOCKER_COMPOSE_CMD[@]}" stop pandoc >/dev/null

echo "[3/3] Generating TeX Live formats..."
"${DOCKER_COMPOSE_CMD[@]}" run --rm --entrypoint bash pandoc -lc 'fmtutil-sys --all'

echo "=== Setup complete ==="
echo "pdx setup / pdx new / pdx build are available."
