require("config.lazy")

-- Create autocmd group with lazyvim_ prefix
local function augroup(name)
	return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end

-- Delays for startup sequence (in ms)
local DELAY_NEOTREE = 50
local DELAY_OPENCODE = 100
local DELAY_STARTER = 150
local DELAY_WIPE_BUFFER = 50
local DELAY_FOCUS = 50

local starter = require("mini.starter")
local startup_done = false
local opencode_started = false

-- Remove ministarter buffer from buffer list
local function close_starter_buffer()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.bo[buf].filetype == "ministarter" and vim.api.nvim_buf_is_valid(buf) then
			vim.cmd("bwipeout! " .. buf)
		end
	end
end

-- Focus the center window (excludes neo-tree and opencode)
local function focus_center_window()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local pos = vim.api.nvim_win_get_position(win)
		local buf_name = vim.fn.bufname(vim.api.nvim_win_get_buf(win))
		if pos[2] > 0 and not buf_name:match("neo%-tree") and not buf_name:match("opencode") then
			vim.api.nvim_set_current_win(win)
			return true
		end
	end
	return false
end

-- Remove unnamed/empty buffers that have no content
local function wipe_unnamed_buffers()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if
			vim.bo[buf].buflisted
			and vim.bo[buf].buftype == ""
			and vim.fn.bufname(buf) == ""
			and vim.bo[buf].filetype == ""
		then
			vim.cmd("bwipeout! " .. buf)
		end
	end
end

-- Count buffers that are normal files (not special buffers like neo-tree, opencode, starter)
local function has_normal_buffer()
	local count = 0
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if
			vim.bo[buf].buflisted
			and vim.bo[buf].filetype ~= "ministarter"
			and vim.bo[buf].filetype ~= "neo-tree"
			and not vim.fn.bufname(buf):match("opencode")
			and vim.api.nvim_buf_is_valid(buf)
			and vim.bo[buf].buftype == ""
		then
			count = count + 1
		end
	end
	return count
end

vim.api.nvim_create_autocmd("VimEnter", {
	group = augroup("three_column_startup"),
	once = true,
	callback = function()
		if vim.fn.argc() > 0 or startup_done then
			return
		end
		startup_done = true

		vim.defer_fn(function()
			vim.cmd("Neotree show position=left")

			vim.defer_fn(function()
				if not opencode_started then
					opencode_started = true
					require("opencode.terminal").toggle("opencode --port", { split = "right" })
				end
				focus_center_window()

				vim.defer_fn(function()
					if focus_center_window() then
						starter.open()
						vim.defer_fn(wipe_unnamed_buffers, DELAY_WIPE_BUFFER)
					end
				end, DELAY_STARTER)
			end, DELAY_OPENCODE)
		end, DELAY_NEOTREE)
	end,
})

vim.api.nvim_create_autocmd("BufEnter", {
	group = augroup("file_open_center"),
	callback = function()
		local buf_name = vim.fn.bufname()
		local filetype = vim.bo.filetype
		if filetype == "ministarter" or filetype == "neo-tree" or buf_name:match("opencode") then
			return
		end
		if vim.fn.argc() == 0 and buf_name == "" then
			return
		end
		vim.defer_fn(function()
			close_starter_buffer()
			focus_center_window()
		end, DELAY_FOCUS)
	end,
})

vim.api.nvim_create_autocmd("BufAdd", {
	group = augroup("hide_unnamed"),
	callback = function()
		vim.schedule(function()
			for _, buf in ipairs(vim.api.nvim_list_bufs()) do
				if
					vim.bo[buf].buflisted
					and vim.bo[buf].buftype == ""
					and vim.fn.bufname(buf) == ""
					and buf ~= vim.api.nvim_get_current_buf()
				then
					vim.bo[buf].bufhidden = "wipe"
				end
			end
		end)
	end,
})

vim.api.nvim_create_autocmd("BufEnter", {
	group = augroup("starter_restore"),
	callback = function()
		local cur_filetype = vim.bo.filetype
		local cur_bufname = vim.fn.bufname()
		if cur_filetype == "ministarter" or cur_filetype == "neo-tree" or cur_bufname:match("opencode") then
			return
		end
		if cur_filetype ~= "" and cur_bufname ~= "" then
			return
		end

		vim.schedule(function()
			if has_normal_buffer() == 0 then
				close_starter_buffer()
				if focus_center_window() then
					starter.open()
				end
			end
		end)
	end,
})
