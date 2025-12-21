vim.opt.tags = './tags;,tags;'
vim.o.cmdheight = 0 -- 显示命令行区域

-- 映射 Ctrl+Shift+V 粘贴（插入模式）
vim.api.nvim_set_keymap("i", "<C-S-v>", "<C-r>+", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-S-v>", '"+p', { noremap = true, silent = true })
---

require("config.lazy")

vim.opt.spelllang = "en,cjk" -- 允许中英文混合
-- 禁用标点风格检查
vim.g.vim_markdown_strikethrough = 0 -- 如果使用 vim-markdown 插件

-- 补全
require("mini.pairs").setup({
  mappings = {
    ['"'] = { action = "closeopen", pair = '""', neigh_pattern = '[^\\"].*[^\\]"' },
    ["'"] = { action = "closeopen", pair = "''", neigh_pattern = "[^\\'].*[^\\]'" },
  },
})

vim.diagnostic.config({
  virtual_text = false, -- 可以为 false，如果你不想让虚拟文字干扰代码行
})

--- 设置粘贴板
vim.cmd([[set clipboard=unnamedplus]])
-- themes --
-- vim.cmd([[colorscheme tokyonight]])
