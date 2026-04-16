#!/usr/bin/env bash

install_tmux() {
  local root="$1"
  info "Installing tmux setup..."

  has_cmd tmux || install_pkg tmux || true
  has_cmd tmux || warn "tmux binary not found; config will still be installed."

  if [[ ! -d "$HOME/.tmux/.git" ]]; then
    backup_if_exists "$HOME/.tmux"
    rm -rf "$HOME/.tmux"
    git clone https://github.com/gpakosz/.tmux.git "$HOME/.tmux"
    mark_managed_path tmux "$HOME/.tmux"
  fi

  ln -sfn "$HOME/.tmux/.tmux.conf" "$HOME/.tmux.conf"
  mark_managed_path tmux "$HOME/.tmux.conf"
  copy_file "$root/assets/tmux/tmux.conf.local" "$HOME/.tmux.conf.local"
  mark_managed_path tmux "$HOME/.tmux.conf.local"

  mkdir -p "$HOME/.tmux/themes"
  if [[ ! -d "$HOME/.tmux/themes/dracula.omt/.git" ]]; then
    rm -rf "$HOME/.tmux/themes/dracula.omt"
    git clone https://github.com/dracula/tmux.git "$HOME/.tmux/themes/dracula.omt"
  else
    git -C "$HOME/.tmux/themes/dracula.omt" pull --ff-only || true
  fi
  ln -sfn "$HOME/.tmux/themes/dracula.omt/dracula.conf" "$HOME/.tmux/themes/dracula.conf"
  mark_managed_path tmux "$HOME/.tmux/themes/dracula.conf"

  ok "tmux module installed."
}
