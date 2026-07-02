# Raspberry Pi 4B NAS host configuration
# Standalone Home Manager configuration for Debian on Raspberry Pi

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

  # Allow unfree packages (required for 1password-cli, etc.)
  nixpkgs.config.allowUnfree = true;

  home.username = username;
  home.homeDirectory = homeDir;
  home.stateVersion = "24.11";

  # Pi-specific packages (NAS setup)
  # Note: Most packages come from ../../home/default.nix
  # Only add Pi-specific extras here
  home.packages = with pkgs; [
    # Pi-specific additions
    lsb-release
    opencode
  ];

  # System-level packages (install via apt on Debian):
  # sudo apt install ufw fail2ban hd-idle
  # These require root and system-level configuration, so they're managed outside Nix

  # Docker is managed at system level on Pi (requires root)
  # Install via: curl -fsSL https://get.docker.com | sh
  # Then add user to docker group: sudo usermod -aG docker $USER

  # Pi-specific shell aliases
  programs.zsh.shellAliases = {
    xoff = "sudo /usr/local/bin/xSoft.sh 0 27"; # Pi NAS soft shutdown
  };

  programs.home-manager.enable = true;
}
