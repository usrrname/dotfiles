#!/bin/sh
# Thin wrapper that detects Nix and forwards to the appropriate rebuild command

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# Detect NixOS early to skip Nix installation (NixOS has Nix built-in)
IS_NIXOS=false
if [ -f /etc/os-release ]; then
  . /etc/os-release
  if [ "$ID" = "nixos" ]; then
    IS_NIXOS=true
  fi
elif [ -d /etc/nixos ]; then
  IS_NIXOS=true
fi

# Only try to install Nix if not on NixOS (which has Nix built-in)
if [ "$IS_NIXOS" != "true" ]; then
  command -v nix >/dev/null 2>&1 || {
    echo "❌ Nix is not installed."
    echo "Installing determinate.systems/nix..."
    curl -fsSL https://install.determinate.systems/nix | sh -s -- install
    exit 0
  }
fi

case "$(uname -s)" in
Darwin*)
  echo "🍎 Detected macOS - running darwin-rebuild..."
  sudo darwin-rebuild switch --flake .#mac-jenc
  ;;
Linux*)
  if [ "$IS_NIXOS" = "true" ]; then
    echo "❄️  Detected NixOS - applying home-manager configuration..."
    nix-shell -p home-manager --run "home-manager switch -b backup --impure --flake .#nixos-box"
  else
    # Debian/Raspbian-specific bootstrap (system packages, services, sudo)
    if grep -qi debian /etc/os-release 2>/dev/null || grep -qi raspbian /etc/os-release 2>/dev/null; then
      echo "🍓 Detected Debian/Raspbian — installing apt packages..."
      APT_PACKAGES="
                    syncthing
                    tailscale
                    ufw
                    fail2ban
                    hd-idle
                    docker.io
                    nginx
                    certbot
                    restic
                    btrfs-progs
                    cifs-utils
                    cloudflared
                    avahi-daemon
                "

      # Only install what isn't already installed
      for pkg in $APT_PACKAGES; do
        if ! dpkg -s "$pkg" >/dev/null 2>&1; then
          sudo apt install -y "$pkg"
        else
          echo "   ✓ $pkg already installed"
        fi
      done

      echo "🔧 Enabling systemd services..."
      SYSTEMD_SERVICES="tailscaled"
      for svc in $SYSTEMD_SERVICES; do
        if ! systemctl is-enabled "$svc" >/dev/null 2>&1; then
          sudo systemctl enable --now "$svc"
        fi
      done

      echo "   ℹ️  After setup, enable syncthing: systemctl --user enable --now syncthing.service"

      FLAKE="#pi-nas"
    # Fedora-specific bootstrap (system packages, services, sudo)
    elif grep -qi fedora /etc/os-release 2>/dev/null; then
      echo "📦 Installing Fedora system packages (dnf-only)..."
      # Only packages that truly can't come from Nix go here.
      # bubblewrap needs system namespace APIs — Nix binary can't provide them.
      DNF_PACKAGES="
                    bubblewrap
                    podman-docker
                "

      if [ -n "$DNF_PACKAGES" ]; then
        # shellcheck disable=SC2086
        sudo dnf install -y $DNF_PACKAGES
      else
        echo "   ✓ All packages are Nix-managed — nothing to dnf install"
      fi

      echo "🔧 Enabling systemd services..."
      SYSTEMD_SERVICES="tailscaled"
      for svc in $SYSTEMD_SERVICES; do
        if ! systemctl is-enabled "$svc" >/dev/null 2>&1; then
          sudo systemctl enable --now "$svc"
        fi

      done

      echo "🔌 Enabling podman Docker API socket..."
      systemctl --user enable podman.socket
      systemctl --user start podman.socket

      echo "🔑 Setting up passwordless sudo..."
      echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/10-${USER}-nopasswd >/dev/null

      FLAKE="#fedora"
    else
      FLAKE="" # unknown distro — skip system bootstrap, still try HM
    fi

    HM_INSTALLED=false
    command -v home-manager >/dev/null 2>&1 && HM_INSTALLED=true

    if [ -z "$FLAKE" ] && [ "$HM_INSTALLED" = false ]; then
      echo "❌ Error: home-manager not found and no flake host configured for this distro."
      exit 1
    fi

    # --impure: home/default.nix reads $USER/$HOME via builtins.getEnv to
    # compute home.username/homeDirectory portably across machines/accounts;
    # pure evaluation silently blocks that (getEnv returns ""), so every
    # invocation below needs it, not just first-time bootstrap.
    if [ "$HM_INSTALLED" = false ]; then
      # First-time bootstrap: Home Manager refuses to manage dotfiles that
      # already exist unmanaged (e.g. stock .bashrc/.zshrc/.profile on a
      # fresh account). Clear them before the very first activation only —
      # once `home-manager` is on PATH, a generation already exists. Safe
      # here: the guard clause above already ensured $FLAKE is non-empty.
      echo "🧹 First-time setup — clearing stock dotfiles Home Manager will manage..."
      rm -f "$HOME/.profile" "$HOME/.zshrc" "$HOME/.bashrc"

      # `home-manager` isn't on PATH yet on a brand-new Nix install — the
      # command only appears after the first activation. Bootstrap directly
      # from the flake's own activation package instead.
      HM_TARGET="${FLAKE#\#}"
      echo "🐧 First-time bootstrap - activating via nix run (home-manager not yet on PATH)..."
      nix run --impure ".#homeConfigurations.${HM_TARGET}.activationPackage"
    elif [ -n "$FLAKE" ]; then
      echo "🐧 Detected Linux - running home-manager switch --flake $FLAKE..."
      home-manager switch --impure --flake "$FLAKE"
    else
      echo "🐧 Detected Linux - running home-manager switch..."
      home-manager switch --impure
    fi
  fi
  ;;
*)
  echo "❌ Error: Unsupported operating system: $(uname -s)"
  exit 1
  ;;
esac
