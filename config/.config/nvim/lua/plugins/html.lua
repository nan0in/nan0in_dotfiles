return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        html = {
          filetypes = { "html" },
          settings = {
            html = {},
            css = {},
            javascript = {},
          },
          init_options = {
            configurationSection = { "html", "css", "javascript" },
            embeddedLanguages = {
              css = true,
              javascript = true,
            },
            provideFormatter = true,
          },
        },
      },
    },
  },
}
