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
	zed
)

LINUX=(
	zsh
	zprofile
)

MACOS=(
	act
	iterm2
	yarn
	husky
	verdaccio
	zsh
	zprofile
)

stow_package() {
	local pkg="$1"
	local dir="${2:-common}"
	if [[ -d "$dir/$pkg" ]] && [[ -n "$(ls -A "$dir/$pkg" 2>/dev/null)" ]]; then
		if [[ "$STOW_FLAGS" != "--adopt" ]]; then
			local existing=$(find "$dir/$pkg" -type f -exec test -e ~/{} \; -print 2>/dev/null | head -5)
			if [[ -n "$existing" ]]; then
				echo "   Warning: Existing files will be replaced: $existing"
			fi
		fi
		echo "Stowing $pkg..."
		if stow $STOW_FLAGS -d "$dir" "$pkg" 2>/dev/null; then
			echo "   $pkg stowed successfully"
		else
			echo "   Warning: Could not stow $pkg"
		fi
	else
		echo "Skipping $dir/$pkg (directory doesn't exist or is empty)"
	fi
}

unstow_package() {
	local pkg="$1"
	local dir="${2:-common}"
	if [[ -d "$dir/$pkg" ]]; then
		stow -D -d "$dir" "$pkg" 2>/dev/null || true
	fi
}

echo "Setting up dotfiles for $OS..."
echo ""

if [[ "$STOW_FLAGS" == "--adopt" ]]; then
	echo "Cleaning old symlinks and .DS_Store files..."
	for pkg in "${COMMON[@]}" "${LINUX[@]}" "${MACOS[@]}"; do
		unstow_package "$pkg" common 2>/dev/null || true
		unstow_package "$pkg" linux 2>/dev/null || true
		unstow_package "$pkg" macos 2>/dev/null || true
	done
	rm -f ~/.config/.DS_Store ~/.DS_Store 2>/dev/null || true

	find ~ -maxdepth 2 -type l -name ".*" 2>/dev/null | while read -r link; do
		link_target=$(readlink "$link" 2>/dev/null || true)
		if [[ "$link_target" == *".dotfiles/"* ]] && [[ "$link_target" != *".dotfiles/common/"* ]] && [[ "$link_target" != *".dotfiles/macos/"* ]] && [[ "$link_target" != *".dotfiles/linux/"* ]]; then
			echo "   Removing old symlink: $link -> $link_target"
			rm -f "$link"
		fi
	done
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
