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
    ../modules/starship.nix
    ../modules/git.nix
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
      tmux

      # Editors
      vim

      # Dev tooling
      direnv
      gh
      act # run GitHub Actions locally
      _1password-cli

      # Build tools
      gnumake
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

      # Misc
      gnupg
      cacert
    ]
    ++ lib.optionals isLinux [
      lsb-release
      opencode # AI coding agent (Mac uses anomalyco/tap/opencode via brew)
    ]
    ++ lib.optionals isDarwin [
      # Mac-only nixpkgs additions go here; GUI apps live in homebrew.casks
      # under hosts/mac-jenc/default.nix.
    ];

  xdg.configFile."act/actrc".text = ''
    -P ubuntu-latest=catthehacker/ubuntu:act-latest
    -P ubuntu-22.04=catthehacker/ubuntu:act-latest
    -P ubuntu-20.04=catthehacker/ubuntu:act-latest
    -P ubuntu-18.04=catthehacker/ubuntu:act-latest
  '';

  # Use a user-writable npm global prefix (Nix store is read-only)
  home.sessionVariables.NPM_CONFIG_PREFIX = "$HOME/.npm-global";

  # Install global npm packages that aren't in nixpkgs (Socket Security CLI, husky for git hooks).
  # Runs after Home Manager writes its files; idempotent.
  home.activation.installNpmGlobals = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export NPM_CONFIG_PREFIX="$HOME/.npm-global"
    export PATH="${pkgs.nodejs}/bin:$HOME/.npm-global/bin:$PATH"
    $DRY_RUN_CMD mkdir -p "$HOME/.npm-global"
    # Install husky first (needed by socket's prepare script)
    if ! "$HOME/.npm-global/bin/husky" --version >/dev/null 2>&1; then
      $DRY_RUN_CMD npm install -g husky
    fi
    # Then install socket (its prepare script will work now)
    if ! "$HOME/.npm-global/bin/socket" --version >/dev/null 2>&1; then
      $DRY_RUN_CMD npm install -g socket
    fi
  '';

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [
        # autosuggestions are provided by programs.zsh.autosuggestion.enable above;
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
      reload = "source ~/.zshrc";
      npm = "socket npm";
      npx = "socket npx";
      pnpm="socket pnpm";
    };

    initContent = ''
      export PATH="$HOME/.npm-global/bin:$PATH"

      # Update opencode CLI + all plugins pinned in the opencode config dir's package.json.
      update-opencode() {
        local dir="$HOME/.opencode"
        [ -d "''${XDG_CONFIG_HOME:-$HOME/.config}/opencode" ] && dir="''${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
        opencode upgrade
        [ -f "$dir/package.json" ] || return 0
        local deps
        deps=$(node -e "const p=JSON.parse(require('fs').readFileSync(0));console.log(Object.keys(p.dependencies||{}).join('\n'))" < "$dir/package.json")
        for dep in $deps; do
          opencode plugin "$dep" --force --global
        done
      }
    '';
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
  ];
}
