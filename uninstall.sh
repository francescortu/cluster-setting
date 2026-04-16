#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$ROOT_DIR/modules/common.sh"

line='[ -f "$HOME/.bashrc.cluster" ] && source "$HOME/.bashrc.cluster"'

info "Uninstalling cluster-setting changes..."

# shell
remove_exact_line_from_file "$HOME/.bashrc" "$line" || true
restore_latest_backup "$HOME/.bashrc.cluster" || remove_managed_paths shell || true
restore_latest_backup "$HOME/.bashrc" || true

# tmux
restore_latest_backup "$HOME/.tmux.conf.local" || true
restore_latest_backup "$HOME/.tmux.conf" || true
restore_latest_backup "$HOME/.tmux" || true
remove_managed_paths tmux || true

# nvim
restore_latest_backup "$HOME/.config/nvim" || true
remove_managed_paths nvim || true

# fzf
restore_latest_backup "$HOME/.fzf" || true
remove_managed_paths fzf || true

# gh / miniconda managed user-space installs
remove_managed_paths gh || true
remove_managed_paths miniconda || true

ok "Uninstall completed. Some tools installed outside this repo (npm/pipx/etc.) are left untouched."
