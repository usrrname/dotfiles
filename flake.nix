# flake.nix - Main entry point for NixOS + home-manager
{
  description = "Dotfiles with Nix and Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      systems = {
        linux = "aarch64-linux";
        pi = "aarch64-linux";
      };
    in
    {
      # Home-manager standalone (Debian, RPi, macOS)
      homeConfigurations = {
        linux = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { system = systems.linux; };
          modules = [ ./linux/home.nix ];
        };

        pi = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { system = systems.pi; };
          modules = [ ./linux/home.nix ];
        };
      };

      # NixOS configuration (system + home-manager integrated)
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          ./hosts/nixos/configuration.nix
          home-manager.nixosModules.home-manager
          { home-manager.users.jenc = import ./linux/home.nix; }
        ];
      };
    };
}
