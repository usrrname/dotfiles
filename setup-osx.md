# Setting Up Dotfiles on macOS

**Primary path: Nix + nix-darwin + Home Manager.** Stow is legacy and currently
all stow arrays are empty.

## Prerequisites

### 1. Install Nix

Use Determinate Nix (recommended — handles upgrades cleanly):

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

After install, restart your shell so `nix` is on PATH.

### 2. Clone the repository

```bash
cd ~
git clone https://github.com/usrrname/dotfiles.git .dotfiles
cd .dotfiles
```

### 3. Apply the configuration

```bash
sudo darwin-rebuild switch --flake .#mac-jenc
```

That single command:
- Installs nix-darwin (bootstraps on first run)
- Installs Home Manager
- Installs all nix-managed packages (git, neovim, ripgrep, fzf, node, go, etc.)
- Installs Homebrew if missing and syncs casks (1password, wezterm, claude-code, etc.)
- Materializes `~/.claude/settings.json`, `~/.gitconfig` (at `~/.config/git/config`), nvim config, etc.

## SSH signing (required for git commits)

Git is configured to sign commits with SSH via 1Password's `op-ssh-sign`:

```
gpg.format = "ssh"
gpg.ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
user.signingkey = "~/.ssh/id_ed25519.pub"
commit.gpgsign = true
```

Required steps after a fresh setup:

1. Install and unlock 1Password (it'll arrive via `homebrew.casks`).
2. Enable the **SSH agent** in 1Password settings → Developer.
3. Export your public key to disk (private key stays in 1Password):
   ```bash
   op read "op://Private/<your-ssh-key-item>/public key" > ~/.ssh/id_ed25519.pub
   chmod 644 ~/.ssh/id_ed25519.pub
   ```
4. Test: `git -C ~/.dotfiles commit --allow-empty -m test --dry-run` should not error.

If git complains about a missing pubkey, see `~/Documents/pkm/_sources/Home Lab/Dotfiles migration gotchas — nix + stow + Claude.md` for the recovery flow.

## Day-to-day updates

```bash
cd ~/.dotfiles
git pull
sudo darwin-rebuild switch --flake .#mac-jenc
```

To bump package versions (Claude Code, nvim, etc.):

```bash
nix flake update nixpkgs        # bump pinned nixpkgs
sudo darwin-rebuild switch --flake .#mac-jenc
brew upgrade --cask              # bump cask-installed apps (Claude Code, 1Password, etc.)
```

## Rollback

```bash
darwin-rebuild --list-generations
sudo darwin-rebuild switch --rollback
```

## Verify

```bash
ls -la ~/.claude/                        # settings.json, statusline-command.sh, skills -> ~/.agents/skills
readlink ~/.claude/settings.json         # should resolve into /nix/store/.../home-manager-files/.claude/settings.json
readlink ~/.config/nvim                  # should resolve into the same generation
which claude                              # /opt/homebrew/bin/claude (brew cask)
git config --list --show-origin | grep gpg.format  # should print gpg.format=ssh
```

## Legacy stow path (not used on Mac currently)

`./stow-dotfiles.sh` exists but its arrays are empty. Don't run it on Mac unless
you're moving a specific config out of nix management; see `AGENTS.md` for the
current state.

## Troubleshooting

- **Check distribution detection**: `./setup.sh check`
- **List packages**: `./setup.sh list`
- **Validate package config**: `./setup.sh validate`
- **Dry run setup**: `DRY_RUN=true ./setup.sh`
- **Verify symlinks**: `ls -la ~ | grep "\->"`

### Midnight Commander (mc) Colors

When using **Catppuccin Macchiato** theme in WezTerm, mc's dropdown menus (Options, Left, Right) may appear with unreadable light-on-light colors.

**Solution**: The `.aliasrc-osx` file includes an alias that launches mc with the `modarin256` skin:

```bash
alias mc='mc -S modarin256'
```

This skin is designed for 256-color terminals and provides better contrast with modern color schemes. Alternative skins if needed:
- `mc -S modarin256-defbg` - Black background variant
- `mc -S modarin256root` - Root user variant (darker, high contrast)
- `mc -b` - Black & white mode (guaranteed readable)

## Notes

- Homebrew will be installed automatically if missing
- Some packages may require manual configuration after installation
- Setup is based on [mac.install.guide](https://mac.install.guide/)

### zsh

```bash
## When each is loaded:
.zshenv
        → .zprofile
                → .zshrc 
                        → .zlogin
```

## Packages

## Mise

```bash
mise activate zsh
```

## OrbStack

macOS-specific Docker alternative. See [setup-osx.md](setup-osx.md) for setup details.

Set the default docker context to orbstack:

```bash
docker context use orbstack
```

## uv

Python package manager to replace pip, pip-tools, pipx, poetry, pyenv, twine, virtualenv, etc.

```bash
# Install uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# Create a virtual environment
uv venv

# Install packages
uv pip install <package>

# Run commands in the virtual environment
uv run <command>
```