# Isolated agent sandbox (Lima Debian guest) — minimal footprint, no
# credential tooling. Other language toolchains come per-project via
# direnv + the project's own flake.nix/shell.nix.
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

  home.packages = lib.mkForce (with pkgs; [
    git
    curl
    wget
    ripgrep
    fzf
    tmux
    vim
    nodejs
    direnv
    cacert
    lsb-release
    opencode
  ]);

  headroom.enable = true;
  headroom.enableService = true;

  programs.home-manager.enable = true;
}
