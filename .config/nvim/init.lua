-- bootstrap lazy.nvim, LazyVim
-- 获取当前文件名（不带扩展名）
local function get_filename()
  return vim.fn.expand("%:r") -- %:r 去掉扩展名（如 main.cpp → main）
end

-- F5: 编译当前文件
vim.keymap.set("n", "<F5>", function()
  local filetype = vim.bo.filetype
  local filename = get_filename()
  if filetype == "cpp" then
    vim.cmd("!g++ -Wall -g % -o " .. filename)
  elseif filetype == "c" then
    vim.cmd("!gcc -Wall -g % -o " .. filename)
  end
  print("✅ 编译完成！可执行文件: ./" .. filename)
end, { noremap = true, silent = false })

-- 启用系统剪贴板
vim.opt.clipboard = "unnamedplus"

-- 映射 Ctrl+Shift+V 粘贴（插入模式）
vim.api.nvim_set_keymap("i", "<C-S-v>", "<C-r>+", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-S-v>", '"+p', { noremap = true, silent = true })
---

if vim.g.neovide then
  vim.g.neovide_theme = "auto"
  vim.g.neovide_cursor_vfx_mode = "torpedo"
  vim.o.guifont = "JetBrainsMono Nerd Font:h11"
end

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

-- themes --
vim.cmd([[colorscheme dracula]])
-- vim.cmd([[colorscheme catppuccin]])
-- vim.cmd([[colorscheme cyberdream]])
