{ config, lib, pkgs, ... }:

{
  # OpenCode AI assistant configuration
  xdg.configFile = {
    # Main config files
    "opencode/opencode.json".source = ../common/opencode/.config/opencode/opencode.json;
    "opencode/tui.json".source = ../common/opencode/.config/opencode/tui.json;
    "opencode/oh-my-openagent.json".source = ../common/opencode/.config/opencode/oh-my-openagent.json;
    "opencode/no-comment-hooks.md".source = ../common/opencode/.config/opencode/no-comment-hooks.md;
    "opencode/package.json".source = ../common/opencode/.config/opencode/package.json;

    # Modes
    "opencode/modes/implement.md".source = ../common/opencode/.config/opencode/modes/implement.md;
    "opencode/modes/review.md".source = ../common/opencode/.config/opencode/modes/review.md;

    # Skills
    "opencode/skills/agent-communication.md".source = ../common/opencode/.config/opencode/skills/agent-communication.md;
    "opencode/skills/commit-conventions.md".source = ../common/opencode/.config/opencode/skills/commit-conventions.md;
    "opencode/skills/smart-handoff.md".source = ../common/opencode/.config/opencode/skills/smart-handoff.md;
    "opencode/skills/systematic-debugger.md".source = ../common/opencode/.config/opencode/skills/systematic-debugger.md;
  };

  # Install npm dependencies for opencode plugins
  home.activation.installOpencodeDeps = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    export PATH="${pkgs.nodejs}/bin:$PATH"
    if [ -d ${config.xdg.configHome}/opencode ] && [ -f ${config.xdg.configHome}/opencode/package.json ]; then
      $DRY_RUN_CMD cd ${config.xdg.configHome}/opencode
      $DRY_RUN_CMD npm install --silent 2>/dev/null || true
    fi
  '';
}
