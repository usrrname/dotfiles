# Raspberry Pi-specific zsh configuration
# Inherits from Linux config, add Pi-specific overrides here

# ---- Source Linux base config ----
if [ -f "$HOME/.dotfiles/stow/linux/zsh/.zshrc" ]; then
    source "$HOME/.dotfiles/stow/linux/zsh/.zshrc"
fi

# ---- Pi-specific aliases ----
# Example Pi-specific aliases:
# alias pi-temp='vcgencmd measure_temp'
# alias pi-reboot='sudo reboot'

# ---- Pi-specific paths ----
# Add any Pi-specific paths here

# ---- Hardware-specific ----
# For Raspberry Pi hardware utilities
# export PATH="$HOME/.local/bin:$PATH"
