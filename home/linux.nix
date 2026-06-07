# Linux-specific home-manager configuration
# Shared between NixOS and Fedora hosts

{ config, pkgs, lib, ... }:

{
  # Linux-specific packages
  home.packages = with pkgs; [
    lsb-release
  ];

  # Linux-specific environment variables
  home.sessionVariables = {
    # Add any Linux-specific env vars here
  };

  # Linux-specific program configurations
  # Add any Linux-specific program settings here
}
