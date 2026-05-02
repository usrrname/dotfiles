#!/usr/bin/env bash
set -euo pipefail

detect_os() {
  local uname_out
  uname_out="$(uname -s)"
  case "${uname_out}" in
  Linux*) echo "Linux" ;;
  Darwin*) echo "Mac" ;;
  CYGWIN*) echo "Cygwin" ;;
  MINGW*) echo "MinGw" ;;
  *) echo "UNKNOWN:${uname_out}" ;;
  esac
}

uninstall_nix_mac() {
  echo "Detected macOS. Uninstalling Nix..."

  if ! command -v nix &>/dev/null; then
    echo "Nix is not installed on this system."
    exit 0
  fi

  echo "Stopping Nix daemon..."
  sudo launchctl unload /Library/LaunchDaemons/org.nixos.nix-daemon.plist 2>/dev/null || true
  sudo rm -f /Library/LaunchDaemons/org.nixos.nix-daemon.plist

  echo "Removing Nix store and related directories..."
  sudo rm -rf /nix
  sudo rm -rf /etc/nix
  sudo rm -rf /var/root/.nix-profile
  sudo rm -rf /var/root/.nix-defexpr
  sudo rm -rf /var/root/.nix-channels

  echo "Removing Nix from shell profiles..."
  if [ -f /etc/bashrc ]; then
    sudo sed -i.bak '/# Nix/,/# End Nix/d' /etc/bashrc
    sudo rm -f /etc/bashrc.bak
  fi

  if [ -f /etc/zshrc ]; then
    sudo sed -i.bak '/# Nix/,/# End Nix/d' /etc/zshrc
    sudo rm -f /etc/zshrc.bak
  fi

  if [ -f /etc/bash.bashrc ]; then
    sudo sed -i.bak '/# Nix/,/# End Nix/d' /etc/bash.bashrc
    sudo rm -f /etc/bash.bashrc.bak
  fi

  echo "Removing nixbld users and group..."
  for i in {1..32}; do
    sudo dscl . -delete /Users/nixbld${i} 2>/dev/null || true
  done
  sudo dscl . -delete /Groups/nixbld 2>/dev/null || true

  echo "Cleaning up user-specific Nix files..."
  rm -rf ~/.nix-profile
  rm -rf ~/.nix-defexpr
  rm -rf ~/.nix-channels
  rm -rf ~/.local/state/nix
  rm -rf ~/.cache/nix

  echo "Nix has been uninstalled successfully."
  echo "Please restart your terminal or run 'exec $SHELL -l' to apply changes."
}

main() {
  local os
  os=$(detect_os)

  if [ "$os" = "Mac" ]; then
    uninstall_nix_mac
  else
    echo "This script only supports macOS. Detected OS: $os"
    echo "For other operating systems, please use the appropriate Nix uninstall method."
    exit 1
  fi
}

main "$@"
