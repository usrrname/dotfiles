# Fedora host configuration
Standalone Home Manager configuration for Fedora Workstation.

See [main README](../../README.md#fedora) for quick start instructions.

## System-level changes (via `setup.sh`)

| Change | What it does | Why |
|---|---|---|
| **dnf packages** | Installs `bubblewrap` | bubblewrap needs system namespace APIs that Nix binaries can't provide |
| **systemd services** | Enables `tailscaled` on boot | Tailscale binary is Nix-managed but needs systemd for auto-start |
| **Passwordless sudo** | Writes `/etc/sudoers.d/10-<user>-nopasswd` | Avoids repeated password prompts during bootstrap/update |
| **Default shell** | Sets zsh via `chsh` | Fish is the Fedora default; zsh is managed declaratively via Home Manager |
| **podman socket** | Enables podman's Docker API socket so the real `docker compose` binary can use podman transparently | This lets `docker compose` work without the Docker daemon — podman translates the API, runs rootless |

## Nix-managed packages (`default.nix`)

The Fedora host config manages these via Nix rather than dnf:

| Package | Purpose | Notes |
|---|---|---|
| **tailscale** | VPN/mesh networking | Binary from Nix; systemd service enabled separately |
| **input-remapper** | Keyboard remapping | Preset config deployed via `modules/input-remapper.nix` |
| **gcc, gnumake, openssl** | Build toolchain | Version-pinned by nixpkgs |
| **libyaml, gmp** | Development libraries | For Ruby/Python builds |
| **nodejs, pnpm, yarn** | JavaScript toolchain | Replaces nvm/fnm; npm prefix set to `~/.npm-global` (Nix store is read-only) |
| **python3, uv** | Python toolchain | uv replaces pip/poetry |
| **go** | Go development | |
| **brave** | Web browser | Pure Nix build, no dnf repo needed |
| **\_1password-cli** | 1Password CLI | `op` for secret management |
| **lsb-release** | LSB info | Used by scripts for distro detection |

## Npm activation script

A `home.activation` script in `default.nix` runs after every `home-manager switch` to:
- Create `~/.npm-global` (writable prefix; Nix store is read-only)
- Install `socket` globally if not present (not packaged in nixpkgs)

## Installed modules

| Module | What it does |
|---|---|
| `../../modules/input-remapper.nix` | Deploys a Keychron Q11 preset (`mac-mode.json`) remapping Alt+ keys to Ctrl+Shift+ shortcuts — matches macOS muscle memory for copy/paste/terminal |
| `../../modules/sandbox-repo.nix` | Provides `sandbox-repo` command — runs repos in a bubblewrap-isolated namespace with `/home` as tmpfs, network shared, all caps dropped |
| `../../modules/home-manager-gc.nix` | Weekly auto-clean of old Home Manager generations (keeps 7 days) — included via `home/linux.nix` |

## Key architectural notes

- **Standalone Home Manager**: Fedora uses standalone HM (no nix-darwin/NixOS). Home Manager manages user-level configs only; system packages that can't come from Nix are installed via dnf in `setup.sh`.
- **dnf/Nix split boundary**: Packages that need system libraries (EGL, namespace APIs) come from dnf. Everything else comes from Nix for version-pinning and declarative management.
- **Nix-preset configs migrated**: Configs previously managed via GNU Stow (bash, direnv, gh, tmux, nvim, etc.) are now fully Nix-managed through Home Manager modules.

## How to apply

```bash
# From the dotfiles root:
home-manager switch --flake .#fedora
```

For initial bootstrap (includes dnf packages and system services):
```bash
./setup.sh
```
