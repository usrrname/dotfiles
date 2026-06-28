# dotfiles

Dotfiles managed with [Nix flakes](https://nixos.wiki/wiki/Flakes), [Home Manager](https://nix-community.github.io/home-manager/), and [nix-darwin](https://github.com/LnL7/nix-darwin) for macOS.

> AI agents: [`AGENTS.md`](AGENTS.md) has actionable guidance for working in this repo.

## Quick Start

### macOS

```bash
git clone https://github.com/usrrname/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
sudo darwin-rebuild switch --flake .#mac-jenc
```

### NixOS

```bash
git clone https://github.com/usrrname/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
sudo cp /etc/nixos/hardware-configuration.nix hosts/nixos-box/
sudo nixos-rebuild switch --flake .#nixos-box
```

### Fedora/Ubuntu/Debian (standalone Home Manager)

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
git clone https://github.com/usrrname/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./setup.sh
```

### Raspberry Pi (Debian aarch64)

```bash
git clone https://github.com/usrrname/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
home-manager switch --flake .#pi-nas
```

### Updating

```bash
cd ~/.dotfiles
./update.sh    # git pull + submodule update + setup (auto-detects platform)
```

## Structure

```
├── flake.nix              # Nix flake entry point
├── hosts/
│   ├── mac-jenc/          # macOS system config (nix-darwin)
│   ├── nixos-box/         # NixOS system config
│   ├── fedora/            # Fedora (standalone HM)
│   ├── ubuntu/            # Ubuntu (standalone HM)
│   └── pi-nas/            # Raspberry Pi 4B NAS (standalone HM)
├── home/                  # Shared Home Manager config (packages, programs)
├── modules/               # Reusable Nix modules (bash, claude, direnv, gh, git, nvim, opencode, tmux, starship, wezterm)
├── common/                # Shared config sources (claude, nvim, opencode, git, ssh, wezterm)
├── .claude/               # Project-local Claude Code config
└── docs/plans/            # Migration plans + open issues
```

### What's managed by Nix

- **System packages**: git, curl, ripgrep, fzf, neovim, go, nodejs, pnpm, yarn, bun, gcc, tmux, direnv
- **Homebrew casks** (macOS only): wezterm, obsidian, 1password, orbstack, slack, spotify, brave-browser, tailscale, gpg-suite, claude-code
- **Programs**: git, bash, zsh, direnv, gh, tmux, starship, nvim (LazyVim)
- **AI tools**: opencode (nixpkgs on Linux, anomalyco/tap brew on Mac), claude-code (brew cask)
- **Sandbox tools**: sandbox-repo (bubblewrap-isolated environments)
- **Configs**: git, SSH, Wezterm, nvim/LazyVim, bash/zsh aliases, environment variables, Claude Code settings + statusline, actrc, starship

## Adding a Config or Homebrew Package

Edit `home/default.nix` or `modules/` for Nix-managed programs. For macOS Homebrew casks/brews, edit `hosts/mac-jenc/default.nix` under `homebrew`. Rebuild:

```bash
sudo darwin-rebuild switch --flake .#mac-jenc   # macOS
home-manager switch --flake .#<host>             # Linux standalone HM
```

Validation (no real host needed):

```bash
nix build .#homeConfigurations.test-x86_64-linux
nix build .#homeConfigurations.test-aarch64-linux
```

## Neovim (LazyVim)

`~/.config/nvim` is an out-of-store symlink to `common/nvim/.config/nvim`, so edits take effect on reload without a rebuild. Rebuild plugins:

```bash
nvim --headless -c "Lazy sync" -c "qa"
nvim --headless -c "lua require('lazy').clean()" -c "lua require('lazy').sync()" -c "qa"   # clean + reinstall
```

## Troubleshooting

- **Nix flakes only see git-tracked files** — `git add path/to/file` before `darwin-rebuild`
- **"Existing file would be clobbered"** — remove the old path (`rm ~/.config/nvim`), then re-run
- **64B Homebrew cask stub** — app shows installed but won't launch: `brew reinstall --cask <name>`
- **Rollback:** `sudo darwin-rebuild switch --rollback`
- **Dry run:** `nix build .#darwinConfigurations.mac-jenc.system --dry-run`
- **Common gotchas:** `docs/plans/migration-open-issues.md`
