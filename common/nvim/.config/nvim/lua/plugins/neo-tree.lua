return {
	"nvim-neo-tree/neo-tree.nvim",
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
