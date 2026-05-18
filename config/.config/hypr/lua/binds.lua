-- User core binds (user priority over ambxst)
hl.bind(mainMod .. " + Q",      hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + W",      hl.dsp.window.kill())
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit"))
hl.bind(mainMod .. " + E",      hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + R",      hl.dsp.exec_cmd("spectacle"))
hl.bind(mainMod .. " + P",      hl.dsp.layout("pseudo"))
hl.bind(mainMod .. " + J",      hl.dsp.layout("togglesplit"))

-- Window cycling
hl.bind("ALT + Tab",       hl.dsp.layout("cyclenext"))
hl.bind("ALT + SHIFT + Tab", hl.dsp.layout("cycleprev"))

-- Layout cycle: dwindle -> master -> monocle -> dwindle
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("sh -c 'current=$(hyprctl getoption general:layout | sed -n \"s/^str: //p\"); case \"$current\" in dwindle) next=master ;; master) next=monocle ;; monocle) next=dwindle ;; *) next=dwindle ;; esac; hyprctl keyword general:layout \"$next\" && notify-send -t 1500 -a Hyprland Layout \"$next\"'"))

-- Workspace switching (1-9)
for i = 1, 9 do
  hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = tostring(i) }))
  hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = tostring(i) }))
end
-- Workspace 10 via key 0
hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = "10" }))
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = "10" }))

-- Special workspace
hl.bind(mainMod .. " + S",      hl.dsp.exec_cmd("hyprctl dispatch togglespecialworkspace magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Mouse drag/resize
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Volume, brightness
hl.bind("XF86AudioRaiseVolume",    hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true })
hl.bind("XF86AudioLowerVolume",    hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { repeating = true })
hl.bind("XF86AudioMute",           hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true })
hl.bind("XF86AudioMicMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true })
hl.bind("XF86MonBrightnessUp",     hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { repeating = true })
hl.bind("XF86MonBrightnessDown",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { repeating = true })

-- Media controls
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- Tray recovery
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd("~/.config/hypr/scripts/recover-tray.sh"))

-- ===== ambxst non-conflicting binds =====
hl.bind(mainMod .. " + super_L",     hl.dsp.exec_cmd("ambxst run launcher"))
hl.bind(mainMod .. " + D",           hl.dsp.exec_cmd("ambxst run dashboard"))
hl.bind(mainMod .. " + V",           hl.dsp.exec_cmd("ambxst run clipboard"))
hl.bind(mainMod .. " + PERIOD",      hl.dsp.exec_cmd("ambxst run emoji"))
hl.bind(mainMod .. " + N",           hl.dsp.exec_cmd("ambxst run notes"))
hl.bind(mainMod .. " + T",           hl.dsp.exec_cmd("ambxst run tmux"))
hl.bind(mainMod .. " + SHIFT + W",   hl.dsp.exec_cmd("ambxst run wallpapers"))
hl.bind(mainMod .. " + TAB",         hl.dsp.exec_cmd("ambxst run overview"))
hl.bind(mainMod .. " + ESCAPE",      hl.dsp.exec_cmd("ambxst run powermenu"))
hl.bind(mainMod .. " + SHIFT + C",   hl.dsp.exec_cmd("ambxst run config"))
hl.bind(mainMod .. " + L",           hl.dsp.exec_cmd("loginctl lock-session"))
hl.bind(mainMod .. " + SHIFT + R",   hl.dsp.exec_cmd("ambxst run screenrecord"))
hl.bind(mainMod .. " + SHIFT + A",   hl.dsp.exec_cmd("ambxst run lens"))
hl.bind(mainMod .. " + ALT + B",     hl.dsp.exec_cmd("ambxst reload"))

-- ambxst silent workspace move (Super+Alt+1-9)
for i = 1, 9 do
  hl.bind(mainMod .. " + ALT + " .. i, hl.dsp.window.move({ workspace = tostring(i), silent = true }))
end
hl.bind(mainMod .. " + ALT + 0", hl.dsp.window.move({ workspace = "10", silent = true }))

-- ambxst workspace nav (keyboard)
hl.bind(mainMod .. " + SHIFT + Z", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + SHIFT + X", hl.dsp.focus({ workspace = "e+1" }))

-- ambxst focus move
hl.bind(mainMod .. " + Down",  hl.dsp.focus({ direction = "d" }))
hl.bind(mainMod .. " + Left",  hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + Right", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + Up",    hl.dsp.focus({ direction = "u" }))

-- ambxst window move
hl.bind(mainMod .. " + SHIFT + Left",  hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + Right", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + Up",    hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + Down",  hl.dsp.window.move({ direction = "d" }))

-- ambxst resize
hl.bind(mainMod .. " + ALT + Left",  hl.dsp.window.resize({ x = -50, y = 0, relative = true }))
hl.bind(mainMod .. " + ALT + Right", hl.dsp.window.resize({ x = 50,  y = 0, relative = true }))
hl.bind(mainMod .. " + ALT + Up",    hl.dsp.window.resize({ x = 0,   y = -50, relative = true }))
hl.bind(mainMod .. " + ALT + Down",  hl.dsp.window.resize({ x = 0,   y = 50, relative = true }))

-- Switch binds (lid)
hl.bind("switch:Lid Switch",     hl.dsp.exec_cmd("loginctl lock-session"))
hl.bind("switch:on:Lid Switch",  hl.dsp.exec_cmd("axctl monitor set-dpms 0 0"))
hl.bind("switch:off:Lid Switch", hl.dsp.exec_cmd("axctl monitor set-dpms 0 1"))
