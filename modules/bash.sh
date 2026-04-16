#!/usr/bin/env bash

install_shell() {
  local root="$1"
  local line='[ -f "$HOME/.bashrc.cluster" ] && source "$HOME/.bashrc.cluster"'
  info "Installing shell settings..."
  copy_file "$root/assets/bash/bashrc.cluster" "$HOME/.bashrc.cluster"
  mark_managed_path shell "$HOME/.bashrc.cluster"
  if [[ -f "$HOME/.bashrc" ]] && ! grep -Fqx "$line" "$HOME/.bashrc"; then
    backup_if_exists "$HOME/.bashrc"
  fi
  ensure_line_in_file "$HOME/.bashrc" "$line"
  ok "Shell module installed."
}
