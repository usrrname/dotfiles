{
  pkgs,
  lib,
  ...
}:

{
  # System-level identity
  networking.hostName = "mac-jenc";
  networking.computerName = "mac-jenc";

  # Nix daemon settings (managed by Determinate Systems installer, but
  # nix-darwin can own these declaratively).
  nix.enable = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Declare the user nix-darwin manages so home-manager can attach to it.
  users.users.jenc = {
    name = "jenc";
    home = "/Users/jenc";
  };

  # Manage Homebrew declaratively — used for casks and tap-only formulae
  # that aren't in nixpkgs.
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      # "uninstall" removes anything not declared here on every switch.
      # "zap" also removes orphan config files. Leaving as uninstall to
      # minimise surprise during Phase 1 migration.
      cleanup = "uninstall";
    };

    taps = [
      "peonping/tap"
      "anomalyco/tap"
      "oven-sh/bun"
    ];

    # Formulae that have no nixpkgs equivalent (or that we deliberately
    # keep on Homebrew during the Phase 1 transition).
    brews = [
      "peonping/tap/peon-ping"
      "anomalyco/tap/opencode"
    ];

    # GUI apps. Casks always stay on Homebrew — nixpkgs doesn't ship
    # macOS .app bundles for these.
    casks = [
      "firefox"
      "wezterm"
      "slack"
      "spotify"
      "tailscale"
      "orbstack"
      "gpg-suite"
      "1password"
    ];
  };

  # Let nix-darwin manage /etc/zshrc bits (Apple's defaults + nix paths).
  # User-level zsh config lives in Home Manager.
  programs.zsh.enable = true;

  # Sanity: pin the nix-darwin schema version so we don't accidentally
  # adopt breaking changes when bumping inputs.
  system.stateVersion = 5;

  system.primaryUser = "jenc";
}
