# Dotfiles

Nix flakes (primary) + stow (fallback).

## Setup

```bash
./setup.sh        # Auto-detects Nix; falls back to stow
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

## Stow (fallback only)

```bash
./stow-dotfiles.sh          # Default: --adopt flag
./stow-dotfiles.sh ""       # No flags
```

**Stow arrays are intentionally empty** — all configs are Nix-managed via Home Manager modules:
- **COMMON**: _(empty)_
- **MACOS**: _(empty)_
- **LINUX**: _(empty)_

To add a stow package: add to appropriate array in `stow-dotfiles.sh`, then create `common/[pkg]/` or `macos/[pkg]/` directory. Currently no packages are stow-managed; everything goes through Home Manager modules in `modules/`.

## Claude Code Configuration

Hybrid pattern (see `modules/claude.nix`):
- **Nix-managed** (rebuild required): `~/.claude/settings.json`, `~/.claude/statusline-command.sh` — sourced from `common/claude/.claude/`
- **Symlinked at activation** (live-editable): `~/.claude/skills → ~/.agents/skills` so skill edits never require `darwin-rebuild`
- **Binary install**: `claude-code` is a homebrew cask on Mac (`hosts/mac-jenc/default.nix`), not nixpkgs — brew's mutable path supports the binary's self-update

Project-local Claude config lives at repo root: `~/.dotfiles/.claude/` (skills + `settings.local.json` for this repo).

## Testing

```bash
bats test/stow-dotfiles.bats
```

**Note**: `package.json` references `test/setup.bats` but actual test file is `test/stow-dotfiles.bats`.

## Critical Context

- **Don't assume common/ packages are stowed** — only those in stow arrays get stowed
- **`test/stow-dotfiles.bats` is stale**: the `COMMON packages are defined with expected packages` test asserts `opencode` is in `COMMON=()`, but opencode is nix-managed now. Test will fail; either update test or delete it
- `nix/` directory is never stowed (NixOS-only)
- `.stow-local-ignore` excludes many files from stow (see file for details)
- `macos/docker/` is tracked but **not deployed** — see `docs/plans/migration-open-issues.md`
