# Dotfiles

Managed with stow. Structure: `common/` (all OS), `linux/`, `macos/`, `nix/`.

## Stow

```bash
./stow-dotfiles.sh
```

## Add Package

1. `mkdir -p common/[pkg]/.config/[pkg]`
2. Copy config → `common/[pkg]/`
3. Remove original, stow recreates as symlink
4. Add to `COMMON` array in `stow-dotfiles.sh`

## Notes

- `nix/` not stowed (NixOS-only)
- OS-specific files (zsh, git) replace common versions
- Add to `.stow-local-ignore` to exclude (e.g., `op`)
