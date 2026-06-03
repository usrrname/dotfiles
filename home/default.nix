{
  config,
  pkgs,
  lib,
  ...
}:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in
{
  home.username = "jenc";
  home.homeDirectory = if isDarwin then "/Users/jenc" else "/home/jenc";
  home.stateVersion = "24.11";

  home.packages =
    with pkgs;
    [
      git
      curl
      wget
      tree
      ripgrep
      fzf
      stow
      tmux

      neovim
      vim

      direnv
      gh

      gnumake
      gcc
      openssl

      zsh
      oh-my-zsh
      starship

      gnupg
      cacert
    ]
    ++ lib.optionals isLinux [
      lsb-release
    ]
    ++ lib.optionals isDarwin [
      # Mac-only packages added in Phase 1
    ];

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    settings.user = {
      name = "jenc";
      # email = "jen.chan@rangle.io";  # populate before first switch
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "direnv"
        "gh"
      ];
      theme = "robbyrussell";
    };
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
