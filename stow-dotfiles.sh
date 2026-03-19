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
	git
	direnv
	ssh
	docker
	gh
	op
	vim
	zsh
	zprofile
)

LINUX_PACKAGES=(
	zsh
	zprofile
)

MACOS_PACKAGES=(
	act
	iterm2
	zsh
	zprofile
	yarn
)

stow_package() {
	local pkg="$1"
	if [[ -d "$pkg" ]] && [[ -n "$(ls -A "$pkg" 2>/dev/null)" ]]; then
		echo "Stowing $pkg..."
		if stow $STOW_FLAGS -d common "$pkg" 2>/dev/null; then
			echo "   $pkg stowed successfully"
		else
			echo "   Warning: Could not stow $pkg"
		fi
	else
		echo "Skipping $pkg (directory doesn't exist or is empty)"
	fi
}

echo "Setting up dotfiles for $OS..."
echo ""

echo "Stowing common packages..."
for pkg in "${COMMON[@]}"; do
	stow_package "$pkg"
done

if [[ "$OS" == "Darwin" ]]; then
	echo ""
	echo "Stowing macOS-specific packages..."
	for pkg in "${MACOS_PACKAGES[@]}"; do
		stow_package "$pkg"
	done
fi

echo ""
echo "Dotfiles setup complete!"
