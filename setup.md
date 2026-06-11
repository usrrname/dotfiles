# Setup Scripts — Technical Reference

For usage instructions, see [README.md](README.md). For macOS-specific or
Pi-specific setup, see [setup-osx.md](setup-osx.md) and [setup-pi.md](setup-pi.md).

## Current state

The Nix migration replaced the per-OS package scripts (`scripts/setup/packages-*.sh`,
`scripts/setup-osx.sh`, etc.) that this file used to document. Those files no
longer exist. The scripts that remain are minimal wrappers around nix and stow.

```
├── setup.sh              # Thin wrapper: detects Nix → runs the right rebuild
├── stow-dotfiles.sh      # Stow fallback (all arrays currently empty)
├── update.sh             # git pull + submodule update + setup.sh
└── nix/scripts/          # Misc nix helper scripts
```

## What `setup.sh` does

```sh
if nix is installed:
  on macOS    → sudo darwin-rebuild switch --flake .#mac-jenc
  on NixOS    → sudo nixos-rebuild switch --flake .#nixos-box
  on Linux    → home-manager switch --flake .#fedora
                (fedora target also serves Ubuntu/Debian via standalone HM)
else:
  → ./stow-dotfiles.sh    # legacy stow path
```

The flake-aware path is the default everywhere; the stow fallback only
activates when Nix is genuinely absent. On the Pi NAS host, prefer the explicit
`home-manager switch --flake .#pi-nas` (per `setup-pi.md`).

## What `update.sh` does

```sh
git pull
git submodule update --init --recursive
./setup.sh
```

Use this for routine updates. To bump pinned package versions (separate from
applying config changes):

```sh
nix flake update nixpkgs
./setup.sh
brew upgrade --cask          # Mac only — bumps cask-installed apps like claude-code
```

## What `stow-dotfiles.sh` does

OS-aware stow runner. All three package arrays (`COMMON`, `LINUX`, `MACOS`) are
currently empty — there is nothing to stow. The script remains as a fallback
mechanism. If a future config needs stow management:

1. Add the package name to the appropriate array in `stow-dotfiles.sh`.
2. Create `common/<pkg>/` (or `macos/<pkg>/`, `linux/<pkg>/`) with the directory
   structure that should land at `~/`.
3. Run `./stow-dotfiles.sh ""` (empty arg = no `--adopt`).

**Don't use `--adopt` (the default with no args)** when other tools write into
target directories — see the gotchas doc.

## Package management

Packages are declared in Nix, not in shell arrays:

- **Cross-platform CLI**: `home/default.nix` → `home.packages = with pkgs; [ ... ]`
- **OS-specific in nix**: same file, under `lib.optionals isLinux [ ... ]` /
  `lib.optionals isDarwin [ ... ]` blocks
- **macOS Homebrew (formulae + casks)**: `hosts/mac-jenc/default.nix` →
  `homebrew.brews` / `homebrew.casks` (e.g., `claude-code` is a cask)
- **Linux apt/dnf**: handled by the host OS (the Linux Nix configs don't try to
  manage system packages outside the user environment)

## Related docs

- [README.md](README.md) — Quick start per platform
- [setup-osx.md](setup-osx.md) — macOS setup including 1Password SSH signing
- [setup-pi.md](setup-pi.md) — Raspberry Pi setup
- [docs/plans/migration-open-issues.md](docs/plans/migration-open-issues.md) —
  Outstanding decisions and known gaps
- [docs/plans/migration-to-nix-flakes-home-manager.md](docs/plans/migration-to-nix-flakes-home-manager.md) —
  Original migration plan
