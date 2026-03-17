-- keymaps are automatically loaded on the VeryLazy event
-- default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- add any additional keymaps here

-- 首先定义 keyset 和 opts
local keyset = vim.keymap.set
local opts = { silent = true, noremap = true, expr = true, replace_keycodes = false }

-- 基础设置
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.updatetime = 300

-- 安全地加载 compile 模块
local status_ok, compile = pcall(require, "config.compile")
if status_ok then
  keyset("n", "<F5>", compile.compile_current_file, { noremap = true, silent = false, desc = "Compile current file" })
else
  vim.notify("Warning: config.compile module not found", vim.log.levels.WARN)
end

-- 切换 Inlay Hints 显示/隐藏（修复 CocAction 大小写）
-- keyset("n", "<leader>h", ":call CocAction('toggleInlayHints')<CR>", { silent = true, noremap = true, desc = "Toggle inlay hints" })

-- 检查是否是空格（修复函数名大小写）
_G.CheckBackspace = function()
  local col = vim.fn.col(".") - 1
  return col == 0 or vim.fn.getline("."):sub(col, col):match("%s")
end

-- 诊断导航（使用函数包装避免弃用警告）
keyset("n", "-", function()
  vim.diagnostic.goto_prev({ float = { border = "rounded" } })
end, { desc = "Previous diagnostic" })

keyset("n", "=", function()
  vim.diagnostic.goto_next({ float = { border = "rounded" } })
end, { desc = "Next diagnostic" })
