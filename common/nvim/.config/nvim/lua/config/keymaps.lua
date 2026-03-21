-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

--- Save and append in insert mode --
vim.keymap.set("i", "<D-s>", "<Esc><cmd>w<cr>a", { desc = "Save" })

-- Yank into system clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y') -- yank motion

-- Paste from system clipboard
vim.keymap.set("n", "<leader>p", '"+p') -- paste after cursor

-- Reload LazyVim configuration with space+rl
vim.keymap.set("n", "<leader>rl", function()
	vim.cmd("Lazy reload")
	vim.cmd("Lazy sync")
end, { desc = "Reload Config" })

vim.keymap.set("n", "<Tab>", "<cmd>bnext<cr>", { desc = "Next buffer" })
vim.keymap.set("n", "<S-Tab>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })

-- Move line up/down with Alt+Arrow
vim.keymap.set("n", "<M-Up>", function()
	vim.cmd("move -2")
end, { desc = "Move line up" })

vim.keymap.set("n", "<M-Down>", function()
	vim.cmd("move +1")
end, { desc = "Move line down" })

-- Insert mode Alt+Arrow
vim.keymap.set("i", "<M-Up>", "<Cmd>m .-2<CR>==gi", { desc = "Move line up" })
vim.keymap.set("i", "<M-Down>", "<Cmd>m .+1<CR>==gi", { desc = "Move line down" })
