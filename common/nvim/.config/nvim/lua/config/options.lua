-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- vim.g.lazyvim_php_lsp = "intelephense"
vim.g.mapleader = " "
vim.g.autoformat = true
vim.opt.clipboard = "unnamedplus"

-- Fix tab display for Go files only (Go uses tabs, display as 4 spaces)
vim.api.nvim_create_autocmd("FileType", {
	pattern = "go",
	callback = function()
		vim.opt_local.tabstop = 4
		vim.opt_local.shiftwidth = 4
		vim.opt_local.softtabstop = 4
	end,
})

-- Hide unnamed buffer from tabline
vim.opt.shortmess:append("S")

-- Wrap text by default in buffers
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true

-- disable markdownlint noise --
vim.g.render_markdown = {
	lint = {
		enabled = true,
		-- Disable specific rules
		rules = {
			-- Disable line length warnings
			MD013 = false,
			-- Disable trailing punctuation in headings
			MD026 = false,
			-- Disable blanks around headings
			MD022 = false,
		},
	},
}
