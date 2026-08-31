require("config.lazy")

local function augroup(name)
	return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end

-- OSC 52 clipboard for SSH + Wezterm (copy only - paste via OSC 52 is slow/unreliable)
-- Only enable when in SSH session or when clipboard providers are unavailable
local function should_use_osc52()
	-- Check if we're in an SSH session
	if vim.env.SSH_CONNECTION or vim.env.SSH_CLIENT or vim.env.SSH_TTY then
		return true
	end
	-- Check if running in WezTerm without native clipboard access
	if vim.env.TERM_PROGRAM == "WezTerm" and vim.fn.has("clipboard") == 0 then
		return true
	end
	return false
end

if should_use_osc52() then
	vim.g.clipboard = {
		name = "OSC 52",
		copy = {
			["+"] = require("vim.ui.clipboard.osc52").copy("+"),
			["*"] = require("vim.ui.clipboard.osc52").copy("*"),
		},
		-- Don't use OSC 52 for paste - it's slow and can hang
		-- Fall back to default paste behavior
		paste = {
			["+"] = function() end,
			["*"] = function() end,
		},
	}
end
vim.api.nvim_create_autocmd("VimEnter", {
	group = augroup("startup"),
	once = true,
	callback = function()
		if vim.fn.argc() > 0 then
			return
		end

		vim.defer_fn(function()
			vim.cmd("Neotree show position=left")
		end, 50)
	end,
})
