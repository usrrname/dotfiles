# macOS zshrc - sources .zshrc.osx at end
# This file is stowed to ~/.zshrc on macOS

# use iterm2 on zsh init
source ~/.iterm2_shell_integration.zsh

# devbox called only when `devbox` is typed
devbox() {
  unfunction devbox
  eval "$(command devbox global shellenv --preserve-path-stack -r)"
  command devbox "$@"
}

# Source macOS-specific configuration
if [ -f "$HOME/.zshrc.osx" ]; then
  source "$HOME/.zshrc.osx"
fi
