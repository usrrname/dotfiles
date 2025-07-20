# dotfiles

Dotfiles setup made with:
- [stow](https://www.gnu.org/software/stow/)

- Mac setup from https://mac.install.guide/

- Underlying ideals from [12 Factor App config](https://12factor.net/config)

List all symlinks

```bash
ls -la ~ | grep "\->"
```

## 1Password Secret References

```bash
op://<vault-name>/<item-name>/[section-name/]<field-name>
```