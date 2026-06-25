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
    # Fedora-specific bootstrap (system packages, services, sudo)
    if grep -qi fedora /etc/os-release 2>/dev/null; then
      echo "📦 Installing Fedora system packages (dnf-only)..."
      # Only packages that truly can't come from Nix go here.
      # wezterm needs system EGL/GPU libraries — Nix binary can't find them.
      DNF_PACKAGES="
                    wezterm
                    bubblewrap
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

      echo "🐚 Setting zsh as default shell..."
      ZSH_PATH=$(command -v zsh)
      if [ -n "$ZSH_PATH" ] && [ "$SHELL" != "$ZSH_PATH" ]; then
        if ! grep -qxF "$ZSH_PATH" /etc/shells 2>/dev/null; then
          echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
        fi
        sudo chsh -s "$ZSH_PATH" "$USER"
        echo "   ✓ Default shell set to zsh (log out and back in to apply)"
      fi
    fi

    echo "🐧 Detected Linux - running home-manager..."
    home-manager switch --flake .#fedora
  fi
  ;;
*)
  echo "❌ Error: Unsupported operating system: $(uname -s)"
  exit 1
  ;;
esac
