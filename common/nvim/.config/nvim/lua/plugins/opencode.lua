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
				input = { enabled = false }, -- Disable to prevent startup Telescope prompts

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
			window = {
				position = "right",
				width = 0.4,
			},
		}

		vim.o.autoread = true

		local augroup = vim.api.nvim_create_augroup

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

		vim.api.nvim_create_autocmd("BufWinEnter", {
			pattern = "*",
			callback = function(args)
				vim.defer_fn(function()
					local terminal = require("opencode.terminal")
					if not terminal.winid or not vim.api.nvim_win_is_valid(terminal.winid) then
						return
					end

					local buf = args.buf
					local buftype = vim.api.nvim_buf_get_option(buf, "buftype")

					if buftype ~= "terminal" then
						return
					end

					local term_buf = vim.api.nvim_win_get_buf(terminal.winid)
					if buf ~= term_buf then
						return
					end

					local current_win = vim.api.nvim_get_current_win()
					if current_win == terminal.winid then
						return
					end

					vim.api.nvim_win_close(current_win, true)
				end, 10)
			end,
		})

		-- Guard to prevent toggle spam
		local toggle_in_progress = false

		-- keymaps
		vim.keymap.set({ "n", "x" }, "<leader>oa", function()
			require("opencode").ask("@this: ", { submit = true })
		end, { desc = "Ask opencode…" })
		vim.keymap.set({ "n", "x" }, "<leader>oc", function()
			local terminal = require("opencode.terminal")
			if terminal.winid and vim.api.nvim_win_is_valid(terminal.winid) then
				vim.api.nvim_set_current_win(terminal.winid)
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

			local terminal = require("opencode.terminal")
			local is_visible = terminal.winid ~= nil and vim.api.nvim_win_is_valid(terminal.winid)

			if is_visible then
				local wins = vim.api.nvim_list_wins()
				if #wins > 1 then
					for _, win in ipairs(wins) do
						if win ~= terminal.winid then
							vim.api.nvim_win_close(win, false)
						end
					end
				end
				vim.api.nvim_set_current_win(terminal.winid)
				vim.cmd("startinsert")
				toggle_in_progress = false
			else
				require("opencode.terminal").toggle("opencode --port", { split = "right" })
				vim.defer_fn(function()
					if terminal.winid and vim.api.nvim_win_is_valid(terminal.winid) then
						vim.api.nvim_set_current_win(terminal.winid)
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

		vim.keymap.set("v", "<leader>os", function()
			local start_line = vim.fn.line("'<")
			local end_line = vim.fn.line("'>")
			local lines = vim.fn.getline(start_line, end_line)
			local text = table.concat(lines, "\n")
			require("opencode").ask("```\n" .. text .. "\n```", { submit = false })
		end, { desc = "Send selection to OpenCode" })

		vim.keymap.set("n", "<leader>oe", function()
			require("opencode").ask("Explain this code:\n```\n@this\n```", { submit = true })
		end, { desc = "Explain code" })

		vim.keymap.set("n", "<leader>or", function()
			require("opencode").ask("Review this code for issues:\n```\n@this\n```", { submit = true })
		end, { desc = "Review code" })

		vim.keymap.set("n", "<leader>oh", function()
			local handoff_file = vim.fn.expand("~/.cache/opencode/handoff-latest.txt")
			local check_count = 0
			local max_checks = 30

			vim.fn.mkdir(vim.fn.expand("~/.cache/opencode"), "p")

			if vim.fn.filereadable(handoff_file) == 1 then
				vim.fn.delete(handoff_file)
			end

			require("opencode").ask("handoff", { submit = true })

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
	end,
}
