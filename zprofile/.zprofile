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

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
alias sail='[ -f sail ] && bash sail || bash vendor/bin/sail'
alias pint='./vendor/bin/pint'
