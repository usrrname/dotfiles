# Linux zshenv - sources common .zshenv and adds Linux-specific env
# This file is stowed to ~/.zshenv on Linux

# Source common zshenv
if [ -f "$HOME/.zshenv.common" ]; then
  source "$HOME/.zshenv.common"
fi

# Source Linux-specific zshenv if it exists
if [ -f "$HOME/.zshenv.linux" ]; then
  source "$HOME/.zshenv.linux"
fi
