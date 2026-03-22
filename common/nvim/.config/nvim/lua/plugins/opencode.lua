return {
	"nickjvandyke/opencode.nvim",
	version = "*",
	dependencies = {
		{
			-- `snacks.nvim` integration is recommended, but optional
			---@module "snacks"
			"folke/snacks.nvim",
			optional = true,
			opts = {
				input = {}, -- Enhances `ask()`

				picker = { -- Enhances `select()`
					actions = {
						opencode_send = function(...)
							return require("opencode").snacks_picker_send(...)
						end,
					},
					win = {
						input = {
							keys = {
								["<a-a>"] = { "opencode_send", mode = { "n", "i" } },
							},
						},
					},
				},
			},
		},
	},
	config = function()
		---@type opencode.Opts
		vim.g.opencode_opts = {
			-- Your configuration, if any; goto definition on the type or field for details
		}

		vim.o.autoread = true

		if vim.fs and vim.fs.watch then
			local cwd = vim.fn.getcwd()
			local watch = vim.fs.watch(cwd, function(path, name)
				if name == "change" or name == "rename" then
					vim.cmd("checktime")
				end
			end)
			vim.api.nvim_create_autocmd("VimLeave", {
				group = augroup("close_watch"),
				callback = function()
					if watch then
						watch:close()
					end
				end,
			})
		end

		-- Guard to prevent toggle spam
		local toggle_in_progress = false

		-- keymaps
		vim.keymap.set({ "n", "x" }, "<leader>aa", function()
			require("opencode").ask("@this: ", { submit = true })
		end, { desc = "Ask opencode…" })
		vim.keymap.set({ "n", "x" }, "<leader>ac", function()
			local terminal = require("opencode.terminal")
			if terminal.winid and vim.api.nvim_win_is_valid(terminal.winid) then
				vim.api.nvim_set_current_win(terminal.winid)
				vim.cmd("startinsert")
			end
			vim.defer_fn(function()
				require("opencode").select()
			end, 50)
		end, { desc = "Execute opencode action…" })

		vim.keymap.set({ "n", "t" }, "<leader>ao", function()
			if toggle_in_progress then
				return
			end
			toggle_in_progress = true

			local terminal = require("opencode.terminal")
			local is_visible = terminal.winid ~= nil and vim.api.nvim_win_is_valid(terminal.winid)

			if is_visible then
				vim.api.nvim_set_current_win(terminal.winid)
				vim.cmd("startinsert")
				toggle_in_progress = false
			else
				require("opencode").toggle()
				vim.defer_fn(function()
					if terminal.winid and vim.api.nvim_win_is_valid(terminal.winid) then
						vim.api.nvim_set_current_win(terminal.winid)
						vim.cmd("startinsert")
					end
					toggle_in_progress = false
				end, 200)
			end
		end, { desc = "Toggle opencode" })

		vim.keymap.set({ "n", "x" }, "go", function()
			return require("opencode").operator("@this ")
		end, { desc = "Add range to opencode", expr = true })

		vim.keymap.set("n", "goo", function()
			return require("opencode").operator("@this ") .. "_"
		end, { desc = "Add line to opencode", expr = true })

		vim.keymap.set("n", "<S-Up>", function()
			require("opencode").command("session.half.page.up")
		end, { desc = "Scroll opencode up" })

		vim.keymap.set("n", "<S-Down>", function()
			require("opencode").command("session.half.page.down")
		end, { desc = "Scroll opencode down" })

		vim.keymap.set("n", "<leader>ar", function()
			vim.cmd("checktime")
		end, { desc = "Reload buffer from disk" })
	end,
}
