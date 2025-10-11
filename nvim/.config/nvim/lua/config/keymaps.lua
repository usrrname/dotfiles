-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Map Command+Shift+P (macOS) or Ctrl+Shift+P (Windows/Linux) to Telescope
-- macOS mapping
vim.keymap.set("n", "<D-S-p>", "<cmd>Telescope<CR>", { desc = "Telescope command palette" })
-- Also add insert mode mapping
vim.keymap.set("i", "<D-S-p>", "<ESC><cmd>Telescope<CR>", { desc = "Telescope command palette" })

vim.keymap.set("n", "<D-s>", "<cmd>w<cr>", { desc = "Save" })
-- Save and append in insert mode --
vim.keymap.set("i", "<D-s>", "<Esc><cmd>w<cr>a", { desc = "Save" })

-- Yank into system clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y') -- yank motion

-- Paste from system clipboard
vim.keymap.set("n", "<leader>p", '"+p') -- paste after cursor

