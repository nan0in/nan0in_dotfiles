return {
  -- blink.cmp 配置
  {
    "saghen/blink.cmp",
    dependencies = {
      "Kaiser-Yang/blink-cmp-avante",
      "rafamadriz/friendly-snippets",
    },
    event = { "BufReadPost", "BufNewFile" },

    config = function(_, opts)
      require("blink.cmp").setup(opts)
      --配色1 类dracula
      -- vim.api.nvim_set_hl(0, "BlinkCmpMenu", { bg = "#2b2b3c" })
      -- vim.api.nvim_set_hl(0, "BlinkCmpDoc", { bg = "#2b2b3c" })
      -- vim.api.nvim_set_hl(0, "BlinkCmpMenuSelection", { bg = "#bd93f9", fg = "#191b28", bold = true })
      -- vim.api.nvim_set_hl(0, "BlinkCmpMenuBorder", { fg = "#565f89", bg = "#2b2b3c" })
      -- vim.api.nvim_set_hl(0, "BlinkCmpDocBorder", { fg = "#565f89", bg = "#2b2b3c" })
      --配色2 类tokyonight
      vim.api.nvim_set_hl(0, "BlinkCmpMenu", { bg = "#191b28", fg = "#c0caf5" })
      vim.api.nvim_set_hl(0, "BlinkCmpDoc", { bg = "#191b28", fg = "#c0caf5" })
      vim.api.nvim_set_hl(0, "BlinkCmpMenuBorder", { fg = "#3d59a1", bg = "#191b28" })
      vim.api.nvim_set_hl(0, "BlinkCmpDocBorder", { fg = "#3d59a1", bg = "#191b28" })
      vim.api.nvim_set_hl(0, "BlinkCmpMenuSelection", { bg = "#7aa2f7", fg = "#191b28", bold = true })
    end,

    opts = {
      snippets = { preset = "luasnip" },
      keymap = {
        ["<C-u>"] = { "scroll_documentation_up", "fallback" },
        ["<C-d>"] = { "scroll_documentation_down", "fallback" },
        ["<CR>"] = { "select_and_accept", "fallback" },
      },

      sources = {
        default = { "avante","lsp", "path", "snippets", "buffer" },
        providers = {
          avante = { module = "blink-cmp-avante", name = "Avante", opts = {} },
          lsp = { name = "LSP" },
          path = { name = "Path" },
          snippets = { name = "Snip" },
          buffer = { name = "Buf" },
        },
      },

      completion = {
        trigger = { prefetch_on_insert = false },

        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
          window = {
            border = "rounded",
            winblend = 0,
          },
        },

        menu = {
          border = "rounded",
          winblend = 0,

          draw = {
            columns = {
              { "kind_icon" },
              { "label", "label_description", gap = 1 },
              { "kind" },
              { "source_name" },
            },
            components = {
              kind_icon = {
                ellipsis = false,
                text = function(ctx)
                  return ctx.kind_icon .. ctx.icon_gap
                end,
                highlight = function(ctx)
                  return ctx.kind_hl
                end,
              },
              label = {
                width = { fill = true, max = 60 },
                text = function(ctx)
                  return ctx.label .. ctx.label_detail
                end,
                highlight = function(ctx)
                  return ctx.label_matched and "BlinkCmpLabelMatch" or "BlinkCmpLabel"
                end,
              },
              label_description = {
                width = { max = 30 },
                text = function(ctx)
                  return ctx.label_description
                end,
                highlight = "BlinkCmpLabelDetail",
              },
              source_name = {
                width = { max = 30 },
                text = function(ctx)
                  return "[" .. ctx.source_name .. "]"
                end,
                highlight = "BlinkCmpSource",
              },
            },
          },
        },
      },

      signature = {
        enabled = true,
        window = { border = "rounded" },
      },

      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = "mono",
        kind_icons = {
          Avante = "",
          Path = "",
          Snippets = "",
          Completion = "ﬧ",
          Text = "󰉿",
          Method = "󰊕",
          Function = "󰊕",
          Constructor = "󰒓",
          Field = "󰜢",
          Variable = "󰆦",
          Class = "󰠱",
          Interface = "",
          Module = "",
          Property = "󰜢",
          Unit = "󰑭",
          Value = "󰎠",
          Enum = "",
          Keyword = "󰌋",
          Color = "󰏘",
          File = "󰈙",
          Reference = "󰈇",
          Folder = "󰉋",
          EnumMember = "",
          Constant = "󰏿",
          Struct = "󰙅",
          Event = "",
          Operator = "󰆕",
          TypeParameter = "󰊄",
        },
      },
    },
  },
  -- Avante 配置
  {
    "yetone/avante.nvim",
    build = vim.fn.has("win32") ~= 0 and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
      or "make",
    event = "VeryLazy",
    version = false, -- 永远不要将此值设置为 "*"！永远不要！
    ---@module 'avante'
    ---@type avante.Config
    opts = {
      providers = {
        copilot = {
          support_previous_response_id = false,
        },
        openai = {
          endpoint = "https://llm.imsy.cc/v1",
          model = "gpt-4o",
          suppoet_previous_response_id = false,
        },
      },
    },
    mappings = {
      diff = {
        ours = "co",
        theirs = "ct",
        all_theirs = "ca", -- 在 Diff 界面按 ca 就会把 AI 代码插入文件
        both = "cb",
        cursor = "cc",
        next = "]x",
        prev = "[x",
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- 以下依赖项是可选的，
      "nvim-mini/mini.pick", -- 用于文件选择器提供者 mini.pick
      "nvim-telescope/telescope.nvim", -- 用于文件选择器提供者 telescope
      "ibhagwan/fzf-lua", -- 用于文件选择器提供者 fzf
      "nvim-tree/nvim-web-devicons", -- 或 echasnovski/mini.icons
    },
    web_search_engine = {
      provider = "SerpApi",
      proxy = "http://127.0.0.1:20171",
    },
    behaviour = {
      auto_suggestions = false,
    },
  },
  -- { "mistricky/codesnap.nvim", tag = "v2.0.0-beta.17" },
}
