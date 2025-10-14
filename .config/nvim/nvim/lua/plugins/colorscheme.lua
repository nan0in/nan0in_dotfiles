return {
  {
    "Mofiqul/dracula.nvim",
    opts = {
      transparent_bg = false,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "dracula",
    },
  },
  {
    "folke/tokyonight.nvim",
    opts = {
      style = "moon", -- 还有 available: night | moon | day
      transparent = false, -- 是否启用透明背景

      styles = {
        comments = { italic = false},      -- 批注（注释）字体设置为斜体
        keywords = { italic = true },      -- 关键字也斜体（可选）
        functions = {},                    -- 函数默认样式
        variables = {},                    -- 变量默认样式
      }
  }
  }
}
