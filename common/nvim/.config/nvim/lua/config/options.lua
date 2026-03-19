-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- vim.g.lazyvim_php_lsp = "intelephense"
vim.g.mapleader = " "
vim.g.autoformat = true
vim.opt.clipboard = "unnamedplus"

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
		},
	},
}
