{ pkgs, config, lib, ... }:

let
  sandbox-browser = pkgs.writeShellApplication {
    name = "sandbox-browser";
    runtimeInputs = with pkgs; [ bubblewrap ];
    text = ''
      set -euo pipefail

      SANDBOX_DIR="''${SANDBOX_DIR:-$HOME/.sandbox-browser}"
      BROWSER=''${1:-}
      shift || true

      # Resolve browser — default to chromium if no arg given
      if [ -z "$BROWSER" ]; then
        BROWSER="${lib.getExe pkgs.chromium}"
      elif ! command -v "$BROWSER" >/dev/null 2>&1; then
        echo "❌ Browser not found: $BROWSER" >&2
        exit 1
      fi

      mkdir -p "$SANDBOX_DIR"/{cache,config,downloads}

      if ! command -v bwrap >/dev/null 2>&1; then
        echo "❌ bubblewrap (bwrap) not found — install it first" >&2
        exit 1
      fi

      echo "🌐 Starting sandboxed browser..."
      echo "   Profile dir: $SANDBOX_DIR/config"
      echo "   Cache dir:   $SANDBOX_DIR/cache"
      echo "   Downloads:   $SANDBOX_DIR/downloads"
      echo "   Browser:     $BROWSER"
      echo ""

      exec bwrap \
        --ro-bind /nix /nix \
        --proc /proc \
        --dev /dev \
        --dev-bind /dev/dri /dev/dri \
        --dev-bind /dev/shm /dev/shm \
        --ro-bind /etc /etc \
        --ro-bind /run /run \
        --bind /tmp /tmp \
        --bind "$SANDBOX_DIR/cache" "$HOME/.cache" \
        --bind "$SANDBOX_DIR/config" "$HOME/.config" \
        --bind "$SANDBOX_DIR/downloads" "$HOME/Downloads" \
        --tmpfs "$HOME/.ssh" \
        --tmpfs "$HOME/.gnupg" \
        --tmpfs "$HOME/.aws" \
        --tmpfs "$HOME/.config/gh" \
        --cap-drop ALL \
        "$BROWSER" "$@"
    '';
  };
in {
  home.packages = [ sandbox-browser ];
}
