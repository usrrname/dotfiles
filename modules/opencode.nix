{ config, lib, pkgs, ... }:

{
  # First-run seed: copy template configs, then hand off to runtime management
  home.activation.seedOpencodeConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -d "${config.xdg.configHome}/opencode" ]; then
      $VERBOSE_ECHO "Seeding opencode config from dotfiles..."
      $DRY_RUN_CMD mkdir -p "${config.xdg.configHome}/opencode"
      $DRY_RUN_CMD cp -r ${./../common/opencode/.config/opencode}/* "${config.xdg.configHome}/opencode/"
    fi
  '';

  # Install npm dependencies for opencode plugins
  home.activation.installOpencodeDeps = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    export PATH="${pkgs.nodejs}/bin:$PATH"
    if [ -d "${config.xdg.configHome}/opencode" ] && [ -f "${config.xdg.configHome}/opencode/package.json" ]; then
      $DRY_RUN_CMD cd "${config.xdg.configHome}/opencode"
      $DRY_RUN_CMD npm install --silent 2>/dev/null || true
    fi
  '';
}
