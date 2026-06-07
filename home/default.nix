{
  config,
  pkgs,
  lib,
  ...
}:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
  username = let user = builtins.getEnv "USER"; in if user == "" then "jenc" else user;
  homeDir = if isDarwin then "/Users/${username}" else "/home/${username}";
in
{
  imports = [
    ../modules/tmux.nix
    ../modules/gh.nix
    ../modules/direnv.nix
    ../modules/nvim.nix
    ../modules/opencode.nix
    ../modules/bash.nix
    ../modules/claude.nix
  ];

  home.username = username;
  home.homeDirectory = homeDir;
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
      vim

      # Dev tooling
      direnv
      gh
      act # run GitHub Actions locally
      bruno # API client
      _1password-cli
      opencode # AI coding agent

      # Build tools
      gnumake
      gcc
      openssl

      # Language runtimes & package managers
      nodejs # provides node + npm; replaces fnm/nvm
      pnpm
      yarn
      bun
      go

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

  programs.home-manager.enable = true;

  # Use a user-writable npm global prefix (Nix store is read-only)
  home.sessionVariables.NPM_CONFIG_PREFIX = "$HOME/.npm-global";

  # Install global npm packages that aren't in nixpkgs (Socket Security CLI).
  # Runs after Home Manager writes its files; idempotent.
  home.activation.installNpmGlobals = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export NPM_CONFIG_PREFIX="$HOME/.npm-global"
    export PATH="${pkgs.nodejs}/bin:$HOME/.npm-global/bin:$PATH"
    $DRY_RUN_CMD mkdir -p "$HOME/.npm-global"
    if ! "$HOME/.npm-global/bin/socket" --version >/dev/null 2>&1; then
      $DRY_RUN_CMD npm install -g socket
    fi
  '';

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Jen Chan";
        email = "6406037+usrrname@users.noreply.github.com";
        signingkey = "~/.ssh/id_ed25519.pub";
      };
      color.ui = "auto";
      core.editor = "nvim";
      core.excludesFile = "~/.gitignore_global";
      push.autoSetupRemote = true;
      init.defaultBranch = "main";
      pull.rebase = true;
      alias = {
        g = "git";
        gco = "checkout";
        gst = "status";
        gcb = "checkout -b";
        gcm = "commit -m";
        noedit = "commit --amend --no-edit";
        log = "log --pretty=format:\"%C(yellow)%h%Cred%d\\ %Creset%s%Cblue\\ [%cn]\" --decorate";
        assume = "update-index --assume-unchanged";
        assumed = "!git ls-files -v | grep ^h | cut -c 3-";
        unassume = "update-index --no-assume-unchanged";
        unassumeall = "!git assumed | xargs git update-index --no-assume-unchanged";
        alias = "!git config -l | grep alias | cut -c 7-";
      };
    } // lib.optionalAttrs isDarwin {
      gpg.format = "ssh";
      gpg.ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
      commit.gpgsign = true;
      credential."https://github.com".helper = [ "" "!/opt/homebrew/bin/gh auth git-credential" ];
      credential."https://gist.github.com".helper = [ "" "!/opt/homebrew/bin/gh auth git-credential" ];
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
    shellAliases = {
      # Common aliases (all platforms)
      ll = "ls -alF";
      la = "ls -A";
      l = "ls -CF";
      g = "git";
      vi = "nvim";
      vim = "nvim";
      sudov = "sudo -e";
      "docker-compose" = "docker compose";
      k = "kubectl";
      copilot = "gh copilot";
      gcs = "gh copilot suggest";
      gce = "gh copilot explain";
      cc = "claude code";
      reload = "source ~/.zshrc";
      npm = "socket npm";
      npx = "socket npx";
    } // lib.optionalAttrs isLinux {
      # Linux-specific aliases
      update = "sudo apt update && sudo apt upgrade";
      install = "sudo apt install";
      remove = "sudo apt remove";
      autoremove = "sudo apt autoremove";
      search = "apt search";
      py = "python3";
      pip = "pip3";
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
