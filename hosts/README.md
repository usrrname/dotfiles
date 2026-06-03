# hosts/

Per-host entry points for the flake. Each subdirectory maps to a key in
`flake.nix`'s `darwinConfigurations` / `nixosConfigurations` /
`homeConfigurations` outputs.

Planned (per `docs/plans/migration-to-nix-flakes-home-manager.md`):

- `mac-jenc/`   — nix-darwin host: brew casks + Home Manager (Phase 1)
- `fedora-mini/` — standalone Home Manager on Fedora Workstation (Phase 2)
- `nixos-box/`  — NixOS host folding in `nix/etc/nixos/configuration.nix` (Phase 4)

Currently empty — see the Phase 0 entry in the migration plan for the
flake skeleton's verification target.
