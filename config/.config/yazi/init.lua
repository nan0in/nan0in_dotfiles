-- startship 
require("starship"):setup({
    config_file = "~/.config/yazi/starship.toml", -- 指定配置文件
    hide_flags = false,                      -- 是否隐藏 Yazi 的状态标志
    flags_after_prompt = true, 
})
require("full-border"):setup{
  type = ui.Border.ROUNDED,
}

require("git"):setup {}

Status:children_add(function()
  local h = cx.active.current.hovered
  if h == nil or ya.target_family() ~= "unix" then
    return ui.Line {}
  end

  return ui.Line {
    ui.Span(ya.user_name(h.cha.uid) or tostring(h.cha.uid)):fg("magenta"),
    ui.Span(":"),
    ui.Span(ya.group_name(h.cha.gid) or tostring(h.cha.gid)):fg("magenta"),
    ui.Span(" "),
}
end, 500, Status.RIGHT)
