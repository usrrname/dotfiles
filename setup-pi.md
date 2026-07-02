# Pi NAS Setup (Raspberry Pi / Debian)

Quick guide for setting up this dotfiles repository on a Raspberry Pi
running Debian (e.g., a Pi 4 NAS).

## Prerequisites

- Raspberry Pi with Debian installed
- `git` — `sudo apt install git`
- Nix installed via [Determinate Nix Installer](https://nixos.org/download)

## Setup

```bash
# Clone
cd ~ && git clone <your-repo-url> .dotfiles && cd .dotfiles

# Bootstrap — installs apt packages, enables system services, applies Nix config
./setup.sh
```

This auto-detects Debian, installs system packages (tailscale, syncthing,
docker.io, nginx, ufw, fail2ban, etc.), enables `tailscaled`, and runs
`home-manager switch --flake .#pi-nas`.

## One-Time Manual Steps

**Tailscale auth** (needed once — persists across reboots):

```bash
sudo tailscale up
sudo tailscale set --operator=$USER   # allows user-level serve config
```

**Enable managed services**:

```bash
systemctl --user enable --now syncthing.service
systemctl --user start tailscale-serve.service
```

**Neovim plugins** (if using LazyVim):

```bash
nvim --headless -c "Lazy sync" -c "qa"
```

## Login Banner

SSHing in will show a cowsay dragon with rainbow IPs for
`eth0`, `docker0`, and `tailscale0`. Managed by
`home.file.".bash_login"` in `hosts/pi-nas/default.nix`.

## Migrate Swap from zram to HDD (Recommended)

```bash
# Format HDD partition
sudo mkfs.ext4 /dev/sda2
sudo mkdir -p /mnt/storage
sudo mount /dev/sda2 /mnt/storage

# Create 2GB swap file
sudo fallocate -l 2G /mnt/storage/swapfile
sudo chmod 600 /mnt/storage/swapfile
sudo mkswap /mnt/storage/swapfile
sudo swapon /mnt/storage/swapfile

# Disable zram (Raspberry Pi specific)
sudo mkdir -p /etc/rpi/swap.conf.d
echo -e "[Main]\nMechanism=none" | sudo tee /etc/rpi/swap.conf.d/90-disable-swap.conf > /dev/null
sudo systemctl mask systemd-zram-setup@zram0.service
sudo systemctl mask systemd-zram-setup@.service
sudo systemctl stop rpi-zram-writeback.timer
sudo systemctl disable rpi-zram-writeback.timer
echo "blacklist zram" | sudo tee /etc/modprobe.d/blacklist-zram.conf
sudo update-initramfs -u

# Persist in /etc/fstab — add:
# /dev/sda2 /mnt/storage ext4 defaults 0 2
# /mnt/storage/swapfile none swap sw 0 0

sudo reboot
```

## Updating

```bash
cd ~/.dotfiles && git pull && ./setup.sh
```
```
