#!/bin/sh
# Thin wrapper that detects Nix and forwards to the appropriate rebuild command
# Falls back to stow if Nix is not available

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# Check if Nix is installed
if command -v nix >/dev/null 2>&1; then
    # Detect OS and run appropriate Nix command
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
                echo "🐧 Detected Linux - running home-manager..."
                home-manager switch --flake .#fedora
            fi
            ;;
        *)
            echo "❌ Error: Unsupported operating system: $(uname -s)"
            exit 1
            ;;
    esac
else
    echo "⚠️  Nix not found - falling back to stow..."
    echo ""
    ./stow-dotfiles.sh
fi
