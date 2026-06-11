# dotfiles

Dotfiles managed with [Nix flakes](https://nixos.wiki/wiki/Flakes), [Home Manager](https://nix-community.github.io/home-manager/), and [nix-darwin](https://github.com/LnL7/nix-darwin) for macOS.

Legacy [stow](https://www.gnu.org/software/stow/) setup still available for Linux/non-Nix environments.

## Quick Start

### macOS

```bash
# Clone and rebuild
git clone https://github.com/usrrname/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
sudo darwin-rebuild switch --flake .#mac-jenc
```

### NixOS

```bash
# Clone the repo
git clone https://github.com/usrrname/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Copy hardware configuration from existing install
sudo cp /etc/nixos/hardware-configuration.nix hosts/nixos-box/

# Rebuild
sudo nixos-rebuild switch --flake .#nixos-box
```

### Fedora/Ubuntu/Debian (standalone Home Manager)

```bash
# Install Nix (if not already installed)
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# Clone and apply
git clone https://github.com/usrrname/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
home-manager switch --flake .#fedora
```

### Raspberry Pi (Debian aarch64)

```bash
# Check if Nix is already installed
which nix && nix --version

# If Nix is not installed:
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# Source Nix profile (if home-manager command not found)
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

# Install home-manager (if not available)
nix profile add home-manager

# Clone and apply
git clone https://github.com/usrrname/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
home-manager switch --flake .#pi-nas
```

### Updating

```bash
cd ~/.dotfiles
git pull

# macOS
sudo darwin-rebuild switch --flake .#mac-jenc

# NixOS
sudo nixos-rebuild switch --flake .#nixos-box

# Fedora/Ubuntu/Debian
home-manager switch --flake .#fedora
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
├── modules/               # Nix modules (bash, claude, direnv, gh, nvim, opencode, tmux)
├── common/                # Stow / shared config sources (claude, nvim, opencode)
├── macos/                 # macOS-specific (currently only docker)
├── .claude/               # Project-local Claude Code config for THIS repo
└── docs/plans/            # Migration plans + open issues
```

### What's managed by Nix

- **System packages**: git, curl, wget, ripgrep, fzf, neovim, go, nodejs, pnpm, yarn, bun, etc.
- **Homebrew casks** (macOS only): wezterm, obsidian, 1password, orbstack, slack, spotify, firefox, brave-browser, tailscale, gpg-suite, **claude-code**
- **Programs**: git, ssh, bash, zsh, direnv, gh, tmux, starship, vim, nvim (LazyVim)
- **AI tools**: `opencode` (nix on Linux, brew tap on Mac), `claude-code` (brew cask on Mac)
- **Configs**: SSH config, Wezterm, nvim/LazyVim, bash aliases, shell aliases, environment variables, Claude Code `settings.json` + `statusline-command.sh`

### Claude Code skills are NOT nix-managed (intentional)

`modules/claude.nix` is a hybrid: stable config files are nix-managed (rebuild required to change), but `~/.claude/skills` is a runtime symlink to `~/.agents/skills` so skill edits never need `darwin-rebuild`. See `docs/plans/agent-skills-symlink-deployment.md`.

### What's still stow-managed

Nothing currently. All stow arrays in `stow-dotfiles.sh` are empty; everything is nix-managed. The stow script is kept for fallback on non-Nix systems.

### Removed (no longer needed)

- `verdaccio`, `husky`, `zed`, `mc` (Midnight Commander), `iterm2`
- Stow-managed `bash`, `direnv`, `gh`, `home-manager`, `op`, `ssh`, `tmux`, `vim`, `wezterm` (now nix-managed)
- Stow-managed `agents` (replaced by `~/.agents/skills/` runtime tree)

## Adding a New Config

### Option 1: Nix (preferred for macOS)

Edit `home/default.nix` or `modules/`:

```nix
# Example: add a program
programs.someapp = {
  enable = true;
  # ... settings
};

# Example: link a config file
xdg.configFile."someapp/config.toml".source = ./someapp/config.toml;
```

Then rebuild:
```bash
sudo darwin-rebuild switch --flake .#mac-jenc
```

### Option 2: Stow (for Linux or unmigrated configs)

```bash
# 1. Create the directory structure
mkdir -p common/someapp/.config/someapp

# 2. Copy your config
cp -r ~/.config/someapp/* common/someapp/.config/someapp/

# 3. Remove the original
rm -rf ~/.config/someapp

# 4. Add to COMMON array in stow-dotfiles.sh
# 5. Run stow
./stow-dotfiles.sh
```

## Adding a Homebrew Package

Edit `hosts/mac-jenc/default.nix`:

```nix
homebrew = {
  brews = [
    "some-formula"
  ];
  casks = [
    "some-app"
  ];
};
```

Then rebuild.

## Troubleshooting

**Check what's installed:**
```bash
nix profile list
brew list
brew list --cask
```

**Verify configs:**
```bash
ssh -G hostname  # Check SSH config
nvim --version   # Check neovim
git config --list --show-origin  # See all sources (git config lives at ~/.config/git/config under HM, not ~/.gitconfig)
```

**Rollback:**
```bash
# List generations
darwin-rebuild --list-generations

# Rollback to previous
sudo darwin-rebuild switch --rollback
```

**Dry run:**
```bash
nix build .#darwinConfigurations.mac-jenc.system --dry-run
```

**Nix flakes only see git-tracked files.** New files (or untracked edits to renames) must be `git add`'d before `darwin-rebuild` will see them. The error reads:
> Path 'foo.nix' in the repository "..." is not tracked by Git.

**Common gotchas:** see `docs/plans/migration-open-issues.md` (open items) and `~/Documents/pkm/_sources/Home Lab/Dotfiles migration gotchas — nix + stow + Claude.md` (broader notes).

## Nvim/LazyVim

Build plugins

```bash
nvim --headless -c "Lazy sync" -c "qa"
```

Force clean and reinstall LazyVim plugins

```bash
nvim --headless -c "lua require('lazy').clean()" -c "lua require('lazy').sync()" -c "qa"
```

Refresh and sync plugins (interactive)

```bash
:Lazy clean
:Lazy sync
```

### OpenCode (AI Assistant)

| Keymap | Description |
|--------|-------------|
| `<leader>oo` | Toggle terminal |
| `<leader>oa` | Ask about file/selection |
| `<leader>oc` | Execute action |
| `<leader>os` | Send selection (visual) |
| `<leader>oe` | Explain code |
| `<leader>or` | Review code |
| `go` / `goo` | Add range/line |
| `<S-Up/Down>` | Scroll |

**Security:** Background agents read-only; bash requires confirmation; sessions excluded from git

## 1Password

```bash
op://<vault-name>/<item-name>/[section-name/]<field-name>
```

```bash
Usage:  op read <reference> [flags]

Examples:

Print the secret saved in the field 'password', on the item 'db', in the vault 'app-prod':

op read op://app-prod/db/password

Use a secret reference with a query parameter to retrieve a one-time
password:

op read "op://app-prod/db/one-time password?attribute=otp"

Use a secret reference with a query parameter to get an SSH key's private key in the OpenSSH format:

op read "op://app-prod/ssh key/private key?ssh-format=openssh"

Save the SSH key found on the item 'ssh' in the 'server' vault
as a new file 'key.pem' on your computer:

op read --out-file ./key.pem op://app-prod/server/ssh/key.pem

Use 'op read' in a command with secret references in place of plaintext secrets:

docker login -u $(op read op://prod/docker/username) -p $(op read op://prod/docker/password)
      
```

