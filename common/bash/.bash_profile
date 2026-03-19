# In bash/.bash_profile
# Get the aliases and functions
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
  . ~/.bash_login
fi

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# Set up fzf key bindings and fuzzy completion
eval "$(fzf --bash)"
# If devbox exists, initialize it
if [ -f "$HOME/.devbox/shellenv" ]; then
  eval "$(devbox global shellenv --init-hook)"
fi
eval "$(direnv hook bash)"
