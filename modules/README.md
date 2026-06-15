# modules/

Reusable Home Manager modules — one per tool — composed by `home/default.nix`
and per-host entries in `hosts/`.

## Current modules

| Module | Status | Description |
|--------|--------|-------------|
| `tmux.nix` | ✅ Done | Absorbs `common/tmux/tmux.conf` (~59 bytes) |
| `gh.nix` | ✅ Done | `programs.gh` + `common/gh/.config/gh/config.yml` |
| `direnv.nix` | ✅ Done | `programs.direnv` settings + `common/direnv/.config/direnv/direnvrc` |
| `nvim.nix` | ✅ Done | `programs.neovim` with the LazyVim tree as `xdg.configFile.source` |
| `opencode.nix` | ✅ Done | OpenCode config files + npm plugin deps |
| `bash.nix` | ✅ Done | `programs.bash` with aliases and init scripts |
| `claude.nix` | ✅ Done | Claude Code settings, skills, hooks, agents |
| `git.nix` | 📋 Planned | `programs.git` absorbing `common/git/.gitconfig` and platform overrides |
| `starship.nix` | ✅ Done | `programs.starship` config extracted from `home/default.nix` |
| `zsh.nix` | 📋 Planned | `programs.zsh` absorbing `.zshrc`, `.zshenv`, `.aliasrc-osx` |
| `wezterm.nix` | ✅ Done | `programs.wezterm` + `common/wezterm/.config/wezterm/wezterm.lua` |

## Adding a new module

1. Create `modules/<tool>.nix` with the Home Manager configuration
2. Import it in `home/default.nix` under `imports = [ ... ];`
3. Update this README
