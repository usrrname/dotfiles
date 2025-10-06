#!/bin/zsh

# Source shared package configuration
source "$(dirname "$0")/setup/packages.sh"

# Handle command line arguments
case "${1:-}" in
    "check"|"--check")
        CHECK_ONLY=true
        _is_brew_installed
        exit $?
        ;;
    "validate"|"--validate")
        validate_package_config
        exit $?
        ;;
    "list"|"--list"|"ls")
        list_packages
        ;;
    *)
        # Default to running the setup script
        CHECK_ONLY=false
        DRY_RUN=${DRY_RUN:-false}
        ;;
esac


# If only checking status, run check and exit
if [[ "$CHECK_ONLY" == "true" ]]; then
    _is_brew_installed
fi

# Check if Homebrew is installed
if ! _is_brew_installed; then
    echo "Installing Homebrew..."
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "[DRY RUN] Would install Homebrew"
    else # install brew
        curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | zsh
    fi
else
    echo "Homebrew already installed"
fi

if ! command -v mise &> /dev/null; then
    echo "Installing mise..."
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "[DRY RUN] Would install mise"
    else
        curl https://mise.run | sh
        gem install rails
    fi
else
    echo "mise already installed"
fi

if ! command -v devbox &> /dev/null; then
    echo "Installing devbox..."
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "[DRY RUN] Would install devbox"
    else
        curl -fsSL https://get.jetify.com/devbox | bash  
    fi
else
    echo "devbox already installed"
fi

echo "Installing packages..."

# Install regular brew packages
for PKG in "${BREW_PACKAGES[@]}"; do
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "[DRY RUN] Would install brew package $PKG"
    elif is_brew_package_installed "$PKG"; then
        echo "✅ $PKG is already installed"
    else
        echo "📦 Installing $PKG"
        brew install "$PKG"
    fi
done

# Install cask packages (GUI applications)
for PKG in "${CASK_PACKAGES[@]}"; do
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "[DRY RUN] Would install cask $PKG"
    elif is_cask_installed "$PKG"; then
        echo "✅ $PKG cask is already installed"
    else
        echo "📦 Installing cask $PKG"
        brew install --cask "$PKG"
    fi
done

# configure nvm / node
if command -v nvm &> /dev/null; then
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "[DRY RUN] Would install nvm"
    else
        nvm install stable
        nvm alias default stable
    fi
else
    echo "nvm not installed"
fi

echo "Setup complete!"