# macOS specific environment
# don't create .DS_Store files on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores true
# don't create .DS_Store files on USB volumes
defaults write com.apple.desktopServices DSDontWriteUSBStores -bool true
# show hidden files in Finder by default
defaults write com.apple.finder AppleShowAllFiles YES

# if rust env exists, source it
if [ -f "$HOME/.cargo/env" ]; then
  . "$HOME/.cargo/env"
fi
export PATH="$HOME/.local/bin:$PATH"
