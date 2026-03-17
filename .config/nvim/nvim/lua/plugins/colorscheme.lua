return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "night", -- 还有 available: night | moon | day
      light_style = "day",
      transparent = false, -- 是否启用透明背景

      styles = {
        comments = { italic = true }, -- 批注（注释）字体设置为斜体
        keywords = { italic = false }, -- 关键字也斜体（可选）
        functions = {}, -- 函数默认样式
        variables = {}, -- 变量默认样式
        floats = "transparent",
      },
      day_brightness = 0.3, -- 日间模式亮度调整
      hide_inactive_statusline = false, -- 隐藏不活跃的状态栏
      dim_inactive = true, -- 是否使不活跃窗口变暗
      lualine_bold = true, -- 是否使用粗体字体在 lualine 中
      on_highlights = function(hl,c)
        hl.Visual = { bg = "#283aaa",blend=20}
        -- hl.Visual = { bg = "#2e3c64",blend=20}
      end,
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd([[colorscheme tokyonight]]) -- 在插件加载完成后再执行
    end,
  },
}
