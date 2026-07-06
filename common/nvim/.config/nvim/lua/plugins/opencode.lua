return {
	"nickjvandyke/opencode.nvim",
	version = "*",
	dependencies = {
		{
			---@module "snacks"
			"folke/snacks.nvim",
			optional = true,
			opts = {
				input = { enabled = true }, -- Enhances ask() with floating prompt + LSP completions

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
				-- Float, not sidebar split — floats are immune to layout changes
				-- (Trouble, quickfix, :term, etc.) so the TUI never gets resized
				-- and never corrupts its display via libvterm's reflow-on-resize.
				position = "float",
				width = 0.4,
				height = 0.99,
				row = 1,
				col = -1,
				border = "rounded",
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
			local watch = vim.fs.watch(cwd, function(_, events)
				if vim.tbl_contains(events, "change") or vim.tbl_contains(events, "rename") then
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

				-- Only close if current_win is an unwanted duplicate showing
				-- the term buf (the actual misuse this autocmd guards against).
				if vim.api.nvim_win_get_buf(current_win) ~= buf then
					return
				end

				-- Never close the last regular window — E444.
				local regular_wins = vim.tbl_filter(function(w)
					return vim.api.nvim_win_get_config(w).relative == ""
				end, vim.api.nvim_list_wins())
				if #regular_wins <= 1 then
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
				if term.buf then
					vim.api.nvim_create_autocmd("BufEnter", {
						once = true,
						buffer = term.buf,
						callback = function()
							require("opencode").select()
						end,
					})
				end
			end
		end, { desc = "Execute opencode action…" })

		vim.keymap.set({ "n", "t" }, "<leader>oo", function()
			if toggle_in_progress then
				return
			end
			toggle_in_progress = true

			local term = require("snacks.terminal").get(opencode_cmd, { create = false })
			if term and term.win and vim.api.nvim_win_is_valid(term.win) then
				-- Hide the float, keep buffer + process alive
				term:hide()
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

		-- Scroll any terminal buffer to bottom on focus so latest output is visible.
		vim.api.nvim_create_autocmd({ "WinEnter", "FocusGained" }, {
			callback = function()
				local buf = vim.api.nvim_get_current_buf()
				if vim.bo[buf].buftype == "terminal" then
					local last = vim.api.nvim_buf_line_count(buf)
					pcall(vim.api.nvim_win_set_cursor, 0, { last, 0 })
				end
			end,
		})

		-- Auto-enter insert mode when focusing the opencode float
		vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
			pattern = "term://*opencode*",
			callback = function()
				if vim.api.nvim_get_mode().mode == "n" then
					vim.cmd("startinsert")
				end
			end,
		})

		vim.api.nvim_create_autocmd("TermOpen", {
			pattern = "term://*opencode*",
			callback = function(args)
				vim.keymap.set("t", "<C-n>", "<C-\\><C-n>", { buffer = args.buf })
			end,
		})

		-- Pre-warm: start OpenCode in the background after Neovim finishes loading.
		-- The slowest part is Node.js + oh-my-openagent initialization; deferring
		-- this to VeryLazy instead of waiting for <leader>oo makes the toggle instant.
		vim.api.nvim_create_autocmd("User", {
			pattern = "VeryLazy",
			callback = function()
				local term = require("snacks.terminal").toggle(opencode_cmd, snacks_terminal_opts)
				if term then
					vim.defer_fn(function()
						if term.win and vim.api.nvim_win_is_valid(term.win) then
							term:hide()
						end
					end, 300)
				end
			end,
		})

		-- Auto-show float on prompt — no manual <leader>oo after asking.
		vim.api.nvim_create_autocmd("User", {
			pattern = "OpencodeEvent:tui.command.execute",
			callback = function(args)
				local event = args.data.event
				if event.properties and event.properties.command == "prompt.submit" then
					local term = require("snacks.terminal").get(opencode_cmd, { create = false })
					if term then
						term:show()
					end
				end
			end,
		})
		end,
	}
