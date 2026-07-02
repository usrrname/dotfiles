#!/bin/sh
# Thin wrapper that detects Nix and forwards to the appropriate rebuild command

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

command -v nix >/dev/null 2>&1 || {
  echo "❌ Nix is not installed. Please install Nix first: https://nixos.org/download"
  exit 1
}

case "$(uname -s)" in
Darwin*)
  echo "🍎 Detected macOS - running darwin-rebuild..."
  sudo darwin-rebuild switch --flake .#mac-jenc
  ;;
Linux*)
  # Detect NixOS
  IS_NIXOS=false
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [ "$ID" = "nixos" ]; then
      IS_NIXOS=true
    fi
  elif [ -d /etc/nixos ]; then
    IS_NIXOS=true
  fi

  if [ "$IS_NIXOS" = "true" ]; then
    echo "❄️  Detected NixOS - running nixos-rebuild..."
    sudo nixos-rebuild switch --flake .#nixos-box
  else
    # Debian/Raspbian-specific bootstrap (system packages, services, sudo)
    if grep -qi debian /etc/os-release 2>/dev/null || grep -qi raspbian /etc/os-release 2>/dev/null; then
      echo "🍓 Detected Debian/Raspbian — installing apt packages..."
      APT_PACKAGES="
                    syncthing
                    tailscale
                    ufw
                    fail2ban
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

    if [ -n "$FLAKE" ]; then
      echo "🐧 Detected Linux - running home-manager switch --flake $FLAKE..."
      home-manager switch --flake "$FLAKE"
    else
      echo "🐧 Detected Linux - running home-manager switch..."
      home-manager switch
    fi
  fi
  ;;
*)
  echo "❌ Error: Unsupported operating system: $(uname -s)"
  exit 1
  ;;
esac
