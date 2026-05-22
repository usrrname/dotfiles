require("config.lazy")

local function augroup(name)
	return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end
-- OSC 52 clipboard for SSH + Wezterm
vim.g.clipboard = {
	name = "OSC 52",
	copy = {
		["+"] = require("vim.ui.clipboard.osc52").copy("+"),
		["*"] = require("vim.ui.clipboard.osc52").copy("*"),
	},
	paste = {
		["+"] = require("vim.ui.clipboard.osc52").paste("+"),
		["*"] = require("vim.ui.clipboard.osc52").paste("*"),
	},
}
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
