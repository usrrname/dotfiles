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
./setup.sh                                  # installs apt pkgs + HM config

# One-time manual steps:
sudo tailscale up && sudo tailscale set --operator=$USER   # auth + delegate
systemctl --user enable --now syncthing.service            # start syncthing
systemctl --user start tailscale-serve.service             # start tailscale serve
```

See [`setup-pi.md`](setup-pi.md) for full details.

### Updating

```bash
cd ~/.dotfiles
git pull
./setup.sh    # auto-detects platform and runs the right rebuild
```

## Sandbox (`sandbox-repo`)

Run commands in an isolated workspace via `bwrap` (Linux) / `git` (all platforms). Load it on demand — direnv does **not** auto-load it:

```bash
nix develop .#sandbox-repo
sandbox-repo ~/project              # sandbox existing repo
sandbox-repo ./new-thing make test  # create + run command
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

## Headroom Proxies

Three persistent proxy services run locally for token caching and compression:

| Port | Backend | Purpose |
|------|---------|---------|
| 8787 | Anthropic/OpenAI | Claude Code, Codex |
| 8788 | OpenCode Zen | Pay-as-you-go + free models |
| 8789 | OpenCode Go | $5/mo subscription (open-source models) |

Check status: `headroom doctor` · individual health: `curl http://127.0.0.1:{port}/health`

**macOS (launchd):**

```bash
launchctl list | grep headroom                          # check all loaded
launchctl unload ~/Library/LaunchAgents/org.nixos.headroom-proxy-<name>.plist   # disable
launchctl load   ~/Library/LaunchAgents/org.nixos.headroom-proxy-<name>.plist   # re-enable
```

If a plist is missing after a rebuild, run `sudo darwin-rebuild switch --flake .#mac-jenc`.

**Linux (systemd):**

```bash
systemctl --user status headroom-proxy-<name>            # status
systemctl --user stop headroom-proxy-<name>              # stop
systemctl --user start headroom-proxy-<name>             # start
```

## Adding a Config or Homebrew Package

Edit `home/default.nix` or `modules/` for Nix-managed programs. For macOS Homebrew casks/brews, edit `hosts/mac-jenc/default.nix` under `homebrew`. Rebuild:

```bash
sudo darwin-rebuild switch --flake .#mac-jenc   # macOS
home-manager switch --flake .#<host>             # Linux standalone HM
```

Validation (no real host needed):

```bash
nix build .#homeConfigurations.test-x86_64-linux.activationPackage
nix build .#homeConfigurations.test-aarch64-linux.activationPackage
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
