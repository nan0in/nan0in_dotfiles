return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- 1. clangd 配置
        clangd = {},
        pyright = {
          cmd = { "/home/nan0in27/.local/share/nvim/mason/bin/pyright-langserver", "--stdio" },
        },
      },
    },
  },
}
