# Dotfiles

Nix flakes (primary).

## Setup

```bash
./setup.sh        # Auto-detects platform and runs the right rebuild
```

### First-time macOS bootstrap

On a brand-new Mac (Nix installed but nix-darwin never activated), `./setup.sh` fails with `sudo: darwin-rebuild: command not found` — it assumes `darwin-rebuild` already exists. Bootstrap it once first:

```bash
sudo nix run nix-darwin -- switch --flake .#mac-jenc
```

`sudo` is required for the activation step even though the build itself doesn't need it. After this succeeds, `darwin-rebuild` is on PATH and `./setup.sh` works on every later run.

### Nix Targets

| Host | Command |
| ------ | --------- |
| macOS (Apple Silicon) | `sudo darwin-rebuild switch --flake .#mac-jenc` |
| NixOS | `sudo nixos-rebuild switch --flake .#nixos` |
| Fedora (standalone HM) | `home-manager switch --flake .#fedora` |
| Ubuntu (standalone HM) | `home-manager switch --flake .#ubuntu` |
| Raspberry Pi (standalone HM) | `home-manager switch --flake .#pi-nas` |

### Validation (no real host)

Test the configuration that your host OS is on.

```bash
nix build .#homeConfigurations.test-x86_64-linux.activationPackage
nix build .#homeConfigurations.test-aarch64-linux.activationPackage
```

### Fedora host (`hosts/fedora/`)

- **dnf/Nix split**: `bubblewrap` and `podman-docker` via dnf (system namespace APIs). Everything else from Nix.
- **Fedora packages**: edit `hosts/fedora/default.nix` under `home.packages`. The shared `home/default.nix` is for packages common across all hosts.
- **npm workaround**: Nix store is read-only for `npm install -g`. `hosts/fedora/default.nix` sets `NPM_CONFIG_PREFIX=~/.npm-global` with a `home.activation` script to install globals (`socket`). Add new globals there.
- **Bootstrap**: `./setup.sh` handles the full Fedora bootstrap (dnf pkgs, systemd services, passwordless sudo, zsh). Running `home-manager switch --flake .#fedora` alone only applies Nix user config.
- **input-remapper preset** at `common/input-remapper/.config/input-remapper-2/presets/Keychron Keychron Q11/mac-mode.json`, deployed by `modules/input-remapper.nix`.

## Architecture

- `flake.nix` defines all outputs; `home/default.nix` imports shared modules (`modules/`); per-host overrides in `hosts/<host>/default.nix`.
- `home.stateVersion = "24.11"` (all hosts).
- macOS: Determinate manages Nix itself → `nix.enable = false` in `hosts/mac-jenc/default.nix` to avoid conflicts.
- Homebrew managed declaratively via nix-darwin (`hosts/mac-jenc/default.nix`). `cleanup = "none"` means stale cask metadata lingers.
- `opencode` comes from nixpkgs on Linux, from `anomalyco/tap` brew tap on Mac. The `modules/opencode/opencode.nix` seeds config on first run (copy, not symlink) and runs `npm install` for plugins.
- `claude-code` is a Homebrew cask on Mac (not nixpkgs), declared in `hosts/mac-jenc/default.nix`.

## Claude Code + Headroom Integration

### Claude Code Setup (Hybrid Pattern)

- **Nix-managed** (rebuild needed): `~/.claude/settings.json`, `~/.claude/settings.local.json`, `~/.claude/statusline-command.sh` — sourced from `modules/claude/`
- **Symlinked at activation** (live-editable): `~/.claude/skills → ~/.agents/skills` via `home.activation` hook in `modules/claude/claude.nix`
- **LazyVim plugin** (`modules/nvim/.config/nvim/lua/plugins/claudecode.lua`):
  - Routes Claude API calls through Headroom proxy: `ANTHROPIC_BASE_URL=http://127.0.0.1:8787`
  - Terminal stays in insert mode
  - Requires Headroom proxy running on port 8787

### Headroom Proxy (Token Caching + Compression)

**Purpose:** Token caching (reuses context) and compression (~40% cost savings) for all downstream clients.

**Installation & Service:**

- `modules/headroom.nix`: Installs CLI via `uv tool install headroom-ai[proxy]==0.35.0` (version pinned)
- Manage on either platform with `headroomctl start|stop|restart|status [name ...]` (body: `home/scripts/headroomctl.sh`; launchd on macOS, systemd user services on Linux)
- Bare `stop` deliberately errors — pass explicit targets so always-on backends can't be torn down by accident
- **macOS:** `hosts/mac-jenc/default.nix` creates `launchd.user.agents` services:
  - `org.nixos.headroom-proxy-anthropic` (port 8787, Anthropic backend, runs with `--no-http2` — see troubleshooting)
  - `org.nixos.headroom-proxy-deepseek` (port 8788, OpenCode Zen gateway — free + pay-as-you-go models)
  - `org.nixos.headroom-proxy-go` (port 8789, OpenCode Go subscription gateway — draws from monthly Go quota, not Zen credits)
  - `org.nixos.headroom-proxy-gemini-{1,2,3}` (ports 8790/8791/8792, Google AI Studio)
  - Gemini proxies are lazy-start (`RunAtLoad = false`) — not running at login
  - Each gemini wrapper sources varlock and remaps `GEMINI_API_KEY_{1,2,3}` → `GEMINI_API_KEY` for headroom's handler
  - Logs: `~/.headroom/proxy-<name>.log` / `.err.log`
  - Check: `headroomctl status`, `launchctl list | grep headroom`, or `lsof -i :8787`

