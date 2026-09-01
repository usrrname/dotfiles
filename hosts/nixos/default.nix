# NixOS box system configuration
# This file contains system-level config; user-level config is in home/default.nix
{
  config,
  pkgs,
  lib,
  ...
}: let
  # Username for this host - change if deploying to a different user
  username = "jenc";
  in {
  imports = [
    # Include hardware configuration (must exist on the actual host)
    #./hardware-configuration.nix
    (fetchTarball {
      url = "https://github.com/nix-community/nixos-vscode-server/tarball/master";
      sha256 = "179gqv45mby7wxdmrjmk8qqfgxh9316x2l9dkcvmmqrp9i4w5qfs";
    })
  ];
  
  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Hostname
  networking.hostName = "nixos";

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

  home-manager.users.jenc.home.username = lib.mkForce "jenc";

  # X11 keymap
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Auto-login
  services.getty.autologinUser = username;

  services.postgresql = {
      enable = true;
      authentication = ''
        local all all trust
        host  all all 127.0.0.1/32 trust
      '';
      initialScript = pkgs.writeText "backend-initScript" ''
        CREATE ROLE ${username} WITH LOGIN PASSWORD '${username}' CREATEDB;
        CREATE DATABASE ${username};
        GRANT ALL PRIVILEGES ON DATABASE ${username} TO ${username};
      '';
    };
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # System packages (system-level only; user packages in home/default.nix)
  environment.systemPackages = with pkgs; [
    wget
    gitFull
    nixfmt-rfc-style
    vimPlugins.nvim-cmp
    vimPlugins.LazyVim
    claude-code
    ghostty.terminfo
  ];
  programs.direnv.enable = true;
  # Enable OpenSSH
  services.openssh.enable = true;

  # VSCode server (uncomment when deploying to actual host)
  services.vscode-server = {
    enable = true;
    installPath = "/home/jenc/.cursor-server";
  };

  # prevent fail from guest kernel doesn't allow (re)mounting debugfs at /sys/kernel/debug
  systemd.mounts = [
    {
      where = "/sys/kernel/debug";
      enable = lib.mkForce false;
    }
  ];
  # Automatic garbage collection
  nix.settings.sandbox = false;
  nix.settings.use-sandbox = false;

  nix.gc.automatic = true;
  nix.gc.dates = "03:15";

  # System state version
  system.stateVersion = "24.11";
}
