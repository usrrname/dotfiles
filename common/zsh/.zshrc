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

# devbox called only when `devbox` is typed
devbox() {
  unfunction devbox
  eval "$(command devbox global shellenv --preserve-path-stack -r)"
  command devbox "$@"
}

# uv
eval "$(uv generate-shell-completion zsh)"
export PATH="$HOME/.local/bin:$PATH"