- **Linux:** `modules/headroom.nix` creates `systemd.user.services` from `headroom.proxies`:
  - Fedora (`hosts/fedora/default.nix`): `headroom-proxy-anthropic` (8787), `headroom-proxy-deepseek` (8788), `headroom-proxy-go` (8789)
  - Ubuntu: `headroom-proxy-anthropic` (8787) only (module default)
  - Logs: `journalctl --user -u headroom-proxy-<name> -f`
  - Check: `systemctl --user status headroom-proxy-<name>`, `headroomctl status`, or `lsof -i :<port>`

**Self-bootstrap:** If Nix activation hasn't run, the proxy wrapper automatically installs the CLI on first start.

### OpenCode Integration

- `modules/opencode/opencode.nix`: Seeds `~/.opencode/opencode.jsonc` (or `~/.config/opencode/` on Linux)
- **Providers:**
  - `headroom-zen` → `http://127.0.0.1:8788/v1` (Zen gateway: free + pay-as-you-go models)
  - `headroom-go` → `http://127.0.0.1:8789/v1` (Go subscription endpoint `https://opencode.ai/zen/go/v1`; free `*-free` models are NOT served here)
  - `headroom-gemini-{1,2,3}` → `http://127.0.0.1:{8790,8791,8792}/v1` (Google AI Studio via the gemini proxies)
- **Gemini models:** gemini-3.7-flash, gemini-3.6-flash, gemini-2.5-pro/flash, gemini-3.1-flash-image
- **Gemini prerequisite:** start the matching proxy first — `headroomctl start gemini-<N>`
- `headroom-go` model list mirrors `https://opencode.ai/zen/go/v1/models` (limits from models.dev)
- Each provider requires its own port's proxy running; Anthropic/Claude models are not used through opencode

### Troubleshooting

**Proxy not running:**

```bash
# macOS
launchctl list | grep headroom           # Check if loaded
curl http://127.0.0.1:8787/health       # Test health endpoint
tail -f ~/.headroom/proxy-anthropic.log  # View logs

# Linux
systemctl --user status headroom-proxy-anthropic
journalctl --user -u headroom-proxy-anthropic -f
curl http://127.0.0.1:8787/health
```

**Claude Code can't reach proxy:**

1. Verify proxy is listening: `lsof -i :8787`
2. Check `ANTHROPIC_BASE_URL` is set (visible in `headroom doctor`)
3. Rebuild to ensure launchd/systemd service is registered
4. Check proxy logs for incoming requests

**"'claude' not found in PATH" during activation:** — HM activation scripts don't inherit the Homebrew prefix, and a non-zero exit aborts the remaining activation steps. `modules/headroom.nix` exports `/opt/homebrew/bin` on Darwin and guards `headroom init claude` on the CLI being present; use the same pattern for any activation script calling brew-installed CLIs.

**OpenCode not routing through Headroom:**

- Verify `baseURL` in `opencode.jsonc` is `http://127.0.0.1:8788/v1` (with `/v1`) and the provider is named `headroom-zen`

**Token savings not accumulating:**

```bash
headroom stats                          # Compression history
curl http://127.0.0.1:8787/stats       # Detailed proxy stats
```

### Project-local config

- `~/.dotfiles/.claude/settings.local.json` — for .dotfiles-specific overrides

## Neovim

- `~/.config/nvim` is an out-of-store symlink to `modules/nvim/.config/nvim` via `home.activation` (not `mkOutOfStoreSymlink`, which Home Manager 26.11-pre+ rejects) — see `modules/nvim/nvim.nix` for the pattern.
- LazyVim needs write access (lazy-lock.json), which fails with read-only Nix store symlinks.
- Rebuild plugins: `nvim --headless -c "Lazy sync" -c "qa"`.

## Shell

- `npm`, `npx`, `pnpm` aliased through `socket npm`, `socket npx`, `socket pnpm` (see `home/default.nix` `programs.zsh.shellAliases`).
- `act` configured to use `catthehacker/ubuntu:act-latest` images for running GHA locally (`home/default.nix` `xdg.configFile."act/actrc"`).

## Important Constraints

- **Nix flakes only see git-tracked files.** Stage new files before building: `git add path/to/file`.
- On macOS, `./setup.sh` runs `sudo darwin-rebuild`. Homebrew changes require the same command.
- `macos/docker/` is tracked but **not deployed** — see `docs/plans/migration-open-issues.md`.

## Troubleshooting

**"Error installing file outside $HOME"** — HM 26.11-pre+ rejects `mkOutOfStoreSymlink`. Use `home.activation` scripts instead (see `modules/nvim/nvim.nix`).

**"Existing file would be clobbered"** — old symlinks block activation. `rm ~/.config/nvim` (or whatever path), then re-run.

**64B Homebrew cask stub** — `brew bundle` can write metadata before binary finishes downloading. `brew list --cask <name>` says installed but `/Applications/<Name>.app` is a 64-byte skeleton. Fix: `brew reinstall --cask <name>`.

**"sudo: darwin-rebuild: command not found"** — nix-darwin has never been activated on this machine. See [First-time macOS bootstrap](#first-time-macos-bootstrap) above.

**Rollback:** `sudo darwin-rebuild switch --rollback`.
**Dry run:** `nix build .#darwinConfigurations.mac-jenc.system --dry-run`.
