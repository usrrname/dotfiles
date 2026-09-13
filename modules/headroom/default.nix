{
  config,
  lib,
  pkgs,
  ...
}: let
  # PyPI-only (not in nixpkgs) — pin the version so every host/sandbox from
  # this flake matches; `headroom update` can't silently diverge them.
  headroomVersion = "0.37.0";

  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  username = config.home.username;

  ensureHeadroom = ''
    export HEADROOM_VERSION="${headroomVersion}"
    export UV_BIN_DIR="${pkgs.uv}/bin"
    ${builtins.readFile ./ensure-installed.sh}
  '';

  # Cross-platform proxy bootstrap; systemd (Linux) uses this directly, while
  # macOS's launchd wrapper in hosts/mac-jenc replaces it with a
  # varlock-aware version.
  headroomProxy = name: args:
    pkgs.writeShellScript "headroom-proxy-${name}" ''
      set -euo pipefail
      ${ensureHeadroom}
      export PROXY_ARGS="${args}"
      ${builtins.readFile ./proxy-run.sh}
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
    # Nix owns the CLI install and proxy lifecycle (launchd/systemd); headroom
    # owns its own agent config (see install-agent-config.sh). Sandboxes
    # reproduce this with their own $HOME and a local proxy on the same port.
    home.activation.headroom = lib.hm.dag.entryAfter ["writeBoundary"] ''
      ( # Subshell: keeps `set -e` scoped to this step, not the rest of
        # home-manager's shared activation script.
        set -euo pipefail
        ${ensureHeadroom}
        ${lib.optionalString isDarwin ''
          # claude-code is a Homebrew cask; activation PATH lacks the brew prefix.
          export PATH="/opt/homebrew/bin:$PATH"
        ''}
        ${builtins.readFile ./install-agent-config.sh}
      )
    '';

    home.packages = [pkgs.uv];

    # Linux: systemd user services for proxy instances
    systemd.user.services = lib.mkIf (isLinux && config.headroom.enableService) (
      lib.mapAttrs' (
        name: proxy:
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
      )
      config.headroom.proxies
    );
  };
}
