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
			pattern = "*",
			callback = function()
				local ok, terminal = pcall(require, "claudecode.terminal")
				if not ok then
					return
				end

				local term_buf = terminal.get_active_terminal_bufnr()
				if term_buf then
					local bufinfo = vim.fn.getbufinfo(term_buf)
					if bufinfo and #bufinfo > 0 and #bufinfo[1].windows > 0 then
						local buf = vim.api.nvim_get_current_buf()
						local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
						if buftype == "" and vim.api.nvim_get_mode().mode == "n" then
							vim.cmd("startinsert")
						end
					end
				end
			end,
		})
	end,
}
