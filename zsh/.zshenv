. "$HOME/.cargo/env"

# don't create .DS_Store files on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores true
# don't create .DS_Store files on USB volumes
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
# show hidden files in Finder by default
defaults write com.apple.finder AppleShowAllFiles YES
