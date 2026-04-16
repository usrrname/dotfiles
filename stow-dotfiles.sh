#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
cd "$SCRIPT_DIR"

OS=$(uname -s)

IS_NIXOS=false
if [[ "$OS" == "Linux" ]]; then
  if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    if [[ "$ID" == "nixos" ]]; then
      IS_NIXOS=true
    fi
  elif [[ -d /etc/nixos ]]; then
    IS_NIXOS=true
  fi
fi

if [[ $# -eq 0 ]]; then
  STOW_FLAGS="--adopt"
elif [[ -z "$1" ]]; then
  STOW_FLAGS=""
else
  STOW_FLAGS="$1"
fi

COMMON=(
  bash
  nvim
  direnv
  ssh
  gh
  mc
  opencode
  vim
  zed
  wezterm
  tmux
)

LINUX=(
  git
  zsh
  zprofile
)

MACOS=(
  git
  act
  iterm2
  yarn
  husky
  verdaccio
  zsh
  zprofile
)

unstow_all() {
  echo "Unstowing all packages..."
  for pkg in "${COMMON[@]}" "${LINUX[@]}" "${MACOS[@]}"; do
    for dir in common linux macos; do
      if [[ -d "$dir/$pkg" ]]; then
        stow -D -d "$dir" -t ~ "$pkg" 2>/dev/null || true
      fi
    done
  done
}

clean_symlinks() {
  echo "Cleaning existing symlinks pointing to .dotfiles..."

  find ~ -maxdepth 3 -type l 2>/dev/null | while read -r link; do
    target=$(readlink "$link" 2>/dev/null || true)
    if [[ "$target" == *".dotfiles/"* ]]; then
      echo "   Removing: $link -> $target"
      rm -f "$link"
    fi
  done

  if [[ "$OS" == "Darwin" ]]; then
    find . -name ".DS_Store" -delete 2>/dev/null || true
    rm -f ~/.config/.DS_Store ~/.DS_Store 2>/dev/null || true
  fi
}

stow_package() {
  local pkg="$1"
  local dir="${2:-common}"
  if [[ -d "$dir/$pkg" ]] && [[ -n "$(ls -A "$dir/$pkg" 2>/dev/null)" ]]; then
    echo "Stowing $pkg..."
    if [[ "$OS" == "Darwin" ]]; then
      find "$dir/$pkg" -name ".DS_Store" -delete 2>/dev/null || true
    fi
    local stow_output
    stow_output=$(stow $STOW_FLAGS -d "$dir" -t ~ "$pkg" 2>&1) && {
      echo "   $pkg stowed successfully"
    } || {
      echo "   Warning: Could not stow $pkg"
      echo "   Error: $stow_output"
    }
  else
    echo "Skipping $dir/$pkg (directory doesn't exist or is empty)"
  fi
}

echo "Setting up dotfiles for $OS..."
echo ""

if [[ "$STOW_FLAGS" == "--adopt" ]]; then
  if [[ ! -d "$HOME/.dotfiles" ]]; then
    echo "No existing .dotfiles folder found. Skipping cleanup."
  else
    unstow_all
    clean_symlinks
  fi
  echo ""
fi

echo "Stowing common packages..."
for pkg in "${COMMON[@]}"; do
  stow_package "$pkg" common
done

if [[ "$OS" == "Darwin" ]]; then
  echo ""
  echo "Stowing macOS-specific packages..."
  for pkg in "${MACOS[@]}"; do
    stow_package "$pkg" macos
  done
elif [[ "$OS" == "Linux" ]] && [[ "$IS_NIXOS" == "false" ]]; then
  echo ""
  echo "Stowing Linux-specific packages..."
  for pkg in "${LINUX[@]}"; do
    stow_package "$pkg" linux
  done
fi

echo ""
echo "Dotfiles setup complete!"
