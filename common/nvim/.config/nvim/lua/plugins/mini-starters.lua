return {
  "echasnovski/mini.nvim",
  opts = {
    starter = {
      content_hooks = {
        require("mini.starter").gen_hook.aligning("center", "center"),
      },
    },
  },
}
