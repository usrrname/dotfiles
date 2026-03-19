# Dotfiles

Managed with stow. Supports macOS, Raspberry Pi (Debian), and NixOS.

## Repository Structure

```
.dotfiles/
├── common/          # Shared (stowed on ALL OS)
│   ├── bash/         # Bash shell configuration
│   ├── git/          # Git configuration (shared user/aliases)
│   ├── nvim/         # Neovim/LazyVim configuration
│   ├── ssh/          # SSH configuration
│   ├── docker/       # Docker configuration
│   ├── gh/           # GitHub CLI configuration
│   ├── direnv/       # direnv configuration
│   ├── vim/          # Vim configuration
│   ├── op/           # 1Password CLI configuration
│   ├── opencode/     # OpenCode configuration
│   ├── zsh/          # Shared zsh config (sources OS-specific at end)
│   └── zprofile/     # Shared zprofile (direnv, pyenv)
│
├── linux/            # Ubuntu/Linux (stowed on Linux + Pi)
│   ├── zsh/          # Linux: fnm, uv, nvim path, .zshrc.linux
│   └── zprofile/     # Linux-specific zprofile
│
├── macos/            # macOS only (stowed on macOS only)
│   ├── zsh/          # macOS: Homebrew, pnpm, mysql, SSH_AUTH_SOCK
│   ├── zprofile/     # macOS: brew shellenv, OrbStack
│   ├── iterm2/       # iTerm2 configuration
│   ├── act/          # nektos/act configuration
│   ├── husky/        # Git hooks
│   ├── yarn/         # Yarn configuration
│   └── verdaccio/    # Local npm registry
│
├── pi/               # Raspberry Pi only (stowed on Pi only)
│   └── (Pi-specific configs)
│
├── scripts/          # Setup and maintenance scripts
├── test/             # Bats tests
└── nix/              # NixOS configuration (not auto-stowed)
```

## OS-Specific Branches

| Branch | Purpose |
|--------|---------|
| `main` | Base - shared/common files only |
| `ubuntu-main` | `main` + Ubuntu/Linux zsh configs |
| `macos-main` | `main` + macOS zsh, zprofile, iterm2, cursor |
| `pi-main` | `main` + Debian/Pi specific |

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

If AGENTS.md does not exist, refer to:
.cursor/rules/*
.rules/*
