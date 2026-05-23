#!/bin/sh
# Unified setup script that auto-detects OS and runs appropriate setup
# Uses /bin/sh for maximum portability (works on both macOS and Linux)

set -e

# Get script directory in a portable way
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# Detect NixOS specifically
IS_NIXOS=false
if [ "$(uname -s)" = "Linux" ]; then
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [ "$ID" = "nixos" ]; then
            IS_NIXOS=true
        fi
    elif [ -d /etc/nixos ]; then
        IS_NIXOS=true
    fi
fi

# Detect Raspberry Pi specifically
PI_MODEL=""
IS_RASPBERRY_PI=false
if [ "$(uname -s)" = "Linux" ]; then
    if [ -f /sys/firmware/devicetree/base/model ]; then
        PI_MODEL=$(tr -d '\0' < /sys/firmware/devicetree/base/model)
        case "$PI_MODEL" in
            "Raspberry Pi"*)
                IS_RASPBERRY_PI=true
                ;;
        esac
    fi
    if [ "$IS_RASPBERRY_PI" = "false" ] && [ -f /proc/cpuinfo ]; then
        if grep -qE "Hardware.*:.*BCM(283[5-7]|271[12])" /proc/cpuinfo 2>/dev/null; then
            IS_RASPBERRY_PI=true
        fi
    fi
fi

# Detect OS and run appropriate setup script
case "$(uname -s)" in
    Darwin*)
        echo "🍎 Detected macOS"
        exec "$SCRIPT_DIR/scripts/setup-osx.sh" "$@"
        ;;
    Linux*)
        if [ "$IS_RASPBERRY_PI" = "true" ]; then
            echo "🍎 Detected $PI_MODEL"
            export PI_MODEL
            exec "$SCRIPT_DIR/scripts/setup-pi.sh" "$@"
            exit 0
        elif [ "$IS_NIXOS" = "true" ]; then
            echo "❄️  Detected NixOS"
            echo ""
            echo "⚠️  Note: NixOS uses a declarative configuration system."
            echo "   Package management should be done via /etc/nixos/configuration.nix"
            echo "   This setup script is designed for Debian/Ubuntu systems."
            echo ""
            echo "   For NixOS, you can:"
            echo "   - Use the stow script to symlink dotfiles: ./stow-dotfiles.sh"
            echo "   - Manually configure packages in /etc/nixos/configuration.nix"
            echo ""
            exit 0
        else
            echo "🐧 Detected Linux (Debian/Ubuntu)"
            exec "$SCRIPT_DIR/scripts/setup-linux.sh" "$@"
        fi
        ;;
    *)
        echo "❌ Error: Unsupported operating system: $(uname -s)"
        echo ""
        echo "Please run the appropriate setup script manually:"
        echo "  macOS: ./scripts/setup-osx.sh"
        echo "  Linux (Debian/Ubuntu): ./scripts/setup-linux.sh"
        exit 1
        ;;
esac

