require("config.lazy")

local function augroup(name)
  return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end

local startup_done = false
local opencode_started = false

local function close_starter_buffer()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].filetype == "ministarter" and vim.api.nvim_buf_is_valid(buf) then
      vim.cmd("bwipeout! " .. buf)
    end
  end
end

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

vim.api.nvim_create_autocmd("VimEnter", {
  group = augroup("three_column_startup"),
  once = true,
  callback = function()
    if vim.fn.argc() > 0 or startup_done then return end
    startup_done = true

    local starter = require("mini.starter")

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
            vim.b.ministarter_config = {
              content_hooks = {
                starter.gen_hook.aligning("center", "center"),
              },
            }
            starter.open()
          end
        end, 150)
      end, 100)
    end, 50)
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
    end, 50)
  end,
})

vim.api.nvim_create_autocmd("BufAdd", {
  group = augroup("hide_unnamed"),
  callback = function()
    vim.schedule(function()
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[buf].buflisted and vim.bo[buf].buftype == "" and vim.fn.bufname(buf) == "" and buf ~= vim.api.nvim_get_current_buf() then
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
      local non_special = 0
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[buf].buflisted
          and vim.bo[buf].filetype ~= "ministarter"
          and vim.bo[buf].filetype ~= "neo-tree"
          and not vim.fn.bufname(buf):match("opencode")
          and vim.api.nvim_buf_is_valid(buf)
          and vim.bo[buf].buftype == "" then
          non_special = non_special + 1
        end
      end
      if non_special == 0 then
        close_starter_buffer()
        if focus_center_window() then
          require("mini.starter").open()
        end
      end
    end)
  end,
})
