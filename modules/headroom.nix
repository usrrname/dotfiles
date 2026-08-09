{
  config,
  lib,
  pkgs,
  ...
}: let
  # headroom is PyPI-only (not in nixpkgs). Pin the exact version so every
  # host (and any sandbox built from this flake) reproduces the same proxy +
  # MCP behavior; `headroom update` can't silently diverge them.
  headroomVersion = "0.34.0";
  # Install (or align) the CLI. `uv tool install --force` recreates the venv
  # when the pinned version differs; guarded so matching installs are a no-op.
  ensureHeadroom = ''
    export PATH="$HOME/.local/bin:${pkgs.uv}/bin:$PATH"
    if ! command -v headroom >/dev/null 2>&1 \
      || [ "$(headroom --version 2>/dev/null | grep -o 'version [0-9.]*' | cut -d' ' -f2)" != "${headroomVersion}" ]; then
      $DRY_RUN_CMD uv tool install --force --python 3.13 "headroom-ai[proxy]==${headroomVersion}"
    fi
  '';
in {
  options.headroom.enable = lib.mkEnableOption "headroom context-compression setup (uv CLI + agent MCP config)";

  config = lib.mkIf config.headroom.enable {
    # Ownership boundary:
    #   - Nix owns the CLI install and the proxy lifecycle (launchd on macOS,
    #     systemd/container-init elsewhere).
    #   - headroom owns its agent config. `headroom mcp install` writes the
    #     MCP server entry for every detected agent (claude, opencode, codex,
    #     ...) and tracks fingerprints in ~/.headroom/mcp_installs.json;
    #     `headroom init claude` installs durable hooks + provider routing.
    #     Never hand-edit those blocks — headroom regenerates them.
    # Re-ran at every activation so a rebuild can't silently stale the agent
    # config; both commands are idempotent (--force only overwrites on
    # fingerprint mismatch). Sandboxes reproduce the same recipe with their
    # own $HOME and a local proxy on the same port.
    home.activation.headroom = lib.hm.dag.entryAfter ["writeBoundary"] ''
      ${ensureHeadroom}
      $DRY_RUN_CMD headroom mcp install --force
      $DRY_RUN_CMD headroom init claude
    '';

    home.packages = [pkgs.uv];
  };
}
