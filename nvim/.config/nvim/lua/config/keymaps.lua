-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Map Command+Shift+P (macOS) or Ctrl+Shift+P (Windows/Linux) to Telescope
-- macOS mapping

vim.keymap.set("n", "<C-s>", "<cmd>w<cr>", { desc = "Save" })

--- Save and append in insert mode --
vim.keymap.set("i", "<D-s>", "<Esc><cmd>w<cr>a", { desc = "Save" })

-- Yank into system clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y') -- yank motion

-- Paste from system clipboard
vim.keymap.set("n", "<leader>p", '"+p') -- paste after cursor

vim.keymap.set("n", "c", "<cmd>Config<cr>", { desc = "Open Config" })

-- Reload LazyVim configuration
vim.keymap.set("n", "<leader>r", function()
	vim.cmd("Lazy reload")
	vim.cmd("Lazy sync")
end, { desc = "Reload Config" })

-- Restart Neovim
vim.keymap.set("n", "<leader>R", function()
	vim.cmd("wa")
	vim.cmd("qa")
	-- Restart and open dashboard
	vim.fn.system("nvim +'lua require(\"snacks\").open()' &")
end, { desc = "Restart LazyVim" })
