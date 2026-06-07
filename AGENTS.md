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
| Fedora (standalone HM) | `home-manager switch --flake .#fedora-mini` |
| Raspberry Pi (standalone HM) | `home-manager switch --flake .#pi-nas` |

## Stow (fallback only)

```bash
./stow-dotfiles.sh          # Default: --adopt flag
./stow-dotfiles.sh ""       # No flags
```

**Stow arrays are intentionally minimal** — most `common/` configs are Nix-managed:
- **COMMON**: `agents`
- **MACOS**: `act`
- **LINUX**: _(empty)_

To add a stow package: add to appropriate array in `stow-dotfiles.sh`, then create `common/[pkg]/` or `macos/[pkg]/` directory.

## Testing

```bash
bats test/stow-dotfiles.bats
```

**Note**: `package.json` references `test/setup.bats` but actual test file is `test/stow-dotfiles.bats`.

## Critical Context

- **Don't assume common/ packages are stowed** — only those in stow arrays get stowed
- **Test expects `opencode` in COMMON array** but it's not currently there (test will fail)
- `nix/` directory is never stowed (NixOS-only)
- `.stow-local-ignore` excludes many files from stow (see file for details)
