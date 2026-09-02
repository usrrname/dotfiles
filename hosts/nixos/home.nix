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
