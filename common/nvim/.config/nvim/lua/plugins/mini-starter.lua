return {
  "nvim-mini/mini.starter",
  lazy = false,
  config = function()
    require("mini.starter").setup({
      autoopen = false,
    })
  end,
}
