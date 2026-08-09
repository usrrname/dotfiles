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

  # headroom CLI + agent MCP config + systemd proxy service
  headroom.enable = true;
  headroom.enableService = true;
  # Fedora runs standalone Home Manager, so proxies are user-scoped systemd services
  # Logs: journalctl --user -u headroom-proxy-anthropic -f
  # deepseek (8788) relays to opencode's Zen gateway with --mode token for
  # ~25-35% more session length; anthropic (8787) stays in default cache mode.
  headroom.proxies = {
    anthropic = {
      port = 8787;
      args = "--port 8787";
    };
    deepseek = {
      port = 8788;
      args = "--port 8788 --mode token --openai-api-url https://opencode.ai/zen/v1 --provider-name OpenCode";
    };
    # OpenCode Go subscription gateway (kimi-k3 etc. against monthly Go quota,
    # not Zen credits). Free models stay on the Zen proxy (8788).
    go = {
      port = 8789;
      args = "--port 8789 --mode token --openai-api-url https://opencode.ai/zen/go/v1 --provider-name OpenCodeGo";
    };
  };

  programs.home-manager.enable = true;
}
