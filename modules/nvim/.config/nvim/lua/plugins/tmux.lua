return {
  "christoomey/vim-tmux-navigator",
  lazy = false,
  keys = {
    { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Tmux/Win Left" },
    { "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Tmux/Win Down" },
    { "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Tmux/Win Up" },
    { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Tmux/Win Right" },
    { "<leader>tmh", "<cmd>TmuxNavigateLeft<cr>", desc = "Tmux left" },
    { "<leader>tmj", "<cmd>TmuxNavigateDown<cr>", desc = "Tmux down" },
    { "<leader>tmk", "<cmd>TmuxNavigateUp<cr>", desc = "Tmux up" },
    { "<leader>tml", "<cmd>TmuxNavigateRight<cr>", desc = "Tmux right" },
  },
}
