{ config, pkgs, ... }:
{
  imports = [
    ../../home
    ../../home/linux.nix
  ];
  home.packages = with pkgs; [
    claude-code
    prettier # JavaScript/TypeScript/Vue formatter
    eslint # JavaScript/TypeScript linter
    rustfmt # Rust formatter
    clippy # Rust linter
  ];

  # This VM has no local headroom proxy (removed in favor of the macOS
  # host's, reachable via OrbStack's DNS alias for the host).
  home.sessionVariables = {
    ANTHROPIC_BASE_URL = "http://host.orb.internal:8787";
  };

  # Keep nix-direnv's .direnv (and its flake-input symlinks into /nix/store,
  # which can point at multi-GB sources like full kernel trees) out of
  # project directories, so dev-server file watchers never walk into them.
  xdg.configFile."direnv/direnvrc".text = ''
    layout_dir() {
      echo "''${XDG_CACHE_HOME:-$HOME/.cache}/direnv/layouts/$(echo "$PWD" | md5sum | cut -d' ' -f1)"
    }
  '';

  programs.bash.bashrcExtra = ''
    export HYDRA_SSH_USER="jenc"
    export HYDRA_X86_64_BUILDER="hydra-x8664"
    export HYDRA_AARCH64_BUILDER="hydra-aarch64"
    export HYDRA_SSH_IDENTITY="$HOME/.ssh/id_ed25519"
    export NIX_KEY="$HOME/nix-keys/jenc.private.pem"
  '';

  programs.zsh.initContent = ''
    export HYDRA_SSH_USER="jenc"
    export HYDRA_X86_64_BUILDER="hydra-x8664"
    export HYDRA_AARCH64_BUILDER="hydra-aarch64"
    export HYDRA_SSH_IDENTITY="$HOME/.ssh/id_ed25519"
    export NIX_KEY="$HOME/nix-keys/jenc.private.pem"
  '';
}
