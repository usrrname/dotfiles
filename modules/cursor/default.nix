{
  config,
  lib,
  pkgs,
  ...
}:
let
  settingsFile = builtins.fromJSON (builtins.readFile ./settings.json);
in {
  options.cursor.enable = lib.mkEnableOption "Cursor IDE configuration";

  config = lib.mkIf config.cursor.enable {
    xdg.configFile."cursor/settings.json".text = builtins.toJSON settingsFile;
  };
}
