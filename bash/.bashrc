# bashrc
if [ -f ~/.bash_aliases ]; then
. ~/.bash_aliases
fi

# enable bash completion
if [ -f /etc/bash_completion ]; then
  source /etc/bash_completion
else
  echo "⚠️ Warning: Bash completion file not found at /etc/bash_completion"
fi

# enable direnv
eval "$(direnv hook bash)"