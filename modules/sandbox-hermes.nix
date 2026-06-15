{ pkgs, config, lib, ... }:

let
  sandbox-hermes = pkgs.writeShellApplication {
    name = "sandbox-hermes";
    runtimeInputs = with pkgs; [ bubblewrap ];
    text = ''
      set -euo pipefail

      HERMES_BIN="''${HERMES_BIN:-$HOME/.local/bin/hermes}"

      if [ ! -f "$HERMES_BIN" ]; then
        echo "❌ Hermes binary not found at $HERMES_BIN" >&2
        echo "   Install it first: curl -fsSL https://raw.githubusercontent.com/..." >&2
        exit 1
      fi
      if [ ! -d "$HOME/.hermes" ]; then
        echo "❌ Hermes config not found at $HOME/.hermes" >&2
        exit 1
      fi

      # Resolve user Nix profile for tool PATH
      NIX_USER_PROFILE="$(readlink -f "$HOME/.nix-profile" 2>/dev/null || true)"
      if [ -n "$NIX_USER_PROFILE" ] && [ -d "$NIX_USER_PROFILE/bin" ]; then
        SANDBOX_PATH="$NIX_USER_PROFILE/bin:/nix/var/nix/profiles/default/bin:$PATH"
      else
        SANDBOX_PATH="$PATH"
      fi

      echo "🧊 Hermes sandbox active"
      echo "   Config:  $HOME/.hermes (writable)"
      echo "   Home:    read-only except sealed paths"
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
        --ro-bind "$HOME" "$HOME" \
        --bind "$HOME/.hermes" "$HOME/.hermes" \
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
