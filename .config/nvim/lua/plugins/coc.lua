local keyset = vim.keymap.set
local opts = { silent = true, noremap = true, expr = true, replace_keycodes = false }

-- Use 空格+h doHover to show documentation in preview window
function _G.show_docs()
  local cw = vim.fn.expand("<cword>")
  if vim.fn.index({ "vim", "help" }, vim.bo.filetype) >= 0 then
    vim.api.nvim_command("h " .. cw)
  elseif vim.api.nvim_eval("coc#rpc#ready()") then
    vim.fn.CocActionAsync("doHover")
  else
    vim.api.nvim_command("!" .. vim.o.keywordprg .. " " .. cw)
  end
end
keyset("n", "<leader>h", "<CMD>lua _G.show_docs()<CR>", { silent = true })

-- 检查前后文跳转错误
keyset("n", "-", "<Plug>(coc-diagnostic-prev)", opts)
keyset("n", "=", "<Plug>(coc-diagnostic-next)", opts)

-- GoTo code navigation 找到代码相关位置
keyset("n", "gd", "<Plug>(coc-definition)", opts)
keyset("n", "gy", "<Plug>(coc-type-definition)", opts)
keyset("n", "gi", "<Plug>(coc-implementation)", opts)
keyset("n", "gr", "<Plug>(coc-references)", opts)

-- 高光突出悬停
vim.api.nvim_create_augroup("CocGroup", {})
vim.api.nvim_create_autocmd("CursorHold", {
  group = "CocGroup",
  command = "silent call CocActionAsync('highlight')",
  desc = "Highlight symbol under cursor on CursorHold",
})

-- 使用ctrl f以及ctrl b滚动
---@diagnostic disable-next-line: redefined-local
local opts = { silent = true, nowait = true, expr = true }
keyset("n", "<C-f>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', opts)
keyset("n", "<C-b>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"', opts)
keyset("i", "<C-f>", 'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(1)<cr>" : "<Right>"', opts)
keyset("i", "<C-b>", 'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(0)<cr>" : "<Left>"', opts)
keyset("v", "<C-f>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', opts)
keyset("v", "<C-b>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"', opts)

return {
  { "neoclide/coc.nvim", branch = "release" },
}
