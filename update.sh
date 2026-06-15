#!/bin/sh
# Pull updates and sync dotfiles
# Updates git repo, submodules, and applies Nix configuration

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "🔄 Pulling latest changes..."
git pull

echo ""
echo "📦 Updating submodules..."
git submodule update --init --recursive

echo ""
echo "⚙️  Applying configuration..."
./setup.sh

echo ""
echo "✅ Update complete!"
