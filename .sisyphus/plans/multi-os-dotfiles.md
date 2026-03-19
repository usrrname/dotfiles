# Multi-OS Dotfiles Plan

## Overview

Restructure dotfiles into OS-specific branches so users only clone files relevant to their operating system. Uses git branches per OS with a shared `main` branch containing common configs.

## Branch Structure

| Branch | Purpose |
|--------|---------|
| `main` | Base - shared/common files only |
| `ubuntu-main` | `main` + Ubuntu/Linux zsh configs |
| `macos-main` | `main` + macOS zsh, zprofile, iterm2, cursor |
| `pi-main` | `main` + Debian/Pi specific |

## Directory Structure

```
dotfiles/
├── common/              # Shared (stowed on ALL OS)
│   ├── bash/
│   ├── git/
│   ├── nvim/
│   ├── docker/
│   ├── gh/
│   ├── ssh/
│   ├── direnv/
│   ├── vim/
│   ├── op/              # 1Password CLI
│   ├── opencode/
│   └── oh-my-zsh/
│
├── linux/               # Ubuntu/Linux (stowed on Linux + Pi)
│   ├── zsh/
│   │   ├── .zshenv        # Linux: cargo env, no defaults
│   │   ├── .zshrc         # Sources .zshrc.linux
│   │   ├── .zshrc.linux   # Linux: fnm, uv, nvim /opt
│   │   └── .aliases       # Linux aliases
│   └── zprofile/
│       ├── .zprofile        # Shared: direnv, pyenv
│       └── .zprofile.linux  # Placeholder
│
├── macos/               # macOS only (stowed on macOS only)
│   ├── zsh/
│   │   ├── .zshenv.osx     # macOS: defaults commands
│   │   ├── .zshrc          # Sources .zshrc.osx
│   │   ├── .zshrc.osx      # macOS: Homebrew, pnpm, mysql, SSH_AUTH_SOCK
│   │   └── .aliases.osx
│   ├── zprofile/
│   │   └── .zprofile.osx   # macOS: brew shellenv, OrbStack
│   ├── iterm2/
│   ├── cursor/
│   ├── orbstack/
│   ├── act/
│   └── yarn/
│
└── pi/                  # Raspberry Pi only (stowed on Pi only)
    └── (Pi-specific configs)
```

## File Transformations

### Current → New File Mapping

| Current Location | New Location | Notes |
|-----------------|--------------|-------|
| `zsh/.zshrc` | `common/zsh/.zshrc` | Shared core, sources OS-specific at end |
| `zsh/.osx_aliasrc` | `macos/zsh/.aliases.osx` | macOS aliases |
| `zsh/.zshenv` | Split: `common/zsh/.zshenv` + `macos/zsh/.zshenv.osx` | Remove defaults from shared |
| `zprofile/.zprofile` | `linux/zprofile/.zprofile` + `macos/zprofile/.zprofile` | Shared direnv/pyenv |
| `git/.gitconfig` | `common/git/.gitconfig` | Shared user/aliases |
| `git/.gitconfig` + GPG | `macos/git/.gitconfig.osx` + `linux/git/.gitconfig.linux` | 1Password SSH signing per OS |

## Installation

**Ubuntu/Linux:**
```bash
git clone https://github.com/usrrname/dotfiles.git
cd dotfiles
git checkout ubuntu-main
stow -v common linux
```

**macOS:**
```bash
git clone https://github.com/usrrname/dotfiles.git
cd dotfiles
git checkout macos-main
stow -v common macos
```

**Raspberry Pi:**
```bash
git clone https://github.com/usrrname/dotfiles.git
cd dotfiles
git checkout pi-main
stow -v common linux pi
```

## Key Changes by File

### `zsh/.zshrc`
- Sources Oh-My-Zsh, plugins (git, 1password, gh, zsh-autosuggestions, zsh-autocomplete, direnv)
- Sources OS-specific file at end: `source ~/.zshrc.$OSTYPE` (or `.osx`/`.linux`)

### `zsh/.zshenv`
- Shared: `. "$HOME/.cargo/env"`, `export PATH="$HOME/.local/bin:$PATH"`
- **macOS**: Additional `defaults write` commands in `.zshenv.osx`

### `zsh/.zshrc.linux`
- fnm: `eval "$(fnm env --use-on-cd)"`
- uv: `eval "$(uv generate-shell-completion zsh)"`
- nvim: `export PATH="/opt/nvim/bin:$PATH"`

### `zsh/.zshrc.osx`
- Homebrew paths
- pnpm: `export PNPM_HOME="$HOME/Library/pnpm"`
- mysql paths
- SSH_AUTH_SOCK: `~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock`
- fnm

### `git/.gitconfig`
- Shared: user, color, core editor, aliases
- **macOS**: 1Password SSH signing via `.gitconfig.osx`
- **Linux**: 1Password SSH signing via `.gitconfig.linux` (uses Linux op-ssh-sign path)

### `oh-my-zsh/`
- Moved from `macos/oh-my-zsh` to `common/oh-my-zsh`
- Installed on both Linux and macOS

### `op/` (1Password CLI)
- Moved from `macos/1password` to `common/op`
- Available on both Linux and macOS

## Sensitive Data Protection

Existing `.gitignore` patterns remain unchanged:
- `.env*` - environment variables
- `*.pem`, `*.key`, `*.pub` - SSH keys
- `id_rsa*` - RSA keys
- `.DS_Store` - macOS metadata

## Files to Update

1. Create `common/`, `linux/`, `macos/`, `pi/` directories
2. Move and split existing files per mapping above
3. Update `.stow-local-ignore` patterns for new structure
4. Update `stow-dotfiles.sh` or deprecate (users stow manually per branch)
5. Update `AGENTS.md` directory structure documentation
6. Update `README.md` with new installation instructions
7. Create branches: `ubuntu-main`, `macos-main`, `pi-main` from `main`

## Implementation Order

1. Create directory structure
2. Move `bash/`, `git/`, `nvim/`, `docker/`, `gh/`, `ssh/`, `direnv/`, `vim/`, `op/`, `opencode/` to `common/`
3. Refactor `zsh/` into `common/zsh/` and `macos/zsh/`, `linux/zsh/`
4. Refactor `zprofile/` into `linux/zprofile/` and `macos/zprofile/`
5. Create OS-specific git configs for 1Password SSH signing
6. Update `.stow-local-ignore`
7. Update documentation (`AGENTS.md`, `README.md`)
8. Create OS branches from `main`
9. Test each branch with stow
