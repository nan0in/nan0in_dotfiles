-- lua/snippets/markdown.lua
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

-- 必须通过 add_snippets 添加，而不是直接 return table
ls.add_snippets("markdown", {

  -- 3. 任务列表 (task -> - [ ] ...)
  s("task", {
    t("- [ ] "), i(1, "Todo item"),
  }),

  -- 4. 快速表格 3列 (tb -> 生成表格骨架)
  s("tb", {
    t("| "), i(1, "Title1"), t(" | "), i(2, "Title2"), t(" | "), i(3, "Title3"), t(" |"),
    t({ "", "| :--- | :--- | :--- |", "" }), -- 自动生成分割线
    t("| "), i(4, "Data1"), t(" | "), i(5, "Data2"), t(" | "), i(6, "Data3"), t(" |"),
  }),

  -- 5. 折叠块/手风琴 (fold -> <details>...)
  s("fold", {
    t("<details>"),
    t({ "", "  <summary>" }), i(1, "点击展开查看"), t("</summary>"),
    t({ "", "", "  " }), i(2, "隐藏的内容..."),
    t({ "", "", "</details>" }),
  }),

  -- === 下面是更多的 Callout 警告块 (GitHub/Obsidian 风格) ===
  
  -- 提示 (tip -> > [!TIP])
  s("tip", {
    t("> [!TIP]"),
    t({ "", "> " }), i(1, "这里是个小技巧..."),
  }),

  -- 警告 (warn -> > [!WARNING])
  s("warn", {
    t("> [!WARNING]"),
    t({ "", "> " }), i(1, "注意安全..."),
  }),

  -- 错误 (err -> > [!CAUTION])
  s("err", {
    t("> [!CAUTION]"),
    t({ "", "> " }), i(1, "这里有严重错误..."),
  }),

  -- 重要 (imp -> > [!IMPORTANT])
  s("imp", {
    t("> [!IMPORTANT]"),
    t({ "", "> " }), i(1, "重要信息..."),
  }),
  -- 示例：输入 note 按 Tab 变 Callout
  s("note", {
    t("> [!NOTE]"),
    t({ "", "> " }),
    i(1, "Content..."),
  }),
  -- 1. 图片插入 (img -> ![alt](url))
  s("img", {
    t("!["), i(1, "Alt text"), t("]("), i(2, "image_url"), t(")"),
  }),

  -- === 下面是更多的 Callout，兼容hugo用的  ===
   s("hnote", {
    t({ "{{< notice notice-note>}}", "" }),
    i(1, "内容"),
    t({ "", "{{< /notice >}}" }),
  }),

   s("htip", {
    t({ "{{< notice notice-tip>}}", "" }),
    i(1, "内容"),
    t({ "", "{{< /notice >}}" }),
  }),

   s("hwarn", {
    t({ "{{< notice notice-warning >}}", "" }),
    i(1, "内容"),
    t({ "", "{{< /notice >}}" }),
  }),

  -- Info Notice
  s("hinfo", {
    t({ "{{< notice notice-info >}}", "" }),
    i(1, "内容"),
    t({ "", "{{< /notice >}}" }),
  }),
})

