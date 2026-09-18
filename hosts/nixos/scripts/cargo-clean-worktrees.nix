{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.cargo-clean-worktrees;
  script = pkgs.writeShellScript "cargo-clean-worktrees" ''
    set -euo pipefail
    find "${cfg.worktreesDir}" -mindepth 2 -maxdepth 3 -name Cargo.toml -print0 |
      while IFS= read -r -d "" manifest; do
        echo "cargo clean: $manifest"
        ${pkgs.cargo}/bin/cargo clean --manifest-path "$manifest"
      done
  '';
in {
  options.modules.cargo-clean-worktrees = {
    enable = lib.mkEnableOption "nightly cargo clean across git worktrees";
    worktreesDir = lib.mkOption {
      type = lib.types.str;
      description = "Directory containing worktree checkouts to clean (each worktree may hold several Cargo.toml manifests)";
    };
    onCalendar = lib.mkOption {
      type = lib.types.str;
      default = "02:00";
      description = "systemd OnCalendar expression, evaluated in the system's local timezone";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.cargo-clean-worktrees = {
      Unit.Description = "cargo clean across device-sw worktrees";
      Service = {
        Type = "oneshot";
        ExecStart = "${script}";
      };
    };

    systemd.user.timers.cargo-clean-worktrees = {
      Unit.Description = "Nightly cargo clean timer for device-sw worktrees";
      Timer = {
        OnCalendar = cfg.onCalendar;
        Persistent = true; # catch up after boot if the VM was off at 2am
      };
      Install.WantedBy = ["timers.target"];
    };
  };
}
