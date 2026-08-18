{
  config,
  lib,
  pkgs,
  ...
}: let
  aliases = import ./aliases.nix {inherit config lib pkgs;};

  # Base aliases that work everywhere (shared with bash.nix)
  baseAliases = aliases.base;

  # Zsh-only aliases
  zshAliases = {
    reload = "source ~/.zshrc";
    # Socket Security wraps npm/npx/pnpm for supply-chain checks
    npm = "socket npm";
    npx = "socket npx";
    pnpm = "socket pnpm";
  };
in {
  programs.zsh = {
    enable = true;
    autocd = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [
        # autosuggestions are provided by programs.zsh.autosuggestion.enable above
        "git"
        "gh"
      ];
      theme = "robbyrussell";
    };

    shellAliases = baseAliases // zshAliases;

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

  # dircolors and direnv are top-level HM modules, not zsh sub-options.
  # enableZshIntegration defaults to true when programs.zsh.enable is true,
  # so the direnv hook is added to zshrc automatically (no oh-my-zsh plugin needed).
  programs.dircolors.enable = true;
  programs.direnv.enable = true;
}
