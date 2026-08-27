{
  pkgs,
  config,
  lib,
  ...
}: let
  sandbox-repo = pkgs.writeShellApplication {
    name = "sandbox-repo";
    runtimeInputs = with pkgs; [bubblewrap git opencode];
    text = builtins.readFile ./sandbox-repo.sh;
  };
in {
  home.packages = [sandbox-repo];
}
