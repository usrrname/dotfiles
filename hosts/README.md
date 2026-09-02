# hosts/

Per-host entry points for the flake. Each subdirectory maps to a key in
`flake.nix`'s `darwinConfigurations` / `nixosConfigurations` /
`homeConfigurations` outputs.

## Current hosts

| Host | Type | Status | Apply command |
| ------ | ------ | -------- | --------------- |
| `mac-jenc/` | nix-darwin | ✅ Done | `sudo darwin-rebuild switch --flake .#mac-jenc` |
| `nixos/` | NixOS | ✅ Done | `nixos-rebuild switch --flake .#nixos` |
| `fedora/` | standalone HM | ✅ Done | `home-manager switch --flake .#fedora` |
| `ubuntu/` | standalone HM | ✅ Done | `home-manager switch --flake .#ubuntu` |
| `pi-nas/` | standalone HM | ✅ Done | `home-manager switch --flake .#pi-nas` |
| `sandbox/` | standalone HM | ✅ Done | `home-manager switch --flake .#sandbox` |

## Host configuration

### mac-jenc (macOS Apple Silicon)

- Uses nix-darwin for system config
- Homebrew managed declaratively for casks (OrbStack, 1Password, etc.)
- Home Manager for user packages and dotfiles

### nixos (OrbStack NixOS VM, aarch64)

- Full NixOS system config running in OrbStack VM on macOS
- Requires `hardware-configuration.nix` (gitignored, copied from `/etc/nixos/`)
- Standalone Home Manager for user packages and dotfiles

### fedora (Fedora Workstation x86_64)

- Standalone Home Manager (no nix-darwin/NixOS)
- System packages managed via dnf
- Nix only manages user environment

### ubuntu (Ubuntu Workstation x86_64)

- Standalone Home Manager (no nix-darwin/NixOS)
- System packages managed via apt
- Nix only manages user environment

### pi-nas (Raspberry Pi 4B NAS, Debian aarch64)

- Standalone Home Manager on ARM Linux
- System packages managed via apt
- Nix only manages user environment
- Pi-specific packages: ufw, fail2ban, hd-idle, tailscale
- Docker managed at system level (not via Nix)
- `xoff` alias for soft shutdown

### sandbox (Lima Debian agent sandbox)

- Isolated Home Manager environment for Claude Code agent
- Minimal footprint: no credential tooling or global language toolchains
- Per-project toolchains via direnv + project flakes
- Core utilities: git, curl, wget, ripgrep, fzf, tmux, neovim, nodejs
- Claude Code CLI installed via npm in activation script
- Headroom proxy integration for local development

## Adding a new host

1. Create `hosts/<hostname>/default.nix`
2. Add to `flake.nix` under the appropriate output (`darwinConfigurations`, `nixosConfigurations`, or `homeConfigurations`)
3. Update this README
