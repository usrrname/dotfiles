
# macOS zprofile - sources common and adds macOS-specific config

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

# Source common zprofile first
if [ -f "$DOTFILES_DIR/common/zprofile/.zprofile" ]; then
    source "$DOTFILES_DIR/common/zprofile/.zprofile"
fi

# Homebrew
[ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"

# Show all filename extensions in Finder
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Set screenshot location
defaults write com.apple.screencapture "location" -string "~/pictures/screenshots"

# Disable Liquid Glass
defaults write -g com.apple.SwiftUI.DisableSolarium -bool YES

# don't create .DS_Store files on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores true
# don't create .DS_Store files on USB volumes
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
# show hidden files in Finder by default
defaults write com.apple.finder AppleShowAllFiles YES

# Added by OrbStack
[ -f ~/.orbstack/shell/init.zsh ] && source ~/.orbstack/shell/init.zsh 2>/dev/null || :
