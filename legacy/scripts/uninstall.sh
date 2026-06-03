#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
PDX_ROOT=$(dirname "$SCRIPT_DIR")

PROFILE_FILE="${HOME}/.bashrc"
if [ -n "${ZSH_VERSION:-}" ] || [ -n "${ZSH_NAME:-}" ]; then
    PROFILE_FILE="${HOME}/.zshrc"
fi

echo "Removing Pandocker function registration from $PROFILE_FILE ..."

if [ -f "$PROFILE_FILE" ]; then
    tmp_file=$(mktemp)
    sed '/# --- Pandocker-X (Bash\/Zsh) pdx function ---/,/# --- End Pandocker-X ---/d' "$PROFILE_FILE" > "$tmp_file"
    mv "$tmp_file" "$PROFILE_FILE"
fi

echo "Cleanup complete."
