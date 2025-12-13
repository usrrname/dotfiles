# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# ---- theme ----
export PROMPT='~🧻 '
export ZSH_THEME="robbyrussell"

# zstyle ':omz:update' mode auto # update automatically without asking

# Uncomment the following line to change how often to auto-update (in days).
zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="yyyy-mm-dd"

# ---- Plugins ----
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
plugins=(git 1password gh autosuggestions autocomplete direnv)

# Set ZSH path before sourcing oh-my-zsh
export ZSH="$HOME/.zsh"
export ZSH_PLUGINS="$HOME/.zsh/plugins"
export ZSH_CUSTOM="$HOME/.zsh/custom"
source $ZSH/oh-my-zsh.sh
export NVM_DIR="$HOME/.nvm"

# ---- User configuration --------

# Preferred editor for local and remote sessions
 if [[ -n $SSH_CONNECTION ]]; then
  echo "🔒 SSH connection detected"
 else
   export EDITOR='nvim'
 fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ------- aliases --------
# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.

# get aliases
if [ -f "$ZSH_CUSTOM/.aliasrc" ]; then
  source "$ZSH_CUSTOM/.aliasrc"
else
  echo "⚠️ Warning: Alias file not found at $ZSH_CUSTOM/.aliasrc"
fi  

# use iterm2 on zsh init
source ~/.iterm2_shell_integration.zsh

# mysql
export PKG_CONFIG_PATH="/usr/local/opt/mysql-client/lib/pkgconfig"
export PATH="/usr/local/opt/mysql-client/bin:$PATH"

# Docker CLI completions.
fpath=(/Users/jenc/.docker/completions $fpath)
# End of Docker CLI completions

# devbox called only when11 1``
devbox() {
  unfunction devbox
  eval "$(command devbox global shellenv --preserve-path-stack -r)"
  command devbox "$@"
}

# Only start ssh-agent if not already running
if [ -z "$SSH_AUTH_SOCK" ]; then
  eval "$(ssh-agent -s)" > /dev/null
fi

# pnpm
export PNPM_HOME="/Users/jenc/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
# uv
eval "$(uv generate-shell-completion zsh)"
export PATH="$HOME/.local/bin:$PATH"