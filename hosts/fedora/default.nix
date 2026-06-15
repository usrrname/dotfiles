# Fedora host configuration
# Standalone Home Manager configuration for Fedora Workstation

{ config, pkgs, lib, ... }:

let
  username = let user = builtins.getEnv "USER"; in if user == "" then "jenc" else user;
  homeDir = "/home/${username}";
in
{
  imports = [
    ../../home
    ../../home/linux.nix
    ../../modules/input-remapper.nix
    ../../modules/wezterm.nix
    ../../modules/sandbox-browser.nix
  ];

  home.username = username;
  home.homeDirectory = homeDir;
  home.stateVersion = "24.11";

  # Additional packages specific to Fedora host
  # Nix-managed — no dnf needed for these
  home.packages = with pkgs; [
    # System tools (Nix provides the binary, systemd service enabled separately)
    tailscale
    # wezterm is installed via dnf — the Nix binary can't find system GPU libraries (libEGL)
    input-remapper

    # Build tools
    gcc
    gnumake
    openssl
    
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
    brave        # Web browser
    bruno        # API client
    _1password-cli
    
    # Local LLM server
    ollama
  ];

  # Use a user-writable npm global prefix (Nix store is read-only)
  home.sessionVariables.NPM_CONFIG_PREFIX = "$HOME/.npm-global";

  # Install global npm packages that aren't in nixpkgs
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
