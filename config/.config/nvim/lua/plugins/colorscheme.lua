return {
  {
    "folke/tokyonight.nvim",
    lazy=false,
    priority = 1000,
    opts = {
      style = "moon", -- 还有 available: night | moon | day
      transparent = false, -- 是否启用透明背景

      styles = {
        comments = { italic = false }, -- 批注（注释）字体设置为斜体
        keywords = { italic = true }, -- 关键字也斜体（可选）
        functions = {}, -- 函数默认样式
        variables = {}, -- 变量默认样式
      },
      config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd([[colorscheme tokyonight]]) -- 在插件加载完成后再执行
    end,
    },
  },
}
