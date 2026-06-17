return {
	-- The `ui.edgy` LazyVim extra already matches neo-tree (left) and the
	-- snacks-backed claude/opencode terminals (right) automatically. We only
	-- override the per-edge default sizes so the side panels are the width we
	-- want and the center editor is the only window that flexes.
	"folke/edgy.nvim",
	opts = function(_, opts)
		opts.options = opts.options or {}

		-- Pin each side's width AND set winfixwidth so the center editor (and
		-- transient splits) can't steal columns from the side panels — that was
		-- letting the right claude/opencode panel shrink below its 0.4 share.
		opts.options.left = opts.options.left or {}
		opts.options.left.size = 40
		opts.options.left.wo = vim.tbl_extend("force", opts.options.left.wo or {}, { winfixwidth = true })

		opts.options.right = opts.options.right or {}
		opts.options.right.size = 0.4
		opts.options.right.wo = vim.tbl_extend("force", opts.options.right.wo or {}, { winfixwidth = true })

		-- Disable edgy's resize animation. The default 30fps slide animates
		-- every layout change, which shows up as the right terminal panel
		-- "flashing" while claude/opencode streams output and the panel keeps
		-- re-laying-out. Without it, resizes are instant and flicker-free.
		opts.animate = opts.animate or {}
		opts.animate.enabled = false
	end,
	init = function()
		-- edgy re-pins its sidebar widths on BufWinEnter/WinResized/FileType/
		-- VimResized but NOT on WinClosed. So deleting the center buffer (which
		-- closes its window) lets neo-tree absorb the freed columns and squeezes
		-- the right panel. edgy's check_main recreates a center window on
		-- WinClosed but never re-runs the layout, so the widths stay wrong.
		-- Re-run edgy's layout on the next tick (after check_main) to snap the
		-- left/right widths back, then scroll any terminal panel to the bottom
		-- so it isn't left scrolled-up with blank space after the resize.
		vim.api.nvim_create_autocmd("WinClosed", {
			group = vim.api.nvim_create_augroup("edgy_relayout_on_close", { clear = true }),
			callback = function()
				vim.schedule(function()
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
				end)
			end,
		})
	end,
}
