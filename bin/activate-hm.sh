#!/usr/bin/env sh

set -e

#-------------------------------------------------
# hms
#-------------------------------------------------
# aliasing "home-manager switch" command for flake
CONFIG_DIR=${XDG_CONFIG_HOME:=$HOME/nix}
/nix/var/nix/profiles/default/bin/nix \
  --extra-experimental-features "nix-command flakes" \
  run $CONFIG_DIR/home-manager#homeConfigurations.\"$USER\".activationPackage
