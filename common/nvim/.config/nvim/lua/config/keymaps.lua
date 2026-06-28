-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

--- Save and append in insert mode --
vim.keymap.set("i", "<D-s>", "<Esc><cmd>w<cr>a", { desc = "Save" })

vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to system clipboard" })

-- Yank as shell command: cleans up line breaks, \n literals, and whitespace for pasting into terminals
vim.keymap.set("v", "<leader>Y", function()
	local start_pos = vim.fn.getpos("'<")
	local end_pos = vim.fn.getpos("'>")
	local lines = vim.fn.getline(start_pos[2], end_pos[2])

	if #lines == 0 then
		return
	end

	local first_line = lines[1]
	local last_line = lines[#lines]

	if start_pos[2] == end_pos[2] then
		lines[1] = first_line:sub(start_pos[3], end_pos[3])
	else
		lines[1] = first_line:sub(start_pos[3])
		lines[#lines] = last_line:sub(1, end_pos[3])
	end

	local text = table.concat(lines, "\n")
	local transformations = {
		{ "\\n", "\n" },
		{ "\\\n%s*", " " },
		{ "\n+", " " },
		{ "%s+", " " },
		{ "^%s*", "" },
		{ "%s*$", "" },
	}

	for _, transform in ipairs(transformations) do
		text = text:gsub(transform[1], transform[2])
	end

	vim.fn.setreg("+", text)
	vim.fn.setreg('"', text)

	vim.notify("Yanked as shell command: " .. text:sub(1, 50) .. (#text > 50 and "..." or ""), vim.log.levels.INFO)
end, { desc = "Yank as shell command (clean format)" })

-- Reload LazyVim configuration with space+rl
vim.keymap.set("n", "<leader>rl", function()
	vim.cmd("Lazy reload")
	vim.cmd("Lazy sync")
end, { desc = "Reload Config" })



-- Move line up/down with Alt+Arrow
vim.keymap.set("n", "<M-Up>", function()
	vim.cmd("move -2")
end, { desc = "Move line up" })

vim.keymap.set("n", "<M-Down>", function()
	vim.cmd("move +1")
end, { desc = "Move line down" })

-- Insert mode Alt+Arrow
vim.keymap.set("i", "<M-Up>", "<Cmd>m .-2<CR>==gi", { desc = "Move line up" })
vim.keymap.set("i", "<M-Down>", "<Cmd>m .+1<CR>==gi", { desc = "Move line down" })

-- Delete the current buffer but KEEP its window. Snacks.bufdelete swaps
-- in an alternate buffer instead of closing the window, so the center
-- editor never collapses and neo-tree doesn't grab the freed space.
vim.keymap.set("n", "<leader>bd", function()
	Snacks.bufdelete()
end, { desc = "Delete buffer (keep window)" })

vim.keymap.set("n", "<leader>mp", "<Plug>(md-render-preview)", { desc = "Markdown preview (toggle)" })
vim.keymap.set("n", "<leader>mt", "<Plug>(md-render-preview-tab)", { desc = "Markdown preview in tab (toggle)" })
vim.keymap.set("n", "<leader>md", "<Plug>(md-render-demo)", { desc = "Markdown render demo" })
