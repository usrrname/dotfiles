#!/bin/zsh

declare -a PKGS=("direnv" "git" "1password-cli" "cursor" "docker" "google-chrome" "iterm2" "slack" "spotify" "zoom" "nvm" "pnpm" "act" "yarn" "orbstack" "fnm" "pyenv" "gh" "claude-code")

# Check for dry-run mode
DRY_RUN=${DRY_RUN:-false}

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "[DRY RUN] Would install Homebrew"
    else
        # install brew
        curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | zsh
    fi
else
    echo "Homebrew already installed"
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

### Env setup for yarn and pnpm
if ! command -v corepack &> /dev/null; then
    npm i -g corepack
fi

nvm alias default stable

echo "Setup complete!"