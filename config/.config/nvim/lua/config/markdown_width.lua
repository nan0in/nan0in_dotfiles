-- Markdown 文本区固定 200 列（纯视觉，不改文件内容）
--
-- 为什么不能直接设个选项：
--   Neovim 的软换行 'wrap' 是布尔的，只能按「窗口文本区宽度」折行，没有「折在第 N 列」这种设置；
--   而且它按屏幕列算，一个汉字占 2 列（80 列窗口一行只放得下 40 个汉字）。
--   用 extmark 往行里塞虚拟 "\n" 也不行——渲染出来是 ^@ 一个 NUL，不会断行。
-- 所以这里换个思路：把窗口本身的文本区缩到 200 列，右边开一个不可用的留白窗口吃掉多余宽度。
-- 打开 markdown 自动生效，离开自动还原。
--
-- 注意：窗口宽度 ≠ 文本区宽度，行号 / 符号列 / 折叠列要占地方，
-- 用 getwininfo().textoff 补回来，才能保证文本区正好是 TARGET 列。

local M = {}

local TARGET = 200 -- 目标文本区列数

local state = {} -- [tabpage] = { edit = 编辑窗, pad = 留白窗, saved_fix = 原来的 winfixwidth }
local busy = false -- 自己开关窗口时抑制连锁触发的 BufEnter

local function textoff(win)
  local info = vim.fn.getwininfo(win)[1]
  return info and info.textoff or 0
end

-- 编辑窗所在那一行横向一共有多宽（含左树等同行的兄弟窗口和竖直分隔线）
local function row_width(win)
  local infos = vim.fn.getwininfo()
  local row, total, n
  for _, i in ipairs(infos) do
    if i.winid == win then
      row = i.winrow
      break
    end
  end
  if not row then
    return vim.o.columns
  end
  total, n = 0, 0
  for _, i in ipairs(infos) do
    if i.winrow == row then
      total = total + i.width
      n = n + 1
    end
  end
  return total + (n - 1)
end

-- 留白缓冲区：铺满真实空行，否则窗口里会是一整屏 ~
local function pad_buffer()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.fn["repeat"]({ "" }, 500))
  vim.b[buf].md_width_pad = true
  return buf
end

local function restore(win, saved_fix)
  if vim.api.nvim_win_is_valid(win) then
    pcall(function()
      vim.wo[win].winfixwidth = saved_fix
    end)
  end
end

-- 关掉留白、把编辑窗恢复原样
local function clear(tab)
  local s = state[tab]
  state[tab] = nil
  if not s then
    return
  end
  busy = true
  pcall(function()
    -- 确认它还是我们的留白窗再关；万一被拿去装别的 buffer 了就不能动
    if
      vim.api.nvim_win_is_valid(s.pad)
      and vim.b[vim.api.nvim_win_get_buf(s.pad)].md_width_pad
    then
      vim.api.nvim_win_close(s.pad, true)
    end
    restore(s.edit, s.saved_fix)
  end)
  busy = false
end

