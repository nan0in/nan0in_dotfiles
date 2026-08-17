-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
vim.api.nvim_create_autocmd("FileType", {
  pattern ={"lua","markdown","gitcommit"},
  callback = function()
    vim.opt_local.textwidth = 0 -- 自动换行的长度，0为不自动换行
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.spell = false -- 覆盖默认true,即拼写检查
    vim.opt_local.wrap = true
  end,
})

-- 记住上次编辑位置
local lastplace = vim.api.nvim_create_augroup("LastPlace", { clear = true })
vim.api.nvim_create_autocmd("BufReadPost", {
  group = lastplace,
  pattern = "*",
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

