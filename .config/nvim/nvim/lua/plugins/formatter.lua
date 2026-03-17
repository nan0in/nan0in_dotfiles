return {
  "mhartington/formatter.nvim",
  config = function()
    -- 预定义一个辅助函数，方便自定义 Verilog 等特殊格式化工具
    local util = require("formatter.util")

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
        javascriptreact = { require("formatter.filetypes.javascript").prettier },
        typescriptreact = { require("formatter.filetypes.typescript").prettier },
        vue = { require("formatter.filetypes.vue").prettier },
        svelte = { require("formatter.filetypes.svelte").prettier }, 
        css = { require("formatter.filetypes.css").prettier },
        scss = { require("formatter.filetypes.css").prettier },     
        html = { require("formatter.filetypes.html").prettier },
        json = { require("formatter.filetypes.json").prettier },
        jsonc = { require("formatter.filetypes.json").prettier },    
        yaml = { require("formatter.filetypes.yaml").prettier },
        toml = { require("formatter.filetypes.toml").taplo },        -- 新增 TOML (Rust/Python 常用)
        xml = { require("formatter.filetypes.xml").xmlformat },      -- 新增 XML
        markdown = { require("formatter.filetypes.markdown").prettier },
        graphql = { require("formatter.filetypes.graphql").prettier },
        rust = { require("formatter.filetypes.rust").rustfmt },
        go = {
          require("formatter.filetypes.go").gofmt,
          require("formatter.filetypes.go").goimports,
        },
        -- Shell 脚本
        sh = { require("formatter.filetypes.sh").shfmt },
        zsh = { require("formatter.filetypes.sh").shfmt }, -- 显式支持 zsh
        c = {
          function()
            return {
              exe = "clang-format",
              args = { "--style=Google" }, -- 可以在这里改成 LLVM, Mozilla, Chromium 等
              stdin = true,
            }
          end,
        },
        cpp = {
          require("formatter.filetypes.cpp").clangformat,
        },
        
        cmake = { require("formatter.filetypes.cmake").cmake_format },
        verilog = {
          function()
            return {
              exe = "verible-verilog-format",
              args = { "-" },
              stdin = true,
            }
          end,
        },
        systemverilog = {
          function()
            return {
              exe = "verible-verilog-format",
              args = { "-" },
              stdin = true,
            }
          end,
        },
        asm = {
          function()
            return {
              exe = "asmfmt",
              stdin = true,
            }
          end,
        },
        sql = { require("formatter.filetypes.sql").pgformat }, -- 或者 sqlformat
        terraform = { require("formatter.filetypes.terraform").terraformfmt },
        ["*"] = {
          require("formatter.filetypes.any").remove_trailing_whitespace,
        },
      },
    })

    vim.keymap.set("n", "<leader>f", "<cmd>Format<CR>", { desc = "Format buffer" })
    vim.keymap.set("n", "<leader>F", "<cmd>FormatWrite<CR>", { desc = "Format and save" })
  end,
}
