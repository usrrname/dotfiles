---@diagnostic disable: undefined-global
--- evaluates to plugin manager path usually at $HOME/.local/share/lazy/lazy.nvim --
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- Install lazy.nvim if not present
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--branch=stable",
		lazyrepo,
		lazypath,
	})

	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end

-- Add lazy.nvim to runtime path
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
return require("lazy").setup({
	spec = {
		-- LazyVim core
		{ "LazyVim/LazyVim", import = "lazyvim.plugins" },
		-- Language extras
		{ import = "lazyvim.plugins.extras.lang.typescript" },
		{ import = "lazyvim.plugins.extras.lang.json" },
		-- import/override with custom plugins
		{ import = "plugins" },
		-- NeoTree
		{
			"nvim-neo-tree/neo-tree.nvim",
			opts = {
				filesystem = {
					filtered_items = {
						hide_hidden = false,
						hide_dotfiles = false,
						hide_gitignored = true,
						hide_ignored = false, -- hide files that are ignored by other gitignore-like files
						-- other gitignore-like files, in descending order of precedence.
						ignore_files = {
							".neotreeignore",
							-- ".rgignore"
						},
					},
				},
			},
		},
		-- Treesitter configuration
		{
			"nvim-treesitter/nvim-treesitter",
			opts = {
				ensure_installed = {
					"bash",
					"html",
					"javascript",
					"json",
					"lua",
					"markdown",
					"markdown_inline",
					"python",
					"query",
					"regex",
					"tsx",
					"typescript",
					"vim",
					"yaml",
				},
			},
			config = function(_, opts)
				vim.list_extend(opts.ensure_installed, {
					"tsx",
					"typescript",
					"go",
				})
			end,
		},
	},
	defaults = {
		lazy = false,
		version = "*",
		rocks = {
			enabled = true,
			hererocks = true,
			lua = "5.1",
		},
	},
	install = { colorscheme = { "catppuccin-macchiato" } },
	checker = {
		enabled = true,
		notify = true,
	},
	performance = {
		rtp = {
			disabled_plugins = {
				"gzip",
				-- "matchit",
				-- "matchparen",
				-- "netrwPlugin",
				"tarPlugin",
				"tohtml",
				"zipPlugin",
			},
		},
	},
})
