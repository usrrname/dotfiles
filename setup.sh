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
                echo "📦 Installing Fedora system packages..."
                sudo dnf install -y wezterm input-remapper

                echo "🔧 Enabling system services..."
                sudo systemctl enable --now input-remapper

                echo "🔑 Setting up passwordless sudo..."
                echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/10-${USER}-nopasswd >/dev/null
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
