# Raspberry Pi 4B NAS host configuration
# Standalone Home Manager configuration for Debian on Raspberry Pi

{ config, pkgs, lib, ... }:

{
  imports = [
    ../../home
    ../../home/linux.nix
  ];

  home.username = "jenc";
  home.homeDirectory = "/home/jenc";
  home.stateVersion = "24.11";

  # Pi-specific packages (NAS setup)
  home.packages = with pkgs; [
    # Core tools (minimal for NAS)
    git
    curl
    wget
    tree
    vim
    neovim
    ripgrep
    stow
    lsb-release

    # Development tools
    direnv
    nodejs
    pnpm
    go
    opencode

    # Python
    python3
    uv

    # Networking
    tailscale
  ];

  # System-level packages (install via apt on Debian):
  # sudo apt install ufw fail2ban hd-idle
  # These require root and system-level configuration, so they're managed outside Nix

  # Docker is managed at system level on Pi (requires root)
  # Install via: curl -fsSL https://get.docker.com | sh
  # Then add user to docker group: sudo usermod -aG docker $USER

  # Use a user-writable npm global prefix
  home.sessionVariables.NPM_CONFIG_PREFIX = "$HOME/.npm-global";

  # Install global npm packages
  home.activation.installNpmGlobals = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export NPM_CONFIG_PREFIX="$HOME/.npm-global"
    export PATH="${pkgs.nodejs}/bin:$HOME/.npm-global/bin:$PATH"
    $DRY_RUN_CMD mkdir -p "$HOME/.npm-global"
    if ! "$HOME/.npm-global/bin/socket" --version >/dev/null 2>&1; then
      $DRY_RUN_CMD npm install -g socket
    fi
  '';

  programs.home-manager.enable = true;
}
