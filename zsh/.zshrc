# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# ---- theme ----
export PROMPT='~🧻 '
ZSH_THEME="robbyrussell"

zstyle ':omz:update' mode auto # update automatically without asking

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
plugins=(git zsh-autosuggestions zsh-autocomplete 1password gh direnv)

# Set ZSH path before sourcing oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"
source $ZSH/oh-my-zsh.sh
export NVM_DIR="$HOME/.nvm"
export ZSH_CUSTOM="$HOME/zsh/custom"
# ---- User configuration --------

# Preferred editor for local and remote sessions
 if [[ -n $SSH_CONNECTION ]]; then
  echo "SSH connection detected"
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
source $ZSH_CUSTOM/alias

# use iterm2 on zsh init
source ~/.iterm2_shell_integration.zsh

# mysql
export PKG_CONFIG_PATH="/usr/local/opt/mysql-client/lib/pkgconfig"
export PATH="/usr/local/opt/mysql-client/bin:$PATH"

# Docker CLI completions.
fpath=(/Users/jenc/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions


# Auto-refresh devbox global environment on shell start
if command -v devbox >/dev/null 2>&1; then
    eval "$(devbox global shellenv --preserve-path-stack -r)"
fi
# Rust environment
source "$HOME/.cargo/env"

eval "$(ssh-agent -s)"
# Mise
eval "$(/Users/jenc/.local/bin/mise activate zsh)"

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