# Setting Up Dotfiles on Debian Trixie & Raspberry Pi 4

Quick guide for setting up this dotfiles repository on Debian Trixie running on Raspberry Pi 4.

## Prerequisites

1. Clone the repository:
   ```bash
   cd ~
   git clone <your-repo-url> .dotfiles
   cd .dotfiles
   ```

2. Install `stow` (for symlinking dotfiles):
   ```bash
   sudo apt update
   sudo apt install -y stow
   ```

## Setup Steps

### 1. Install Packages

Run the Linux setup script to install all required packages:

```bash
# Preview what will be installed (dry run)
DRY_RUN=true ./scripts/setup-linux.sh

# Check current package status
./scripts/setup-linux.sh check

# List all packages
./scripts/setup-linux.sh list

# Run the installation
./scripts/setup-linux.sh
```

The script automatically:
- Detects Debian Trixie and architecture
- Installs base packages (git, curl, neovim, build tools, etc.)
- Installs special packages (nvm, pyenv, mise, devbox, tailscale, rust, etc.)
- Installs development tools (GitHub CLI, 1Password CLI, ripgrep, etc.)

### 2. Symlink Dotfiles

Use `stow` to create symlinks for your dotfiles:

**If you have existing dotfiles** (use `--adopt` to preserve them):
```bash
# Preview changes first
stow --adopt -n bash
stow --adopt -n zsh
stow --adopt -n nvim

# Apply changes
stow --adopt bash
stow --adopt zsh
stow --adopt nvim
stow --adopt git
stow --adopt direnv
```

**If starting fresh** (no existing dotfiles):
```bash
stow bash
stow zsh
stow nvim
stow git
stow direnv
```

**Verify symlinks:**
```bash
ls -la ~ | grep "\->"
```

### 3. Configure Shell Environment

Add to your `~/.bashrc` or `~/.zshrc`:

```bash
# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Pyenv
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"

# Mise
eval "$(mise activate bash)"  # or zsh if using zsh

# Rust
source "$HOME/.cargo/env"
```

Reload your shell:
```bash
source ~/.bashrc  # or source ~/.zshrc
```

### 4. Post-Installation (Optional)

**Tailscale** (if installed):
```bash
sudo tailscale up
sudo systemctl enable --now tailscaled
```

**Neovim plugins** (if using LazyVim):
```bash
nvim --headless -c "Lazy sync" -c "qa"
```

## About `stow --adopt`

The `--adopt` flag moves existing files into the package directory and replaces them with symlinks. This preserves your current configuration while bringing it under Stow management.

**Always use dry-run first:**
```bash
stow --adopt -n <package>
```

## Available Dotfile Packages

- `bash/` - Bash configuration
- `zsh/` - Zsh configuration
- `nvim/` - Neovim/LazyVim configuration
- `git/` - Git configuration
- `direnv/` - Direnv configuration
- `ssh/` - SSH configuration
- And more...

## Troubleshooting

- **Check distribution detection**: `./scripts/setup-linux.sh check`
- **List packages**: `./scripts/setup-linux.sh list`
- **Dry run setup**: `DRY_RUN=true ./scripts/setup-linux.sh`
- **Verify symlinks**: `ls -la ~ | grep "\->"`

## Notes

- The setup script requires `sudo` privileges for package installation
- Some packages (like Tailscale) require manual configuration after installation
- Raspberry Pi-specific packages are available in `APT_PACKAGES_PI` but may need explicit inclusion


## Install Neovim from source

```bash
wget https://github.com/neovim/neovim/releases/download/v0.11.5/nvim-linux-arm64.tar.gz
tar -xzf nvim-linux-arm64.tar.gz
# remove the tar.gz file after extraction
rm -rf nvim-linux-arm64.tar.gz 

# To run Neovim from anywhere (instead of the full path), add it to your PATH. 

sudo mv ~/nvim-linux-arm64 /opt/nvim
echo 'export PATH="/opt/nvim/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

