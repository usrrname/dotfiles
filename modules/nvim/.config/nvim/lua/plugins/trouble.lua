return {
	"folke/trouble.nvim",
	init = function()
		-- Neovim 0.12 removed vim.treesitter.highlighter._on_line (replaced by
		-- _on_range); trouble 3.7.1 still calls it and crashes when opening the
		-- diagnostics view. Upstream issue: folke/trouble.nvim#694.
		local file = vim.fn.stdpath("data") .. "/lazy/trouble.nvim/lua/trouble/view/treesitter.lua"
		local f = io.open(file, "rb")
		if not f then
			return
		end
		local content = f:read("*a")
		f:close()
		if content:find("TSHighlighter%[name%] then") then
			return
		end
		local patched, count = content:gsub(
			"TSHighlighter%[name%]%(_, win, buf, ...%)",
			"if TSHighlighter[name] then TSHighlighter[name](_, win, buf, ...) end"
		)
		if count == 0 then
			vim.notify("trouble.nvim treesitter patch: pattern not found", vim.log.levels.WARN)
			return
		end
		local w = io.open(file, "wb")
		w:write(patched)
		w:close()
	end,
}
