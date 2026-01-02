# dotfiles

[![Built with Devbox](https://www.jetify.com/img/devbox/shield_moon.svg)](https://www.jetify.com/devbox/docs/contributor-quickstart/)

Dotfiles setup made with:
- [stow](https://www.gnu.org/software/stow/)

- [direnv](https://direnv.net) w/ global config in `~/.config/direnv/direnvrc`

- Mac setup from [mac.install.guide](https://mac.install.guide/)

- Underlying ideals from [12 Factor App config](https://12factor.net/config)

`./setup-osx.sh` tested with [Bats](https://github.com/bats-core/bats-core)

### Contents
- [dotfiles](#dotfiles)
    - [Contents](#contents)
  - [Maintenance](#maintenance)
  - [act](#act)
  - [zsh](#zsh)
  - [Mise](#mise)
  - [Symlinking](#symlinking)
  - [Nvim/LazyVim](#nvimlazyvim)
  - [1Password](#1password)
  - [Devbox](#devbox)
  - [OrbStack](#orbstack)
  - [uv](#uv)


## Maintenance

Keep submodules updated

```bash
git submodule update
```

## act

```bash
# insert 1password token into github action secrets
act -s GITHUB_TOKEN=$(op read $GITHUB_TOKEN)
```

## zsh

```bash
## When each is loaded:
.zshenv
        → .zprofile
                → .zshrc 
                        → .zlogin
```

## Mise

```bash
mise activate zsh
```

## Symlinking

```bash
cp <directory> <target>
mkdir -p <directory>
stow <directory>
```

List all symlinks

```bash
ls -la ~ | grep "\->"
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

## Devbox

[FAQ](https://www.jetify.com/docs/devbox/faq/)

```bash
devbox add <package> # add a package to the devbox environment
devbox rm <package> # remove a package from the devbox environment
devbox info # show info about the devbox environment
devbox update # update packages in devbox
devbox version update # update devbox to the latest version
devbox shell # initialize the devbox shell
devbox generate direnv # generate a direnvrc file
```

Clean up packages in nix store

```bash
devbox run -- nix store gc --extra-experimental-features nix-command
```

## OrbStack

Set the default docker context to orbstack

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