-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Map Command+Shift+P (macOS) or Ctrl+Shift+P (Windows/Linux) to Telescope

-- macOS-style keybindings

vim.api.nvim_set_keymap("n", "<D-a>", "ggVG", { desc = "Select all" })

--- Save and append in insert mode --
vim.keymap.set("i", "<D-s>", "<Esc><cmd>w<cr>a", { desc = "Save" })

-- Yank into system clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y') -- yank motion

-- Paste from system clipboard
vim.keymap.set("n", "<leader>p", '"+p') -- paste after cursor

-- Reload LazyVim configuration
vim.keymap.set("n", "<leader>r", function()
	vim.cmd("Lazy reload")
	vim.cmd("Lazy sync")
end, { desc = "Reload Config" })
