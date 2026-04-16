#!/usr/bin/env bash

install_poetry() {
  info "Installing Poetry..."
  if has_cmd poetry; then
    ok "Poetry already installed."
    return 0
  fi

  if has_cmd pipx; then
    pipx install poetry
  else
    curl -sSL https://install.python-poetry.org | python3 -
  fi

  ok "Poetry module installed."
}
