return {
	"folke/which-key.nvim",
	opts = {
		spec = {
			-- Open Code --
			{ "<leader>o", group = "opencode" },
			{ "<leader>oo", desc = "Toggle opencode" },
			{ "<leader>oa", desc = "Ask opencode", mode = { "n", "x" } },
			{ "<leader>oc", desc = "Execute opencode action" },
			{ "<leader>oe", desc = "Explain code" },
			{ "<leader>or", desc = "Review code" },
			{ "<leader>oh", desc = "Smart handoff to clipboard" },
			{ "<leader>oy", desc = "Copy last handoff to clipboard" },
		},
	},
}
