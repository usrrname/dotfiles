# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
     (fetchTarball "https://github.com/nix-community/nixos-vscode-server/tarball/master")   
];


 # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

users.users.jenc = {
  isNormalUser = true;
  description = "jenc";
  extraGroups = [ "networkmanager" "wheel" ];
  packages = with pkgs; [];
};

 programs.neovim = {
  enable = true;
  defaultEditor = true;
  viAlias = true;
  vimAlias = true;
	configure = {
	    customRC = ''

          let mapleader = "\<Space>"

          lua << EOF
            ${builtins.readFile /home/jenc/.config/nvim/init.lua}

            ${builtins.readFile /home/jenc/.config/nvim/lua/config/lazy.lua}

            ${builtins.readFile /home/jenc/.config/nvim/lua/config/keymaps.lua}

            ${builtins.readFile /home/jenc/.config/nvim/lua/config/autocmds.lua}
          EOF

        '';
	};

 };


 # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  system.userActivationScripts.zshrc = "touch .zshrc"; # to avoid being prompted to generate the config for first time

  programs.direnv.enable = true;
 
 # Enable Zsh with Oh My Zsh
  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      plugins = [ "git" "zsh-autosuggestions" "zsh-autocomplete" "1password" "gh" "direnv" ];
      theme = "robbyrussell";
    };
  };
 
 
 # Enable automatic login for the user.
  services.getty.autologinUser = "jenc";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    direnv
    gitFull
    nixfmt-rfc-style
    starship
    vim
    neovim
    zsh
    oh-my-zsh
    tree
    fzf
    vimPlugins.nvim-cmp
    vimPlugins.LazyVim
];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  services.vscode-server = {
    enable = true;
    installPath = "/home/jenc/.cursor-server";
  };
  
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
   networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11";
  
  nix.gc.automatic = true;
  nix.gc.dates = "03:15"; # Run daily at 3:15 AM
}
