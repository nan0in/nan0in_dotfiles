-- Ambxst is loaded first. Remove overlapping generated binds before defining
-- local behavior so one key press dispatches exactly one action.
for _, key in ipairs({ "left", "right", "up", "down", "Left", "Right", "Up", "Down" }) do
  hl.unbind(mainMod .. " + " .. key)
end

for _, key in ipairs({ "left", "right" }) do
  hl.unbind(mainMod .. " + CTRL + " .. key)
end

hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + W", hl.dsp.window.kill())
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd("~/.config/hypr/scripts/toggle-float-keep-focus.sh"))
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))

hl.bind("ALT + Tab", hl.dsp.layout("cyclenext"))
hl.bind("ALT + SHIFT + Tab", hl.dsp.layout("cycleprev"))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("~/.config/hypr/scripts/cycle-layout.sh"))

hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "d" }))

hl.bind(mainMod .. " + CTRL + left", hl.dsp.exec_cmd("hyprctl dispatch focusmonitor l"))
hl.bind(mainMod .. " + CTRL + right", hl.dsp.exec_cmd("hyprctl dispatch focusmonitor r"))
hl.bind(mainMod .. " + SHIFT + CTRL + left", hl.dsp.exec_cmd("hyprctl dispatch movewindow mon:l"))
hl.bind(mainMod .. " + SHIFT + CTRL + right", hl.dsp.exec_cmd("hyprctl dispatch movewindow mon:r"))

for i = 1, 10 do
  local key = i % 10
  hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
  hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + SHIFT + S", hl.dsp.workspace.toggle_special("magic"))

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }), { repeating = true })
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }), { repeating = true })
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd("~/.config/hypr/scripts/recover-tray.sh"))
