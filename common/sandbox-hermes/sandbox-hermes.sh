#!/usr/bin/env bash
# Standalone sandbox for Hermes Agent.
# Runs hermes inside a bwrap namespace with:
#   - ~/.hermes writable (config, memory, skills)
#   - ~/.local/bin read-only (hermes binary + other tools)
#   - HOME is tmpfs — SSH keys, AWS creds, etc. simply don't exist
#   - /usr and /nix available (system libs, Nix tools)
#   - Network shared (Telegram, web search)

set -euo pipefail

HERMES_BIN="${HERMES_BIN:-$HOME/.local/bin/hermes}"

# Validate
if [ ! -f "$HERMES_BIN" ]; then
  echo "❌ Hermes binary not found at $HERMES_BIN" >&2
  echo "   Install: curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash" >&2
  exit 1
fi
if [ ! -d "$HOME/.hermes" ]; then
  echo "❌ Hermes config not found at $HOME/.hermes" >&2
  exit 1
fi

# Resolve Nix profile for tool PATH (runs outside sandbox)
NIX_USER_PROFILE="$(readlink -f "$HOME/.nix-profile" 2>/dev/null || true)"
if [ -n "$NIX_USER_PROFILE" ] && [ -d "$NIX_USER_PROFILE/bin" ]; then
  SANDBOX_PATH="$NIX_USER_PROFILE/bin:/nix/var/nix/profiles/default/bin:/usr/bin:/usr/local/bin"
else
  SANDBOX_PATH="/nix/var/nix/profiles/default/bin:/usr/bin:/usr/local/bin"
fi

# Create a temp directory to serve as an empty HOME
SANDBOX_HOME="$(mktemp -d /tmp/sandbox-hermes-XXXXXX)"

echo "🧊 Hermes sandbox active"
echo "   Config:  $HOME/.hermes (writable)"
echo "   HOME:    isolated tmp (secrets don't exist)"
echo "   /usr:    read-only (system libs, bash)"
echo "   /nix:    available (curl, git, node, etc.)"
echo "   Network: shared (Telegram, web search)"
echo ""

exec bwrap \
  --ro-bind /nix /nix \
  --ro-bind /usr /usr \
  --ro-bind /lib64 /lib64 \
  --proc /proc \
  --dev /dev \
  --ro-bind /etc /etc \
  --ro-bind /run/systemd/resolve /run/systemd/resolve \
  --bind /tmp /tmp \
  --bind "$SANDBOX_HOME" "$HOME" \
  --bind "$HOME/.hermes" "$HOME/.hermes" \
  --ro-bind "$HOME/.local/bin" "$HOME/.local/bin" \
  --ro-bind "$HOME/.local/share" "$HOME/.local/share" \
  --setenv HOME "$HOME" \
  --setenv PATH "$SANDBOX_PATH" \
  --unshare-ipc \
  --cap-drop ALL \
  "$HERMES_BIN" "$@"
