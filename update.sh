#!/bin/sh
# Pull updates and sync dotfiles
# Updates git repo, submodules, packages, and dotfile symlinks

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "🔄 Pulling latest changes..."
git pull

echo ""
echo "📦 Updating submodules..."
git submodule update --init --recursive

echo ""
echo "📦 Installing/updating packages..."
./setup.sh

echo ""
echo "🔗 Updating dotfile symlinks..."
./stow-dotfiles.sh

echo ""
echo "✅ Update complete!"

