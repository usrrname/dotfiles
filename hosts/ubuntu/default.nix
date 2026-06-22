# Ubuntu host configuration
# Standalone Home Manager configuration for Ubuntu Workstation

{ config, pkgs, lib, ... }:

let
  username = let user = builtins.getEnv "USER"; in if user == "" then "jenc" else user;
  homeDir = "/home/${username}";
in
{
  imports = [
    ../../home
    ../../home/linux.nix
  ];

  home.username = username;
  home.homeDirectory = homeDir;
  home.stateVersion = "24.11";

  # Additional packages specific to Ubuntu host
  home.packages = with pkgs; [
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
    _1password-cli
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
