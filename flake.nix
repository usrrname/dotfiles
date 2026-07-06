{
  description = "jenc's dotfiles — Nix flakes + Home Manager";

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

  outputs = inputs @ {
      self,
      nixpkgs,
      home-manager,
      nix-darwin,
      ...
    }:
    let
      # allowUnfree must be set on the pkgs import here: standalone Home
      # Manager ignores `nixpkgs.config.*` set inside host modules when
      # `pkgs` is passed explicitly. Needed for unfree pkgs like
      # _1password-cli.
      mkLinuxHome =
        system:
       inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          modules = [ ./home ];
        };

      # Standalone Home Manager for non-NixOS Linux hosts (Fedora, Ubuntu, Debian)
      mkStandaloneLinuxHome =
        system: hostConfig:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          modules = [ hostConfig ];
        };

      # nix fmt invokes the formatter with the flake root as argv[1]; the
      # wrapper walks the tree and formats every .nix file it finds.
      mkFormatter =
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        pkgs.writeShellApplication {
          name = "dotfiles-fmt";
          runtimeInputs = [ pkgs.alejandra ];
          text = ''
            root="''${1:-.}"
            find "$root" \
              -name '*.nix' \
              -not -path '*/node_modules/*' \
              -not -path '*/.git/*' \
              -not -path '*/result*' \
              -print0 \
              | xargs -0 alejandra --quiet
          '';
        };
      in
    {
      # throwaway targets so `nix flake check` and
      # `home-manager build --flake .#test-<arch>` validate the skeleton
      # without touching any real host. Both x86 and ARM Linux are
      # generated so this works in any OrbStack VM regardless of Mac
      # architecture.
      #
      homeConfigurations = {
        # Phase 0 — throwaway targets for validation
        test-x86_64-linux = mkLinuxHome "x86_64-linux";
        test-aarch64-linux = mkLinuxHome "aarch64-linux";
        
        # Fedora (standalone Home Manager)
        # Apply on Fedora host: home-manager switch --flake .#fedora
        fedora = mkStandaloneLinuxHome "x86_64-linux" ./hosts/fedora;
        
        # Ubuntu (standalone Home Manager)
        # Apply on Ubuntu host: home-manager switch --flake .#ubuntu
        ubuntu = mkStandaloneLinuxHome "x86_64-linux" ./hosts/ubuntu;
        
        # Raspberry Pi 4B NAS (standalone Home Manager on Debian)
        # Apply on Pi: home-manager switch --flake .#pi-nas
        pi-nas = mkStandaloneLinuxHome "aarch64-linux" ./hosts/pi-nas;
      };

      # Apple Silicon Mac. After installing Nix on the Mac:
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

      # Format Nix files: `nix fmt`
      formatter.aarch64-darwin = mkFormatter "aarch64-darwin";
      formatter.x86_64-linux = mkFormatter "x86_64-linux";

      # Ephemeral repo sandbox — run commands in an isolated workspace
      # Enter with: nix develop .#sandbox-repo
      devShells.x86_64-linux.sandbox-repo =
        let
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
        in
        pkgs.mkShell {
          name = "sandbox-repo";
          packages = with pkgs; [ bubblewrap git ];
          shellHook = ''
            echo "🧊 Repo sandbox — bwrap + git available"
            echo ""
            echo "Quick start:"
            echo "  sandbox-repo ~/project             # sandbox existing repo"
            echo "  sandbox-repo ./new-thing make test  # create + run command"
            echo ""
          '';
        };

      # NixOS box. Apply on the NixOS host:
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
