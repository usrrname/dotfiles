# Isolated agent sandbox (Lima Debian guest) — minimal footprint.
# No credential tooling (gh, _1password-cli, gnupg, act) since this host
# never holds credentials. No baked-in language runtimes — bring those
# per-project via direnv + the project's own flake.nix/shell.nix instead
# of duplicating multiple toolchains in the base image.
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
    direnv
    cacert
    lsb-release
    opencode
  ]);

  headroom.enable = true;
  headroom.enableService = true;

  programs.home-manager.enable = true;
}
