#!/usr/bin/env bash

install_ai() {
  local root="$1"
  info "Installing AI CLI tools..."

  if ! has_cmd npm; then
    install_pkg npm || install_pkg nodejs || true
  fi

  has_cmd copilot || install_npm_global "@github/copilot" || true
  has_cmd codex || install_npm_global "@openai/codex" || true
  has_cmd gemini || install_npm_global "@google/gemini-cli" || true
  has_cmd claude || install_npm_global "@anthropic-ai/claude-code" || true

  mkdir -p "$HOME/.copilot" "$HOME/.codex" "$HOME/.gemini" "$HOME/.claude"

  if [[ ! -f "$HOME/.copilot/config.json" ]]; then
    copy_file "$root/assets/ai-templates/copilot-config.json" "$HOME/.copilot/config.json"
  fi
  if [[ ! -f "$HOME/.codex/config.toml" ]]; then
    copy_file "$root/assets/ai-templates/codex-config.toml" "$HOME/.codex/config.toml"
  fi
  if [[ ! -f "$HOME/.gemini/settings.json" ]]; then
    copy_file "$root/assets/ai-templates/gemini-settings.json" "$HOME/.gemini/settings.json"
  fi
  if [[ ! -f "$HOME/.claude/settings.json" ]]; then
    copy_file "$root/assets/ai-templates/claude-settings.json" "$HOME/.claude/settings.json"
  fi

  info "Run login once per tool on the new cluster:"
  info "  copilot auth login"
  info "  codex login"
  info "  gemini"
  info "  claude login"
  ok "AI module installed."
}
