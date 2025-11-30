# Show filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show hidden files
defaults write com.apple.finder AppleShowAllFiles -bool true

# Set screenshot location
defaults write com.apple.screencapture "location" -string "~/pictures/screenshots"

eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(direnv hook zsh)"
eval "$(pyenv init -)"

# Mise uses shims to load dev tools into the PATH
# https://mise.jdx.dev/dev-tools/shims.html#mise-activate-shims
eval "$(mise activate zsh --shims)"
# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

# Load secrets to use anywhere in the filesystem
source $HOME/.dotfiles/.env.secret
