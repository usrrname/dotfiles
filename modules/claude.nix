{ config, lib, pkgs, ... }:

let
  claudeDir = ../macos/claude/.claude;
in
{
  # Claude Code configuration
  home.file = {
    ".claude/settings.json".source = "${claudeDir}/settings.json";
    ".claude/statusline-command.sh".source = "${claudeDir}/statusline-command.sh";
    ".claude/agents".source = "${claudeDir}/agents";
    ".claude/rules".source = "${claudeDir}/rules";
    ".claude/skills".source = "${claudeDir}/skills";
    ".claude/hooks".source = "${claudeDir}/hooks";
  };
}
