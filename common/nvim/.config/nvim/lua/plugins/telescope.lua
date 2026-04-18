return {
	"nvim-telescope/telescope.nvim",
	dependencies = {
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
		},
	},

	keys = {
		{
			"<leader>fp",
			function() require("telescope.builtin").find_files({ cwd = require("lazy.core.config").options.root }) end,
			desc = "Find Plugin File",
		},
		{
			"<D-f>",
			function()
				-- Use valid directory, fallback to cwd if current buffer path is invalid
				local cwd = vim.fn.expand("%:p:h")
				if cwd == "" or cwd:match("ministarter") or not vim.fn.isdirectory(cwd) then
					cwd = vim.fn.getcwd()
				end
				require("telescope.builtin").find_files({
					prompt_title = "Find Files",
					cwd = cwd,
					hidden = true,
					file_ignore_patterns = {
						".git/",
						"node_modules/",
						"vendor/",
						"dist/",
						"public",
						"build",
						".next/",
						".turbo/",
						".wrangler/",
						".cache/",
						"nix/store/",
						"tmp/",
						".venv",
						"build/",
						"results/",
					},
				})
			end,
			desc = "Find Files",
		},
	},
	-- change some options
	opts = {
		defaults = {
			layout_strategy = "horizontal",
			layout_config = { prompt_position = "top" },
			sorting_strategy = "ascending",
			winblend = 0,
			-- Disable treesitter highlighting
			preview = {
				treesitter = false,
			},
			-- Prevent cwd change prompts
			cwd_only = false,
			cwd = vim.fn.getcwd(),
		},
		extensions = {
			fzf = {
				fuzzy = true,
				override_generic_sorter = true,
				override_file_sorter = true,
				case_mode = "smart_case",
			},
		},
	},
	-- Add config function to load extensions
	config = function(_, opts)
		require("telescope").setup(opts)

		-- Load fzf extension with error handling
		pcall(function()
			require("telescope").load_extension("fzf")
		end)
	end,
}
