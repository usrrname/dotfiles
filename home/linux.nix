# Linux-specific home-manager configuration
# Shared between NixOS and Fedora hosts
{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../modules/home-manager-gc.nix
  ];

  # Auto-clean old Home Manager generations weekly (systemd user timer)
  modules.home-manager-gc = {
    enable = true;
    keepDays = 7;
    frequency = "weekly";
  };

  # Linux-specific packages
  home.packages = with pkgs; [
    lsb-release
    gcc
  ];

  # Linux-specific environment variables
  home.sessionVariables = {
    # Add any Linux-specific env vars here
  };

  # Linux-specific program configurations
  # Add any Linux-specific program settings here
}
