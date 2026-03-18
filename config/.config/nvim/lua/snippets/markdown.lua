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

  -- === Hugo Admonition Shortcodes ===

  -- 摘要 (abstract)
  s("abstract", {
    t('{{< admonition type=abstract title="'), i(1, "摘要"), t('" open=false >}}'),
    t({ "", "" }), i(2, "内容"),
    t({ "", "{{< /admonition >}}" }),
  }),

  -- Bug
  s("bug", {
    t('{{< admonition type=bug title="'), i(1, "bug"), t('" open=false >}}'),
    t({ "", "" }), i(2, "内容"),
    t({ "", "{{< /admonition >}}" }),
  }),

  -- 范例 (example)
  s("example", {
    t('{{< admonition type=example title="'), i(1, "范例"), t('" open=false >}}'),
    t({ "", "" }), i(2, "内容"),
    t({ "", "{{< /admonition >}}" }),
  }),

  -- 失败 (failure)
  s("failure", {
    t('{{< admonition type=failure title="'), i(1, "失败"), t('" open=false >}}'),
    t({ "", "" }), i(2, "内容"),
    t({ "", "{{< /admonition >}}" }),
  }),

  -- 讯息 (info)
  s("hinfo", {
    t('{{< admonition type=info title="'), i(1, "讯息"), t('" open=false >}}'),
    t({ "", "" }), i(2, "内容"),
    t({ "", "{{< /admonition >}}" }),
  }),

  -- 网站 (node)
  s("node", {
    t('{{< admonition type=node title="'), i(1, "網站"), t('" open=false >}}'),
    t({ "", "" }), i(2, "内容"),
    t({ "", "{{< /admonition >}}" }),
  }),

  -- 问题 (question)
  s("question", {
    t('{{< admonition type=question title="'), i(1, "问题"), t('" open=false >}}'),
    t({ "", "" }), i(2, "内容"),
    t({ "", "{{< /admonition >}}" }),
  }),

  -- 引用 (quote)
  s("hquote", {
    t('{{< admonition type=quote title="'), i(1, "引用"), t('" open=false >}}'),
    t({ "", "" }), i(2, "内容"),
    t({ "", "{{< /admonition >}}" }),
  }),

  -- 成功 (success)
  s("success", {
    t('{{< admonition type=success title="'), i(1, "成功"), t('" open=false >}}'),
    t({ "", "" }), i(2, "内容"),
    t({ "", "{{< /admonition >}}" }),
  }),

  -- 提示 (htip - Hugo admonition)
  s("htip", {
    t('{{< admonition type=tip title="'), i(1, "提示"), t('" open=false >}}'),
    t({ "", "" }), i(2, "内容"),
    t({ "", "{{< /admonition >}}" }),
  }),

  -- 警告 (hwarn - Hugo admonition)
  s("hwarn", {
    t('{{< admonition type=warning title="'), i(1, "警告"), t('" open=false >}}'),
    t({ "", "" }), i(2, "内容"),
    t({ "", "{{< /admonition >}}" }),
  }),

  -- === Hugo 特殊 Shortcodes ===

  -- 聊天气泡 (chat)
  s("chat", {
    t('{{< chat position="'), i(1, "left"), t('" name="'), i(2, "Name"), t('" timestamp="'), i(3, "2024-01-01 12:00"), t('">}}'),
    t({ "", "" }), i(4, "消息内容"),
    t({ "", "{{< /chat >}}" }),
  }),

  -- 时间线 (timeline)
  s("timeline", {
    t('{{< timeline date="'), i(1, "2024-01-01"), t('" title="'), i(2, "标题"),
    t('" description="'), i(3, "描述"), t('" tags="'), i(4, "标签"),
    t('" url="'), i(5), t('" >}}'),
  }),

  -- 折叠块 Hugo版 (details)
  s("details", {
    t("{{< details >}}"),
    t({ "", "" }), i(1, "内容"),
    t({ "", "{{< /details >}}" }),
  }),

  -- 文件下载链接 (download)
  s("download", {
    t('<a href="'), i(1, "/downloads/example.pdf"), t('" download>下载 '), i(2, "example"), t("</a>"),
  }),

  -- 文章 frontmatter 模板 (front)
  s("front", {
    t({ "---", "title: " }), i(1, "标题"),
    t({ "", "description: " }), i(2, "描述"),
    t({ "", "featured: false", "categories:", "  - " }), i(3, "分类"),
    t({ "", "math: true", "tags:", "  - " }), i(4, "标签"),
    t({ "", "date: " }), i(5),
    t({ "", "image: banner.png", "---" }),
  }),

})

