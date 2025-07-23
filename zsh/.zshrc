

# ---- theme ----
ZSH_THEME="robbyrussell"

# ---- case-sensitive completion ----
# CASE_SENSITIVE="true"

# ---- hyphen-insensitive completion ----
# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

zstyle ':omz:update' mode auto      # update automatically without asking

# Uncomment the following line to change how often to auto-update (in days).
zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
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

# Set ZSH path before sourcing oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"

source $ZSH/oh-my-zsh.sh

# ---- Plugins ----
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-autosuggestions zsh-autocomplete 1password gh direnv)

# ---- User configuration --------

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
 if [[ -n $SSH_CONNECTION ]]; then
  echo "SSH connection detected"
  echo "EDITOR: ${EDITOR}"
 else
   export EDITOR='mvim'
 fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ------- aliases --------
# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
alias zshconfig="mate ~/.zshrc"
alias brewup='brew update; brew upgrade; brew prune; brew cleanup; brew doctor'
alias showFiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app'
alias hideFiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app'
alias nfslogin='ssh jenchan_ifcatsneedart@ssh.phx.nearlyfreespeech.net'
alias vi='nvim'
alias expose=../script/expose.sh
alias pip='pip3'
alias python='python3'
alias g='git'
alias copilot='gh copilot'
alias gcs='gh copilot suggest'
alias gce='gh copilot explain'
alias composer="php /usr/local/bin/composer.phar"
alias cc='claude code'
alias mysql=/usr/local/mysql/bin/mysql
alias mysqladmin=/usr/local/mysql/bin/mysqladmin
alias thingymachine='ssh@68.183.204.78'
alias pn=pnpm
alias cursor='/Applications/Cursor.app/Contents/Resources/app/bin/cursor'

export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# use iterm2 on zsh init
source ~/.iterm2_shell_integration.zsh

source ~/.dotfiles/scripts/create-worktree-from-pr.sh
alias cwp='create-worktree-from-pr'
source ~/.dotfiles/scripts/create-local-worktrees.sh
alias clw='create-local-worktrees'

export PKG_CONFIG_PATH="/usr/local/opt/mysql-client/lib/pkgconfig"
export PATH="/usr/local/opt/mysql-client/bin:$PATH"

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/jenc/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions

# Laravel / Sail
alias sail='[ -f sail ] && bash sail || bash vendor/bin/sail'
alias pint='./vendor/bin/pint'

# nektos/act
alias act='act --container-architecture linux/amd64'

eval "$(direnv hook zsh)"
eval "$(fnm env)"
eval "$(pyenv init -)"