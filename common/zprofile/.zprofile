
# Shared zprofile - direnv, pyenv
# This file is stowed to ~/.zprofile on all OS

# Only run if command exists (faster)
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"
command -v pyenv >/dev/null 2>&1 && eval "$(pyenv init -)"

# Load secrets to use anywhere in the filesystem
if [ -f "$HOME/.dotfiles/.env.secret" ]; then
  source $HOME/.dotfiles/.env.secret
fi
