# dotfiles

Dotfiles setup made with:

- [stow](https://www.gnu.org/software/stow/)

- [direnv](https://direnv.net) w/ global config in `~/.config/direnv/direnvrc`

- Underlying ideals from [12 Factor App config](https://12factor.net/config)

## Quick Start

The setup script automatically detects your operating system and runs the appropriate installer.

**No special requirements** - works with standard shells on supported systems.

**Supported Systems:**

- [macOS setup](setup-osx.md) based on [mac.install.guide](https://mac.install.guide/) tested with [Bats](https://github.com/bats-core/bats-core) (see [setup-osx.md](setup-osx.md))
- [Raspberry Pi 4 setup](setup-pi.md) running Debian Trixie
- **NixOS** - Managed via `/etc/nixos/configuration.nix` (auto-configured by `bin/init.sh`)

```bash
# Install packages (auto-detects OS)
./setup.sh

# Check package status
./setup.sh check

# List all packages
./setup.sh list

# Validate package configuration (macOS only)
./setup.sh validate
```

The script will automatically:

- **macOS**: Run `scripts/setup-osx.sh` (uses Homebrew)
- **Linux (Debian/Ubuntu)**: Run `scripts/setup-linux.sh` (uses APT)
- **NixOS**: Shows guidance (package management via configuration.nix)

You can still run the OS-specific scripts directly if needed:

- `./scripts/setup-osx.sh` for macOS
- `./scripts/setup-linux.sh` for Linux

### Symlinking Dotfiles

After installing packages, symlink your dotfiles using the OS-aware stow script:

```bash
# Stow all dotfiles (auto-detects OS and only stows relevant packages)
./stow-dotfiles.sh

# Stow without adopting existing files (use if starting fresh)
./stow-dotfiles.sh ""
```

## Setup

Clone the repository and run the init script — it auto-detects your OS and configures everything:

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

### Updating Dotfiles

After pulling updates from the repository, use the update script to sync everything:

```bash
# Pull updates, update submodules, install new packages, and update symlinks
./update.sh
```

This will:

1. Pull latest changes from git
2. Update git submodules
3. Install any new packages (setup scripts check if already installed)
4. Update dotfile symlinks (stow is idempotent, safe to run multiple times)

## Troubleshooting

- **Check distribution detection**: `./setup.sh check`
- **List packages**: `./setup.sh list`
- **Dry run setup**: `DRY_RUN=true ./setup.sh`
- **Verify symlinks**: `ls -la ~ | grep "\->"`
- **macOS-specific**: See [setup-osx.md](setup-osx.md) for additional troubleshooting

## Adding a New Config Package

Want to add `~/.config/someapp` to your dotfiles? Here's how:

```bash
# 1. Create the directory structure in your dotfiles repo
mkdir -p common/someapp/.config/someapp

# 2. Copy your existing config into it
cp -r ~/.config/someapp/* common/someapp/.config/someapp/

# 3. Remove the original (stow will recreate it as a symlink)
rm -rf ~/.config/someapp

# 4. Add the package name to the COMMON array in stow-dotfiles.sh
# COMMON=(... someapp ...)

# 5. Run stow to create the symlinks
./stow-dotfiles.sh
```

That's it! Your config is now tracked in git and symlinked to `~/.config/someapp`.

**Note:** Some tools (like the 1Password CLI) don't work with symlinks. For those, add the package name to `.stow-local-ignore` instead — this tells stow to skip it entirely.

### Contents

- [dotfiles](#dotfiles)
  - [Quick Start](#quick-start)
    - [Symlinking Dotfiles](#symlinking-dotfiles)
    - [Updating Dotfiles](#updating-dotfiles)
  - [Troubleshooting](#troubleshooting)
  - [Adding a New Config Package](#adding-a-new-config-package)
  - [Maintenance](#maintenance)
  - [act](#act)
  - [Symlinking](#symlinking)
  - [Nvim/LazyVim](#nvimlazyvim)
  - [1Password](#1password)

## Maintenance

Keep submodules updated

```bash
git submodule update
```

## act

```bash
# insert 1password token into github action secrets
act -s GITHUB_TOKEN=$(op read $GITHUB_TOKEN)
```

## Symlinking

```bash
./stow-dotfiles.sh
```

**Manual stow** (if you need to stow individual packages):

```bash
cp <directory> <target>
mkdir -p <directory>
stow <directory>
```

## Nvim/LazyVim

Build plugins

```bash
nvim --headless -c "Lazy sync" -c "qa"
```

Force clean and reinstall LazyVim plugins

```bash
nvim --headless -c "lua require('lazy').clean()" -c "lua require('lazy').sync()" -c "qa"
```

Refresh and sync plugins (interactive)

```bash
:Lazy clean
:Lazy sync
```

## 1Password

```bash
op://<vault-name>/<item-name>/[section-name/]<field-name>
```

```bash
Usage:  op read <reference> [flags]

Examples:

Print the secret saved in the field 'password', on the item 'db', in the vault 'app-prod':

op read op://app-prod/db/password

Use a secret reference with a query parameter to retrieve a one-time
password:

op read "op://app-prod/db/one-time password?attribute=otp"

Use a secret reference with a query parameter to get an SSH key's private key in the OpenSSH format:

op read "op://app-prod/ssh key/private key?ssh-format=openssh"

Save the SSH key found on the item 'ssh' in the 'server' vault
as a new file 'key.pem' on your computer:

op read --out-file ./key.pem op://app-prod/server/ssh/key.pem

Use 'op read' in a command with secret references in place of plaintext secrets:

docker login -u $(op read op://prod/docker/username) -p $(op read op://prod/docker/password)
      
```

