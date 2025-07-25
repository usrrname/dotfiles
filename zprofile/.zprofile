direnv grant ~/.dotfiles/.envrc
direnv allow ~/.dotfiles/.envrc

# Show filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show hidden files
defaults write com.apple.finder AppleShowAllFiles -bool true

# Set screenshot location
defaults write com.apple.screencapture "location" -string "~/pictures/screenshots"

eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(direnv hook zsh)"
eval "$(fnm env)"
eval "$(pyenv init -)"
