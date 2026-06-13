hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 20,
        border_size = 2,
        col = {
            active_border = {
                colors = { "rgba(444693ff)", "rgba(2a5caaff)" },
                angle = 45
            },
            inactive_border = "rgba(595959aa)"  -- 单色不需要表结构
        },
        layout = "dwindle"
    },
  decoration = {
    rounding = 10,
    rounding_power = 4,
    active_opacity = 1.0,
    inactive_opacity = 0.95,
    fullscreen_opacity = 1.0,
    dim_inactive = true,
    dim_strength = 0.1,
    shadow = {
      enabled = true,
      range = 4,
      render_power = 3,
      color = "0x66404040",
      color_inactive = "0x66404040",
      offset = "1 2",
      scale = 1.0,
    },
    blur = {
      enabled = true,
      size = 5,
      passes = 2,
      new_optimizations = true,
      xray = true,
      ignore_opacity = false,
      noise = 0.0,
      contrast = 1.0,
      brightness = 1.0,
      special = false,
      vibrancy = 0.1696,
      vibrancy_darkness = 0.0,
      popups_ignorealpha = 0.25,
    },
  },
  group = {
    ["col.border_active"]          = "#d0bcff",
    ["col.border_inactive"]        = "#948f99",
    ["col.border_locked_active"]   = "#f2b8b5",
    ["col.border_locked_inactive"] = "#948f99",
    groupbar = {
      ["col.active"]          = "#d0bcff",
      ["col.inactive"]        = "#948f99",
      ["col.locked_active"]   = "#f2b8b5",
      ["col.locked_inactive"] = "#948f99",
    },
  },
})
