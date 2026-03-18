# Dotfiles

Managed with stow. Supports macOS, Raspberry Pi (Debian), and NixOS.

## Repository Structure
```
.dotfiles/
├── bash/          # Bash shell configuration
├── zsh/           # Zsh shell configuration  
├── nvim/          # Neovim/LazyVim configuration
├── git/           # Git configuration
├── ssh/           # SSH configuration
├── docker/        # Docker configuration
├── gh/            # GitHub CLI configuration
├── scripts/       # Setup and maintenance scripts
├── test/          # Bats tests
├── nix/           # NixOS configuration (not auto-stowed)
└── op/            # 1Password CLI configuration
```

If AGENTS.md does not exist, refer to:
.cursor/rules/*
.rules/*
