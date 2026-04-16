#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$ROOT_DIR/modules/common.sh"
source "$ROOT_DIR/modules/bash.sh"
source "$ROOT_DIR/modules/fzf.sh"
source "$ROOT_DIR/modules/tmux.sh"
source "$ROOT_DIR/modules/nvim.sh"
source "$ROOT_DIR/modules/ai.sh"
source "$ROOT_DIR/modules/poetry.sh"
source "$ROOT_DIR/modules/uv.sh"
source "$ROOT_DIR/modules/miniconda.sh"

ALL_MODULES=("shell" "fzf" "tmux" "nvim" "ai" "poetry" "uv" "miniconda")

print_usage() {
  cat <<'EOF'
Usage: ./install.sh [OPTIONS]

Options:
  --all                    Install all modules
  --modules a,b,c          Install selected modules (names from --list)
  --list                   Show available modules
  --non-interactive        Fail if no selection flags are provided
  -h, --help               Show this help
EOF
}

print_modules() {
  cat <<'EOF'
Available modules:
  shell      - PS1/prompt, history, aliases, shared shell config
  fzf        - fzf binary + keybindings/completion
  tmux       - tmux + oh-my-tmux + dracula theme + your local config
  nvim       - Neovim config (NvChad-based files from this repo)
  ai         - Copilot/Codex/Gemini/Claude CLIs + safe config templates
  poetry     - Poetry installer
  uv         - uv installer
  miniconda  - Miniconda installer
EOF
}

is_valid_module() {
  local m="$1"
  local x
  for x in "${ALL_MODULES[@]}"; do
    [[ "$x" == "$m" ]] && return 0
  done
  return 1
}

interactive_select_modules() {
  info "Interactive selection (re-runnable installer)."
  print_modules
  echo
  echo "Select modules by number or name (space/comma separated)."
  echo "Example: 1 3 ai or all"
  echo "1) shell  2) fzf  3) tmux  4) nvim  5) ai  6) poetry  7) uv  8) miniconda"
  read -r -p "Selection: " raw
  raw="${raw//,/ }"

  if [[ -z "$raw" ]]; then
    die "No selection provided."
  fi

  local out=()
  local tok
  for tok in $raw; do
    case "$tok" in
      all) out=("${ALL_MODULES[@]}"); break ;;
      1) out+=("shell") ;;
      2) out+=("fzf") ;;
      3) out+=("tmux") ;;
      4) out+=("nvim") ;;
      5) out+=("ai") ;;
      6) out+=("poetry") ;;
      7) out+=("uv") ;;
      8) out+=("miniconda") ;;
      *)
        if is_valid_module "$tok"; then
          out+=("$tok")
        else
          die "Invalid module: $tok"
        fi
        ;;
    esac
  done

  uniq_list "${out[@]}"
}

run_module() {
  local m="$1"
  case "$m" in
    shell) install_shell "$ROOT_DIR" ;;
    fzf) install_fzf "$ROOT_DIR" ;;
    tmux) install_tmux "$ROOT_DIR" ;;
    nvim) install_nvim "$ROOT_DIR" ;;
    ai) install_ai "$ROOT_DIR" ;;
    poetry) install_poetry "$ROOT_DIR" ;;
    uv) install_uv "$ROOT_DIR" ;;
    miniconda) install_miniconda "$ROOT_DIR" ;;
    *) die "Unknown module: $m" ;;
  esac
}

NON_INTERACTIVE=0
SELECTED=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --all)
      SELECTED=("${ALL_MODULES[@]}")
      shift
      ;;
    --modules)
      [[ $# -lt 2 ]] && die "--modules requires a value"
      IFS=',' read -r -a mod_arr <<< "$2"
      for m in "${mod_arr[@]}"; do
        [[ -z "$m" ]] && continue
        is_valid_module "$m" || die "Invalid module in --modules: $m"
        SELECTED+=("$m")
      done
      shift 2
      ;;
    --list)
      print_modules
      exit 0
      ;;
    --non-interactive)
      NON_INTERACTIVE=1
      shift
      ;;
    -h|--help)
      print_usage
      exit 0
      ;;
    *)
      die "Unknown argument: $1"
      ;;
  esac
done

if [[ ${#SELECTED[@]} -eq 0 ]]; then
  if [[ "$NON_INTERACTIVE" -eq 1 ]]; then
    die "No modules selected in non-interactive mode."
  fi
  mapfile -t SELECTED < <(interactive_select_modules)
else
  mapfile -t SELECTED < <(uniq_list "${SELECTED[@]}")
fi

info "Modules: ${SELECTED[*]}"
for m in "${SELECTED[@]}"; do
  run_module "$m"
done

ok "Done. Re-run install.sh anytime to add missing modules."
