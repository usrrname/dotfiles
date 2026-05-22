return {
  "kevalin/mermaid.nvim",
  version = "^3.0.0",
  ft = "mermaid",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  config = function()
    require("mermaid").setup({})
  end,
}
