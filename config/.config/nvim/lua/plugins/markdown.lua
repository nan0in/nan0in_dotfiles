return {
  -- Markdown
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons", -- 强制添加这个依赖，这是最通用的图标库
    },
    opts = {
      file_types = { "markdown", "norg", "rmd", "org","Avante" },
      -- 显式开启渲染功能，防止被误关
      render_modes = { "n", "c", "t" }, -- 在普通模式和命令模式下渲染
      checkbox = {
        enabled = true,
      },
      code = {
        width = "block",
        left_pad = 2,
        right_pad = 4,
      },
      -- 标题渲染配置 start
      heading = {
        enabled = true,
        render_modes = false,
        atx = true,
        setext = true,
        sign = true,
        icons = { "󰼏 ", "󰎨 " },
        position = "overlay",
        signs = { "󰫎 " },
        width = "full",
        left_margin = 0,
        left_pad = 0,
        right_pad = 0,
        min_width = 0,
        border = false,
        border_virtual = false,
        border_prefix = false,
        above = "▄",
        below = "▀",
        backgrounds = {
          "RenderMarkdownH1Bg",
          "RenderMarkdownH2Bg",
          "RenderMarkdownH3Bg",
          "RenderMarkdownH4Bg",
          "RenderMarkdownH5Bg",
          "RenderMarkdownH6Bg",
        },
        foregrounds = {
          "RenderMarkdownH1",
          "RenderMarkdownH2",
          "RenderMarkdownH3",
          "RenderMarkdownH4",
          "RenderMarkdownH5",
          "RenderMarkdownH6",
        },
        custom = {},
      },
      -- 标题渲染配置 end
    },
    ft = { "markdown", "norg", "rmd", "org","Avante" },
  },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    config = function()
      -- 可选：设置快捷键
      vim.g.mkdp_theme = "dark" -- 暗色主题
    end,
  },
  {
    "3rd/image.nvim",
    opts = {
      backend = "kitty", -- 或者 "ueberzug"
      tmux_show_only_in_active_window = true,
      integrations = {
        markdown = {
          enabled = true,
          clear_in_insert_mode = true,
          download_remote_images = true, -- 甚至能渲染网络图片
          only_render_image_at_cursor = true,  --只渲染光标下的图片 
          only_render_image_at_cursor_mode = "popup",  --只渲染光标下的图片 
        },
      },
    },
  },
}
