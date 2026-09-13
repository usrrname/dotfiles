return {
	"coder/claudecode.nvim",
	opts = {
		-- Neovim's :terminal can't render OSC 8 hyperlinks (neovim/neovim#28789),
		-- so Claude's links reach the buffer as an invisible escape wrapper with
		-- no URL text at all. Forcing plain output keeps the URL visible/greppable.
		env = {
			FORCE_HYPERLINK = "0",
		},
		terminal = {
			-- "auto" can fall back to a native terminal that ignores snacks_win_opts.
			provider = "snacks",
			split_side = "right",
			split_width_percentage = 0.40,
			-- Merged over claudecode.terminal.snacks.build_opts's split defaults via
			-- vim.tbl_deep_extend("force", ...), so this wins and produces a float.
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
	init = function()
		-- Route through Headroom for token caching/compression, but respect an
		-- already-exported ANTHROPIC_BASE_URL (e.g. nixos's host.orb.internal).
		if vim.env.ANTHROPIC_BASE_URL == nil then
			vim.env.ANTHROPIC_BASE_URL = "http://127.0.0.1:8787"
		end

		vim.api.nvim_create_autocmd("BufEnter", {
			-- Snacks spawns the job via a plain string cmd, which Neovim runs
			-- through $SHELL -c "claude" -- so the buffer name ends up reflecting
			-- the shell (e.g. term://.../28121:/bin/zsh), not "claude". Match all
			-- terminal buffers and identify Claude via Snacks' own
			-- vim.b[].snacks_terminal.cmd, set from the actual spawned command.
			pattern = "term://*",
			callback = function(ev)
				if vim.api.nvim_get_option_value("buftype", { buf = ev.buf }) ~= "terminal" then
					return
				end

				local term_info = vim.b[ev.buf].snacks_terminal
				if not term_info or not tostring(term_info.cmd or ""):find("claude", 1, true) then
					return
				end

				-- gx fallback: Neovim can't make OSC 8 links clickable inside
				-- :terminal buffers, so open the URL under the cursor manually.
				vim.keymap.set("n", "gx", function()
					local url = vim.api.nvim_get_current_line():match("https?://[^%s%)%]\"'>,]+")
					if url then
						vim.ui.open(url)
					else
						vim.notify("No URL found on this line", vim.log.levels.WARN)
					end
				end, { buffer = ev.buf, desc = "Open URL under cursor" })

				local win = vim.fn.bufwinid(ev.buf)
				if win ~= -1 then
					pcall(vim.api.nvim_win_set_cursor, win, { vim.api.nvim_buf_line_count(ev.buf), 0 })
				end

				-- BufEnter can fire without real user focus (e.g. buffer shown in a
				-- background split); only steal insert mode when this window is
				-- the one actually focused.
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
