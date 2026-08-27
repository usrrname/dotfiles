{
  config,
  lib,
  pkgs,
  ...
}: let
  # Homebrew tap build reads ~/.opencode/; nixpkgs build honors XDG.
  opencodeDir =
    if pkgs.stdenv.isDarwin
    then "${config.home.homeDirectory}/.opencode"
    else "${config.xdg.configHome}/opencode";
in {
  # First-run seed: copy template configs, then hand off to runtime management.
  # Idempotent — skipped once the target dir exists, so user edits persist.
  home.activation.seedOpencodeConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ ! -d "${opencodeDir}" ]; then
      $VERBOSE_ECHO "Seeding opencode config to ${opencodeDir}..."
      $DRY_RUN_CMD mkdir -p "${opencodeDir}"
      $DRY_RUN_CMD cp -r ${./../common/opencode/.config/opencode}/. "${opencodeDir}/"
      # cp -r preserves the Nix store's read-only dir permissions; later
      # activation steps (e.g. syncOpencodePeonPingConfig) need to write here.
      $DRY_RUN_CMD chmod -R u+w "${opencodeDir}"
    fi
  '';

  # Sync peon-ping config from dotfiles to the XDG runtime path. peon-ping-setup
  # creates its own config on first run; this activation ensures the dotfiles
  # version is the source of truth on every rebuild.
  home.activation.syncOpencodePeonPingConfig = lib.hm.dag.entryAfter ["seedOpencodeConfig"] ''
    peonPingDir="$HOME/.config/opencode/peon-ping"
    if [ -d "$peonPingDir" ] || [ -d "${../common/opencode/.config/opencode/peon-ping}" ]; then
      $VERBOSE_ECHO "Syncing peon-ping config from dotfiles..."
      $DRY_RUN_CMD mkdir -p "$peonPingDir"
      $DRY_RUN_CMD cp -f ${../common/opencode/.config/opencode/peon-ping/config.json} "$peonPingDir/config.json"
      $DRY_RUN_CMD cp -f ${../common/opencode/.config/opencode/peon-ping/peon-icon.png} "$peonPingDir/peon-icon.png"
    fi
  '';

  # Install npm dependencies for opencode plugins
  home.activation.installOpencodeDeps = lib.hm.dag.entryAfter ["linkGeneration"] ''
    export PATH="${pkgs.nodejs}/bin:$PATH"
    if [ -d "${opencodeDir}" ] && [ -f "${opencodeDir}/package.json" ]; then
      $DRY_RUN_CMD cd "${opencodeDir}"
      $DRY_RUN_CMD npm install --silent 2>/dev/null || true
    fi
  '';
}
