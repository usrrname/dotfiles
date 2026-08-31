---
name: nix-darwin-macos
description: Manage macOS dotfiles via Nix flakes, nix-darwin, and Home Manager. Use when adding packages, installing nix-darwin, running darwin-rebuild, managing Homebrew casks/brews declaratively, bootstrapping a Mac, or troubleshooting Nix on macOS in the ~/.dotfiles repo.
---

# nix-darwin macOS

Manage the dotfiles flake on macOS. Repo root is `~/.dotfiles`.

## Bootstrap (first-time Nix install)

1. Install Nix:

   ```
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```

2. Open a new shell or `source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh`
3. Verify: `nix --version`
4. Bootstrap nix-darwin (needs `sudo` — activation refuses to run as a normal user even though the build step doesn't):

   ```
   cd ~/.dotfiles
   sudo nix run nix-darwin -- switch --flake .#mac-jenc
   ```

   Do this before `./setup.sh` on a brand-new Mac: `setup.sh` assumes `darwin-rebuild` already exists and just calls `sudo darwin-rebuild switch`, which fails with `sudo: darwin-rebuild: command not found` when nix-darwin has never been activated. Once this bootstrap succeeds, `darwin-rebuild` is on PATH and `./setup.sh` works directly on every later run.

## Key Files

| File | Purpose |
|---|---|
| `flake.nix` | Root flake: inputs (nixpkgs, home-manager, nix-darwin), host configs |
| `flake.lock` | Pinned inputs — commit after `nix flake update` |
| `hosts/mac-jenc/default.nix` | macOS host: hostname, homebrew casks/brews/taps, user |
| `home/default.nix` | Cross-platform Home Manager: packages, git, zsh, direnv, starship, fzf |
| `docs/plans/migration-to-nix-flakes-home-manager.md` | Full migration plan with phases |

## Add a Package

**nixpkgs CLI tool** → `home/default.nix` `home.packages`:

```nix
home.packages = with pkgs; [
  # existing...
  new-package  # search: https://search.nixos.org/packages
];
```

**macOS GUI app (cask)** → `hosts/mac-jenc/default.nix` `homebrew.casks`:

```nix
homebrew.casks = [ "firefox" "new-app" ];
```

**Homebrew-only formula** → `hosts/mac-jenc/default.nix` `homebrew.brews`:

```nix
homebrew.brews = [ "peonping/tap/peon-ping" "tap/formula" ];
```

**New Homebrew tap** → `hosts/mac-jenc/default.nix` `homebrew.taps`:

```nix
homebrew.taps = [ "owner/repo" ];
```

## Apply Changes

```
cd ~/.dotfiles
nix run nix-darwin -- switch --flake .#mac-jenc
```

## Verify

```
# Flake evaluates without errors
nix flake check

# See what changed
darwin-rebuild build --flake .#mac-jenc

# List managed brew packages
brew list | sort

# List managed casks
brew list --cask | sort

# List Home Manager generations (rollback)
darwin-rebuild --list-generations
```

## Rollback

```
darwin-rebuild --rollback
```

## Troubleshooting

- **"nix: command not found"** — Nix not installed or shell not sourced. Run bootstrap step 1, then open new shell.
- **"sudo: darwin-rebuild: command not found"** — nix-darwin has never been activated on this machine (`darwin-rebuild` doesn't exist yet, for root or the user). Run bootstrap step 4 (`sudo nix run nix-darwin -- switch --flake .#mac-jenc`) once, then `./setup.sh` / `sudo darwin-rebuild switch` work from then on.
- **Empty `/nix` directory** — Broken install. Remove `/nix` and reinstall.
- **Protocol "http" disabled** — Transient DNS. Retry or use `sh <(curl -L https://nixos.org/nix/install) --daemon`
- **Home Manager vs nix-darwin conflict** — nix-darwin owns system-level (`/etc/`, `/Applications`), Home Manager owns `~/`. Don't declare the same path in both.
- **Cask not installing** — Check `homebrew.enable = true` in `hosts/mac-jenc/default.nix`. nix-darwin must manage Homebrew for declarative casks.
