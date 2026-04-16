#!/usr/bin/env bash

install_code() {
  info "Installing VS Code CLI (code)..."

  if has_cmd code; then
    ok "code already installed."
    return 0
  fi

  local arch url tmpd exe
  case "$(uname -m)" in
    x86_64|amd64) arch="x64" ;;
    aarch64|arm64) arch="arm64" ;;
    *) warn "Unsupported architecture for VS Code CLI auto-install: $(uname -m)"; return 1 ;;
  esac

  url="https://update.code.visualstudio.com/latest/cli-linux-${arch}/stable"
  tmpd="$(mktemp -d)"
  curl -fL --progress-bar "$url" -o "$tmpd/code_cli.tar.gz"
  tar -xzf "$tmpd/code_cli.tar.gz" -C "$tmpd"
  exe="$(find "$tmpd" -type f -name code | head -n1 || true)"
  if [[ -z "$exe" ]]; then
    rm -rf "$tmpd"
    die "Could not find 'code' binary in downloaded archive."
  fi

  mkdir -p "$HOME/.local/bin"
  cp "$exe" "$HOME/.local/bin/code"
  chmod +x "$HOME/.local/bin/code"
  mark_managed_path code "$HOME/.local/bin/code"
  rm -rf "$tmpd"

  ok "VS Code CLI installed to $HOME/.local/bin/code"
  info "You can now run: code tunnel"
}
