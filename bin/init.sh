#!/bin/bash
set -e

cd "$(dirname "$0")/.."

OS=$(uname -s)
DIR=""

setup_nixos() {
    echo "NixOS detected. Setting up configuration..."
    if [[ ! -d /etc/nixos ]]; then
        echo "Error: /etc/nixos does not exist. Are you running NixOS?"
        exit 1
    fi
    if [[ -f /etc/nixos/configuration.nix ]]; then
        echo "Warning: /etc/nixos/configuration.nix already exists."
        read -p "Overwrite? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Skipping configuration copy."
        else
            echo "Copying configuration.nix to /etc/nixos..."
            sudo cp nix/etc/nixos/configuration.nix /etc/nixos/configuration.nix
        fi
    else
        echo "Copying configuration.nix to /etc/nixos..."
        sudo cp nix/etc/nixos/configuration.nix /etc/nixos/configuration.nix
    fi
    echo "Building NixOS configuration..."
    sudo nixos-rebuild switch
    echo "Done! Restart your shell or source /etc/profile"
    exit 0
}

case "$OS" in
  Darwin) DIR="common macos" ;;
  Linux)
    if [[ -f /etc/os-release ]]; then
      . /etc/os-release
      if [[ "$ID" == "nixos" ]]; then
        setup_nixos
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
