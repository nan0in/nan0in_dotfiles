return {
  -- Minuet AI 配置
  {
    "milanglacier/minuet-ai.nvim",
    enabled = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "Saghen/blink.cmp",
    },
    config = function()
      require("minuet").setup({
        n_completions = 1,
        provider = "openai", -- 需要指定提供商
        provider_options = {
          openai = {
            api_key = "OPENAI_API_KEY", -- 使用环境变量
            end_point = "https://llm.imsy.cc/v1/chat/completions", -- 使用 chat/completions 端点
            model = "gpt-4o",
            stream = true, -- 添加流式传输
            -- 可选参数
            optional = {
              max_tokens = 256,
              top_p = 0.9,
            },
            -- 自定义 prompt 函数
            prompt = function(context_before_cursor, context_after_cursor, _)
              local prompt_message = ""

              -- 检查是否有 vectorcode 配置
              local has_vc, vectorcode_config = pcall(require, "vectorcode.config")
              local vectorcode_cacher = nil
              if has_vc then
                vectorcode_cacher = vectorcode_config.get_cacher_backend()
                for _, file in ipairs(vectorcode_cacher.get_files()) do
                  prompt_message = prompt_message .. "<|file_sep|>" .. file.path .. "\n" .. file.document
                end
              end
              return prompt_message
                .. "<|file_prefix|>\n"
                .. context_before_cursor
                .. "<|fim_suffix|>"
                .. context_after_cursor
                .. "<|fim_middle|>"
            end,
            suffix = false,
          },
        },
        -- 添加前端配置
        blink = {
          enable_auto_complete = true,
        },
        request_timeout = 15,
      })
    end,
  },
  -- blink.cmp 配置
  {
    "saghen/blink.cmp",
    -- enabled=false,
    dependencies = {
      -- "milanglacier/minuet-ai.nvim", -- 明确声明依赖
    },
    event = { "BufReadPost", "BufNewFile" },
    version = "1.*",
    opts = {
      completion = {
        documentation = {
          auto_show = true,
        },
        trigger = {
          prefetch_on_insert = false,
        },
      },
      keymap = {
        ["<C-u>"] = { "scroll_documentation_up", "fallback" },
        ["<C-d>"] = { "scroll_documentation_down", "fallback" },
        -- Alt+y => 手动触发 Minuet
        -- ["<A-y>"] = {
        --   function()
        --     if pcall(require, "minuet") then
        --       return require("minuet").make_blink_map()
        --     end
        --     return nil
        --   end,
        --   "fallback",
        -- },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer", },
        -- providers = {
        --   minuet = {
        --     name = "minuet",
        --     module = "minuet.blink",
        --     async = true,
        --     timeout_ms = 3000,
        --     score_offset = 50, -- 提升 Minuet 优先级
        --   },
        -- },
      },
      signature = { enabled = true },
    },
  },
}
