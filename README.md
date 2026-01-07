# dotfiles

[![Built with Devbox](https://www.jetify.com/img/devbox/shield_moon.svg)](https://www.jetify.com/devbox/docs/contributor-quickstart/)

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
- **NixOS** - Package management via `/etc/nixos/configuration.nix` (setup script provides guidance, stow script works normally)

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

The script automatically:
- **Stows common packages** on all systems (bash, zsh, nvim, git, etc.)
- **Stows macOS-specific packages** on macOS only (see [setup-osx.md](setup-osx.md) for details)
- **Skips OS-specific packages** on other systems (e.g., Raspberry Pi won't get macOS packages)
- **Note**: The `nix/` folder is not stowed automatically - it should be managed manually or via NixOS `configuration.nix`

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

### Contents
- [dotfiles](#dotfiles)
  - [Quick Start](#quick-start)
    - [Symlinking Dotfiles](#symlinking-dotfiles)
    - [Updating Dotfiles](#updating-dotfiles)
  - [Troubleshooting](#troubleshooting)
    - [Contents](#contents)
  - [Maintenance](#maintenance)
  - [act](#act)
  - [Symlinking](#symlinking)
  - [Nvim/LazyVim](#nvimlazyvim)
  - [1Password](#1password)
  - [Devbox](#devbox)


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

## Devbox

[FAQ](https://www.jetify.com/docs/devbox/faq/)

```bash
devbox add <package> # add a package to the devbox environment
devbox rm <package> # remove a package from the devbox environment
devbox info # show info about the devbox environment
devbox update # update packages in devbox
devbox version update # update devbox to the latest version
devbox shell # initialize the devbox shell
devbox generate direnv # generate a direnvrc file
```
Clean up packages in nix store

```bash
devbox run -- nix store gc --extra-experimental-features nix-command
```