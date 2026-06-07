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
      #
      homeConfigurations = {
        test-x86_64-linux = mkLinuxHome "x86_64-linux";
        test-aarch64-linux = mkLinuxHome "aarch64-linux";
      };

      # Phase 1 — Apple Silicon Mac. After installing Nix on the Mac:
      #   nix run nix-darwin -- switch --flake .#mac-jenc
      darwinConfigurations.mac-jenc = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./hosts/mac-jenc
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.jenc = import ./home;
          }
        ];
      };

      # Phase 4 — NixOS box. Apply on the NixOS host:
      #   nixos-rebuild switch --flake .#nixos-box
      nixosConfigurations.nixos-box = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/nixos-box
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.jenc = {
              imports = [
                ./home
                ./home/linux.nix
              ];
            };
          }
        ];
      };
    };
}
