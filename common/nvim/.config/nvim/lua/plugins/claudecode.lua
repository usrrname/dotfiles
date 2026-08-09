return {
	"coder/claudecode.nvim",
	opts = {
		terminal = {
			-- Force the snacks provider (not "auto", which can fall back to a
			-- NATIVE terminal that ignores snacks_win_opts).
			provider = "snacks",
			split_side = "right",
			split_width_percentage = 0.40,
			-- Float pinned to the right edge, claudecode's snacks provider
			-- vim.tbl_deep_extend("force", ...) merges these over the split
			-- defaults in claudecode.terminal.snacks.build_opts.
			snacks_win_opts = {
				position = "float",
				width = 0.4,
				height = 0.99,
				row = 1,
				col = -1,
				border = "rounded",
			},
		},
	},
	-- Keep the claude terminal in insert mode while it's focused.
	init = function()
		-- Route Claude API calls through Headroom Doctor proxy for token caching
		vim.env.ANTHROPIC_BASE_URL = "http://127.0.0.1:8787"

		vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
			pattern = "term://*claude*",
			callback = function(ev)
				-- Scroll to the bottom WITHOUT `normal! G`: when this fires via a
				-- window switch while already in terminal mode (e.g. edgy's window
				-- picker calling nvim_set_current_win), `normal!` errors with
				-- "Can't re-enter normal mode from terminal mode". Setting the
				-- cursor directly works from any mode.
				local win = vim.fn.bufwinid(ev.buf)
				if win ~= -1 then
					pcall(vim.api.nvim_win_set_cursor, win, { vim.api.nvim_buf_line_count(ev.buf), 0 })
				end
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
