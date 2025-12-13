# bashrc completion
if [ -f ~/.nix-profile/etc/bash_completion.d/nix ]; then
  source ~/.nix-profile/etc/bash_completion.d/nix
fi

# Only start ssh-agent if not already running
if [ -z "$SSH_AUTH_SOCK" ]; then
  eval "$(ssh-agent -s)" > /dev/null
fi