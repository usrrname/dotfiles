# modules/

Reusable Home Manager modules — one per tool — composed by `home/default.nix`
and per-host entries in `hosts/`.

Planned (Phase 3, ordered low-risk-first):

1. `tmux.nix`     — absorbs `common/tmux/tmux.conf` (~59 bytes, trivial)
2. `gh.nix`       — `programs.gh` + `common/gh/.config/gh/config.yml`
3. `direnv.nix`   — `programs.direnv` settings + `common/direnv/.config/direnv/direnvrc`
4. `git.nix`      — `programs.git` absorbing `common/git/.gitconfig` and platform overrides
5. `starship.nix` — `programs.starship` (currently inline in `home/default.nix`)
6. `zsh.nix`      — `programs.zsh` absorbing `.zshrc`, `.zshenv`, `.aliasrc-osx`
7. `nvim.nix`     — `programs.neovim` with the LazyVim tree as `xdg.configFile.source`
8. `wezterm.nix`  — `.wezterm.lua` via `xdg.configFile`

Currently empty.
