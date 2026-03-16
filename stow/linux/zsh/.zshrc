# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# ---- Basic Configuration ----
export EDITOR="nvim"
export VISUAL="$EDITOR"

# ---- Theme ----
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

# ---- Plugins ----
plugins=(git direnv zsh-autosuggestions zsh-autocomplete)

# ---- Load oh-my-zsh ----
source "$ZSH/oh-my-zsh.sh"

# ---- User Configuration ----
export PATH="$HOME/.local/bin:$PATH"

# ---- Linux-specific aliases ----
alias ll='ls -la'
alias la='ls -a'

# ---- 1Password SSH Agent ----
# Enable 1Password SSH agent on Linux
# Requires: op (1Password CLI) and op-ssh-agent
if command -v op &> /dev/null; then
    # Set SSH_AUTH_SOCK for 1Password
    export SSH_AUTH_SOCK="$HOME/.1Password/agent.sock"
    
    # Start op-ssh-agent if not running
    if [ ! -S "$SSH_AUTH_SOCK" ]; then
        op-ssh-agent --startup 2>/dev/null || true
    fi
fi
