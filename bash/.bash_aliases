# Functions
mkcd() {
  mkdir -p "$1" && cd "$1"
}

extract() {
  if [ -f $1 ]; then
    case $1 in
    *.tar.bz2) tar xjf $1 ;;
    *.tar.gz) tar xzf $1 ;;
    *.bz2) bunzip2 $1 ;;
    *.rar) unrar e $1 ;;
    *.gz) gunzip $1 ;;
    *.tar) tar xf $1 ;;
    *.tbz2) tar xjf $1 ;;
    *.tgz) tar xzf $1 ;;
    *.zip) unzip $1 ;;
    *.Z) uncompress $1 ;;
    *.7z) 7z x $1 ;;
    *) echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

alias update='sudo apt update && sudo apt upgrade'
alias install='sudo apt install'
alias remove='sudo apt remove'
alias search='apt search'
alias py='python3'
alias pip='pip3'

# Improved directory listing
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# git
alias g='git'

# gh cli
alias copilot='gh copilot'
alias gcs='gh copilot suggest'
alias gce='gh copilot explain'

# Make files untracked by git
# example: untrack <filename>
alias untrack='git update-index --assume-unchanged'
# example: restore-tracking <filename>
alias 'restore-tracking'='git update-index --no-assume-unchanged'

# editors/code assistants
alias cc='claude code'
alias vi='/opt/nvim/bin/nvim'
alias nvim='/opt/nvim/bin/nvim'
alias xoff='sudo /usr/local/bin/xSoft.sh 0 27'

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  alias dir='dir --color=auto'
  alias vdir='vdir --color=auto'

  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

cd() {
  builtin cd "$@" || return

  if [ "$PWD" = "$HOME" ] || [[ $PWD == "$HOME"/* ]]; then
    ls -AClht --color=auto --group-directories-first --time-style=full-iso
  fi
}
