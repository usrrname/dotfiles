return {
	"greggh/claude-code.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	config = function()
		require("claudecode").setup({
			terminal = {
				split_side = "right",
				split_width_percentage = 0.40,
			},
		})

		vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
			pattern = "term://*claude*",
			callback = function()
				vim.cmd("normal! G")
				if vim.api.nvim_get_mode().mode == "n" then
					vim.cmd("startinsert")
				end
			end,
		})

		vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave" }, {
			pattern = "term://*claude*",
			callback = function()
				if vim.api.nvim_get_mode().mode == "t" then
					vim.cmd("stopinsert")
				end
			end,
		})
	end,
}
