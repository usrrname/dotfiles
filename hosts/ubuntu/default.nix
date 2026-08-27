# Ubuntu host configuration
# Standalone Home Manager configuration for Ubuntu Workstation
{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../../home
    ../../home/linux.nix
  ];

  home.stateVersion = "24.11";

  # Additional packages specific to Ubuntu host
  home.packages = with pkgs; [
    # Build tools
    gnumake
    openssl

    # Development libraries
    libyaml
    gmp

    # Additional CLI tools
    lsb-release

    # Node.js and package managers (replacing nvm/fnm)
    nodejs
    pnpm
    yarn

    # Python tools
    python3
    uv

    # Go
    go

    # Additional tools
    _1password-cli
  ];

  # headroom CLI + agent MCP config + systemd proxy service
  headroom.enable = true;
  headroom.enableService = true;
  # Ubuntu runs standalone Home Manager, so proxies are user-scoped systemd services
  # Logs: journalctl --user -u headroom-proxy-anthropic -f

  programs.home-manager.enable = true;
}
