return {
	"nickjvandyke/opencode.nvim",
	version = "*",
	dependencies = {
		{
			---@module "snacks"
			"folke/snacks.nvim",
			optional = true,
			opts = {
				input = { enabled = false }, -- Disable to prevent startup Telescope prompts

				picker = { -- Enhances `select()`
					actions = {
						---@param picker snacks.Picker
						opencode_send = function(picker)
							local items = vim.tbl_map(function(item) ---@param item snacks.picker.Item
								return item.file
										and require("opencode").format({
											path = item.file,
											from = item.pos,
											to = item.end_pos,
										})
									or item.text
							end, picker:selected({ fallback = true }))

							require("opencode").prompt(table.concat(items, ", ") .. " ")
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
		local opencode_cmd = "opencode --port"

		---@type snacks.terminal.Opts
		local snacks_terminal_opts = {
			win = {
				position = "right",
				width = 0.4,
				enter = false,
			},
		}

		---@type opencode.Opts
		vim.g.opencode_opts = {
			server = {
				start = function()
					require("snacks.terminal").open(opencode_cmd, snacks_terminal_opts)
				end,
			},
		}

		vim.o.autoread = true

		local augroup = vim.api.nvim_create_augroup

		if vim.fs and vim.fs.watch then
			local cwd = vim.fn.getcwd()
			local watch = vim.fs.watch(cwd, function(_, name)
				if name == "change" or name == "rename" then
					vim.cmd("checktime")
				end
			end)
			vim.api.nvim_create_autocmd("VimLeave", {
				group = augroup("close_watch", { clear = true }),
				callback = function()
					if watch then
						watch:close()
					end
				end,
			})
		end

		-- Prevent the opencode terminal buffer from being shown in a second window
		vim.api.nvim_create_autocmd("BufWinEnter", {
			pattern = "*",
			callback = function(args)
				vim.defer_fn(function()
					local term = require("snacks.terminal").get(opencode_cmd, { create = false })
					if not term or not term.win or not vim.api.nvim_win_is_valid(term.win) then
						return
					end

					local buf = args.buf
					local buftype = vim.api.nvim_get_option_value("buftype", { buf = buf })

					if buftype ~= "terminal" then
						return
					end

					if buf ~= term.buf then
						return
					end

					local current_win = vim.api.nvim_get_current_win()
					if current_win == term.win then
						return
					end

					vim.api.nvim_win_close(current_win, true)
				end, 10)
			end,
		})

		local toggle_in_progress = false

		-- keymaps
		vim.keymap.set({ "n", "x" }, "<leader>oa", function()
			require("opencode").ask("@this: ")
		end, { desc = "Ask opencode…" })

		vim.keymap.set({ "n", "x" }, "<leader>oc", function()
			local term = require("snacks.terminal").get(opencode_cmd, { create = false })
			if term and term.win and vim.api.nvim_win_is_valid(term.win) then
				vim.api.nvim_set_current_win(term.win)
				vim.cmd("startinsert")
			end
			vim.defer_fn(function()
				require("opencode").select()
			end, 50)
		end, { desc = "Execute opencode action…" })

		vim.keymap.set({ "n", "t" }, "<leader>oo", function()
			if toggle_in_progress then
				return
			end
			toggle_in_progress = true

			local term = require("snacks.terminal").get(opencode_cmd, { create = false })
			local is_visible = term and term.win and vim.api.nvim_win_is_valid(term.win)

			if is_visible then
				local wins = vim.api.nvim_list_wins()
				if #wins > 1 then
					for _, win in ipairs(wins) do
						if win ~= term.win then
							vim.api.nvim_win_close(win, false)
						end
					end
				end
				vim.api.nvim_set_current_win(term.win)
				vim.cmd("startinsert")
				toggle_in_progress = false
			else
				require("snacks.terminal").toggle(opencode_cmd, snacks_terminal_opts)
				vim.defer_fn(function()
					local t = require("snacks.terminal").get(opencode_cmd, { create = false })
					if t and t.win and vim.api.nvim_win_is_valid(t.win) then
						vim.api.nvim_set_current_win(t.win)
						vim.cmd("startinsert")
					end
					toggle_in_progress = false
				end, 200)
			end
		end, { desc = "Toggle opencode" })

		vim.keymap.set({ "n", "v", "x" }, "go", function()
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

		vim.keymap.set("n", "<leader>oe", function()
			require("opencode").prompt("Explain this code:\n```\n@this\n```")
		end, { desc = "Explain code" })

		vim.keymap.set("n", "<leader>or", function()
			require("opencode").prompt("Review this code for issues:\n```\n@this\n```")
		end, { desc = "Review code" })

		vim.keymap.set("n", "<leader>oh", function()
			local handoff_file = vim.fn.expand("~/.cache/opencode/handoff-latest.txt")
			local check_count = 0
			local max_checks = 30

			vim.fn.mkdir(vim.fn.expand("~/.cache/opencode"), "p")

			if vim.fn.filereadable(handoff_file) == 1 then
				vim.fn.delete(handoff_file)
			end

			require("opencode").prompt("handoff")

			local timer = vim.loop.new_timer()
			timer:start(
				1000,
				1000,
				vim.schedule_wrap(function()
					check_count = check_count + 1

					if check_count > max_checks then
						timer:stop()
						vim.notify("Handoff timeout - check file manually at " .. handoff_file, vim.log.levels.WARN)
						return
					end

					if vim.fn.filereadable(handoff_file) == 1 then
						local lines = vim.fn.readfile(handoff_file)
						if #lines > 0 and lines[#lines] == "---HANDOFF_COMPLETE---" then
							timer:stop()

							local content_lines = {}
							for i = 1, #lines - 1 do
								table.insert(content_lines, lines[i])
							end

							local content = table.concat(content_lines, "\n")

							if vim.fn.has("mac") == 1 then
								vim.fn.system("pbcopy", content)
							elseif vim.fn.has("linux") == 1 then
								vim.fn.system("xclip -selection clipboard", content)
							end

							vim.notify("Handoff copied to clipboard!", vim.log.levels.INFO)
						end
					end
				end)
			)
		end, { desc = "Smart handoff to clipboard" })

		vim.keymap.set("n", "<leader>oy", function()
			local handoff_file = vim.fn.expand("~/.cache/opencode/handoff-latest.txt")
			if vim.fn.filereadable(handoff_file) == 0 then
				vim.notify("No handoff file found. Run <leader>oh first.", vim.log.levels.WARN)
				return
			end

			local lines = vim.fn.readfile(handoff_file)
			if #lines == 0 then
				vim.notify("Handoff file is empty", vim.log.levels.WARN)
				return
			end

			local content_lines = {}
			for i = 1, #lines do
				if lines[i] ~= "---HANDOFF_COMPLETE---" then
					table.insert(content_lines, lines[i])
				end
			end

			local content = table.concat(content_lines, "\n")

			if vim.fn.has("mac") == 1 then
				vim.fn.system("pbcopy", content)
			elseif vim.fn.has("linux") == 1 then
				vim.fn.system("xclip -selection clipboard", content)
			end

			vim.notify("Handoff copied to clipboard!", vim.log.levels.INFO)
		end, { desc = "Copy last handoff to clipboard" })

		vim.api.nvim_create_autocmd("TermOpen", {
			pattern = "term://*opencode*",
			callback = function(args)
				vim.keymap.set("t", "<C-n>", "<C-\\><C-n>", { buffer = args.buf })
			end,
		})

		-- Auto-enter insert mode only when focusing the opencode terminal buffer
		vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
			pattern = "term://*opencode*",
			callback = function()
				if vim.api.nvim_get_mode().mode == "n" then
					vim.cmd("startinsert")
				end
			end,
		})
	end,
}
