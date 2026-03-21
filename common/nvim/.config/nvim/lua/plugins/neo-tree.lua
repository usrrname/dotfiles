return {
	"nvim-neo-tree/neo-tree.nvim",
	opts = {
		default_component_configs = {
			symlink_target = {
				enabled = true,
				display_text = " ➛ %s",
			},
		},
		filesystem = {
			bind_to_cwd = false,
			follow_lib_files = true,
			use_icons = true,
			filtered_items = {
				hide_hidden = false,
				hide_dotfiles = false,
				hide_gitignored = true,
				hide_ignored = false,
				ignore_files = {
					".neotreeignore",
				},
			},
		},
		sources = { "filesystem", "buffers", "git_status" },
	},
}
