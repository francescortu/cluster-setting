#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v python3 >/dev/null 2>&1; then
  echo "[ERROR] python3 is required for the interactive installer." >&2
  exit 1
fi

exec python3 "$ROOT_DIR/installer.py" "$@"
