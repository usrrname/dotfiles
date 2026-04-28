
# macOS zprofile - sources common and adds macOS-specific config

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

# Source common zprofile first
if [ -f "$DOTFILES_DIR/common/zprofile/.zprofile" ]; then
    source "$DOTFILES_DIR/common/zprofile/.zprofile"
fi

# Homebrew
[ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"

# macOS preferences (persist once set, skip in sandboxed shells)
if [[ ! -v CLAUDE_CODE_SANDBOX ]]; then
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true
  defaults write com.apple.screencapture "location" -string "~/pictures/screenshots"
  defaults write -g com.apple.SwiftUI.DisableSolarium -bool YES
  defaults write com.apple.desktopservices DSDontWriteNetworkStores true
  defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
  defaults write com.apple.finder AppleShowAllFiles YES
fi

# Added by OrbStack
[ -f ~/.orbstack/shell/init.zsh ] && source ~/.orbstack/shell/init.zsh 2>/dev/null || :
