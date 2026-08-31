{
  config,
  lib,
  pkgs,
  ...
}: let
  aliases = import ../aliases.nix {inherit config lib pkgs;};

  # Base aliases that work everywhere (shared with zsh.nix)
  baseAliases = aliases.base;
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

      # Load bash-specific aliases
      if [ -f "$HOME/.bash_aliases" ]; then
        . "$HOME/.bash_aliases"
      fi
    '';

    initExtra = builtins.readFile ./.bashrc;

    shellAliases = baseAliases;

    shellOptions = [
      "histappend"
      "checkwinsize"
    ];
  };

  # Bash-specific aliases (cc, reload, package-manager wrappers, ...).
  # Base aliases shared with zsh come from shellAliases above; this file
  # is sourced from .bashrc via bashrcExtra.
  home.file.".bash_aliases" = {
    text = builtins.readFile ./.bash_aliases;
  };
}
