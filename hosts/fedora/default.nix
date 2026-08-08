# Fedora host configuration
# Standalone Home Manager configuration for Fedora Workstation
{
  config,
  pkgs,
  lib,
  ...
}: let
  username = let
    user = builtins.getEnv "USER";
  in
    if user == ""
    then "jenc"
    else user;
  homeDir = "/home/${username}";
in {
  imports = [
    ../../home
    ../../home/linux.nix
    ../../modules/input-remapper.nix
    ../../modules/sandbox-repo.nix
  ];

  home.username = username;
  home.homeDirectory = homeDir;
  home.stateVersion = "24.11";

  # Additional packages specific to Fedora host
  # Nix-managed — no dnf needed for these
  home.packages = with pkgs; [
    # System tools (Nix provides the binary, systemd service enabled separately)
    tailscale
    input-remapper

    # Build tools
    gnumake
    openssl
    rustc # >= 1.94.1 for sdist builds that need a modern toolchain (e.g. litellm)
    cargo

    # Development libraries
    libyaml
    gmp

    # Additional CLI tools
    lsb-release

    # Node.js and package managers (replacing nvm/fnm)
    nodejs
    pnpm
    yarn

    # Python tools
    python3
    uv

    # Go
    go

    # Additional tools
    brave # Web browser
    _1password-cli
  ];

  # Use a user-writable npm global prefix (Nix store is read-only)
  home.sessionVariables = {
    NPM_CONFIG_PREFIX = "$HOME/.npm-global";
    DOCKER_HOST = "unix://$XDG_RUNTIME_DIR/podman/podman.sock";
  };

  # headroom CLI ships only via PyPI (not in nixpkgs); install with uv tool.
  # Idempotent — runs after Home Manager writes its files.
  home.activation.installUvToolHeadroom = lib.hm.dag.entryAfter ["writeBoundary"] ''
    export PATH="$HOME/.local/bin:${pkgs.uv}/bin:$PATH"
    if ! command -v headroom >/dev/null 2>&1; then
      $DRY_RUN_CMD uv tool install --python 3.13 headroom-ai
    fi
  '';

  programs.home-manager.enable = true;
}
