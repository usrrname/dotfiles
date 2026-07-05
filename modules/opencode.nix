{ config, lib, pkgs, ... }:

let
  # Homebrew tap build reads ~/.opencode/; nixpkgs build honors XDG.
  opencodeDir =
    if pkgs.stdenv.isDarwin
    then "${config.home.homeDirectory}/.opencode"
    else "${config.xdg.configHome}/opencode";
in
{
  # First-run seed: copy template configs, then hand off to runtime management.
  # Idempotent — skipped once the target dir exists, so user edits persist.
  home.activation.seedOpencodeConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -d "${opencodeDir}" ]; then
      $VERBOSE_ECHO "Seeding opencode config to ${opencodeDir}..."
      $DRY_RUN_CMD mkdir -p "${opencodeDir}"
      $DRY_RUN_CMD cp -r ${./../common/opencode/.config/opencode}/. "${opencodeDir}/"
    fi
  '';

  # Install npm dependencies for opencode plugins
  home.activation.installOpencodeDeps = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    export PATH="${pkgs.nodejs}/bin:$PATH"
    if [ -d "${opencodeDir}" ] && [ -f "${opencodeDir}/package.json" ]; then
      $DRY_RUN_CMD cd "${opencodeDir}"
      $DRY_RUN_CMD npm install --silent 2>/dev/null || true
    fi
  '';
}
