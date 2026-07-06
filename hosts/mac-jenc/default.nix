{
  pkgs,
  lib,
  system,
  ...
}: let
  # Username for this host - change if deploying to a different user
  username = "jenc";
in {
  # System-level identity
  networking.hostName = "m2";
  networking.computerName = "mac";

  # Nix daemon settings — Determinate manages Nix itself, so disable
  # nix-darwin's native Nix management to avoid conflicts.
  nix.enable = false;

  nixpkgs = {
    hostPlatform= "aarch64-darwin";
    config = {
      inherit system;
      allowUnfree = true;
      experimental-features = "nix-command flakes";
    };
  };

  # Declare the user nix-darwin manages so home-manager can attach to it.
  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
  };

  system.defaults = {
    finder = {
      AppleShowAllFiles = true; # show hidden files in Finder
      ShowPathbar = true;
      FXPreferredViewStyle = "clmv"; # column view
    };
    NSGlobalDomain = {
      AppleShowAllExtensions = true; # show file extensions everywhere
      InitialKeyRepeat = 15; # faster key repeat
      KeyRepeat = 2;
      "com.apple.keyboard.fnState" = true; # F-keys as F-keys
    };
    dock = {
      autohide = true;
      orientation = "bottom";
      showhidden = true;
    };
  };
  # Use TouchId for Sudo
  security.pam.services.sudo_local.touchIdAuth = true;
  # Manage Homebrew declaratively — used for casks and tap-only formulae
  # that aren't in nixpkgs.
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      # "none" — Homebrew's --cleanup now requires --force; nix-darwin
      # hasn't caught up yet. Run `brew bundle cleanup --force` manually.
      cleanup = "none";
    };

    taps = [
      "peonping/tap"
      "anomalyco/tap"
      "oven-sh/bun"
    ];

    # Formulae that have no nixpkgs equivalent
    brews = [
      "peonping/tap/peon-ping"
      "anomalyco/tap/opencode"
    ];

    # GUI apps. Casks always stay on Homebrew — nixpkgs doesn't ship
    # macOS .app bundles for these.
    casks = [
      "brave-browser"
      "firefox"
      "wezterm"
      "slack"
      "spotify"
      "tailscale-app"
      "orbstack"
      "gpg-suite"
      "1password"
      "obsidian"
    ];
  };

  # Add Homebrew to system PATH
  environment.systemPath = ["/opt/homebrew/bin"];

  # Sanity: pin the nix-darwin schema version so we don't accidentally
  # adopt breaking changes when bumping inputs.
  system.stateVersion = 5;

  system.primaryUser = username;
}
