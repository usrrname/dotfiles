{
  pkgs,
  lib,
  system,
  config,
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
    headroomVersion = "0.35.0";
    # Compute anthropic proxy args with conditional code-aware flag.
    # --no-http2: shared HTTP/2 connections can corrupt TLS state when many
    # concurrent streams are cancelled (SSLV3_ALERT_BAD_RECORD_MAC), producing
    # dead streams ("0 stream events") and garbled non-streaming retries.
    enableCodeAware = config.headroom.enableCodeAware or false;
    anthropicProxyArgs = "--port 8787 --mode token --no-http2 --budget 500 --budget-period monthly"
      + lib.optionalString enableCodeAware " --code-aware";
    # Shared bootstrap: make sure the pinned headroom CLI is installed, then
    # exec the proxy with the given args.
    # envVars: optional attrset mapping varlock env names → runtime env names
    #          (e.g. { GEMINI_API_KEY_1 = "GEMINI_API_KEY"; } means "read
    #          GEMINI_API_KEY_1 from varlock, export it as GEMINI_API_KEY").
    headroomProxy = name: args: envVars: pkgs.writeShellScript "headroom-proxy-${name}" ''
      export PATH="$HOME/.local/bin:${pkgs.uv}/bin:$PATH"
      if ! command -v headroom >/dev/null 2>&1; then
        uv tool install --force --python 3.13 "headroom-ai[proxy]==${headroomVersion}"
      fi
      # Source varlock-managed env if available
      if command -v varlock >/dev/null 2>&1; then
        eval "$(varlock load --format shell 2>/dev/null)" || true
      fi
      # Remap varlock keys → runtime env vars (e.g. GEMINI_API_KEY_1 → GEMINI_API_KEY)
      ${lib.concatStringsSep "\n" (lib.mapAttrsToList (src: dst: ''
        if [ -n "''${${src}:-}" ]; then
          export ${dst}="''${${src}}"
        fi
      '') envVars)}
      exec headroom proxy ${args}
    '';
    proxyAgent = {
      name,
      args,
      env ? {},
      envVars ? {},
      lazy ? false,
    }: {
      serviceConfig = {
        ProgramArguments = ["${headroomProxy name args envVars}"];
        # lazy = true: don't start at login; start on demand via `launchctl
        # kickstart gui/$(id -u)/org.nixos.headroom-proxy-<name>`. KeepAlive
        # stays on so a lazily-started proxy still restarts if it crashes.
        RunAtLoad = !lazy;
        KeepAlive = true;
        ProcessType = "Background";
        StandardOutPath = "/Users/jenc/.headroom/proxy-${name}.log";
        StandardErrorPath = "/Users/jenc/.headroom/proxy-${name}.err.log";
        EnvironmentVariables = env;
      };
    };
  in {
    # Default (Anthropic) backend — shared by claude, opencode, sandboxes
    # routed at 127.0.0.1. Budget: $500/month (tracks usage, stops at limit).
    # Code-aware flag toggled via headroom.enableCodeAware option.
    headroom-proxy-anthropic = proxyAgent {
      name = "anthropic";
      args = anthropicProxyArgs;
    };
    # OpenCode Zen gateway — the free and pay-as-you-go models in opencode's
    # "headroom-zen" provider resolve here. The client's bearer token is
    # forwarded to the Zen API, so no key lives in the launchd env.
    # --mode token compresses frozen/prefix-cached messages for ~25-35% more
    # session length.
    headroom-proxy-deepseek = proxyAgent {
      name = "deepseek";
      args = "--port 8788 --mode token --openai-api-url https://opencode.ai/zen/v1 --provider-name OpenCode";
    };
    # OpenCode Go subscription gateway — kimi-k3 and other Go subscription
    # models resolve against the monthly Go quota instead of Zen pay-as-you-go
    # credits. Same endpoint family, extra /go path segment. Free models are
    # NOT served here — they stay on the Zen proxy (8788).
    headroom-proxy-go = proxyAgent {
      name = "go";
      args = "--port 8789 --mode token --openai-api-url https://opencode.ai/zen/go/v1 --provider-name OpenCodeGo";
    };
    # Gemini (Google AI Studio) — 3 proxies, each with its own API key.
    # Keys are read from varlock: GEMINI_API_KEY_1, GEMINI_API_KEY_2, GEMINI_API_KEY_3.
    # Each proxy remaps its numbered key → GEMINI_API_KEY for headroom's handler.
    # lazy = true: these don't run until you start them (headroomctl start gemini-N).
    headroom-proxy-gemini-1 = proxyAgent {
      name = "gemini-1";
      args = "--port 8790 --mode token";
      envVars = { GEMINI_API_KEY_1 = "GEMINI_API_KEY"; };
      lazy = true;
    };
    headroom-proxy-gemini-2 = proxyAgent {
      name = "gemini-2";
      args = "--port 8791 --mode token";
      envVars = { GEMINI_API_KEY_2 = "GEMINI_API_KEY"; };
      lazy = true;
    };
    headroom-proxy-gemini-3 = proxyAgent {
      name = "gemini-3";
      args = "--port 8792 --mode token";
      envVars = { GEMINI_API_KEY_3 = "GEMINI_API_KEY"; };
      lazy = true;
    };
  };

  # Add Homebrew to system PATH
  environment.systemPath = ["/opt/homebrew/bin"];

  # Sanity: pin the nix-darwin schema version so we don't accidentally
  # adopt breaking changes when bumping inputs.
  system.stateVersion = 5;

  system.primaryUser = username;
}
