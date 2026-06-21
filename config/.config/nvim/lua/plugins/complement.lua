return {
  -- blink.cmp 配置
  {
    "saghen/blink.cmp",
    dependencies = {
      "Kaiser-Yang/blink-cmp-avante",
      "rafamadriz/friendly-snippets",
    },
    event = { "BufReadPost", "BufNewFile" },

    init = function()
      local function set_blink_cmp_highlights()
        -- 配色1 类dracula
        -- vim.api.nvim_set_hl(0, "BlinkCmpMenu", { bg = "#2b2b3c" })
        -- vim.api.nvim_set_hl(0, "BlinkCmpDoc", { bg = "#2b2b3c" })
        -- vim.api.nvim_set_hl(0, "BlinkCmpMenuSelection", { bg = "#bd93f9", fg = "#191b28", bold = true })
        -- vim.api.nvim_set_hl(0, "BlinkCmpMenuBorder", { fg = "#565f89", bg = "#2b2b3c" })
        -- vim.api.nvim_set_hl(0, "BlinkCmpDocBorder", { fg = "#565f89", bg = "#2b2b3c" })
        -- 配色2 类tokyonight
        vim.api.nvim_set_hl(0, "BlinkCmpMenu", { bg = "#191b28", fg = "#c0caf5" })
        vim.api.nvim_set_hl(0, "BlinkCmpDoc", { bg = "#191b28", fg = "#c0caf5" })
        vim.api.nvim_set_hl(0, "BlinkCmpMenuBorder", { fg = "#3d59a1", bg = "#191b28" })
        vim.api.nvim_set_hl(0, "BlinkCmpDocBorder", { fg = "#3d59a1", bg = "#191b28" })
        vim.api.nvim_set_hl(0, "BlinkCmpMenuSelection", { bg = "#7aa2f7", fg = "#191b28", bold = true })
      end

      vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
        callback = function()
          vim.schedule(set_blink_cmp_highlights)
        end,
      })
      vim.api.nvim_create_autocmd("User", {
        pattern = { "VeryLazy", "LazyVimStarted" },
        callback = function()
          vim.schedule(set_blink_cmp_highlights)
        end,
      })
      set_blink_cmp_highlights()
    end,

    opts = {
      snippets = { preset = "luasnip" },
      keymap = {
        preset = "default",
        ["<C-u>"] = { "scroll_documentation_up", "fallback" },
        ["<C-d>"] = { "scroll_documentation_down", "fallback" },
        ["<CR>"] = { "accept", "fallback" },
      },

      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        providers = {
          lsp = { name = "LSP" },
          path = { name = "Path" },
          snippets = { name = "Snip" },
          buffer = { name = "Buf" },
        },
      },

      completion = {
        trigger = { prefetch_on_insert = false },
        list = {
          selection = {
            preselect = true,
            auto_insert = false,
          },
        },

        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
          window = {
            border = "rounded",
            winblend = 0,
            winhighlight = "Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,EndOfBuffer:BlinkCmpDoc",
          },
        },

        menu = {
          border = "rounded",
          winblend = 0,
          winhighlight = "Normal:BlinkCmpMenu,FloatBorder:BlinkCmpMenuBorder,CursorLine:BlinkCmpMenuSelection,Search:None",

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
  {
    "zbirenbaum/copilot.lua",
    opts = function(_, opts)
      opts.copilot_node_command = vim.fn.expand("~/.local/bin/node-lsp-stable")
      opts.should_attach = function(bufnr, bufname)
        if vim.bo[bufnr].buftype ~= "" or not vim.bo[bufnr].modifiable then
          return false
        end

        if bufname == "" then
          return false
        end

        local stat = vim.uv.fs_stat(bufname)
        return not stat or stat.size <= 2 * 1024 * 1024
      end
    end,
  },
}
