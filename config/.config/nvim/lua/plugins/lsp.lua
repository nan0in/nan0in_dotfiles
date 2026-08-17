return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {
          cmd = {
            require("config.node").command(),
            vim.fn.expand("~/.local/share/nvim/mason/packages/pyright/node_modules/pyright/langserver.index.js"),
            "--stdio",
          },
          settings = {
            python = {
              analysis = {
                diagnosticSeverityOverrides = {
                  reportPossiblyUnboundVariable = "none",
                  reportOptionalMemberAccess = "none",
                },
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

        lua_ls = {
          settings = {
            Lua = {
              completion = { callSnippet = "Replace" },
              diagnostics = { globals = { "vim" } },
              workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
              },
              telemetry = { enable = false },
            },
          },
        },
        -- JSON 支持注释
        jsonls = {
          settings = {
            json = {
              schemas = {},
              validate = { enable = true },
            },
          },
        },
        -- YAML
        yamlls = {
          settings = {
            yaml = {
              keyOrdering = false,
            },
          },
        },
        -- Bash/Shell
        bashls = {},
        -- Dockerfile
        dockerls = {},
      },
    },
  },
}
