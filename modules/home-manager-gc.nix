{ pkgs, config, lib, ... }:

let
  cfg = config.modules.home-manager-gc;
in {
  options.modules.home-manager-gc = {
    enable = lib.mkEnableOption "automatic Home Manager generation GC";
    keepDays = lib.mkOption {
      type = lib.types.int;
      default = 7;
      description = "Remove generations older than this many days";
    };
    frequency = lib.mkOption {
      type = lib.types.str;
      default = "weekly";
      description = "systemd OnCalendar expression (weekly, daily, Mon, etc.)";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.home-manager-gc = {
      Unit = {
        Description = "Home Manager generation garbage collector";
        After = [ "network.target" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = ''${pkgs.home-manager}/bin/home-manager expire-generations ${toString cfg.keepDays}'';
      };
    };

    systemd.user.timers.home-manager-gc = {
      Unit.Description = "Home Manager generation GC timer";
      Timer = {
        OnCalendar = cfg.frequency;
        Persistent = true;          # catch up after boot if missed
        RandomizedDelaySec = 3600;   # don't hit exactly on the hour
      };
      Install.WantedBy = [ "timers.target" ];
    };
  };
}
