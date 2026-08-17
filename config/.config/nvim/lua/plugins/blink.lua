return {
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        ["<C-Space>"] = { "show" },
      },
      completion = {
        menu = {
          auto_show = true,
          border = "rounded",
          winhighlight = "Normal:Pmenu,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
        },
        documentation = {
          window = {
            border = "rounded",
            winblend = 0,
            winhighlight = "Normal:Pmenu,FloatBorder:FloatBorder,EndOfBuffer:Pmenu",
          },
        },
        trigger = {
          show_on_insert = true,
        },
      },
      signature = {
        enabled = true,
        window = {
          border = "rounded",
          winblend = 0,
          winhighlight = "Normal:Pmenu,FloatBorder:FloatBorder,EndOfBuffer:Pmenu",
        },
      },
    },
  },
}
