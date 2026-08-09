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
    hostPlatform = "aarch64-darwin";
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
      "dmno-dev/tap"
    ];

    # Formulae that have no nixpkgs equivalent
    brews = [
      "peonping/tap/peon-ping"
      "anomalyco/tap/opencode"
      # varlock loads .env.schema (resolves OPENCODE_API_KEY from 1Password) and is
      # the single source — no npm varlock dep in package.json. Formula ≥ 1.15 for
      # the plugin schema (0.6.x fails); bumped 0.6.4 → 1.16.1 via `brew upgrade`.
      "dmno-dev/tap/varlock"
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
      "claude-code@latest"
    ];
  };

  # Headroom context-compression proxy instances, one per upstream. Declarative
  # replacement for `headroom install apply --preset persistent-service`. The
  # CLI is installed (version-pinned) by modules/headroom.nix; launchd services
  # defined below are nix-darwin specific (home-manager systemd services handle Linux).
  # Self-bootstrap: if headroom.nix activation hasn't run yet, the proxy wrapper
  # installs the CLI on first start.
  launchd.user.agents = let
    headroomVersion = "0.34.0";
    # Shared bootstrap: make sure the pinned headroom CLI is installed, then
    # exec the proxy with the given args.
    headroomProxy = name: args: pkgs.writeShellScript "headroom-proxy-${name}" ''
      export PATH="$HOME/.local/bin:${pkgs.uv}/bin:$PATH"
      if ! command -v headroom >/dev/null 2>&1; then
        uv tool install --force --python 3.13 "headroom-ai[proxy]==${headroomVersion}"
      fi
      exec headroom proxy ${args}
    '';
    proxyAgent = {
      name,
      args,
    }: {
      serviceConfig = {
        ProgramArguments = ["${headroomProxy name args}"];
        RunAtLoad = true;
        KeepAlive = true;
        ProcessType = "Background";
        StandardOutPath = "/Users/jenc/.headroom/proxy-${name}.log";
        StandardErrorPath = "/Users/jenc/.headroom/proxy-${name}.err.log";
      };
    };
  in {
    # Default (Anthropic) backend — shared by claude, opencode, sandboxes
    # routed at 127.0.0.1. Budget: $200/month (tracks usage, stops at limit).
    headroom-proxy = proxyAgent {
      name = "anthropic";
      args = "--port 8787 --budget 200";
    };
    # DeepSeek via OpenCode Go — the proxy relays to opencode's Zen gateway
    # (https://opencode.ai/zen/v1), so the DeepSeek models in opencode's
    # "headroom" provider resolve through the OpenCode Go subscription. The
    # client's bearer token is forwarded to the Zen API, so no key lives in
    # the launchd env. --mode token compresses frozen/prefix-cached messages
    # for ~25-35% more session length.
    headroom-proxy-deepseek = proxyAgent {
      name = "deepseek";
      args = "--port 8788 --mode token --openai-api-url https://opencode.ai/zen/v1 --provider-name OpenCode";
    };
  };

  # Add Homebrew to system PATH
  environment.systemPath = ["/opt/homebrew/bin"];

  # Sanity: pin the nix-darwin schema version so we don't accidentally
  # adopt breaking changes when bumping inputs.
  system.stateVersion = 5;

  system.primaryUser = username;
}
