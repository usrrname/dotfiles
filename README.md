# dotfiles

[![Built with Devbox](https://www.jetify.com/img/devbox/shield_moon.svg)](https://www.jetify.com/devbox/docs/contributor-quickstart/)

Dotfiles setup made with:
- [stow](https://www.gnu.org/software/stow/)

- Mac setup from https://mac.install.guide/

- Underlying ideals from [12 Factor App config](https://12factor.net/config)

- Trying out Devbox for isolated consistent dev environments

List all symlinks

```bash
ls -la ~ | grep "\->"
```

## 1Password Secret References

```bash
op://<vault-name>/<item-name>/[section-name/]<field-name>
```

## Devbox

```bash
devbox add <package> # add a package to the devbox environment
devbox rm <package> # remove a package from the devbox environment
devbox info # show info about the devbox environment
devbox update # update packages in devbox
devbox shell # initialize the devbox shell
```
