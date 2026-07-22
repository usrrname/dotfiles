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
  #   - settings.json is an out-of-store symlink to the dotfiles working tree so
  #     Claude Code can write it (plugins, permissions, marketplaces do atomic
  #     temp+rename, which fails on a read-only /nix/store symlink). Claude's edits
  #     land in ~/.dotfiles and show up as git diffs there — commit or discard.
  #   - statusline-command.sh stays store-managed (Claude only reads/executes it)
  #   - ~/.claude/skills is symlinked to ~/.agents/skills via the activation hook
  #     below so skill edits don't require a rebuild
  #   - agents/, rules/, hooks/ are not managed here (add back if needed)
  home.file = {
    ".claude/settings.json".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/common/claude/.claude/settings.json";
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
