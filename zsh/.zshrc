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

# shell aliases
alias showFiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app'
alias hideFiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app'
alias zshconfig="mate ~/.zshrc"

# brew
alias brewup='brew update; brew upgrade; brew prune; brew cleanup; brew doctor'

# package management
alias pn=pnpm

# ssh
alias nfslogin='ssh jenchan_ifcatsneedart@ssh.phx.nearlyfreespeech.net'
alias thingymachine='ssh@68.183.204.78'
alias expose=../script/expose.sh

# python
alias python='python3'
alias pip='pip3'

# git
alias g='git'
# git worktrees
source ~/.dotfiles/scripts/create-worktree-from-pr.sh
alias cwp='create-worktree-from-pr'
source ~/.dotfiles/scripts/create-local-worktrees.sh
alias clw='create-local-worktrees'
source ~/.dotfiles/scripts/cleanup-merged-worktrees.sh
alias clean_merged_trees='cleanup-merged-worktrees'
source ~/.dotfiles/scripts/clean-worktree.sh
alias cwt='clean-worktree'
# gh cli
alias copilot='gh copilot'
alias gcs='gh copilot suggest'
alias gce='gh copilot explain'

# editors/code assistants
alias cc='claude code'
alias vi='nvim'
alias cursor='/Applications/Cursor.app/Contents/Resources/app/bin/cursor'

# databases
alias mysql=/usr/local/mysql/bin/mysql
alias mysqladmin=/usr/local/mysql/bin/mysqladmin

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

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

# php / Laravel
alias composer="php /usr/local/bin/composer.phar"
alias sail='[ -f sail ] && zsh sail || zsh vendor/bin/sail'
alias pint='./vendor/bin/pint'

# nektos/act
alias act='act --container-architecture linux/amd64'

# Auto-refresh devbox global environment on shell start
if command -v devbox >/dev/null 2>&1; then
    eval "$(devbox global shellenv --preserve-path-stack -r)"
fi
# Rust environment
source "$HOME/.cargo/env"
eval "$(ssh-agent -s)"
eval "$(~/.local/bin/mise activate)"

# pnpm
export PNPM_HOME="/Users/jenc/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
