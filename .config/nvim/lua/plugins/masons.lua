return {
  {
    "mason-org/mason.nvim",
    enabled=false,
    build = ":MasonUpdate",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    enabled=false,
    dependencies = { "mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {}, -- 不自动下载
        automatic_installation = false, -- 关闭自动安装
      })
    end,
  },
}
