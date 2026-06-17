return {
	-- Extend the coder/claudecode.nvim plugin that the `ai.claudecode` LazyVim
	-- extra already provides. This file previously pulled in a SECOND plugin
	-- (greggh/claude-code.nvim) while configuring coder's module — removed to
	-- dedupe. lazy.nvim deep-merges these opts into the extra's, so the panel
	-- still opens on the right; edgy owns its width (see plugins/edgy.lua).
	"coder/claudecode.nvim",
	opts = {
		terminal = {
			split_side = "right",
			split_width_percentage = 0.40,
		},
	},
	-- Keep the claude terminal in insert mode while it's focused.
	init = function()
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
