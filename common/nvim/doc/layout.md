# LazyVim Layout Requirements

## Overview

Three-column Neovim layout with AI assistant on startup.

## Layout

```
┌──────────┬───────────────────┬────────────┐
│ Neo-tree │    Center         │ OpenCode   │
│ (left)   │ (edit/startup)    │ (right)    │
└──────────┴───────────────────┴────────────┘
```

## Startup Sequence

1. Open Neo-tree (left sidebar)
2. Open OpenCode server (right split, `opencode --port`)
3. Focus center window
4. Open mini-starter (startup screen)
5. Wipe unnamed buffers

## Components

| Component | Plugin | Purpose |
|-----------|--------|---------|
| File tree | neo-tree.nvim | Filesystem browser |
| Startup screen | mini.starter | Welcome logo + actions |
| AI assistant | opencode.nvim | Code completion/chat |
| Keymaps | which-key | Leader key menus |

## Custom Logo

ASCII art header generated via `figlet -f big "CRAZY"`:

```
  _____                  __      ___           
 / ____|                 \ \    / (_)          
| |     _ __ __ _ _____   \ \  / / _ _ __ ___  
| |    | '__/ _` |_  / | | \ \/ / | | '_ ` _ \ 
| |____| | | (_| |/ /| |_| |\  /  | | | | | | |
 \_____|_|  \__,_/___|\__, | \/   |_|_| |_| |_| |
                       __/ |                   
                      |___/                     
```

## Keymaps

| Key | Action |
|-----|--------|
| `<leader>ao` | Toggle OpenCode |
| `<leader>ac` | Execute OpenCode action (focuses terminal first) |
| `<leader>aa` | Ask OpenCode |
| `<leader>os` | Switch session (opens picker) |
| `<leader>ar` | Reload buffer from disk |
| `<S-Up>` | Scroll OpenCode up |
| `<S-Down>` | Scroll OpenCode down |

## Auto-Reload

File watching via `vim.fs.watch` on CWD triggers `checktime` on file changes, keeping buffers synchronized when OpenCode modifies files externally.

## Notes

- OpenCode starts on VimEnter via `opencode --port`
- Mini-starter displays custom CrazyVim logo (figlet `big` font)
- Neo-tree and OpenCode excluded from buffer cleanup logic
- `<leader>ac` focuses OpenCode terminal before opening picker
- `<leader>os` opens session picker for switching sessions
