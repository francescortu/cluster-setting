#!/usr/bin/env bash

install_fzf() {
  info "Installing fzf..."

  if ! has_cmd fzf; then
    install_pkg fzf || true
  fi

  if ! has_cmd fzf; then
    if [[ ! -d "$HOME/.fzf/.git" ]]; then
      git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
      mark_managed_path fzf "$HOME/.fzf"
    fi
    "$HOME/.fzf/install" --key-bindings --completion --no-update-rc --no-zsh --no-fish
  else
    if [[ -d "$HOME/.fzf" ]]; then
      "$HOME/.fzf/install" --key-bindings --completion --no-update-rc --no-zsh --no-fish || true
    fi
  fi

  ok "fzf module installed."
}
