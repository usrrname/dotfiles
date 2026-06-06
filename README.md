# dotfiles

Dotfiles managed with [Nix flakes](https://nixos.wiki/wiki/Flakes), [Home Manager](https://nix-community.github.io/home-manager/), and [nix-darwin](https://github.com/LnL7/nix-darwin) for macOS.

Legacy [stow](https://www.gnu.org/software/stow/) setup still available for Linux/non-Nix environments.

## Quick Start (macOS)

```bash
# Clone and rebuild
git clone https://github.com/usrrname/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
sudo darwin-rebuild switch --flake .#mac-jenc
```

This installs packages, links configs, and sets up the system declaratively.

### Updating

```bash
cd ~/.dotfiles
git pull
sudo darwin-rebuild switch --flake .#mac-jenc
```

## Structure

```
├── flake.nix              # Nix flake entry point
├── hosts/mac-jenc/        # macOS system config (nix-darwin)
├── home/                  # Home Manager config (packages, programs)
├── modules/               # Nix modules (direnv, gh, nvim, tmux)
├── common/                # Stow packages (legacy, being migrated)
└── macos/                 # macOS-specific stow packages
```

### What's managed by Nix

- **System packages**: git, curl, wget, ripgrep, fzf, neovim, go, fnm, etc.
- **Homebrew casks**: wezterm, obsidian, 1password, orbstack, etc.
- **Programs**: git, ssh, zsh, direnv, gh, tmux, starship
- **Configs**: SSH config, Wezterm, shell aliases, environment variables

### What's still stow-managed

- `bash`, `agents`, `vim`, `opencode` (common)
- `act`, `claude`, `iterm2`, `husky`, `verdaccio` (macOS)

To stow these:
```bash
./stow-dotfiles.sh
```

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
```

**Verify configs:**
```bash
ssh -G hostname  # Check SSH config
nvim --version   # Check neovim
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

