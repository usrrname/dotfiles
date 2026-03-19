# OPENSPEC:START
# OpenSpec shell completions configuration
fpath=("/Users/jenc/.oh-my-zsh/custom/completions" $fpath)
autoload -Uz compinit
compinit
# OPENSPEC:END

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# ---- theme ----
export PROMPT='~🧻 '
export ZSH_THEME="robbyrussell"

# Uncomment the following line to change how often to auto-update (in days).
zstyle ':omz:update' frequency 13

COMPLETION_WAITING_DOTS="true"

# Disable marking untracked files under VCS as dirty
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Timestamp format for history
HIST_STAMPS="yyyy-mm-dd"

# ---- Plugins ----
plugins=(git 1password gh zsh-autosuggestions zsh-autocomplete direnv)

# Set ZSH path before sourcing oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
source "$ZSH/oh-my-zsh.sh"
export NVM_DIR="$HOME/.nvm"

# ---- User configuration --------

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  echo "🔒 SSH connection detected"
else
  export EDITOR='nvim'
fi

# ---- Shared aliases --------
alias vi='nvim'

# uv
eval "$(uv generate-shell-completion zsh)"
export PATH="$HOME/.local/bin:$PATH"

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

source ~/.aliasrc-osx
