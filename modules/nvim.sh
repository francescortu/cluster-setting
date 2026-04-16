#!/usr/bin/env bash

install_nvim_user() {
  local arch url tmpd
  case "$(uname -m)" in
    x86_64|amd64)
      url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
      ;;
    *)
      warn "Unsupported architecture for nvim auto-install: $(uname -m)"
      return 1
      ;;
  esac

  tmpd="$(mktemp -d)"
  curl -fsSL "$url" -o "$tmpd/nvim.tgz"
  tar -xzf "$tmpd/nvim.tgz" -C "$tmpd"
  mkdir -p "$HOME/.local/opt" "$HOME/.local/bin"
  rm -rf "$HOME/.local/opt/nvim"
  mv "$tmpd"/nvim-linux-* "$HOME/.local/opt/nvim"
  ln -sfn "$HOME/.local/opt/nvim/bin/nvim" "$HOME/.local/bin/nvim"
  mark_managed_path nvim "$HOME/.local/opt/nvim"
  mark_managed_path nvim "$HOME/.local/bin/nvim"
  rm -rf "$tmpd"
}

install_nvim() {
  local root="$1"
  info "Installing Neovim setup..."

  has_cmd nvim || install_nvim_user || true

  backup_if_exists "$HOME/.config/nvim"
  mkdir -p "$HOME/.config/nvim"
  if has_cmd rsync; then rsync -a --delete "$root/assets/nvim/" "$HOME/.config/nvim/"
  else rm -rf "$HOME/.config/nvim"; cp -a "$root/assets/nvim" "$HOME/.config/nvim"; fi
  mark_managed_path nvim "$HOME/.config/nvim"

  if has_cmd nvim; then
    nvim --headless "+Lazy! sync" +qa || true
  else
    warn "nvim binary not found; config copied only."
  fi

  ok "nvim module installed."
}
