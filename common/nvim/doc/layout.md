# LazyVim Layout

## Overview

Neo-tree on the left (LazyVim-managed split), OpenCode on the right (float).

## Layout

```
┌──────────┬────────────────────┐
│ Neo-tree │      Center        │
│ (split)  │  (edit/startup)    │
├──────────┤                    │  ┌──────────────┐
│ Terminal │                    │  │   OpenCode   │
│ (split)  │                    │  │   (float)    │
└──────────┴────────────────────┘  └──────────────┘
```

Not shown: OpenCode floats above the editor, anchored to the right edge. It never
affects the window layout — immune to splits, panels, and resize glitches.

## Startup Sequence

1. Open Neo-tree (left split, `winfixwidth`)
2. Focus center window, open mini-starter
3. Wipe unnamed buffers
4. `VeryLazy`: pre-warm OpenCode in background (float opens briefly, then hides)

## Components

| Component | Plugin | Purpose |
|-----------|--------|---------|
| File tree | neo-tree.nvim | Filesystem browser |
| Startup screen | mini.starter | Welcome logo + actions |
| AI assistant | opencode.nvim | Code completion/chat |
| Keymaps | which-key | Leader key menus |
| Merge conflicts | git-conflict.nvim | Visual conflict resolution |
| Git blame | blame.nvim | Inline commit annotations + blame stack |

## Merge Conflict Resolution

git-conflict.nvim provides VSCode-style conflict handling.

**Keybindings** (active when a file has conflicts):

| Key | Action |
|-----|--------|
| `co` | Choose ours (local changes) |
| `ct` | Choose theirs (incoming changes) |
| `cb` | Choose both |
| `c0` | Choose none |
| `[x` | Previous conflict |
| `]x` | Next conflict |
| `:GitConflictListQf` | List all conflicts in quickfix |

## Git Blame

blame.nvim shows inline commit annotations (author, date, message) and supports a blame stack to navigate history.

**Commands:**

| Command | Description |
|---------|-------------|
| `:BlameToggle` | Toggle blame view on/off |
| `:BlameToggle virtual` | Toggle inline virtual text |
| `:BlameToggle window` | Toggle side window view |

**Navigation:**

| Key | Action |
|-----|--------|
| `[g` | Previous commit (blame stack pop) |
| `]g` | Next commit (blame stack push) |

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
| `<leader>oo` | Toggle OpenCode float |
| `<leader>oc` | Execute OpenCode action |
| `<leader>oa` | Ask OpenCode about file/selection |
| `<leader>or` | Review code |
| `<leader>oe` | Explain code |
| `<leader>oh` | Smart handoff to clipboard |
| `<leader>oy` | Copy last handoff to clipboard |
| `<S-Up>` | Scroll OpenCode up |
| `<S-Down>` | Scroll OpenCode down |
| `<C-n>` | Leave OpenCode terminal mode |

## Auto-Reload

File watching via `vim.fs.watch` on CWD triggers `checktime` on file changes, keeping buffers synchronized when OpenCode modifies files externally.

## Notes

- OpenCode pre-warms on `VeryLazy` (float opens briefly then hides)
- Mini-starter displays custom CrazyVim logo (figlet `big` font)
- Terminal floats are immune to window layout changes — no SIGWINCH glitch
- Edgy was removed — neo-tree is a plain split, not a sidebar
