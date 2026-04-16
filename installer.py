#!/usr/bin/env python3
from __future__ import annotations

import argparse
import subprocess
import sys
import termios
import tty
from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class Module:
    key: str
    label: str
    description: str


MODULES = [
    Module("shell", "Shell", "PS1/prompt, history, aliases, shared shell config"),
    Module("fzf", "fzf", "fzf binary + keybindings/completion"),
    Module("tmux", "tmux", "oh-my-tmux + dracula theme + your local config"),
    Module("nvim", "Neovim", "NvChad-based config from this repo"),
    Module("ai", "AI CLIs", "Copilot/Codex/Gemini/Claude + safe config templates"),
    Module("gh", "GitHub CLI", "Install gh (GitHub CLI)"),
    Module("code", "VS Code CLI", "Install code CLI (for code tunnel)"),
    Module("poetry", "Poetry", "Install Poetry"),
    Module("uv", "uv", "Install uv"),
    Module("miniconda", "Miniconda", "Install Miniconda"),
]
MODULE_KEYS = {m.key for m in MODULES}

RESET = "\033[0m"
DIM = "\033[2m"
BOLD = "\033[1m"
CYAN = "\033[96m"
GREEN = "\033[92m"
YELLOW = "\033[93m"
RED = "\033[91m"


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Interactive cluster setting installer")
    p.add_argument("--all", action="store_true", help="Install all modules")
    p.add_argument("--modules", help="Comma-separated module list")
    p.add_argument("--list", action="store_true", help="Show available modules")
    p.add_argument("--non-interactive", action="store_true", help="Fail if no modules are selected")
    return p.parse_args()


def print_modules() -> None:
    print("Available modules:")
    for m in MODULES:
        print(f"  {m.key:<10} - {m.description}")


def clear_screen() -> None:
    print("\033[2J\033[H", end="")


def read_key() -> str:
    fd = sys.stdin.fileno()
    old = termios.tcgetattr(fd)
    try:
        tty.setraw(fd)
        ch = sys.stdin.read(1)
        if ch == "\x1b":
            ch2 = sys.stdin.read(1)
            ch3 = sys.stdin.read(1)
            if ch2 == "[" and ch3 in ("A", "B", "C", "D"):
                return {"A": "up", "B": "down", "C": "right", "D": "left"}[ch3]
            return "esc"
        if ch in ("\r", "\n"):
            return "enter"
        if ch == " ":
            return "space"
        return ch
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old)


def render_menu(cursor: int, selected: set[str]) -> None:
    clear_screen()
    print(f"{BOLD}{CYAN}cluster-setting installer{RESET}")
    print(f"{DIM}Use ↑/↓ to move, space to toggle, a to toggle all, enter to install, q to quit.{RESET}\n")
    for i, m in enumerate(MODULES):
        focused = i == cursor
        mark = "[x]" if m.key in selected else "[ ]"
        pointer = "❯" if focused else " "
        color = CYAN if focused else ""
        end = RESET if focused else ""
        print(f"{color}{pointer} {mark} {m.key:<10} {m.description}{end}")
    print(f"\n{YELLOW}Selected: {', '.join(sorted(selected)) if selected else 'none'}{RESET}")


def interactive_select() -> list[str]:
    if not sys.stdin.isatty():
        raise RuntimeError("Interactive mode requires a TTY. Use --modules or --all.")

    cursor = 0
    selected: set[str] = set()
    while True:
        render_menu(cursor, selected)
        key = read_key()
        if key in ("q", "\x03"):  # q or ctrl-c
            raise RuntimeError("Installation cancelled.")
        if key == "up":
            cursor = (cursor - 1) % len(MODULES)
        elif key == "down":
            cursor = (cursor + 1) % len(MODULES)
        elif key == "space":
            k = MODULES[cursor].key
            if k in selected:
                selected.remove(k)
            else:
                selected.add(k)
        elif key == "a":
            if len(selected) == len(MODULES):
                selected.clear()
            else:
                selected = set(m.key for m in MODULES)
        elif key == "enter":
            if not selected:
                print(f"{RED}Select at least one module.{RESET}")
                continue
            clear_screen()
            return [m.key for m in MODULES if m.key in selected]


def run_module(root: Path, key: str, idx: int, total: int) -> None:
    print(f"\n{BOLD}{GREEN}[{idx}/{total}] Installing {key}...{RESET}", flush=True)
    print(f"{DIM}{'-' * 72}{RESET}", flush=True)
    subprocess.run(["bash", str(root / "modules" / "run.sh"), key, str(root)], check=True)
    print(f"{DIM}{'-' * 72}{RESET}", flush=True)


def ask_yes_no(prompt: str, default_no: bool = True) -> bool:
    suffix = " [y/N]: " if default_no else " [Y/n]: "
    while True:
        ans = input(prompt + suffix).strip().lower()
        if not ans:
            return not default_no
        if ans in ("y", "yes"):
            return True
        if ans in ("n", "no"):
            return False
        print("Please answer y or n.")


def parse_module_list(raw: str) -> list[str]:
    out: list[str] = []
    for part in raw.split(","):
        k = part.strip()
        if not k:
            continue
        if k not in MODULE_KEYS:
            raise RuntimeError(f"Invalid module: {k}")
        if k not in out:
            out.append(k)
    return out


def main() -> int:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(line_buffering=True)
    if hasattr(sys.stderr, "reconfigure"):
        sys.stderr.reconfigure(line_buffering=True)

    args = parse_args()
    root = Path(__file__).resolve().parent

    if args.list:
        print_modules()
        return 0

    selected: list[str] = []
    interactive_mode = not (args.all or args.modules or args.non_interactive)
    if args.all:
        selected = [m.key for m in MODULES]
    elif args.modules:
        selected = parse_module_list(args.modules)
    elif args.non_interactive:
        raise RuntimeError("No modules selected in non-interactive mode.")
    else:
        selected = interactive_select()

    print(f"{BOLD}Modules:{RESET} {', '.join(selected)}")
    for i, key in enumerate(selected, start=1):
        run_module(root, key, i, len(selected))

    if "ai" in selected and interactive_mode and sys.stdin.isatty():
        if ask_yes_no("Run AI logins now in this same terminal?"):
            run_module(root, "ai-login", len(selected) + 1, len(selected) + 1)

    print(f"\n{GREEN}Done. Re-run install.sh anytime to add more modules.{RESET}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except RuntimeError as e:
        print(f"{RED}[ERROR]{RESET} {e}", file=sys.stderr)
        raise SystemExit(1)
