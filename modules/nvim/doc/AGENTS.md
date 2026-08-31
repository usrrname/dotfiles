# LazyVim

`lua/plugins/neo-tree.lua` sets `follow_current_file = { enabled = false }` - REQUIRED to prevent "File not in cwd" on startup.

## Clipboard

Clipboard is set to `unnamedplus` so yanking/deleting automatically uses system clipboard.

**Copy:**
- `y` / `yy` / etc. → system clipboard (via `+` register)
- `<leader>y` → explicit system clipboard yank

**Paste:**
- `p` / `P` → paste from system clipboard

## Auto-insert Mode

When Claude Code or OpenCode terminal is visible and you click/focus the editor, insert mode is automatically entered. Configured in:
- `lua/plugins/opencode.lua` (opencode.nvim)
- `lua/plugins/claudecode.lua` (claudecode.nvim)
