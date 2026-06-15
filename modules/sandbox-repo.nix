{ pkgs, config, lib, ... }:

let
  sandbox-repo = pkgs.writeShellApplication {
    name = "sandbox-repo";
    runtimeInputs = with pkgs; [ bubblewrap git ];
    text = ''
      set -euo pipefail

      usage() {
        cat >&2 <<EOF
    Usage: sandbox-repo <path> [command...]

    Run a command (or interactive shell) inside a sandboxed workspace.
    The repo at <path> is mounted read-write at /workspace.
    ~/.ssh, ~/.aws, ~/.gnupg, ~/.config/gh are inaccessible.
    Network is shared (no --unshare-net) so you can fetch deps.

    If <path> doesn't exist, it's created and git-initialised.

    Examples:
      sandbox-repo ~/projects/my-app            # interactive shell in existing repo
      sandbox-repo ./fresh-project               # creates, git inits, drops in
      sandbox-repo . nix build                   # runs nix build in sandbox
    EOF
        exit 1
      }

      # ---- arg parsing ----
      REPO_PATH="''${1:-}"
      [ -n "$REPO_PATH" ] || usage
      shift || true

      # Resolve to absolute path (don't require it to exist yet)
      REPO_PATH="$(realpath -m "$REPO_PATH")"

      # Create + git init if new
      if [ ! -d "$REPO_PATH" ]; then
        mkdir -p "$REPO_PATH"
        git init "$REPO_PATH"
        echo "📁 Created new repo at $REPO_PATH"
      fi

      # ---- what to run ----
      if [ $# -eq 0 ]; then
        set -- bash
      fi

      # ---- runtime info ----
      echo "🧊 Sandbox active"
      echo "   Workspace:  /workspace → $REPO_PATH (read-write)"
      echo "   /home:      tmpfs (isolated)"
      echo "   /nix:       available"
      echo "   Network:    shared"
      echo "   Command:    $*"
      echo ""

      exec bwrap \
        --bind /nix /nix \
        --bind "$REPO_PATH" /workspace \
        --proc /proc \
        --dev /dev \
        --ro-bind /etc /etc \
        --bind /tmp /tmp \
        --tmpfs /home \
        --setenv HOME /tmp \
        --setenv SANDBOXED 1 \
        --unshare-ipc \
        --chdir /workspace \
        --cap-drop ALL \
        "$@"
    '';
  };
in {
  home.packages = [ sandbox-repo ];
}
