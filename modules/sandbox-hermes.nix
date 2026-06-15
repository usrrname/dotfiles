{ pkgs, config, lib, ... }:

let
  sandbox-hermes = pkgs.writeShellApplication {
    name = "sandbox-hermes";
    runtimeInputs = with pkgs; [ bubblewrap ];
    text = ''
      set -euo pipefail

      # Resolve Hermes paths before entering namespace
      HERMES_BIN="''${HERMES_BIN:-$HOME/.local/bin/hermes}"
      HERMES_CONFIG="$HOME/.hermes"

      if [ ! -f "$HERMES_BIN" ]; then
        echo "❌ Hermes binary not found at $HERMES_BIN" >&2
        echo "   Install it first: curl -fsSL https://raw.githubusercontent.com/..." >&2
        exit 1
      fi

      if [ ! -d "$HERMES_CONFIG" ]; then
        echo "❌ Hermes config not found at $HERMES_CONFIG" >&2
        exit 1
      fi

      # Resolve real paths
      HERMES_BIN="$(readlink -f "$HERMES_BIN")"
      HERMES_CONFIG="$(readlink -f "$HERMES_CONFIG")"

      # Resolve user Nix profile for tool PATH
      NIX_USER_PROFILE="$(readlink -f "$HOME/.nix-profile" 2>/dev/null || true)"
      if [ -n "$NIX_USER_PROFILE" ] && [ -d "$NIX_USER_PROFILE/bin" ]; then
        SANDBOX_PATH="$NIX_USER_PROFILE/bin:/nix/var/nix/profiles/default/bin:$PATH"
      else
        SANDBOX_PATH="$PATH"
      fi

      echo "🧊 Hermes sandbox active"
      echo "   Config:  $HERMES_CONFIG"
      echo "   Binary:  $HERMES_BIN"
      echo "   /nix:    available"
      echo "   Sealed:  ~/.ssh, ~/.aws, ~/.gnupg, ~/.config/gh"
      echo "   Network: shared (Telegram, web)"
      echo ""

      exec bwrap \
        --ro-bind /nix /nix \
        --proc /proc \
        --dev /dev \
        --ro-bind /etc /etc \
        --bind /tmp /tmp \
        --bind "$HERMES_BIN" "$HERMES_BIN" \
        --bind "$HERMES_CONFIG" "$HERMES_CONFIG" \
        --tmpfs "$HOME/.ssh" \
        --tmpfs "$HOME/.aws" \
        --tmpfs "$HOME/.gnupg" \
        --tmpfs "$HOME/.config/gh" \
        --setenv PATH "$SANDBOX_PATH" \
        --unshare-ipc \
        --cap-drop ALL \
        "$HERMES_BIN" "$@"
    '';
  };
in {
  home.packages = [ sandbox-hermes ];
}
