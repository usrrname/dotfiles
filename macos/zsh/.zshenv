# macOS specific environment
# defaults writes are skipped in sandboxed shells (e.g., Claude Code) since they persist once set
if [[ ! -v CLAUDE_CODE_SANDBOX ]]; then
  # don't create .DS_Store files on network volumes
  defaults write com.apple.desktopservices DSDontWriteNetworkStores true
  # don't create .DS_Store files on USB volumes
  defaults write com.apple.desktopServices DSDontWriteUSBStores -bool true
  # show hidden files in Finder by default
  defaults write com.apple.finder AppleShowAllFiles YES
fi

# if rust env exists, source it
if [ -f "$HOME/.cargo/env" ]; then
  . "$HOME/.cargo/env"
fi
export PATH="$HOME/.local/bin:$PATH"

# Forgejo token - lazy-loaded from 1Password
forgejo_token() {
  if [ -z "$FORGEJO_ACCESS_TOKEN" ]; then
    FORGEJO_ACCESS_TOKEN=$(op read "op://rangle/forgejo Access Token/credential" 2>/dev/null)
    export FORGEJO_ACCESS_TOKEN
  fi
  echo "$FORGEJO_ACCESS_TOKEN"
}
