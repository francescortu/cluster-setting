#!/usr/bin/env bash

install_shell() {
  local root="$1"
  info "Installing shell settings..."
  copy_file "$root/assets/bash/bashrc.cluster" "$HOME/.bashrc.cluster"
  ensure_line_in_file "$HOME/.bashrc" '[ -f "$HOME/.bashrc.cluster" ] && source "$HOME/.bashrc.cluster"'
  ok "Shell module installed."
}
