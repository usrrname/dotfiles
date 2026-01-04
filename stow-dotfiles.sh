#!/bin/bash
# OS-aware stow script - only stows relevant dotfiles based on OS

set -e

# Get script directory (works with bash)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
cd "$SCRIPT_DIR"

OS=$(uname -s)

# Detect NixOS specifically (not just any Linux)
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

# Allow passing stow flags (defaults to --adopt if no arguments provided)
# Pass empty string "" to skip --adopt flag
if [[ $# -eq 0 ]]; then
    STOW_FLAGS="--adopt"
elif [[ -z "$1" ]]; then
    STOW_FLAGS=""
else
    STOW_FLAGS="$1"
fi

# Common packages (work on both macOS and Linux)
COMMON=(
    bash
    zsh
    nvim
    git
    direnv
    ssh
    docker
    gh
    op
    act
    npm
    yarn
    gemini
    verdaccio
    vim
    husky
    devbox.d
)

# macOS-specific packages
MACOS_PACKAGES=(
    iterm2
    orbstack
    cursor
    zprofile
)

# Note: nix/ folder is not stowed automatically
# It should be managed manually or via NixOS configuration.nix

# Function to stow a package if it exists and is not empty
stow_package() {
    local pkg="$1"
    if [[ -d "$pkg" ]] && [[ -n "$(ls -A "$pkg" 2>/dev/null)" ]]; then
        echo "📦 Stowing $pkg..."
        if stow $STOW_FLAGS "$pkg" 2>/dev/null; then
            echo "   ✅ $pkg stowed successfully"
        else
            echo "   ⚠️  Warning: Could not stow $pkg (may already be stowed or have conflicts)"
        fi
    else
        echo "⏭️  Skipping $pkg (directory doesn't exist or is empty)"
    fi
}

# Main execution
echo "🔗 Setting up dotfiles for $(uname -s)..."
echo ""

# Stow common packages
echo "📦 Stowing common packages..."
for pkg in "${COMMON[@]}"; do
    stow_package "$pkg"
done

# Stow OS-specific packages
if [[ "$OS" == "Darwin" ]]; then
    echo ""
    echo "🍎 Stowing macOS-specific packages..."
    for pkg in "${MACOS_PACKAGES[@]}"; do
        stow_package "$pkg"
    fi
fi

# Note: nix/ folder is not stowed automatically
# It should be managed manually or via NixOS configuration.nix

echo ""
echo "✅ Dotfiles setup complete!"
echo ""
echo "💡 Verify symlinks:"
echo "   ls -la ~ | grep '\->'"

