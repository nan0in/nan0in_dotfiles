-- One formatting backend: LazyVim's Conform integration.
-- Automatic formatting remains controlled by vim.g.autoformat / vim.b.autoformat.
local function format(args, write)
  local bufnr = vim.api.nvim_get_current_buf()
  local range
  if args and args.range and args.range > 0 then
    local last = vim.api.nvim_buf_get_lines(bufnr, args.line2 - 1, args.line2, true)[1] or ""
    range = { start = { args.line1, 0 }, ["end"] = { args.line2, #last } }
  end
  require("conform").format({ bufnr = bufnr, range = range, async = false }, function(err)
    if write and not err and vim.api.nvim_buf_is_valid(bufnr) then
      vim.api.nvim_buf_call(bufnr, function()
        -- Avoid formatting a second time if autoformat is enabled later.
        local autoformat = vim.b.autoformat
        vim.b.autoformat = false
        local ok, message = pcall(vim.cmd.write)
        vim.b.autoformat = autoformat
        if not ok then
          vim.notify(tostring(message), vim.log.levels.ERROR)
        end
      end)
    end
  end)
end

return {
  { "mhartington/formatter.nvim", enabled = false },
  {
    "stevearc/conform.nvim",
    cmd = { "ConformInfo", "Format", "FormatWrite" },
    keys = {
      {
        "<leader>f",
        function()
          format()
        end,
        mode = { "n", "x" },
        desc = "Format buffer / selection",
      },
      {
        "<leader>F",
        function()
          format(nil, true)
        end,
        desc = "Format and save",
      },
    },
    opts = function(_, opts)
      opts.default_format_opts = vim.tbl_deep_extend("force", opts.default_format_opts or {}, {
        timeout_ms = 5000,
        async = false,
        lsp_format = "fallback",
      })
      opts.notify_on_error = true
      opts.notify_no_formatters = true
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      local by_ft = {
        lua = { "stylua" },
        python = { "isort", "black" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        vue = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        less = { "prettier" },
        html = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        ["markdown.mdx"] = { "prettier" },
        graphql = { "prettier" },
        rust = { "rustfmt" },
        go = { "goimports", "gofmt" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        c = { "clang_format" },
        cpp = { "clang_format" },
        objc = { "clang_format" },
        objcpp = { "clang_format" },
        toml = { "taplo" },
        cmake = { "cmake_format" },
        haskell = { "fourmolu" },
      }
      -- Replace individual pipelines rather than merging list indices from extras.
      for ft, formatters in pairs(by_ft) do
        opts.formatters_by_ft[ft] = formatters
      end
      opts.formatters = opts.formatters or {}
      opts.formatters.isort = vim.tbl_deep_extend("force", opts.formatters.isort or {}, {
        prepend_args = { "--profile", "black" },
      })
      -- Keep Conform's built-in project-local executable/config discovery.
      -- In particular, do not force shell (shfmt) formatting on zsh files.
      vim.api.nvim_create_user_command("Format", function(args)
        format(args)
      end, { range = true, desc = "Format buffer or range with Conform" })
      vim.api.nvim_create_user_command("FormatWrite", function(args)
        format(args, true)
      end, { range = true, desc = "Format then save with Conform" })
    end,
  },
}
