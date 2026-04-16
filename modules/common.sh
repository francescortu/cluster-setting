#!/usr/bin/env bash

info() { printf "[INFO] %s\n" "$*"; }
warn() { printf "[WARN] %s\n" "$*" >&2; }
ok() { printf "[OK] %s\n" "$*"; }
die() { printf "[ERROR] %s\n" "$*" >&2; exit 1; }

has_cmd() { command -v "$1" >/dev/null 2>&1; }
STATE_HOME="${HOME}/.local/share/cluster-setting"

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

restore_latest_backup() {
  local target="$1"
  local latest
  latest="$(ls -1dt "${target}.bak."* 2>/dev/null | head -n1 || true)"
  [[ -n "$latest" ]] || return 1
  rm -rf "$target"
  mv "$latest" "$target"
  ok "Restored backup: $target"
}

remove_exact_line_from_file() {
  local file="$1"
  local line="$2"
  [[ -f "$file" ]] || return 0
  grep -Fqx "$line" "$file" || return 0
  backup_if_exists "$file"
  awk -v line="$line" '$0 != line { print }' "$file" > "${file}.tmp.cluster-setting"
  mv "${file}.tmp.cluster-setting" "$file"
  ok "Updated: $file"
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

install_pkg() {
  local pkg="$1"
  if has_cmd "$pkg"; then
    info "Already installed: $pkg"
    return 0
  fi
  if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
    warn "Skipping system package install for '$pkg' (no sudo mode)."
    return 1
  fi

  local pm
  pm="$(detect_pkg_manager)"
  case "$pm" in
    apt) apt-get update -y >/dev/null 2>&1 || true; apt-get install -y "$pkg" ;;
    dnf) dnf install -y "$pkg" ;;
    yum) yum install -y "$pkg" ;;
    pacman) pacman -Sy --noconfirm "$pkg" ;;
    zypper) zypper --non-interactive install "$pkg" ;;
    none) warn "No supported package manager found for $pkg"; return 1 ;;
  esac
}

install_npm_global() {
  local pkg="$1"
  has_cmd npm || { warn "npm not found, cannot install $pkg"; return 1; }
  npm install -g "$pkg" || npm install -g --prefix "$HOME/.local" "$pkg"
}

mark_managed_path() {
  local module="$1"
  local path="$2"
  mkdir -p "$STATE_HOME/managed"
  touch "$STATE_HOME/managed/${module}.paths"
  grep -Fqx "$path" "$STATE_HOME/managed/${module}.paths" || echo "$path" >> "$STATE_HOME/managed/${module}.paths"
}

remove_managed_paths() {
  local module="$1"
  local f="$STATE_HOME/managed/${module}.paths"
  [[ -f "$f" ]] || return 0
  while IFS= read -r p; do
    [[ -z "$p" ]] && continue
    if [[ -e "$p" || -L "$p" ]]; then
      rm -rf "$p"
      info "Removed managed path: $p"
    fi
  done < "$f"
}
