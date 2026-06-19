return {
	-- The `ui.edgy` LazyVim extra already matches neo-tree (left) and the
	-- snacks-backed claude/opencode terminals (right) automatically. We only
	-- override the per-edge default sizes so the side panels are the width we
	-- want and the center editor is the only window that flexes.
	"folke/edgy.nvim",
	opts = function(_, opts)
		opts.options = opts.options or {}

		-- Pin each side's width AND set winfixwidth so the center editor (and
		-- transient splits) can't steal columns from the side panels —
		opts.options.left = opts.options.left or {}
		opts.options.left.size = 40
		opts.options.left.wo = vim.tbl_extend("force", opts.options.left.wo or {}, { winfixwidth = true })

		opts.options.right = opts.options.right or {}
		opts.options.right.size = 80
		opts.options.right.wo = vim.tbl_extend("force", opts.options.right.wo or {}, { winfixwidth = true })

		-- Disable edgy's resize animation. default 30fps slide animates
		-- every layout change, which shows up as the right terminal panel
		-- "flashing" while claude/opencode streams output and the panel keeps
		-- re-laying-out. Without it, resizes are instant and flicker-free.
		opts.animate = opts.animate or {}
		opts.animate.enabled = false
	end,
	init = function()
		-- Force neo-tree to respect its fixed width even when the center buffer
		-- is deleted. Without this, neo-tree can absorb the freed columns and
		-- squeeze the right panel. The FileType autocmd fires every time neo-tree
		-- opens, ensuring winfixwidth is set regardless of how it's launched.
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "neo-tree",
			command = "setlocal winfixwidth",
		})

		-- Scroll terminals to the bottom when they regain focus. Layout updates
		-- and window switches can leave terminals scrolled up with blank space,
		-- making the bottom portion appear black or empty until the user types.
		-- This ensures the latest output is always visible.
		vim.api.nvim_create_autocmd({ "WinEnter", "FocusGained" }, {
			callback = function()
				local buf = vim.api.nvim_get_current_buf()
				if vim.bo[buf].buftype == "terminal" then
					local last = vim.api.nvim_buf_line_count(buf)
					pcall(vim.api.nvim_win_set_cursor, 0, { last, 0 })
				end
			end,
		})

		-- edgy re-pins its sidebar widths on BufWinEnter/WinResized/FileType/
		-- VimResized but NOT on WinClosed. So deleting the center buffer (which
		-- closes its window) lets neo-tree absorb the freed columns and squeezes
		-- the right panel. edgy's check_main recreates a center window on
		-- WinClosed but never re-runs the layout, so the widths stay wrong.
		-- Re-run edgy's layout on the next tick (after check_main) to snap the
		-- left/right widths back, then scroll any terminal panel to the bottom
		-- so it isn't left scrolled-up with blank space after the resize.
		local relayout_timer = nil
		vim.api.nvim_create_autocmd("WinClosed", {
			group = vim.api.nvim_create_augroup("edgy_relayout_on_close", { clear = true }),
			callback = function()
				if relayout_timer then
					vim.fn.timer_stop(relayout_timer)
				end
				relayout_timer = vim.fn.timer_start(50, function()
					relayout_timer = nil
					pcall(function()
						require("edgy.layout").update()
					end)
					for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
						if vim.api.nvim_win_is_valid(win) then
							local buf = vim.api.nvim_win_get_buf(win)
							if vim.bo[buf].buftype == "terminal" then
								local last = vim.api.nvim_buf_line_count(buf)
								pcall(vim.api.nvim_win_set_cursor, win, { last, 0 })
							end
						end
					end
				end, { ["repeat"] = 0 })
			end,
		})
	end,
}
