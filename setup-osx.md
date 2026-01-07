# Setting Up Dotfiles on macOS

## Prerequisites

1. Clone the repository:
   ```bash
   cd ~
   git clone <your-repo-url> .dotfiles
   cd .dotfiles
   ```

2. Install `stow` (for symlinking dotfiles):
   ```bash
   brew install stow
   ```

## Setup Steps

### 1. Install Packages

Run the unified setup script (auto-detects macOS and runs the appropriate installer):

```bash
# Preview what will be installed (dry run)
DRY_RUN=true ./setup.sh

# Check current package status
./setup.sh check

# Validate package configuration
./setup.sh validate

# List all packages
./setup.sh list

# Run the installation
./setup.sh
```

`setup.sh` script automatically detects macOS and runs `scripts/setup-osx.sh`. You can also run the macOS script directly if needed.

The script automatically installs Homebrew (if needed) and all required packages.

### 2. Symlink Dotfiles

Use the OS-aware stow script to create symlinks (automatically stows only relevant packages for macOS):

```bash
# Stow all dotfiles (auto-detects OS and only stows relevant packages)
./stow-dotfiles.sh

# Stow without adopting existing files (use if starting fresh)
./stow-dotfiles.sh ""
```

The script automatically stows common and macOS-specific packages. Note: The `nix/` folder is not stowed automatically.

**Verify symlinks:**
```bash
ls -la ~ | grep "\->"
```

### 3. Configure Shell Environment

Add to your `~/.zshrc`:

```bash
# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Pyenv
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"

# Mise
eval "$(mise activate zsh)"

# Rust
source "$HOME/.cargo/env"
```

Reload your shell:
```bash
source ~/.zshrc
```

### 4. Post-Installation (Optional)

**Neovim plugins** (if using LazyVim):
```bash
nvim --headless -c "Lazy sync" -c "qa"
```

**OrbStack** (Docker alternative):
```bash
# Set the default docker context to orbstack
docker context use orbstack
```

## About `stow --adopt`

The `--adopt` flag moves existing files into the package directory and replaces them with symlinks. Always use dry-run first:

```bash
stow --adopt -n <package>
```

## Troubleshooting

- **Check distribution detection**: `./setup.sh check`
- **List packages**: `./setup.sh list`
- **Validate package config**: `./setup.sh validate`
- **Dry run setup**: `DRY_RUN=true ./setup.sh`
- **Verify symlinks**: `ls -la ~ | grep "\->"`

## Notes

- Homebrew will be installed automatically if missing
- Some packages may require manual configuration after installation
- Setup is based on [mac.install.guide](https://mac.install.guide/)

### zsh

```bash
## When each is loaded:
.zshenv
        → .zprofile
                → .zshrc 
                        → .zlogin
```

## Packages

## Mise

```bash
mise activate zsh
```

## OrbStack

macOS-specific Docker alternative. See [setup-osx.md](setup-osx.md) for setup details.

Set the default docker context to orbstack:

```bash
docker context use orbstack
```

## uv

Python package manager to replace pip, pip-tools, pipx, poetry, pyenv, twine, virtualenv, etc.

```bash
# Install uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# Create a virtual environment
uv venv

# Install packages
uv pip install <package>

# Run commands in the virtual environment
uv run <command>
```