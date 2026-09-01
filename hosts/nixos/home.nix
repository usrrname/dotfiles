{ config, pkgs, ... }:
  {
    imports = [
      ../../home
      ../../home/linux.nix
    ];
    home.packages = with pkgs; [
      claude-code
    ];

    # This VM has no local headroom proxy (removed in favor of the macOS
    # host's, reachable via OrbStack's DNS alias for the host).
    home.sessionVariables = {
      ANTHROPIC_BASE_URL = "http://host.orb.internal:8787";
    };
  }
