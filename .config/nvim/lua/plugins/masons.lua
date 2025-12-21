return {
  {
    "mason-org/mason.nvim",
    -- enabled=false,
    build = ":MasonUpdate",
    config = function()
      require("mason").setup({
        automatic_enable={
          exclude={
            marksman,
          }
        }
 
      })
    end,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    enabled=false,
    dependencies = { "mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls" },
        automatic_enable={
          exclude={
            marksman,
          }
        }
      })
    end,
  },
}
