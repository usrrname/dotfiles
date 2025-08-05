return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make"
    },
  },
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
      -- Disable treesitter highlighting
      preview = {
        treesitter = false
      },
    },
    extensions = {
      fzf = {
        fuzzy = true,
        override_generic_sorter = true,
        override_file_sorter = true,
        case_mode = "smart_case",
      },
    },
  },
  -- Add config function to load extensions
  config = function(_, opts)
    require("telescope").setup(opts)
    
    -- Load fzf extension with error handling
    pcall(function()
      require("telescope").load_extension("fzf")
    end)
  end,
}
