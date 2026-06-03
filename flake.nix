{
  description = "jenc's dotfiles — Nix flakes + Home Manager (+ nix-darwin) migration target";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nix-darwin,
      ...
    }@inputs:
    let
      mkLinuxHome =
        system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { inherit system; };
          modules = [ ./home ];
        };
    in
    {
      # Phase 0 — throwaway targets so `nix flake check` and
      # `home-manager build --flake .#test-<arch>` validate the skeleton
      # without touching any real host. Both x86 and ARM Linux are
      # generated so this works in any OrbStack VM regardless of Mac
      # architecture.
      homeConfigurations = {
        test-x86_64-linux = mkLinuxHome "x86_64-linux";
        test-aarch64-linux = mkLinuxHome "aarch64-linux";
      };

      # Phase 1 will populate this:
      #   mac-jenc = nix-darwin.lib.darwinSystem { ... };
      darwinConfigurations = { };

      # Phase 4 will populate this, folding in nix/etc/nixos/configuration.nix:
      #   nixos-box = nixpkgs.lib.nixosSystem { ... };
      nixosConfigurations = { };
    };
}
