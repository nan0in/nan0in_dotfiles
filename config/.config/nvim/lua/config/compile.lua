local M = {}

function M.get_filename()
  return vim.fn.expand("%:r")
end

function M.compile_current_file()
  local filetype = vim.bo.filetype
  local filename = M.get_filename()
  
  if filetype == "cpp" then
    vim.cmd("!g++ -Wall -g % -o " .. filename)
  elseif filetype == "c" then
    vim.cmd("!gcc -Wall -g % -o " .. filename)
  elseif filetype == "rust" then
    vim.cmd("!rustc % -o " .. filename)
  elseif filetype == "python" then
    vim.cmd("!python %")
    print("🐍 Python 文件运行!")
    return
  else
    print("❌ 不支持的文件类型: " .. filetype)
    return
  end
  
  print("✅ 编译完成！可执行文件: ./" .. filename)
end

return M
