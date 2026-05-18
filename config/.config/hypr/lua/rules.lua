-- Suppress maximize events
hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })

-- XWayland drag fix
hl.window_rule({ match = { float = true, xwayland = true }, no_focus = true })

-- hyprland-run position
hl.window_rule({ match = { class = "hyprland-run" }, float = true, move = { "20", "monitor_h-120" } })

-- Image viewers float + center
hl.window_rule({
  match = { class = "^(gwenview|swayimg)$" },
  float = true, center = true,
  size = { "(monitor_w*0.6)", "(monitor_h*0.6)" },
})

-- Fullscreen game confine pointer
hl.window_rule({ match = { content = "game", fullscreen = true }, confine_pointer = true })

-- ===== Layer rules (from ambxst) =====
hl.layer_rule({ match = { namespace = "quickshell" }, no_anim = true })
hl.layer_rule({ match = { namespace = "quickshell" }, blur = true })
hl.layer_rule({ match = { namespace = "quickshell" }, blur_popups = true })
hl.layer_rule({ match = { namespace = "selection"  }, no_anim = true })
hl.layer_rule({ match = { namespace = "fabric"     }, blur = true })
hl.layer_rule({ match = { namespace = "ambxst"     }, no_anim = true, blur = true, blur_popups = true })
hl.layer_rule({ match = { namespace = "overview"   }, no_anim = true, blur = true, blur_popups = true })
hl.layer_rule({ match = { namespace = "presets"    }, no_anim = true, blur = true, blur_popups = true })
