# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# Set up fzf key bindings and fuzzy completion
eval "$(fzf --bash)"
eval "$(devbox global shellenv --init-hook)"
eval "$(direnv hook bash)"
eval "$(pyenv init -)"
# cargo
. "$HOME/.cargo/env"
