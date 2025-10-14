return {
  "hedyhli/outline.nvim",
  cmd = { "Outline", "OutlineOpen" },
  keys = {
    { "<leader>cs", "<cmd>Outline<CR>", desc = "Outline Symbol Panel" },
  },
  config = function()
    require("outline").setup({
      -- 可选配置，根据需要调整
      outline_window = {
        position = "right", -- 或 'left'
        width = 25,
      },
      symbol_folding = {
        autoclose_depth = nil,
        auto_unfold = {
          only = 2,
        },
      },
      outline_items = {
        show_symbol_lineno = true,
      },
    })
  end,
}
