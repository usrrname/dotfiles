# Ubuntu host configuration
# Standalone Home Manager configuration for Ubuntu Workstation

{ config, pkgs, lib, ... }:

let
  username = let user = builtins.getEnv "USER"; in if user == "" then "jenc" else user;
  homeDir = "/home/${username}";
in
{
  imports = [
    ../../home
    ../../home/linux.nix
  ];

  home.username = username;
  home.homeDirectory = homeDir;
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

  programs.home-manager.enable = true;
}
