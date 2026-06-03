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
      # Core CLI
      git
      curl
      wget
      tree
      ripgrep
      fzf
      stow
      tmux

      # Editors
      neovim
      vim

      # Dev tooling
      direnv
      gh
      act # run GitHub Actions locally
      bruno # API client
      _1password-cli

      # Build tools
      gnumake
      gcc
      openssl

      # Language runtimes & package managers
      nodejs # provides node + npm; replaces fnm/nvm
      pnpm
      yarn
      bun
      rustup # bring-your-own-toolchain rust

      # Shell
      zsh
      oh-my-zsh
      starship

      # Misc
      gnupg
      cacert
      ollama # local LLM server
    ]
    ++ lib.optionals isLinux [
      lsb-release
    ]
    ++ lib.optionals isDarwin [
      # Mac-only nixpkgs additions go here; GUI apps live in homebrew.casks
      # under hosts/mac-jenc/default.nix.
    ];

  # Install global npm packages that aren't in nixpkgs (Socket Security CLI).
  # Runs after Home Manager writes its files; idempotent.
  home.activation.installNpmGlobals = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH="${pkgs.nodejs}/bin:$PATH"
    if ! command -v socket >/dev/null 2>&1; then
      $DRY_RUN_CMD npm install -g socket
    fi
  '';

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
