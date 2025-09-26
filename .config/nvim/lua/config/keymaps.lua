-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

--- 调用compile模块
local compile = require("config.compile")
vim.keymap.set("n", "<F5>", compile.compile_current_file, { noremap = true, silent = false })
-- 切换 Inlay Hints 显示/隐藏
-- map("n", "<leader>h", ":call CocAction('toggleInlayHints')<CR>", opts)
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.updatetime = 300
local keyset = vim.keymap.set

-- 检查是否是空格
_G.CheckBackspace = function()
  local col = vim.fn.col(".") - 1
  return col == 0 or vim.fn.getline("."):sub(col, col):match("%s")
end

--" Use `-` and `=` 寻找上下报错信息处
--" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list
keyset("n", "-", "<Plug>(coc-diagnostic-prev)", { silent = true })
keyset("n", "=", "<Plug>(coc-diagnostic-next)", { silent = true })


