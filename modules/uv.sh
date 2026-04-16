#!/usr/bin/env bash

install_uv() {
  info "Installing uv..."
  if has_cmd uv; then
    ok "uv already installed."
    return 0
  fi

  curl -LsSf https://astral.sh/uv/install.sh | sh
  ok "uv module installed."
}
