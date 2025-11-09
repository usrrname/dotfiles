-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Map Command+Shift+P (macOS) or Ctrl+Shift+P (Windows/Linux) to Telescope

-- macOS-style keybindings
vim.keymap.set("n", "<C-s>", "<cmd>w<cr>", { desc = "Save" })
vim.keymap.set({ "n", "v", "i" }, "<D-s>", "<cmd>w<cr><esc>", { desc = "Save file" })
vim.keymap.set({ "n", "v", "i" }, "<D-z>", "<cmd>undo<cr>", { desc = "Undo" })
vim.keymap.set({ "n", "v", "i" }, "<D-S-z>", "<cmd>redo<cr>", { desc = "Redo" })
vim.keymap.set({ "n", "v" }, "<D-c>", '"+y', { desc = "Copy" })
vim.keymap.set({ "v" }, "<D-x>", '"+d', { desc = "Cut" })
vim.keymap.set({ "n", "v", "i" }, "<D-v>", '"+p', { desc = "Paste" })
vim.keymap.set({ "n", "v", "i" }, "<D-a>", "ggVG", { desc = "Select all" })
vim.keymap.set({ "n", "v", "i" }, "<D-f>", "<cmd>Telescope live_grep<cr>", { desc = "Find in files" })
vim.keymap.set({ "n", "v", "i" }, "<D-p>", "<cmd>Telescope find_files<cr>", { desc = "Find files" })

--- Save and append in insert mode --
vim.keymap.set("i", "<D-s>", "<Esc><cmd>w<cr>a", { desc = "Save" })

-- Yank into system clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y') -- yank motion

-- Paste from system clipboard
vim.keymap.set("n", "<leader>p", '"+p') -- paste after cursor

-- Open config
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
