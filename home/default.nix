{
  config,
  pkgs,
  lib,
  ...
}: let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
  username = let
    user = builtins.getEnv "USER";
  in
    if user == ""
    then "jenc"
    else user;
  homeDir = let
    home = builtins.getEnv "HOME";
  in
    if home != ""
    then home
    else if isDarwin
    then "/Users/${username}"
    else "/home/${username}";
in {
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
    ../modules/headroom.nix
    ../modules/zsh.nix
    ../modules/ghostty.nix
  ];

  home.username = username;
  home.homeDirectory = homeDir;
  home.stateVersion = "24.11";

  home.packages = with pkgs;
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

      # Misc
      gnupg
      cacert
    ]
    ++ lib.optionals isLinux [
      lsb-release
      opencode # (Mac uses anomalyco/tap/opencode via brew)
    ]
    ++ lib.optionals isDarwin [
      # Mac-only nixpkgs additions go here; GUI apps live in homebrew.casks
      # under hosts/mac-jenc/default.nix.
      rustc # >= 1.94.1 for sdist builds that need a modern toolchain (e.g. litellm)
      cargo

      # On-demand control for headroom proxy launchd services. Lazily-started
      # proxies (the Gemini ones) don't run at login; start them when needed.
      # Script body lives in ./scripts/headroomctl.sh (plain bash, no Nix
      # interpolation) so it can be linted/shellchecked directly.
      (pkgs.writeShellScriptBin "headroomctl"
        (builtins.readFile ./scripts/headroomctl.sh))
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
  home.activation.installNpmGlobals = lib.hm.dag.entryAfter ["writeBoundary"] ''
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
