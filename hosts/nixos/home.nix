{ config, pkgs, ... }:
  {
    imports = [
      ../../home
      ../../home/linux.nix
    ];
    home.packages = with pkgs; [
      claude-code
    ];
  }
