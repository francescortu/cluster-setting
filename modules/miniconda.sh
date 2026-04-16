#!/usr/bin/env bash

install_miniconda() {
  info "Installing Miniconda..."
  if has_cmd conda || [[ -x "$HOME/miniconda3/bin/conda" ]]; then
    ok "Miniconda/conda already installed."
    return 0
  fi

  local installer
  installer="$(mktemp)"
  curl -fsSL https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o "$installer"
  bash "$installer" -b -p "$HOME/miniconda3"
  mark_managed_path miniconda "$HOME/miniconda3"
  rm -f "$installer"
  ok "Miniconda module installed at $HOME/miniconda3."
}
