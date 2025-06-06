return {
  -- {
  --   "scottmckendry/cyberdream.nvim",
  --   lazy = false, -- 设置为非懒加载，确保启动时生效
  --   priority = 1000, -- 高优先级，确保在其他插件之前加载
  --   config = function()
  --     require("cyberdream").setup({
  --       -- 可选的配置项（根据需求调整）
  --       transparent = true, -- 是否启用透明背景
  --       italic_comments = true, -- 注释是否使用斜体
  --       hide_fillchars = true, -- 是否隐藏填充字符（如状态栏空白）
  --       borderless_telescope = true, -- 是否让 Telescope 插件无边框
  --     })
  --   end,
  -- },
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
}
