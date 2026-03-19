# macOS-specific zshrc

# mysql
export PKG_CONFIG_PATH="/usr/local/opt/mysql-client/lib/pkgconfig"
export PATH="/usr/local/opt/mysql-client/bin:$PATH"

# Docker CLI completions.
fpath=(/Users/jenc/.docker/completions $fpath)

# SSH agent socket for 1Password integration
export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock

# Only start ssh-agent if not already running
if [ -z "$SSH_AUTH_SOCK" ]; then
  eval "$(ssh-agent -s)" > /dev/null
fi

# Add SSH key to agent with macOS keychain support
if ! ssh-add -l 2>/dev/null | grep -q "id_ed25519"; then
  ssh-add --apple-use-keychain ~/.ssh/id_ed25519 2>/dev/null || true
  ssh-add --apple-use-keychain ~/.ssh/id_rsa 2>/dev/null || true
fi

# pnpm
export PNPM_HOME="/Users/jenc/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# mysql if using mysql
if [[ -f /opt/homebrew/opt/mysql/bin/mysql ]]; then
  export PATH="/opt/homebrew/opt/mysql/bin:$PATH"
  export PATH="/opt/homebrew/opt/mysql@8.0/bin:$PATH"
  export PATH="/opt/homebrew/opt/mysql@8.4/bin:$PATH"
  export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"
fi

# add homebrew sbin to path
export PATH="/opt/homebrew/sbin:$PATH"

# Load fnm (Fast Node Manager)
eval "$(fnm env --use-on-cd)"

# opencode
export PATH=/Users/jenc/.opencode/bin:$PATH
