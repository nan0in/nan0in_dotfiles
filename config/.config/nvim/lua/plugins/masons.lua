return {
  {
    "mason-org/mason.nvim",
    -- enabled=false,
    build = ":MasonUpdate",
    config = function()
      require("mason").setup({
        automatic_enable={
          exclude={
            "marksman",
            "rust_analyzer",
          }
        }
 
      })
    end,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls","html", "cssls", "jsonls" },
        automatic_enable={
          exclude={
            "marksman",
            "rust_analyzer",
          }
        }
      })
    end,
  },
}