local function setup(win)
  local tab = vim.api.nvim_win_get_tabpage(win)
  if state[tab] or busy then
    return
  end
  -- 浮动窗口、终端、以及用户自己关掉软换行的情况都不插手
  if vim.api.nvim_win_get_config(win).relative ~= "" then
    return
  end
  if not vim.wo[win].wrap then
    return
  end

  local target = TARGET + textoff(win)
  if vim.api.nvim_win_get_width(win) <= target then
    return -- 本来就比 200 列窄，不用折腾
  end

  local saved_fix = vim.wo[win].winfixwidth
  -- 建留白窗之前，这一行里属于别人的宽度（左树等同排窗口 + 分隔线）。
  -- 后面判断还放不放得下时用它兜底，保证不靠挤占文件树来凑 200 列。
  local sib = row_width(win) - vim.api.nvim_win_get_width(win)
  local prev = vim.api.nvim_get_current_win()
  local pad, tmp

  local ok = pcall(function()
    vim.api.nvim_set_current_win(win)
    vim.cmd("botright vnew")
    pad = vim.api.nvim_get_current_win()
    tmp = vim.api.nvim_get_current_buf()
    vim.api.nvim_win_set_buf(pad, pad_buffer())
    -- :vnew 会顺带建一个空缓冲区，不删掉会一直挂在 buffer 列表里
    pcall(vim.api.nvim_buf_delete, tmp, { force = true })
    tmp = nil

    vim.wo[pad].number = false
    vim.wo[pad].relativenumber = false
    vim.wo[pad].signcolumn = "no"
    vim.wo[pad].foldcolumn = "0"
    vim.wo[pad].list = false
    vim.wo[pad].spell = false
    vim.wo[pad].cursorline = false
    vim.wo[pad].winbar = ""

    -- 先把编辑窗缩到目标宽度；winfixwidth 必须在这之后设，否则缩不动
    vim.api.nvim_win_set_width(win, target)
    assert(vim.api.nvim_win_get_width(win) == target, "空间不足")
    -- 编辑窗钉死 200 列；留白窗故意不钉，让它继续当缓冲区，
    -- 否则终端缩小时它不让位，宽度缺口会转嫁到左边的文件树上
    vim.wo[win].winfixwidth = true
  end)

  busy = true
  pcall(vim.api.nvim_set_current_win, vim.api.nvim_win_is_valid(prev) and prev or win)
  busy = false

  if ok then
    state[tab] = { edit = win, pad = pad, saved_fix = saved_fix, sib = sib }
    return
  end

  -- 放不下就完全回退
  if pad and vim.api.nvim_win_is_valid(pad) then
    pcall(vim.api.nvim_win_close, pad, true)
  end
  if tmp then
    pcall(vim.api.nvim_buf_delete, tmp, { force = true })
  end
  restore(win, saved_fix)
end

-- 手动开关（默认不需要，留个后路）
function M.toggle()
  local win = vim.api.nvim_get_current_win()
  local tab = vim.api.nvim_win_get_tabpage(win)
  if state[tab] then
    clear(tab)
  else
    setup(win)
  end
end

local group = vim.api.nvim_create_augroup("md_text_width", { clear = true })

vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
  group = group,
  callback = function()
    if busy then
      return
    end
    local win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_get_current_buf()
    if vim.b[buf].md_width_pad then
      return -- 光标跑到留白窗口里了，什么都不做
    end
    local tab = vim.api.nvim_win_get_tabpage(win)
    local s = state[tab]
    if s and s.pad == win then
      -- 留白窗被拿去装别的 buffer 了，解除跟踪并还原编辑窗，但不动这个窗口
      state[tab] = nil
      restore(s.edit, s.saved_fix)
      return
    end
    if vim.bo[buf].filetype == "markdown" and vim.bo[buf].buftype == "" then
      setup(win)
    elseif state[tab] and state[tab].edit == win then
      clear(tab)
    end
  end,
})

-- 终端或窗口尺寸变了：行号列宽也会变，重新对一次
vim.api.nvim_create_autocmd("VimResized", {
  group = group,
  callback = function()
    for tab, s in pairs(state) do
      if vim.api.nvim_win_is_valid(s.edit) and vim.api.nvim_win_is_valid(s.pad) then
        local target = TARGET + textoff(s.edit)
        -- 扣掉兄弟窗口占的地盘后，还得放得下「目标宽度 + 分隔线 + 1 列留白」，
        -- 否则整体让位，不去挤文件树
        local ok = (row_width(s.edit) - (s.sib or 0)) >= target + 2
          and pcall(vim.api.nvim_win_set_width, s.edit, target)
          and vim.api.nvim_win_get_width(s.edit) == target
        if not ok then
          clear(tab)
        end
      else
        clear(tab)
      end
    end
  end,
})

-- 任一侧窗口被关掉都要收尾，免得留下孤立的留白窗
vim.api.nvim_create_autocmd("WinClosed", {
  group = group,
  callback = function(args)
    local closed = tonumber(args.match)
    for tab, s in pairs(state) do
      if s.pad == closed or s.edit == closed then
        clear(tab)
      end
    end
  end,
})

vim.api.nvim_create_user_command("MdWidth", function()
  M.toggle()
end, { desc = "切换 Markdown 200 列文本区" })

return M
