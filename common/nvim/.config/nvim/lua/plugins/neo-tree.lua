return {
	"nvim-neo-tree/neo-tree.nvim",
	init = function()
		-- Prevent the center editor from stealing columns from neo-tree's window.
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "neo-tree",
			command = "setlocal winfixwidth",
		})
	end,
	opts = {
		filesystem = {
			bind_to_cwd = true,
			follow_current_file = { enabled = false },
			filtered_items = {
				visible = true,
				hide_dotfiles = false,
				hide_by_name = {
					-- '.git',
					-- '.DS_Store',
					-- 'thumbs.db',
				},
			},
		},
	},
}
