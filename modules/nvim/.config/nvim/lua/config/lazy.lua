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

		-- Treesitter configuration
		{
			"nvim-treesitter/nvim-treesitter",
			opts = {
				ensure_installed = {
					"bash",
					"html",
					"javascript",
					"typescript",
					"json",
					"lua",
					"markdown",
					"python",
					"query",
					"regex",
					"tsx",
					"vim",
					"yaml",
				},
			},
			config = function(_, opts)
				vim.list_extend(opts.ensure_installed, {
					"tsx",
					"typescript",
				})
			end,
		},
	},
	-- Default plugin loading behavior
	defaults = {
		-- Don't lazy-load by default (load at startup)
		lazy = false,
		-- Use latest version for all plugins
		version = "*",
		-- LuaRocks integration for plugins needing Lua deps
		rocks = {
			enabled = true,
			hererocks = true,
			lua = "5.1",
		},
	},
	-- Theme to install if missing on first run
	install = { colorscheme = { "catppuccin-macchiato" } },
	-- Automatically check for plugin updates
	checker = { enabled = true },
	-- Performance optimizations
	performance = {
		-- Runtime path settings
		rtp = {
			-- Disable unused built-in vim plugins for faster startup
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
