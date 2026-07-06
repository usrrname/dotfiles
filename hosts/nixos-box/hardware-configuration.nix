# Placeholder hardware configuration for nixos-box
# This file must be replaced with the actual hardware configuration
# from /etc/nixos/hardware-configuration.nix on the target host.
#
# To generate: nixos-generate-config --dir /tmp/nixos-config
# Then copy hardware-configuration.nix to this location.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Placeholder values - must be replaced with actual hardware config
  boot.initrd.availableKernelModules = [];
  boot.initrd.kernelModules = [];
  boot.kernelModules = [];
  boot.extraModulePackages = [];

  # Placeholder file systems - must be replaced
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/PLACEHOLDER";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/PLACEHOLDER";
    fsType = "vfat";
  };

  swapDevices = [];

  # Networking
  networking.useDHCP = lib.mkDefault true;

  # Architecture
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
