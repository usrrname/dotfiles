# Dotfiles

Nix flakes (primary).

## Setup

```bash
./setup.sh        # Auto-detects platform and runs the right rebuild
./update.sh       # Git pull + submodule update + setup
```

### Nix Targets

| Host | Command |
|------|---------|
| macOS (Apple Silicon) | `darwin-rebuild switch --flake .#mac-jenc` |
| NixOS | `nixos-rebuild switch --flake .#nixos-box` |
| Fedora (standalone HM) | `home-manager switch --flake .#fedora` |
| Ubuntu (standalone HM) | `home-manager switch --flake .#ubuntu` |
| Raspberry Pi (standalone HM) | `home-manager switch --flake .#pi-nas` |

### Validation (no real host)

```bash
nix build .#homeConfigurations.test-x86_64-linux
nix build .#homeConfigurations.test-aarch64-linux
```

### Fedora host (`hosts/fedora/`)

- **dnf/Nix split**: `bubblewrap` and `podman-docker` via dnf (system namespace APIs). Everything else from Nix.
- **Fedora packages**: edit `hosts/fedora/default.nix` under `home.packages`. The shared `home/default.nix` is for packages common across all hosts.
- **npm workaround**: Nix store is read-only for `npm install -g`. `hosts/fedora/default.nix` sets `NPM_CONFIG_PREFIX=~/.npm-global` with a `home.activation` script to install globals (`socket`). Add new globals there.
- **Bootstrap**: `./setup.sh` handles the full Fedora bootstrap (dnf pkgs, systemd services, passwordless sudo, zsh). Running `home-manager switch --flake .#fedora` alone only applies Nix user config.
- **input-remapper preset** at `common/input-remapper/.config/input-remapper-2/presets/Keychron Keychron Q11/mac-mode.json`, deployed by `modules/input-remapper.nix`.

## Architecture

- `flake.nix` defines all outputs; `home/default.nix` imports shared modules (`modules/`); per-host overrides in `hosts/<host>/default.nix`.
- `home.stateVersion = "24.11"` (all hosts).
- macOS: Determinate manages Nix itself → `nix.enable = false` in `hosts/mac-jenc/default.nix` to avoid conflicts.
- Homebrew managed declaratively via nix-darwin (`hosts/mac-jenc/default.nix`). `cleanup = "none"` means stale cask metadata lingers.
- `opencode` comes from nixpkgs on Linux, from `anomalyco/tap` brew tap on Mac. The `modules/opencode.nix` seeds config on first run (copy, not symlink) and runs `npm install` for plugins.
- `claude-code` is a Homebrew cask on Mac (not nixpkgs), declared in `hosts/mac-jenc/default.nix`.

## Claude Code (Hybrid Pattern)

- **Nix-managed** (rebuild needed): `~/.claude/settings.json`, `~/.claude/statusline-command.sh` — sourced from `common/claude/.claude/`
- **Symlinked at activation** (live-editable): `~/.claude/skills → ~/.agents/skills` via `home.activation` hook in `modules/claude.nix`
- Project-local config: `~/.dotfiles/.claude/settings.local.json`

## Neovim

- `~/.config/nvim` is an out-of-store symlink to `common/nvim/.config/nvim` via `home.activation` (not `mkOutOfStoreSymlink`, which Home Manager 26.11-pre+ rejects) — see `modules/nvim.nix` for the pattern.
- LazyVim needs write access (lazy-lock.json), which fails with read-only Nix store symlinks.
- Rebuild plugins: `nvim --headless -c "Lazy sync" -c "qa"`.

## Shell

- `npm`, `npx`, `pnpm` aliased through `socket npm`, `socket npx`, `socket pnpm` (see `home/default.nix` `programs.zsh.shellAliases`).
- `act` configured to use `catthehacker/ubuntu:act-latest` images for running GHA locally (`home/default.nix` `xdg.configFile."act/actrc"`).

## Important Constraints

- **Nix flakes only see git-tracked files.** Stage new files before building: `git add path/to/file`.
- On macOS, `./setup.sh` runs `sudo darwin-rebuild`. Homebrew changes require the same command.
- `macos/docker/` is tracked but **not deployed** — see `docs/plans/migration-open-issues.md`.

## Troubleshooting

**"Error installing file outside $HOME"** — HM 26.11-pre+ rejects `mkOutOfStoreSymlink`. Use `home.activation` scripts instead (see `modules/nvim.nix`).

**"Existing file would be clobbered"** — old symlinks block activation. `rm ~/.config/nvim` (or whatever path), then re-run.

**64B Homebrew cask stub** — `brew bundle` can write metadata before binary finishes downloading. `brew list --cask <name>` says installed but `/Applications/<Name>.app` is a 64-byte skeleton. Fix: `brew reinstall --cask <name>`.

**Rollback:** `sudo darwin-rebuild switch --rollback`.
**Dry run:** `nix build .#darwinConfigurations.mac-jenc.system --dry-run`.
