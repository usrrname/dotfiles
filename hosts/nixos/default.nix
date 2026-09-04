# NixOS box system configuration
# This file contains system-level config; user-level config is in home/default.nix
{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}:
let
  # Username for this host - change if deploying to a different user
  username = "jenc";
in
{
  imports = [
    "${modulesPath}/virtualisation/lxc-container.nix"
    ./incus.nix
    ./orbstack.nix
    ./hydra.nix
    (fetchTarball {
      url = "https://github.com/nix-community/nixos-vscode-server/tarball/master";
      sha256 = "179gqv45mby7wxdmrjmk8qqfgxh9316x2l9dkcvmmqrp9i4w5qfs";
    })
  ];

  networking = {
    dhcpcd.enable = false;
    useDHCP = false;
    useHostResolvConf = false;
  };

  systemd.network = {
    enable = true;
    networks."50-eth0" = {
      matchConfig.Name = "eth0";
      networkConfig = {
        DHCP = "ipv4";
        IPv6AcceptRA = true;
      };
      linkConfig.RequiredForOnline = "routable";
    };
  };

  # Timezone and locale
  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_CA.UTF-8";

  # SSH agent for cargo private key access (device-sw dev-env-setup)
  programs.ssh.startAgent = true;

  # nix-ld for VS Code Remote-SSH compatibility (device-sw dev-env-setup)
  programs.nix-ld.enable = true;

  users.users.jenc = {
    uid = 501;
    extraGroups = [
      "wheel"
      "orbstack"
      "audio"
    ];
    isSystemUser = true;
    group = "users";
    createHome = true;
    home = "/home/jenc";
    homeMode = "700";
    useDefaultShell = true;
  };

  security.sudo.wheelNeedsPassword = false;
  users.mutableUsers = false;

  # Shell
  programs.zsh.enable = true;

  # Passwordless sudo
  security.sudo.extraRules = [
    {
      users = [ "${username}" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

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
    nixfmt
    nodejs
    pnpm
    vimPlugins.nvim-cmp
    vimPlugins.LazyVim
    claude-code
    ghostty.terminfo
  ];
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Enable OpenSSH (required by sops for key management)
  services.openssh.enable = lib.mkForce true;

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
  nix.settings.trusted-users = [
    "root"
    username
  ];

  nix.settings.substituters = [
    "https://cache.nixos.org/"
    "https://hydra.vital.company"
  ];
  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "hydra.vital.company-1:olecgNoiYwSyPA3/vfE7bbkq0yfp5NGbV1xdc/LZpIQ="
  ];
  nix.settings.netrc-file = "/etc/netrc";

  # Trust Vital's internal CA so HTTPS to hydra.vital.company (and other
  # internal hosts) verifies correctly.
  security.pki.certificateFiles = [ ./certs/vital-internal-ca.pem ];

  nix.gc.automatic = true;
  nix.gc.dates = "03:15";

  # System state version
  system.stateVersion = "24.11";
}
