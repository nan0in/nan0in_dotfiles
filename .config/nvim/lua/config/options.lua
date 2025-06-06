-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
local opt = vim.opt
local g = vim.g

-- Chinese in vim
opt.encoding = "utf-8"
opt.fileencodings = { "utf-8", "gbk", "gb18030", "gb2312" }

-- faster updates (默认 4000ms，这里设置为 100ms)
opt.updatetime = 100

-- 减少解释信息
opt.shortmess:append("c")

-- 补全菜单高度
opt.pumheight = 5

-- 系统剪贴板支持
opt.clipboard = "unnamedplus"

-- 语法高亮
opt.syntax = "on"

local function augroup(name)
  return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end

-- wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("wrap_spell"),
  pattern = { "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = false -- 覆盖默认的 true
  end,
})
