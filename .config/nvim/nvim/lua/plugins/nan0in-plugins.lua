return {
  -- Vundle 替代: lazy.nvim 自动管理插件
  -- 大纲式导航（Go 需 gotags 支持）
  { "preservim/tagbar" },

  -- 代码片段系统
  { "SirVer/ultisnips" },
  { "honza/vim-snippets" },

  -- Dracula 主题（设置别名为 dracula）
  { "dracula/vim", name = "dracula" },

  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons", -- 可选：文件图标支持
    },
    keys = {
      -- 将 <leader>e 改为
      { "<leader>m", "<cmd>NvimTreeToggle<cr>", desc = "Toggle File Explorer" },
    },
    config = function()
      require("nvim-tree").setup({
        -- 基础配置
        view = {
          width = 35, -- 侧边栏宽度
          side = "left", -- 显示在左侧
        },
        -- Git 状态集成（替代 nerdtree-git-plugin）
        git = {
          enable = true,
          ignore = false,
          timeout = 500,
        },
        -- 文件过滤（隐藏文件）
        filters = {
          dotfiles = false, -- 显示 . 开头的文件
        },
        -- 快捷键配置
        on_attach = function(bufnr)
          local api = require("nvim-tree.api")

          -- 自定义快捷键
          local function opts(desc)
            return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
          end

          -- 常用操作
          vim.keymap.set("n", "o", api.node.open.edit, opts("Open"))
          vim.keymap.set("n", "<CR>", api.node.open.edit, opts("Open"))
          vim.keymap.set("n", "s", api.node.open.vertical, opts("Open: Vertical Split"))
          vim.keymap.set("n", "a", api.fs.create, opts("Create File/Dir"))
          vim.keymap.set("n", "d", api.fs.remove, opts("Delete"))
        end,
      })
    end,
  },
  {
    "preservim/vim-markdown",
    ft = "markdown",
    init = function()
      vim.g.vim_markdown_spellcheck = 0 -- 关闭拼写检查
      vim.g.vim_markdown_conceal = 0 -- 关闭特殊符号隐藏
    end,
  },
  {
    "saghen/blink.cmp",
    event = { "BufReadPost", "BufNewFile" },
    version = "1.*",
    -- build = 'cargo build --realease',
    opts = {
      completion = {
        documentation = {
          auto_show = true,
        },
      },
      keymap = {
        ["<C-u>"] = { "scroll_documentation_up", "fallback" },
        ["<C-d>"] = { "scroll_documentation_down", "fallback" },
      },
      signature = {
        enabled = true,
      },
    },
  },
  {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup({
        filetypes = { "*" }, -- 对所有文件类型生效
        user_default_options = {
          RGB = true, -- 启用 RGB 颜色（如 `rgb(255, 0, 0)`
          RRGGBB = true, -- 启用 6 位 HEX 颜色（如 `#FF0000`）
          RRGGBBAA = true, -- 启用 8 位 HEX 带透明度（如 `#FF000080`）
          rgb_fn = true, -- 启用 CSS `rgb()` 颜色
          hsl_fn = true, -- 启用 CSS `hsl()` 颜色
          css = true, -- 启用 CSS 颜色高亮
          css_fn = true, -- 启用 CSS 函数（如 `rgba()`, `hsla()`）
          mode = "background", -- 显示背景色（也可以设为 "foreground" 或 "virtualtext"）
        },
      })
    end,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.nvim" }, -- if you use the mini.nvim suite
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
  },
  -- 图片粘贴
  {
    "HakonHarnes/img-clip.nvim",
    event = "VeryLazy",
    opts = {
        clipboard_command = "wl-paste",
        img_dir = {"src", "assets", "images"},
        img_dir_txt = {"src", "assets", "images"},
      -- add options here
      -- or leave it empty to use the default settings
    },
    keys = {
      -- suggested keymap
      { "<leader>p", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
    },
  },
  -- 用于快速添加、删除、修改成对符号，如括号、引号等
  {
  "kylechui/nvim-surround",
  version = "*", -- Use for stability; omit to use `main` branch for the latest features
  event = "VeryLazy",
  config = function()
    require("nvim-surround").setup({})
  end,
},
}
