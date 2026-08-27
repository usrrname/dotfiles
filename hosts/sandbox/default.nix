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

  # mkForce replaces home.packages entirely rather than merging, so
  # modules/nvim.nix's `home.packages = [pkgs.neovim]` would otherwise be
  # silently discarded even though its LazyVim config symlink still runs.
  home.packages = lib.mkForce (with pkgs; [
    git
    curl
    wget
    ripgrep
    fzf
    tmux
    neovim
    nodejs
    direnv
    cacert
    lsb-release
    opencode
  ]);

  headroom.enable = true;
  headroom.enableService = true;

  # claude-code is npm-only here (no nixpkgs package, no Homebrew cask like
  # mac-jenc). headroom.nix's activation only runs `headroom init claude`
  # (installs the hooks that route Claude Code through the local proxy) when
  # `command -v claude` succeeds — so the CLI must exist *before* that block
  # runs. entryBefore ["headroom"] makes that ordering explicit instead of
  # relying on activation-script file order.
  home.activation.installClaudeCli = lib.hm.dag.entryBefore ["headroom"] ''
    export PATH="${pkgs.nodejs}/bin:$PATH"
    ${builtins.readFile ./install-claude-cli.sh}
  '';

  # nix-daemon.sh's PATH setup isn't reliably reaching new shells here;
  # export directly rather than depend on it. Includes npm-global/bin so
  # claude (installed above) and other npm-global CLIs resolve.
  programs.bash.initExtra = ''
    export PATH="$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$HOME/.npm-global/bin:$PATH"
  '';

  programs.home-manager.enable = true;
}
