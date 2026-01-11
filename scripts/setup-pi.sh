#!/bin/bash

# Setup script for Debian and Ubuntu
# Automatically detects distribution and installs packages accordingly

# Source shared package configuration
source "$(dirname "$0")/setup/packages-pi.sh"

# Handle command line arguments
case "${1:-}" in
    "check"|"--check")
        CHECK_ONLY=true
        _is_apt_available
        exit $?
        ;;
    "list"|"--list"|"ls")
        list_packages
        exit 0
        ;;
    *)
        # Default to running the setup script
        CHECK_ONLY=false
        DRY_RUN=${DRY_RUN:-false}
        ;;
esac

# If only checking status, run check and exit
if [[ "$CHECK_ONLY" == "true" ]]; then
    _is_apt_available
    exit $?
fi

# Display detected distribution
echo "🖥️  Detected distribution: $DISTRO_ID $DISTRO_VERSION"
echo ""

# Check if running as root for apt operations
if [[ $EUID -ne 0 ]] && [[ "$DRY_RUN" != "true" ]]; then
    echo "⚠️  This script requires sudo privileges for package installation"
    echo "Some operations will prompt for your password"
    echo ""
fi

# Update package lists
echo "🔄 Updating package lists..."
if [[ "$DRY_RUN" == "true" ]]; then
    echo "[DRY RUN] Would run: sudo apt update"
else
    sudo apt update
fi

# Install APT packages
echo ""
echo "📦 Installing APT packages..."
for PKG in "${APT_PACKAGES[@]}"; do
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "[DRY RUN] Would install apt package $PKG"
    elif is_apt_package_installed "$PKG"; then
        echo "✅ $PKG is already installed"
    else
        echo "📦 Installing $PKG"
        sudo apt install -y "$PKG" || echo "⚠️  Failed to install $PKG"
    fi
done

# Install Tailscale
if ! is_tailscale_installed; then
    echo "Installing Tailscale..."
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "[DRY RUN] Would install Tailscale"
    else
        curl -fsSL https://tailscale.com/install.sh | sh
        echo "✅ Tailscale installed"
        echo "⚠️  Note: Run 'sudo tailscale up' to connect to your Tailnet"
        echo "⚠️  Note: Run 'sudo systemctl enable --now tailscaled' to start the service"
    fi
else
    echo "✅ Tailscale is already installed"
fi

# Install nvm
if ! command -v nvm &> /dev/null; then
    echo "Installing nvm..."
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "[DRY RUN] Would install nvm"
    else
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
        # Source nvm for current session
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        nvm install stable
        nvm alias default stable
    fi
else
    echo "✅ nvm already installed"
    if command -v nvm &> /dev/null && [[ "$DRY_RUN" != "true" ]]; then
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        nvm install stable 2>/dev/null || true
        nvm alias default stable 2>/dev/null || true
    fi
fi

# Install direnv
if ! command -v direnv &> /dev/null; then
    echo "Installing direnv..."
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "[DRY RUN] Would install direnv"
    else
        # Try apt first (works on both Ubuntu and Debian)
        if ! sudo apt install -y direnv 2>/dev/null; then
            echo "⚠️  APT install failed, trying binary install..."
            curl -sfL https://direnv.net/install.sh | bash
        fi
    fi
else
    echo "✅ direnv already installed"
fi

# Install GitHub CLI (gh)
if ! command -v gh &> /dev/null; then
    echo "Installing GitHub CLI..."
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "[DRY RUN] Would install GitHub CLI"
    else
        type -p curl >/dev/null || sudo apt install curl -y
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt update
        sudo apt install gh -y
    fi
else
    echo "✅ GitHub CLI already installed"
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "📝 Next steps:"
echo "   - Run 'sudo tailscale up' to connect to your Tailnet"
echo "   - Run 'sudo systemctl enable --now tailscaled' to enable Tailscale service"