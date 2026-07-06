return {
	"nvim-neo-tree/neo-tree.nvim",
	init = function()
		local augroup = vim.api.nvim_create_augroup("neo_tree_config", { clear = true })

		vim.api.nvim_create_autocmd("FileType", {
			group = augroup,
			pattern = "neo-tree",
			command = "setlocal winfixwidth",
		})

		-- When the last non-neo-tree window closes, keep a placeholder split so
		-- neo-tree stays at its winfixwidth size instead of expanding full-width.
		vim.api.nvim_create_autocmd("WinClosed", {
			group = augroup,
			callback = function()
				vim.schedule(function()
					local wins = vim.api.nvim_tabpage_list_wins(0)
					if #wins ~= 1 then
						return
					end
					local buf = vim.api.nvim_win_get_buf(wins[1])
					if vim.bo[buf].filetype ~= "neo-tree" then
						return
					end
					vim.cmd("rightbelow vsplit | enew")
				end)
			end,
		})
	end,
	opts = {
		window = {
			width = 30,
		},
		filesystem = {
			bind_to_cwd = true,
			follow_current_file = { enabled = false },
			filtered_items = {
				visible = true,
				hide_dotfiles = false,
				hide_by_name = {
					"**/node_modules/**",
					"**/.cargo/**",
					".git",
					".DS_Store",
					"thumbs.db",
				},
			},
		},
	},
}
