#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="${2:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
MODULE="${1:-}"

source "$ROOT_DIR/modules/common.sh"
source "$ROOT_DIR/modules/bash.sh"
source "$ROOT_DIR/modules/fzf.sh"
source "$ROOT_DIR/modules/tmux.sh"
source "$ROOT_DIR/modules/nvim.sh"
source "$ROOT_DIR/modules/ai.sh"
source "$ROOT_DIR/modules/gh.sh"
source "$ROOT_DIR/modules/poetry.sh"
source "$ROOT_DIR/modules/uv.sh"
source "$ROOT_DIR/modules/miniconda.sh"

case "$MODULE" in
  shell) install_shell "$ROOT_DIR" ;;
  fzf) install_fzf "$ROOT_DIR" ;;
  tmux) install_tmux "$ROOT_DIR" ;;
  nvim) install_nvim "$ROOT_DIR" ;;
  ai) install_ai "$ROOT_DIR" ;;
  ai-login) login_ai_tools ;;
  gh) install_gh ;;
  poetry) install_poetry "$ROOT_DIR" ;;
  uv) install_uv "$ROOT_DIR" ;;
  miniconda) install_miniconda "$ROOT_DIR" ;;
  *) die "Unknown module: $MODULE" ;;
esac
