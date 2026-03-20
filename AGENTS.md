# Dotfiles

Managed with stow. Supports macOS, Linux (Debian/Ubuntu), Raspberry Pi, and NixOS.

## Repository Structure

```
.dotfiles/
├── common/          # Shared (stowed on ALL OS)
│   ├── bash/         # Bash shell configuration
│   ├── git/          # Git ignore (shared)
│   ├── nvim/         # Neovim/LazyVim configuration
│   ├── ssh/          # SSH configuration
│   ├── docker/       # Docker configuration
│   ├── gh/           # GitHub CLI configuration
│   ├── direnv/       # direnv configuration
│   ├── mc/           # Midnight Commander configuration
│   ├── vim/          # Vim configuration
│   ├── op/           # 1Password CLI configuration
│   └── opencode/     # OpenCode configuration
│
├── linux/            # Linux (stowed on Debian/Ubuntu + Pi)
│   ├── git/          # Linux gitconfig (op-ssh-sign path)
│   ├── zsh/          # Linux zsh (fnm, uv, nvim path)
│   └── zprofile/     # Linux zprofile
│
├── macos/            # macOS only
│   ├── git/          # macOS gitconfig (1Password SSH signing)
│   ├── zsh/          # macOS zsh (Homebrew, pnpm, SSH_AUTH_SOCK)
│   ├── zprofile/     # macOS zprofile
│   ├── iterm2/       # iTerm2 configuration
│   ├── act/          # nektos/act configuration
│   ├── husky/        # Git hooks
│   └── verdaccio/    # Local npm registry
│
├── bin/
│   └── init.sh       # Auto-detect OS, sparse-checkout, stow
│
├── scripts/          # Setup scripts
├── test/             # Bats tests
└── nix/              # NixOS configuration (copied to /etc/nixos on NixOS)
```

## Setup

```bash
git clone https://github.com/usrrname/dotfiles.git
cd dotfiles
./bin/init.sh
```

The init script:
1. Detects your OS (macOS, Linux, or NixOS)
2. Configures git sparse-checkout to only checkout relevant files
3. **macOS/Linux**: Runs stow to create symlinks
4. **NixOS**: Copies configuration and runs `nixos-rebuild switch`

## Manual Stow

```bash
# Stow all (auto-detects OS)
./stow-dotfiles.sh

# Stow without adopting
./stow-dotfiles.sh ""
```

## Adding a ~/.config Package to Dotfiles

Stow maps `common/[pkg]/.config/[pkg]/` → `~/.config/[pkg]/`.

### Steps to add a new ~/.config package (e.g., `mc`):

```bash
# 1. Create directory structure
mkdir -p common/mc/.config/mc

# 2. Copy existing config
cp -r ~/.config/mc/* common/mc/.config/mc/

# 3. Remove original (stow will recreate as symlink)
rm -rf ~/.config/mc

# 4. Add to COMMON array in stow-dotfiles.sh
# COMMON=(... mc ...)

# 5. Stow
./stow-dotfiles.sh
```

### For packages needing exclusion (symlinks cause issues):

Add to `.stow-local-ignore` (one per line):
- `op` — 1Password CLI refuses to follow symlinks for config files

## Notes

- `nix/` is not stowed - managed via NixOS configuration
- OS-specific files (zsh, zprofile, git) replace common versions
- Use `--adopt` flag to overwrite existing files

If AGENTS.md does not exist, refer to:
.cursor/rules/*
.rules/*
