{
  config,
  lib,
  pkgs,
  ...
}: let
  claudeDir = ../common/claude/.claude;
in {
  # Claude Code configuration
  #
  # Hybrid layout:
  #   - settings.json and statusline-command.sh are nix-managed (stable, change rarely)
  #   - ~/.claude/skills is symlinked to ~/.agents/skills via the activation hook
  #     below so skill edits don't require a rebuild
  #   - agents/, rules/, hooks/ are not managed here (add back if needed)
  home.file = {
    ".claude/settings.json".source = "${claudeDir}/settings.json";
    ".claude/statusline-command.sh" = {
      source = "${claudeDir}/statusline-command.sh";
      executable = true;
    };
  };

  home.activation.linkClaudeSkills = lib.hm.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD mkdir -p $HOME/.agents/skills
    if [ -L $HOME/.claude/skills ] || [ ! -e $HOME/.claude/skills ]; then
      $DRY_RUN_CMD ln -sfn $HOME/.agents/skills $HOME/.claude/skills
    fi
  '';
}
