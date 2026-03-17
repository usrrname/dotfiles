# linux/home.nix - Home Manager configuration for Linux (Debian/RPi)
{ config, pkgs, lib, ... }:

{
  # =====================================================================
  # BASE PACKAGES - CLI tools and development libraries
  # =====================================================================
  home.packages = with pkgs; [
    # Version control
    git

    # HTTP clients
    curl
    wget

    # Essential build tools
    build-essential
    openssl
    libyaml-dev
    libgmp-dev
    ca-certificates
    gnupg

    # 1Password CLI
    op

  # Node.js version manager
    fnm

  # Shell prompts
    starship

  # direnv
    direnv

  # Utilities
    stow
    tree
    unzip
    lsb-release

    # System monitoring
    htop

    # Editors
    vim
    neovim
  ];

  # =====================================================================
  # SPECIAL PACKAGES - Tools that need custom installation
  # Note: These are typically installed via other means:
  # - nvm: via script (https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh)
  # - pnpm: via npm install -g pnpm
  # - direnv: can be installed via nix or binary release
  # - tailscale: via official script
  # =====================================================================


  # =====================================================================
  # ENVIRONMENT VARIABLES
  # =====================================================================
  home.stateVersion = "24.05";
  home.username = "jenc";
  home.homeDirectory = "/home/jenc";

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # =====================================================================
  # SHELL CONFIGURATION
  # =====================================================================

  # Enable zsh via home-manager (optional - can also use stow)
  # programs.zsh.enable = true;

  # Enable bash via home-manager (optional)
  # programs.bash.enable = true;

  # =====================================================================
  # NOTES
  # =====================================================================
  #
  # Package notes:
  # - Most apt packages are available in nixpkgs
  # - Some packages may need special handling (docker, tailscale, etc.)
  # - For Pi-specific: use lib.optionals pkgs.hostPlatform.isAarch64
  #
  # To add conditional packages:
  #   home.packages = (home.packages or []) ++ (with pkgs; lib.optionals pkgs.hostPlatform.isAarch64 [
  #     # Pi-specific packages here
  #   ]);
}
