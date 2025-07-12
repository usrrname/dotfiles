return {
  "nvim-telescope/telescope.nvim",
  keys = {
      -- add a keymap to browse plugin files
      -- stylua: ignore
      {
        "<leader>fp",
        function() require("telescope.builtin").find_files({ cwd = require("lazy.core.config").options.root }) end,
        desc = "Find Plugin File",
      },

    {
      "n",
      "<D-f>",
      function()
        require("telescope.builtin").find_files({
          prompt_title = "Find Files",
          cwd = vim.fn.expand("%:p:h"),
          hidden = true,
          file_ignore_patterns = { ".git/", "node_modules/", "vendor/" },
        })
      end,
    },
  },
  -- change some options
  opts = {
    defaults = {
      layout_strategy = "horizontal",
      layout_config = { prompt_position = "top" },
      sorting_strategy = "ascending",
      winblend = 0,
    },
  },
}
