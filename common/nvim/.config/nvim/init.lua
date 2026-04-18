require("config.lazy")

local function augroup(name)
	return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
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
