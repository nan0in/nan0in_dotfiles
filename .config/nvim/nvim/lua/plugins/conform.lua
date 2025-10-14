return {
  "stevearc/conform.nvim",
  optional = true,
  opts = {
    -- 禁用保存时自动格式化
    format_on_save = false,

    formatters_by_ft = {
      ["python"] = { "autopep8" },
      ["css"] = { "prettier" },
      ["html"] = { "html-lsp" },
      ["htmldjango"] = { "html-lsp" },
      ["c"] = { "clang-format" },
      ["cpp"] = { "clang-format" },
    },
  },

  config = function(_, opts)
    require("conform").setup(opts)

    -- 设置 Ctrl+Alt+s 手动格式化并保存
    vim.keymap.set({ "n", "v" }, "<C-A-s>", function()
      require("conform").format({ async = false, lsp_fallback = true })
      vim.cmd("w")  -- 格式化后保存
    end, { desc = "Format and save" })

    -- 正常的 :w 保存不会触发格式化
    vim.keymap.set("n", "<C-s>", ":w<CR>", { desc = "Save without formatting" })
  end,
}
