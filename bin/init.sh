#!/bin/bash
set -e

cd "$(dirname "$0")/.."

OS=$(uname -s)
DIR=""

case "$OS" in
  Darwin) DIR="common macos" ;;
  Linux)
    if [[ -f /etc/os-release ]]; then
      . /etc/os-release
      if [[ "$ID" == "nixos" ]]; then
        echo "NixOS detected. Managing via /etc/nixos/configuration.nix instead."
        exit 0
      fi
    fi
    DIR="common linux"
    ;;
  *) echo "Unsupported OS: $OS"; exit 1 ;;
esac

echo "Detected $OS — configuring sparse-checkout for: $DIR"
git sparse-checkout set $DIR

echo ""
echo "Stowing dotfiles..."
./stow-dotfiles.sh

echo ""
echo "Done! Restart your shell or source ~/.zshrc (or ~/.bashrc)"
