require("config.lazy")

local function augroup(name)
	return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end

local DELAY_NEOTREE = 50
local DELAY_STARTER = 150
local DELAY_OPENCODE = 200

local starter = require("mini.starter")
local startup_done = false

vim.api.nvim_create_autocmd("VimEnter", {
	group = augroup("startup"),
	once = true,
	callback = function()
		if vim.fn.argc() > 0 or startup_done then
			return
		end
		startup_done = true

		vim.defer_fn(function()
			vim.cmd("Neotree show position=left")

			vim.defer_fn(function()
				starter.open()
			end, DELAY_STARTER)

			vim.defer_fn(function()
				pcall(function()
					require("opencode.terminal").toggle("opencode --port", { split = "right" })
				end)
			end, DELAY_OPENCODE)

			vim.defer_fn(function()
				for _, buf in ipairs(vim.api.nvim_list_bufs()) do
					if vim.bo[buf].buflisted and vim.bo[buf].buftype == "" and vim.fn.bufname(buf) == "" and vim.bo[buf].filetype == "" then
						vim.cmd("bwipeout! " .. buf)
					end
				end
			end, 300)
		end, DELAY_NEOTREE)
	end,
})
