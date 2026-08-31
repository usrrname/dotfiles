# Bash-specific aliases.
# Shared base aliases (ll, g, vi, ...) are managed via
# programs.bash.shellAliases (see modules/aliases.nix).
#
# Deployed to ~/.bash_aliases by modules/bash/bash.nix and sourced from
# .bashrc. Edit this file in the repo and rebuild to apply.

# Bash-only aliases
alias cc='claude code'
alias reload='source ~/.bashrc'

# Direnv helpers
alias da='direnv allow'
alias dr='direnv reload'

# Run Nix garbage collection
alias ngc='nix-env --delete-generations old && nix-store --gc'

# OS-specific package manager aliases (detected at runtime)
if command -v dnf >/dev/null 2>&1; then
  alias update='sudo dnf update && sudo dnf upgrade'
  alias install='sudo dnf install'
  alias remove='sudo dnf remove'
  alias autoremove='sudo dnf autoremove'
  alias search='sudo dnf search'
else
  alias update='sudo apt update && sudo apt upgrade'
  alias install='sudo apt install'
  alias remove='sudo apt remove'
  alias autoremove='sudo apt autoremove'
  alias search='sudo apt search'
fi