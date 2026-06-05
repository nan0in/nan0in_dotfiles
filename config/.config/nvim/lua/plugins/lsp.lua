return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {
          settings = {
            python = {
              analysis = {
                reportPossiblyUnboundVariable = "none",
              },
            },
          },
        },
        clangd = {
          capabilities = {
            offsetEncoding = "utf-8",
          },
          settings = {
            clangd = {
              -- 启用这些功能
              fallbackFlags = { "-std=c17" },
              index = {
                -- 启用索引
                background = true,
              },
              -- 启用交叉引用
              crossFileReferences = true,
              -- 启用调用层次结构
              callHierarchy = true,
              -- 启用类型层次结构
              typeHierarchy = true,
            },
          },
        },
      },
    },
  },
}
