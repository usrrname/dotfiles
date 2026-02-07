
# Only run if command exists (faster)
[ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"
command -v pyenv >/dev/null 2>&1 && eval "$(pyenv init -)"

# Show all filename extensions in Finder
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Set screenshot location
defaults write com.apple.screencapture "location" -string "~/pictures/screenshots"

# don't create .DS_Store files on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores true
# don't create .DS_Store files on USB volumes
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
# show hidden files in Finder by default
defaults write com.apple.finder AppleShowAllFiles YES


# Mise uses shims to load dev tools into the PATH
# https://mise.jdx.dev/dev-tools/shims.html#mise-activate-shims
eval "$(mise activate zsh --shims)"
# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
[ -f ~/.orbstack/shell/init.zsh ] && source ~/.orbstack/shell/init.zsh 2>/dev/null || :

# Load secrets to use anywhere in the filesystem
source $HOME/.dotfiles/.env.secret
