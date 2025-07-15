#!/bin/zsh

declare -a PKGS=("direnv" "1password" "cursor" "docker" "google-chrome" "iterm2" "slack" "spotify" "zoom")

# Check for dry-run mode
DRY_RUN=${DRY_RUN:-false}

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "[DRY RUN] Would install Homebrew"
    else
        curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | zsh
    fi
else
    echo "Homebrew already installed"
fi

echo "Installing packages..."
for PKG in "${PKGS[@]}"; do
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "[DRY RUN] Would install $PKG"
    elif brew list --cask "$PKG" &> /dev/null; then
        echo "$PKG is already installed"
    else
        echo "Installing $PKG"
        brew install --cask "$PKG"
    fi
done

echo "Setup complete!"