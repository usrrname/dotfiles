{ config, lib, pkgs, ... }:

let
  # Base aliases that work everywhere
  baseAliases = {
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
    # Socket Security wraps npm/npx/pnpm for supply-chain checks
    npm = "socket npm";
    npx = "socket npx";
    pnpm = "socket pnpm";
  };
in
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [
        # autosuggestions are provided by programs.zsh.autosuggestion.enable above
        "git"
        "direnv"
        "gh"
      ];
      theme = "robbyrussell";
    };

    shellAliases = baseAliases;

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
}
