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

-- Don't auto-equalize window sizes when splits open/close.
vim.opt.equalalways = false

-- Wrap text by default in buffers
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true

-- Cap the number of listed buffers; close the least-recently-used hidden
-- buffer(s) when a new one is opened past the limit.
local MAX_BUFFERS = 8
vim.api.nvim_create_autocmd("BufAdd", {
	callback = function()
		vim.schedule(function()
			local listed = vim.tbl_filter(function(info)
				return info.listed == 1 and info.name ~= "" and vim.bo[info.bufnr].buftype == ""
			end, vim.fn.getbufinfo({ buflisted = 1 }))

			if #listed <= MAX_BUFFERS then
				return
			end

			-- Oldest-used first; skip buffers that are currently shown in a window
			-- or have unsaved changes.
			table.sort(listed, function(a, b)
				return a.lastused < b.lastused
			end)

			local to_close = #listed - MAX_BUFFERS
			for _, info in ipairs(listed) do
				if to_close <= 0 then
					break
				end
				if #info.windows == 0 and vim.bo[info.bufnr].modified == false then
					pcall(vim.api.nvim_buf_delete, info.bufnr, { force = false })
					to_close = to_close - 1
				end
			end
		end)
	end,
})

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
