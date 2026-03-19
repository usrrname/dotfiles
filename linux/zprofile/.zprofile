
# Linux zprofile - sources common and adds Linux-specific config

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

# Source common zprofile first
if [ -f "$DOTFILES_DIR/common/zprofile/.zprofile" ]; then
    source "$DOTFILES_DIR/common/zprofile/.zprofile"
fi
