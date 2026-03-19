# macOS zshenv
# Sources common zshenv and adds macOS-specific environment

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

# Source common base
if [ -f "$DOTFILES_DIR/common/zsh/.zshenv" ]; then
    source "$DOTFILES_DIR/common/zsh/.zshenv"
fi

# Source macOS-specific environment
if [ -f "$DOTFILES_DIR/macos/zsh/.zshenv.osx" ]; then
    source "$DOTFILES_DIR/macos/zsh/.zshenv.osx"
fi
