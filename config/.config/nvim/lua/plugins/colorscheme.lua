return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "night",
      transparent = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = false },
        functions = {},
        variables = {},
        floats = "transparent",
      },
      dim_inactive = false,
      on_highlights = function(hl, c)
        hl.Visual = { bg = "#283aaa", blend = 20 }
        hl.SignColumn = { bg = "NONE" }
        hl.FoldColumn = { bg = "NONE" }
        hl.EndOfBuffer = { bg = "NONE" }
        hl.NormalNC = { bg = "NONE" }
        hl.MsgArea = { bg = "NONE" }
      end,
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd([[colorscheme tokyonight]])
    end,
  },
}
