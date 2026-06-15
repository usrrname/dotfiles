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



## Claude Code Configuration

Hybrid pattern (see `modules/claude.nix`):
- **Nix-managed** (rebuild required): `~/.claude/settings.json`, `~/.claude/statusline-command.sh` — sourced from `common/claude/.claude/`
- **Symlinked at activation** (live-editable): `~/.claude/skills → ~/.agents/skills` so skill edits never require `darwin-rebuild`
- **Binary install**: `claude-code` is a homebrew cask on Mac (`hosts/mac-jenc/default.nix`), not nixpkgs — brew's mutable path supports the binary's self-update

Project-local Claude config lives at repo root: `~/.dotfiles/.claude/` (skills + `settings.local.json` for this repo).

## Testing

Stow is no longer used.

## Critical Context
- `macos/docker/` is tracked but **not deployed** — see `docs/plans/migration-open-issues.md`
