# Linux zprofile - sources common and adds Linux-specific config
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

# Source common zprofile first
if [ -f "$DOTFILES_DIR/common/zprofile/.zprofile" ]; then
    source "$DOTFILES_DIR/common/zprofile/.zprofile"
fi

# Only run if command exists (faster)
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"
command -v pyenv >/dev/null 2>&1 && eval "$(pyenv init -)"

# Load secrets to use anywhere in the filesystem
if [ -f "$HOME/.dotfiles/.env.secret" ]; then
  source $HOME/.dotfiles/.env.secret
fi
