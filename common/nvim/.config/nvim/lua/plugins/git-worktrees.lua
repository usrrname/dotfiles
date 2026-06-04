-- lazy.nvim example
return {
	"ThePrimeagen/git-worktree.nvim",
	config = function()
		require("git-worktree").setup({})
		require("telescope").load_extension("git_worktree")
	end,
	keys = {
		{ "<leader>gw", "<cmd>Telescope git_worktree git_worktrees<cr>", desc = "Switch Worktree" },
		{ "<leader>gwa", "<cmd>Telescope git_worktree create_git_worktree<cr>", desc = "Create Worktree" },
	},
}
