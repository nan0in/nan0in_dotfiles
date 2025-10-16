return {
  "mhartington/formatter.nvim",
  config = function()
    require("formatter").setup({
      logging = true,
      log_level = vim.log.levels.WARN,

      filetype = {
        lua = { require("formatter.filetypes.lua").stylua },
        python = {
          require("formatter.filetypes.python").black,
          require("formatter.filetypes.python").isort,
        },
        javascript = { require("formatter.filetypes.javascript").prettier },
        typescript = { require("formatter.filetypes.typescript").prettier },
        vue = { require("formatter.filetypes.vue").prettier },
        css = { require("formatter.filetypes.css").prettier },
        html = { require("formatter.filetypes.html").prettier },
        json = { require("formatter.filetypes.json").prettier },
        yaml = { require("formatter.filetypes.yaml").prettier },
        markdown = { require("formatter.filetypes.markdown").prettier },
        rust = { require("formatter.filetypes.rust").rustfmt },
        go = {
          require("formatter.filetypes.go").gofmt,
          require("formatter.filetypes.go").goimports,
        },
        sh = { require("formatter.filetypes.sh").shfmt },
        c = {
          require("formatter.filetypes.c").clangformat,
        },
        cpp = {
          require("formatter.filetypes.cpp").clangformat,
        },
      },
    })

    -- 快捷键
    vim.keymap.set("n", "<leader>f", "<cmd>Format<CR>", { desc = "Format buffer" })
    vim.keymap.set("n", "<leader>F", "<cmd>FormatWrite<CR>", { desc = "Format and save" })
  end,
}
