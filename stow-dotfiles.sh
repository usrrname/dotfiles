#!/bin/bash
# OS-aware stow script - stows relevant dotfiles based on OS
# Uses new directory structure: stow/common/, stow/macos/, stow/linux/, stow/pi/

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
cd "$SCRIPT_DIR"

# Detect OS
OS=$(uname -s)
ARCH=$(uname -m)

# Detect NixOS specifically
IS_NIXOS=false
if [[ "$OS" == "Linux" ]]; then
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        if [[ "$ID" == "nixos" ]]; then
            IS_NIXOS=true
        fi
    elif [[ -d /etc/nixos ]]; then
        IS_NIXOS=true
    fi
fi

# Detect Raspberry Pi (ARM64)
IS_PI=false
if [[ "$ARCH" == "aarch64" ]] || [[ "$ARCH" == "arm64" ]]; then
    IS_PI=true
fi

# Determine which OS-specific directory to use
STOW_OS=""
if [[ "$OS" == "Darwin" ]]; then
    STOW_OS="macos"
elif [[ "$IS_PI" == "true" ]]; then
    STOW_OS="pi"
elif [[ "$OS" == "Linux" ]]; then
    STOW_OS="linux"
fi

# Allow passing stow flags (defaults to --adopt if no arguments provided)
# Pass empty string "" to skip --adopt flag
if [[ $# -eq 0 ]]; then
    STOW_FLAGS="--adopt"
elif [[ -z "$1" ]]; then
    STOW_FLAGS=""
else
    STOW_FLAGS="$1"
fi

# Function to stow a package if it exists and is not empty
stow_package() {
    local pkg="$1"
    local dir="stow/$pkg"

    if [[ -d "$dir" ]] && [[ -n "$(ls -A "$dir" 2>/dev/null)" ]]; then
        echo "📦 Stowing $pkg..."
        if stow $STOW_FLAGS -d stow -t "$HOME" "$pkg" 2>/dev/null; then
            echo "   ✅ $pkg stowed successfully"
        else
            echo "   ⚠️  Warning: Could not stow $pkg (may already be stowed or have conflicts)"
        fi
    else
        echo "⏭️  Skipping $pkg (directory doesn't exist or is empty)"
    fi
}

# Main execution
echo "🔗 Setting up dotfiles for $OS..."
echo ""

# Stow common packages (work on all OSes)
echo "📦 Stowing common packages..."
stow_package "common"

# Stow OS-specific packages
if [[ -n "$STOW_OS" ]]; then
    echo ""
    echo "📦 Stowing $STOW_OS-specific packages..."
    stow_package "$STOW_OS"
fi

echo ""
echo "✅ Dotfiles setup complete!"
echo ""
echo "💡 Verify symlinks:"
echo "   ls -la ~ | grep '\->'"
