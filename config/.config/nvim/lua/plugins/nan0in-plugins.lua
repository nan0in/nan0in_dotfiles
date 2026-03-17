return {
  {
    "github/copilot.vim",
    -- enabled = false, -- 完全禁用插件
    config = function()
      -- 1. 禁用默认的 Tab 映射，防止冲突
      -- vim.g.copilot_no_tab_map = true
      -- 2. 设置快捷键：Ctrl + J 接受补全
      -- <C-J> 代表 Ctrl+J，你也可以换成 <M-CR> (Alt+Enter)
      vim.keymap.set("i", "<C-J>", 'copilot#Accept("\\<CR>")', {
        expr = true,
        replace_keycodes = false,
      })
    end,
  },
  -- Vundle 替代: lazy.nvim 自动管理插件
  -- 大纲式导航（Go 需 gotags 支持）
  { "preservim/tagbar" },

  -- 代码片段系统
  { "SirVer/ultisnips" },
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
  -- 图片粘贴
  {
    "HakonHarnes/img-clip.nvim",
    event = "VeryLazy",
    opts = {
      defalte = {
        embed_image_as_base64 = false, -- 是否以 base64 格式嵌入图片 
        prompt_for_filename = false, -- 是否在粘贴时提示输入文件名 
        drag_and_drop = {
          insert_mode = true, -- 是否在插入模式下启用拖放功能
        },
        clipboard_command = "wl-paste",
        img_dir = { "src", "assets", "images" },
        img_dir_txt = { "src", "assets", "images" },
        -- add options here
        -- or leave it empty to use the default settings
      },
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
  {
    "SilverofLight/kd_translate.nvim",
    config = function()
      require("kd").setup({
        window = {
          -- your window config here
        },
      })
    end,
    keys = {
      { "<leader>t", "<cmd>TranslateNormal<cr>", desc = "󰊿 TranslateNormal", mode = "n" },
      { "<leader>T", "<cmd>TranslateVisual<cr>", desc = "󰊿 TranslateVisual", mode = "v" },
    },
  },
  -- cooperate with tmux to navigate between vim and tmux splits seamlessly
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
    },
    keys = {
      -- 这里的快捷键必须和 Tmux 里的 M-a/s/w/d 一一对应
      { "<A-a>", "<cmd>TmuxNavigateLeft<cr>", desc = "Go to left pane" },
      { "<A-s>", "<cmd>TmuxNavigateDown<cr>", desc = "Go to lower pane" },
      { "<A-w>", "<cmd>TmuxNavigateUp<cr>", desc = "Go to upper pane" },
      { "<A-d>", "<cmd>TmuxNavigateRight<cr>", desc = "Go to right pane" },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters = {
        markdownlint = {
          -- 核心修改在这里：
          -- 我们给 markdownlint 命令追加参数，告诉它全局禁用 MD013 规则
          -- "--" 的作用是告诉命令行参数结束，后面跟文件名
          args = { "--disable", "MD013", "--" },
        },
      },
    },
  },
  git = {
    throttle = {
      enabled = true, -- not enabled by default
      -- max 2 ops every 5 seconds
      rate = 1,
      duration = 15 * 1000, -- in ms
    },
  },
}
