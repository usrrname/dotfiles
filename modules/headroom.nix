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

  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
  username = config.home.username;
  homeDir = config.home.homeDirectory;

  # Install (or align) the CLI. `uv tool install --force` recreates the venv
  # when the pinned version differs; guarded so matching installs are a no-op.
  ensureHeadroom = ''
    export PATH="$HOME/.local/bin:${pkgs.uv}/bin:$PATH"
    if ! command -v headroom >/dev/null 2>&1 \
      || [ "$(headroom --version 2>/dev/null | grep -o 'version [0-9.]*' | cut -d' ' -f2)" != "${headroomVersion}" ]; then
      $DRY_RUN_CMD uv tool install --force --python 3.13 "headroom-ai[proxy]==${headroomVersion}"
    fi
  '';

  # Shared bootstrap script for proxy startup (works on Darwin + Linux)
  headroomProxy = name: args:
    pkgs.writeShellScript "headroom-proxy-${name}" ''
      export PATH="$HOME/.local/bin:${pkgs.uv}/bin:$PATH"
      if ! command -v headroom >/dev/null 2>&1; then
        uv tool install --force --python 3.13 "headroom-ai[proxy]==${headroomVersion}"
      fi
      exec headroom proxy ${args}
    '';
in {
  options.headroom.enable = lib.mkEnableOption "headroom context-compression setup (uv CLI + agent MCP config)";
  options.headroom.enableService = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable headroom proxy service (launchd on macOS, systemd on Linux)";
  };
  options.headroom.proxies = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule {
      options = {
        port = lib.mkOption {
          type = lib.types.int;
          description = "Port to listen on";
        };
        args = lib.mkOption {
          type = lib.types.str;
          description = "Additional arguments to pass to headroom proxy";
        };
      };
    });
    default = {
      anthropic = {
        port = 8787;
        args = "--port 8787";
      };
    };
    description = "Headroom proxy instances to run";
  };

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

    # Linux: systemd user services for proxy instances
    systemd.user.services = lib.mkIf (isLinux && config.headroom.enableService) (
      lib.mapAttrs' (name: proxy:
        lib.nameValuePair "headroom-proxy-${name}" {
          Unit = {
            Description = "Headroom context-compression proxy (${name})";
            After = ["network-online.target"];
          };
          Service = {
            Type = "simple";
            ExecStart = "${headroomProxy name proxy.args}";
            Restart = "on-failure";
            RestartSec = 10;
            StandardOutput = "journal";
            StandardError = "journal";
            SyslogIdentifier = "headroom-proxy-${name}";
            # Run in background without tying to session
            KillMode = "mixed";
          };
          Install = {
            WantedBy = ["default.target"];
          };
        }
      ) config.headroom.proxies
    );
  };
}
