#!/usr/bin/env bash

install_gh_user() {
  local arch ver url tmpd
  case "$(uname -m)" in
    x86_64|amd64) arch="amd64" ;;
    aarch64|arm64) arch="arm64" ;;
    *) warn "Unsupported architecture for gh auto-install: $(uname -m)"; return 1 ;;
  esac

  ver="$(curl -fsSL https://api.github.com/repos/cli/cli/releases/latest | sed -n 's/.*"tag_name": *"v\([0-9.]*\)".*/\1/p' | head -n1)"
  [[ -n "$ver" ]] || { warn "Failed to resolve latest gh version"; return 1; }
  url="https://github.com/cli/cli/releases/download/v${ver}/gh_${ver}_linux_${arch}.tar.gz"

  tmpd="$(mktemp -d)"
  curl -fsSL "$url" -o "$tmpd/gh.tgz"
  tar -xzf "$tmpd/gh.tgz" -C "$tmpd"
  mkdir -p "$HOME/.local/bin"
  cp "$tmpd"/gh_*_linux_"$arch"/bin/gh "$HOME/.local/bin/gh"
  chmod +x "$HOME/.local/bin/gh"
  mark_managed_path gh "$HOME/.local/bin/gh"
  rm -rf "$tmpd"
}

install_gh() {
  info "Installing GitHub CLI (gh)..."

  if has_cmd gh; then
    ok "gh already installed."
    return 0
  fi

  install_gh_user || true

  if has_cmd gh; then
    ok "gh module installed."
  else
    warn "Could not auto-install gh in user-space."
    warn "Install manually: https://github.com/cli/cli/blob/trunk/docs/install_linux.md"
  fi
}
