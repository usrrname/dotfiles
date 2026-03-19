# Linux zprofile - sources .zprofile.linux at end
# This file is stowed to ~/.zprofile on Linux

# Source Linux-specific configuration
if [ -f "$HOME/.zprofile.linux" ]; then
  source "$HOME/.zprofile.linux"
fi
