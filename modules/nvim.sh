#!/usr/bin/env bash

install_nvim() {
  local root="$1"
  info "Installing Neovim setup..."

  has_cmd nvim || install_pkg nvim || true
  has_cmd rsync || install_pkg rsync || true

  mkdir -p "$HOME/.config/nvim"
  if has_cmd rsync; then
    rsync -a --delete "$root/assets/nvim/" "$HOME/.config/nvim/"
  else
    backup_if_exists "$HOME/.config/nvim"
    rm -rf "$HOME/.config/nvim"
    cp -a "$root/assets/nvim" "$HOME/.config/nvim"
  fi

  if has_cmd nvim; then
    nvim --headless "+Lazy! sync" +qa || true
  else
    warn "nvim binary not found; config copied only."
  fi

  ok "nvim module installed."
}
