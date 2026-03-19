# macOS zprofile - sources .zprofile.osx at end
# This file is stowed to ~/.zprofile on macOS

# Source macOS-specific configuration
if [ -f "$HOME/.zprofile.osx" ]; then
  source "$HOME/.zprofile.osx"
fi
