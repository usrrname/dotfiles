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

Run the unified setup script (auto-detects Linux and runs the appropriate installer):

```bash
# Preview what will be installed (dry run)
DRY_RUN=true ./setup.sh

# Check current package status
./setup.sh check

# List all packages
./setup.sh list

# Run the installation
./setup.sh
```

**Note**: The unified `setup.sh` script automatically detects Linux and runs `scripts/setup-linux.sh`. You can also run the Linux script directly if needed.

The script automatically:
- Detects Debian Trixie and architecture
- Installs base packages (git, curl, neovim, build tools, etc.)
- Installs special packages (nvm, pyenv, mise, devbox, tailscale, rust, etc.)
- Installs development tools (GitHub CLI, 1Password CLI, ripgrep, etc.)

### 2. Symlink Dotfiles

Use the OS-aware stow script to create symlinks (automatically stows only relevant packages for Debian):

```bash
# Stow all dotfiles (auto-detects OS and only stows relevant packages)
./stow-dotfiles.sh

# Stow without adopting existing files (use if starting fresh)
./stow-dotfiles.sh ""
```

The script automatically:
- **Stows common packages** (bash, zsh, nvim, git, direnv, etc.)
- **Skips macOS-specific packages** (see `setup-osx.md` for macOS setup)
- **Note**: The `nix/` folder is not stowed automatically - it should be managed manually or via NixOS `configuration.nix`

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

### 5. Migrate Swap from zram to HDD (Recommended)

Move swap from zram to a dedicated HDD partition to prevent SD card wear and improve reliability.

**Prerequisites**: A dedicated HDD partition (e.g., `/dev/sda2`)

```bash
# 1. Format HDD partition as ext4
sudo mkfs.ext4 /dev/sda2
sudo mkdir -p /mnt/storage
sudo mount /dev/sda2 /mnt/storage

# 2. Create 2GB swap file
sudo fallocate -l 2G /mnt/storage/swapfile
sudo chmod 600 /mnt/storage/swapfile
sudo mkswap /mnt/storage/swapfile
sudo swapon /mnt/storage/swapfile

# 3. Disable zram (Raspberry Pi specific)
sudo mkdir -p /etc/rpi/swap.conf.d
echo -e "[Main]\nMechanism=none" | sudo tee /etc/rpi/swap.conf.d/90-disable-swap.conf > /dev/null
sudo systemctl mask systemd-zram-setup@zram0.service
sudo systemctl mask systemd-zram-setup@.service
sudo systemctl stop rpi-zram-writeback.timer
sudo systemctl disable rpi-zram-writeback.timer

# 4. Blacklist zram module
echo "blacklist zram" | sudo tee /etc/modprobe.d/blacklist-zram.conf
sudo update-initramfs -u

# 5. Make persistent in /etc/fstab
sudo vi /etc/fstab
# Add:
# /dev/sda2 /mnt/storage ext4 defaults 0 2
# /mnt/storage/swapfile none swap sw 0 0

# 6. Reboot and verify
sudo reboot
# After reboot:
swapon --show  # Should show only /mnt/storage/swapfile
lsmod | grep zram  # Should return nothing
```

**Note**: Adjust partition (`/dev/sda2`) and swap size (`2G`) as needed. Remaining space on partition can be used for other services.

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

- **Check distribution detection**: `./setup.sh check`
- **List packages**: `./setup.sh list`
- **Dry run setup**: `DRY_RUN=true ./setup.sh`
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

