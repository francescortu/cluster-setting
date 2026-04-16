#!/usr/bin/env bash

install_gh() {
  info "Installing GitHub CLI (gh)..."

  if has_cmd gh; then
    ok "gh already installed."
    return 0
  fi

  if ! install_pkg gh; then
    warn "Package 'gh' failed, trying 'github-cli'..."
    install_pkg github-cli || true
  fi

  if has_cmd gh; then
    ok "gh module installed."
  else
    warn "Could not auto-install gh with system package manager."
    warn "Install manually: https://github.com/cli/cli/blob/trunk/docs/install_linux.md"
  fi
}
