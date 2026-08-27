{
  config,
  lib,
  pkgs,
  ...
}: let
  # OS detection based on system hostname and home username
  isFedora =
    pkgs.stdenv.isLinux
    && (
      (config ? system.nixos.hostName
        && (
          config.system.nixos.hostName
          == "fedora-mini"
          || config.system.nixos.hostName == "fedora"
          || config.system.nixos.hostName == "fedora-desktop"
        ))
      || (config ? home
        && (
          config.home.username
          == "jenc"
          || config.home.username == "user"
        ))
    );
  isDebianLike = pkgs.stdenv.isLinux && !isFedora;

  aliases = import ../aliases.nix {inherit config lib pkgs;};

  # Base aliases that work everywhere (shared with zsh.nix)
  baseAliases = aliases.base;

  # Bash-only aliases
  bashAliases = {
    cc = "claude code";
    reload = "source ~/.bashrc";
    # Direnv helpers
    da = "direnv allow";
    dr = "direnv reload";
    # Run Nix garbage collection
    ngc = "nix-env --delete-generations old && nix-store --gc";
  };

  # OS-specific package manager aliases
  osSpecificAliases = {
    update =
      if isFedora
      then "sudo dnf update && sudo dnf upgrade"
      else "sudo apt update && sudo apt upgrade";
    install =
      if isFedora
      then "sudo dnf install"
      else "sudo apt install";
    remove =
      if isFedora
      then "sudo dnf remove"
      else "sudo apt remove";
    autoremove =
      if isFedora
      then "sudo dnf autoremove"
      else "sudo apt autoremove";
    search =
      if isFedora
      then "sudo dnf search"
      else "sudo apt search";
  };
in {
  programs.bash = {
    enable = true;
    enableCompletion = true;

    bashrcExtra = ''
      # If not running interactively, don't do anything
      case $- in
        *i*) ;;
        *) return ;;
      esac
    '';

    initExtra = builtins.readFile ./.bashrc;

    shellAliases = baseAliases // bashAliases // osSpecificAliases;

    shellOptions = [
      "histappend"
      "checkwinsize"
    ];
  };
}
