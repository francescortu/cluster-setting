#!/usr/bin/env bash

info() { printf "[INFO] %s\n" "$*"; }
warn() { printf "[WARN] %s\n" "$*" >&2; }
ok() { printf "[OK] %s\n" "$*"; }
die() { printf "[ERROR] %s\n" "$*" >&2; exit 1; }

has_cmd() { command -v "$1" >/dev/null 2>&1; }

uniq_list() {
  printf "%s\n" "$@" | awk '!seen[$0]++'
}

backup_if_exists() {
  local target="$1"
  if [[ -e "$target" || -L "$target" ]]; then
    local ts
    ts="$(date +%Y%m%d_%H%M%S)"
    local backup="${target}.bak.${ts}"
    cp -a "$target" "$backup"
    info "Backup: $target -> $backup"
  fi
}

ensure_parent_dir() {
  mkdir -p "$(dirname "$1")"
}

copy_file() {
  local src="$1"
  local dst="$2"
  ensure_parent_dir "$dst"
  if [[ -f "$dst" ]] && cmp -s "$src" "$dst"; then
    info "Unchanged: $dst"
    return 0
  fi
  [[ -e "$dst" || -L "$dst" ]] && backup_if_exists "$dst"
  cp "$src" "$dst"
  ok "Installed: $dst"
}

ensure_line_in_file() {
  local file="$1"
  local line="$2"
  touch "$file"
  grep -Fqx "$line" "$file" || {
    printf "\n%s\n" "$line" >> "$file"
    ok "Updated: $file"
  }
}

detect_pkg_manager() {
  if has_cmd apt-get; then echo apt
  elif has_cmd dnf; then echo dnf
  elif has_cmd yum; then echo yum
  elif has_cmd pacman; then echo pacman
  elif has_cmd zypper; then echo zypper
  else echo none
  fi
}

try_sudo() {
  if has_cmd sudo; then
    sudo "$@"
  else
    "$@"
  fi
}

install_pkg() {
  local pkg="$1"
  if has_cmd "$pkg"; then
    info "Already installed: $pkg"
    return 0
  fi

  local pm
  pm="$(detect_pkg_manager)"
  case "$pm" in
    apt) try_sudo apt-get update -y >/dev/null 2>&1 || true; try_sudo apt-get install -y "$pkg" ;;
    dnf) try_sudo dnf install -y "$pkg" ;;
    yum) try_sudo yum install -y "$pkg" ;;
    pacman) try_sudo pacman -Sy --noconfirm "$pkg" ;;
    zypper) try_sudo zypper --non-interactive install "$pkg" ;;
    none) warn "No supported package manager found for $pkg"; return 1 ;;
  esac
}

install_npm_global() {
  local pkg="$1"
  has_cmd npm || { warn "npm not found, cannot install $pkg"; return 1; }
  npm install -g "$pkg"
}
