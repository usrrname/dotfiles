-- Claude Code Neovim plugin - terminal integration for Claude
return {
	-- Plugin repo to install via lazy.nvim
	"coder/claudecode.nvim",
	-- Plugin options
	opts = {
		-- Terminal window configuration
		terminal = {
			-- Force the snacks provider (not "auto", which can fall back to a
			-- NATIVE terminal that ignores snacks_win_opts).
			provider = "snacks",
			-- Open terminal on the right side
			split_side = "right",
			-- Use 40% of screen width for the split
			split_width_percentage = 0.40,
			-- Float pinned to the right edge, claudecode's snacks provider
			-- vim.tbl_deep_extend("force", ...) merges these over the split
			-- defaults in claudecode.terminal.snacks.build_opts.
			snacks_win_opts = {
				-- Float position anchored to right edge
				position = "float",
				-- 40% of editor width
				width = 0.4,
				-- Almost full height
				height = 0.99,
				-- Top row offset
				row = 1,
				-- Right-aligned (-1 = far right)
				col = -1,
				-- Rounded border style
				border = "rounded",
			},
		},
	},
	-- Initialize plugin: set up env and autocmds
	init = function()
		-- Route Claude API calls through Headroom proxy for token caching/compression
		vim.env.ANTHROPIC_BASE_URL = "http://127.0.0.1:8787"

		-- Auto-enter insert mode and scroll when focusing Claude terminal
		vim.api.nvim_create_autocmd("BufEnter", {
			-- Match any terminal buffer with 'claude' in its name
			pattern = "term://*claude*",
			callback = function(ev)
				-- Only proceed if this is actually a terminal buffer
				if vim.api.nvim_get_option_value("buftype", { buf = ev.buf }) ~= "terminal" then
					return
				end

				-- Get window showing this buffer, scroll to bottom
				local win = vim.fn.bufwinid(ev.buf)
				if win ~= -1 then
					pcall(vim.api.nvim_win_set_cursor, win, { vim.api.nvim_buf_line_count(ev.buf), 0 })
				end

				-- Only force insert mode if we're currently in normal mode
				-- and the current window is actually this terminal's window
				if vim.api.nvim_get_mode().mode == "n" then
					local current_win = vim.api.nvim_get_current_win()
					local term_win = vim.fn.bufwinid(ev.buf)
					if term_win ~= -1 and current_win == term_win then
						vim.cmd("startinsert")
					end
				end
			end,
		})
	end,
}

