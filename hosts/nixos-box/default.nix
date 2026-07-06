# NixOS box system configuration
# This file contains system-level config; user-level config is in home/default.nix
{
  config,
  pkgs,
  ...
}: let
  # Username for this host - change if deploying to a different user
  username = "jenc";
in {
  imports = [
    # Include hardware configuration (must exist on the actual host)
    ./hardware-configuration.nix
    # VSCode server support (uncomment when deploying to actual host)
    # (fetchTarball {
    #   url = "https://github.com/nix-community/nixos-vscode-server/tarball/master";
    #   sha256 = "0000000000000000000000000000000000000000000000000000"; # Update with actual hash
    # })
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Hostname
  networking.hostName = "nixos-box";

  # Networking
  networking.networkmanager.enable = true;
  networking.firewall.enable = false;

  # Timezone and locale
  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_CA.UTF-8";

  # User account
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = ["networkmanager" "wheel"];
  };

  # X11 keymap
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Auto-login
  services.getty.autologinUser = username;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # System packages (system-level only; user packages in home/default.nix)
  environment.systemPackages = with pkgs; [
    wget
    gitFull
    nixfmt-rfc-style
    vimPlugins.nvim-cmp
    vimPlugins.LazyVim
  ];

  # Enable OpenSSH
  services.openssh.enable = true;

  # VSCode server (uncomment when deploying to actual host)
  # services.vscode-server = {
  #   enable = true;
  #   installPath = "/home/jenc/.cursor-server";
  # };

  # Automatic garbage collection
  nix.gc.automatic = true;
  nix.gc.dates = "03:15";

  # System state version
  system.stateVersion = "24.11";
}
