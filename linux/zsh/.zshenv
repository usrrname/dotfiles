# Linux zshenv
# Sources common zshenv and adds Linux-specific environment

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

# Source common base
if [ -f "$DOTFILES_DIR/common/zsh/.zshenv" ]; then
    source "$DOTFILES_DIR/common/zsh/.zshenv"
fi

# Source Linux-specific environment
if [ -f "$DOTFILES_DIR/linux/zsh/.zshenv.linux" ]; then
    source "$DOTFILES_DIR/linux/zsh/.zshenv.linux"
fi
