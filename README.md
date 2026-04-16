# cluster-setting

Portable personal cluster setup with an idempotent module installer.

## What this repo installs

- **shell**: PS1 prompt, history sharing, aliases, fzf styling (`~/.bashrc.cluster`)
- **fzf**: binary + keybindings/completions
- **tmux**: `oh-my-tmux`, your `.tmux.conf.local`, dracula theme
- **nvim**: your NvChad-based Neovim config
- **ai**: Copilot, Codex, Gemini, Claude CLIs + safe config templates
- **poetry**: Poetry installer
- **uv**: uv installer
- **miniconda**: Miniconda installer

## Quick start (new cluster)

```bash
git clone https://github.com/francescortu/cluster-setting.git
cd cluster-setting
chmod +x install.sh
./install.sh
```

## Non-interactive examples

```bash
./install.sh --list
./install.sh --modules shell,fzf,tmux,nvim,ai
./install.sh --all
./install.sh --modules poetry,uv,miniconda
```

## Re-runnable by design

Run `install.sh` again anytime; it installs only what is missing and backups replaced files as `*.bak.TIMESTAMP`.

## Security notes

- No auth tokens/credentials are stored in this repo.
- For AI CLIs on a new cluster, login once after install:

```bash
copilot auth login
codex login
gemini
claude login
```

- Put machine-specific secrets in `~/.bashrc.private` (automatically sourced by `~/.bashrc.cluster`).

## Suggested extra things to copy

- `~/.gitconfig` and `~/.ssh/config` (without private keys in repo)
- `~/.config/gh/hosts.yml` only if you accept token migration risk
- common package list (`pip freeze`, `npm -g ls --depth=0`)
- VS Code settings/extensions list if you use remote code-server
