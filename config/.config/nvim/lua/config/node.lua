local M = {}

local function node_major(command)
  local version = vim.fn.system({ command, "--version" })
  if vim.v.shell_error ~= 0 then
    return nil
  end

  return tonumber(version:match("v?(%d+)"))
end

function M.command()
  local candidates = {
    vim.fn.expand("~/.local/bin/node-lsp-stable"),
    vim.fn.exepath("node"),
    "/usr/bin/node",
  }

  for _, command in ipairs(candidates) do
    if command ~= "" and vim.fn.executable(command) == 1 then
      local major = node_major(command)
      if major and major >= 22 then
        return command
      end
    end
  end

  return "node"
end

return M
