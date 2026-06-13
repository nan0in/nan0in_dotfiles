hl.window_rule({
  name = "suppress-maximize-events",
  match = { class = ".*" },
  suppress_event = "maximize",
})

hl.window_rule({
  name = "fix-xwayland-drags",
  match = {
    class = "^$",
    title = "^$",
    xwayland = true,
    float = true,
    fullscreen = false,
    pin = false,
  },
  no_focus = true,
})

hl.window_rule({
  name = "move-hyprland-run",
  match = { class = "hyprland-run" },
  move = { "20", "monitor_h-120" },
  float = true,
})

hl.window_rule({
  name = "picture-viewer",
  match = { class = "^(gwenview|swayimg)$" },
  float = true,
  center = true,
  size = { "(monitor_w*0.6)", "(monitor_h*0.6)" },
})

hl.window_rule({
  name = "confine-game-pointer",
  match = {
    content = "game",
    fullscreen = true,
  },
  confine_pointer = true,
})
