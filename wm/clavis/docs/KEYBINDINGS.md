# 当前完整快捷键

从 niri-clavis/config.kdl 的 include 链生成；同键后加载覆盖前加载。

只展示配置，不执行所选命令。修改配置后重新生成此文件。

| 按键 | 最终动作 | 来源 |
|---|---|---|
| Alt+Print | `spawn "python3" "/home/nan0in/.config/niri-clavis/scripts/screenshot.py" "window";` | binds.kdl |
| Alt+Shift+Tab | `spawn "/home/nan0in/.config/niri/scripts/window-tools.py" "cycle" "prev";` | binds.kdl |
| Alt+Tab | `spawn "/home/nan0in/.config/niri/scripts/window-tools.py" "cycle" "next";` | binds.kdl |
| Ctrl+Print | `spawn "python3" "/home/nan0in/.config/niri-clavis/scripts/screenshot.py" "screen";` | binds.kdl |
| Print | `spawn "python3" "/home/nan0in/.config/niri-clavis/scripts/screenshot.py" "region";` | binds.kdl |
| Shift+Print | `spawn "python3" "/home/nan0in/.config/niri-clavis/scripts/screenshot.py" "menu";` | binds.kdl |
| Super+0 | `focus-workspace "10";` | binds.kdl |
| Super+1 | `focus-workspace "1";` | binds.kdl |
| Super+2 | `focus-workspace "2";` | binds.kdl |
| Super+3 | `focus-workspace "3";` | binds.kdl |
| Super+4 | `focus-workspace "4";` | binds.kdl |
| Super+5 | `focus-workspace "5";` | binds.kdl |
| Super+6 | `focus-workspace "6";` | binds.kdl |
| Super+7 | `focus-workspace "7";` | binds.kdl |
| Super+8 | `focus-workspace "8";` | binds.kdl |
| Super+9 | `focus-workspace "9";` | binds.kdl |
| Super+A | `spawn "qs" "-c" "clavis" "ipc" "call" "sidebar" "toggle" "quicksettings";` | binds.kdl |
| Super+Alt+0 | `move-window-to-workspace "10" focus=false;` | binds.kdl |
| Super+Alt+1 | `move-window-to-workspace "1" focus=false;` | binds.kdl |
| Super+Alt+2 | `move-window-to-workspace "2" focus=false;` | binds.kdl |
| Super+Alt+3 | `move-window-to-workspace "3" focus=false;` | binds.kdl |
| Super+Alt+4 | `move-window-to-workspace "4" focus=false;` | binds.kdl |
| Super+Alt+5 | `move-window-to-workspace "5" focus=false;` | binds.kdl |
| Super+Alt+6 | `move-window-to-workspace "6" focus=false;` | binds.kdl |
| Super+Alt+7 | `move-window-to-workspace "7" focus=false;` | binds.kdl |
| Super+Alt+8 | `move-window-to-workspace "8" focus=false;` | binds.kdl |
| Super+Alt+9 | `move-window-to-workspace "9" focus=false;` | binds.kdl |
| Super+Alt+B | `spawn "systemctl" "--user" "restart" "clavis-shell.service" "clavis-clipboard.service";` | binds.kdl |
| Super+Alt+Down | `set-window-height "+50";` | binds.kdl |
| Super+Alt+F | `switch-focus-between-floating-and-tiling;` | binds.kdl |
| Super+Alt+L | `spawn "swaylock" "-f" "-c" "1e1e2e";` | binds.kdl |
| Super+Alt+Left | `set-column-width "-50";` | binds.kdl |
| Super+Alt+Print | `screenshot;` | binds.kdl |
| Super+Alt+Right | `set-column-width "+50";` | binds.kdl |
| Super+Alt+Up | `set-window-height "-50";` | binds.kdl |
| Super+Alt+V | `spawn "/home/nan0in/.config/niri/scripts/window-tools.py" "scratch-send";` | binds.kdl |
| Super+BracketLeft | `consume-or-expel-window-left;` | binds.kdl |
| Super+BracketRight | `consume-or-expel-window-right;` | binds.kdl |
| Super+Ctrl+Alt+B | `spawn "systemctl" "--user" "stop" "clavis-shell.service" "clavis-clipboard.service";` | binds.kdl |
| Super+Ctrl+B | `spawn "qs" "-c" "clavis" "ipc" "call" "control-center" "open" "general.bar";` | binds.kdl |
| Super+Ctrl+Down | `focus-monitor-down;` | binds.kdl |
| Super+Ctrl+Escape | `toggle-keyboard-shortcuts-inhibit;` | binds.kdl |
| Super+Ctrl+H | `focus-monitor-left;` | binds.kdl |
| Super+Ctrl+J | `focus-monitor-down;` | binds.kdl |
| Super+Ctrl+K | `focus-monitor-up;` | binds.kdl |
| Super+Ctrl+L | `focus-monitor-right;` | binds.kdl |
| Super+Ctrl+Left | `focus-monitor-left;` | binds.kdl |
| Super+Ctrl+N | `spawn "qs" "-c" "clavis" "ipc" "call" "control-center" "open" "general.network";` | binds.kdl |
| Super+Ctrl+R | `consume-or-expel-window-right;` | binds.kdl |
| Super+Ctrl+Right | `focus-monitor-right;` | binds.kdl |
| Super+Ctrl+Shift+Down | `move-window-to-monitor-down;` | binds.kdl |
| Super+Ctrl+Shift+H | `move-window-to-monitor-left;` | binds.kdl |
| Super+Ctrl+Shift+J | `move-window-to-monitor-down;` | binds.kdl |
| Super+Ctrl+Shift+K | `move-window-to-monitor-up;` | binds.kdl |
| Super+Ctrl+Shift+L | `move-window-to-monitor-right;` | binds.kdl |
| Super+Ctrl+Shift+Left | `move-window-to-monitor-left;` | binds.kdl |
| Super+Ctrl+Shift+Right | `move-window-to-monitor-right;` | binds.kdl |
| Super+Ctrl+Shift+Up | `move-window-to-monitor-up;` | binds.kdl |
| Super+Ctrl+Shift+W | `spawn "/home/nan0in/.local/bin/waywallen";` | binds.kdl |
| Super+Ctrl+Space | `spawn "fuzzel" "--config" "/home/nan0in/.config/niri/fuzzel/fuzzel.ini";` | binds.kdl |
| Super+Ctrl+T | `toggle-column-tabbed-display;` | binds.kdl |
| Super+Ctrl+Up | `focus-monitor-up;` | binds.kdl |
| Super+D | `spawn "qs" "-c" "clavis" "ipc" "call" "sidebar" "toggle" "dashboard";` | binds.kdl |
| Super+Down | `focus-window-down;` | binds.kdl |
| Super+E | `spawn "python3" "/home/nan0in/.config/niri-clavis/scripts/desktop-actions.py" "folder";` | binds.kdl |
| Super+Escape | `spawn "qs" "-c" "clavis" "ipc" "call" "power-menu" "toggle";` | binds.kdl |
| Super+F | `fullscreen-window;` | binds.kdl |
| Super+F1 | `spawn "python3" "/home/nan0in/.config/niri-clavis/scripts/keybindings.py";` | binds.kdl |
| Super+H | `focus-column-left;` | binds.kdl |
| Super+J | `toggle-column-tabbed-display;` | binds.kdl |
| Super+K | `focus-window-up;` | binds.kdl |
| Super+L | `spawn "/home/nan0in/.config/niri-clavis/scripts/lock.py";` | binds.kdl |
| Super+Left | `focus-column-left;` | binds.kdl |
| Super+M | `maximize-column;` | binds.kdl |
| Super+N | `spawn "python3" "/home/nan0in/.config/niri-clavis/scripts/desktop-actions.py" "notes";` | binds.kdl |
| Super+P | `switch-preset-column-width;` | binds.kdl |
| Super+Page_Down | `focus-workspace-down;` | binds.kdl |
| Super+Page_Up | `focus-workspace-up;` | binds.kdl |
| Super+Period | `spawn "python3" "/home/nan0in/.config/niri-clavis/scripts/desktop-actions.py" "emoji";` | binds.kdl |
| Super+Q | `spawn "kitty";` | binds.kdl |
| Super+R | `spawn "python3" "/home/nan0in/.config/niri-clavis/scripts/screenshot.py" "region";` | binds.kdl |
| Super+Return | `spawn "kitty";` | binds.kdl |
| Super+Right | `focus-column-right;` | binds.kdl |
| Super+S | `spawn "/home/nan0in/.config/niri/scripts/window-tools.py" "scratch";` | binds.kdl |
| Super+Shift+0 | `move-window-to-workspace "10";` | binds.kdl |
| Super+Shift+1 | `move-window-to-workspace "1";` | binds.kdl |
| Super+Shift+2 | `move-window-to-workspace "2";` | binds.kdl |
| Super+Shift+3 | `move-window-to-workspace "3";` | binds.kdl |
| Super+Shift+4 | `move-window-to-workspace "4";` | binds.kdl |
| Super+Shift+5 | `move-window-to-workspace "5";` | binds.kdl |
| Super+Shift+6 | `move-window-to-workspace "6";` | binds.kdl |
| Super+Shift+7 | `move-window-to-workspace "7";` | binds.kdl |
| Super+Shift+8 | `move-window-to-workspace "8";` | binds.kdl |
| Super+Shift+9 | `move-window-to-workspace "9";` | binds.kdl |
| Super+Shift+A | `spawn "python3" "/home/nan0in/.config/niri-clavis/scripts/desktop-actions.py" "ocr";` | binds.kdl |
| Super+Shift+B | `spawn "python3" "/home/nan0in/.config/niri-clavis/scripts/desktop-actions.py" "recover-tray";` | binds.kdl |
| Super+Shift+C | `spawn "qs" "-c" "clavis" "ipc" "call" "control-center" "toggle" "general";` | binds.kdl |
| Super+Shift+Down | `move-window-down;` | binds.kdl |
| Super+Shift+F | `spawn "python3" "/home/nan0in/.config/niri-clavis/scripts/desktop-actions.py" "float-workspace";` | binds.kdl |
| Super+Shift+H | `consume-or-expel-window-left;` | binds.kdl |
| Super+Shift+J | `move-window-down;` | binds.kdl |
| Super+Shift+K | `move-window-up;` | binds.kdl |
| Super+Shift+L | `consume-or-expel-window-right;` | binds.kdl |
| Super+Shift+Left | `consume-or-expel-window-left;` | binds.kdl |
| Super+Shift+M | `quit;` | binds.kdl |
| Super+Shift+R | `spawn "python3" "/home/nan0in/.config/niri-clavis/scripts/desktop-actions.py" "record";` | binds.kdl |
| Super+Shift+Right | `consume-or-expel-window-right;` | binds.kdl |
| Super+Shift+S | `spawn "/home/nan0in/.config/niri/scripts/window-tools.py" "scratch-send";` | binds.kdl |
| Super+Shift+Slash | `show-hotkey-overlay;` | binds.kdl |
| Super+Shift+Space | `spawn "qs" "-c" "clavis" "ipc" "call" "spotlight" "web";` | binds.kdl |
| Super+Shift+T | `spawn "qs" "-c" "clavis" "ipc" "call" "keystone" "tools";` | binds.kdl |
| Super+Shift+Up | `move-window-up;` | binds.kdl |
| Super+Shift+V | `toggle-window-floating;` | binds.kdl |
| Super+Shift+W | `spawn "qs" "-c" "clavis" "ipc" "call" "spotlight" "openMode" "wallpapers";` | binds.kdl |
| Super+Shift+X | `focus-workspace-down;` | binds.kdl |
| Super+Shift+Z | `focus-workspace-up;` | binds.kdl |
| Super+Slash | `spawn "qs" "-c" "clavis" "ipc" "call" "shortcut-map" "toggle";` | binds.kdl |
| Super+Space | `spawn "qs" "-c" "clavis" "ipc" "call" "spotlight" "toggle";` | binds.kdl |
| Super+T | `spawn "kitty" "tmux" "new-session" "-A" "-s" "main";` | binds.kdl |
| Super+Tab | `toggle-overview;` | binds.kdl |
| Super+Up | `focus-window-up;` | binds.kdl |
| Super+V | `spawn "qs" "-c" "clavis" "ipc" "call" "spotlight" "openMode" "clipboard";` | binds.kdl |
| Super+W | `close-window;` | binds.kdl |
| Super+WheelScrollDown | `focus-workspace-down;` | binds.kdl |
| Super+WheelScrollUp | `focus-workspace-up;` | binds.kdl |
| Super_L | `spawn "qs" "-c" "clavis" "ipc" "call" "spotlight" "toggle";` | binds.kdl |
| XF86AudioLowerVolume | `spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-";` | binds.kdl |
| XF86AudioMicMute | `spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle";` | binds.kdl |
| XF86AudioMute | `spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle";` | binds.kdl |
| XF86AudioNext | `spawn "playerctl" "next";` | binds.kdl |
| XF86AudioPause | `spawn "playerctl" "play-pause";` | binds.kdl |
| XF86AudioPlay | `spawn "playerctl" "play-pause";` | binds.kdl |
| XF86AudioPrev | `spawn "playerctl" "previous";` | binds.kdl |
| XF86AudioRaiseVolume | `spawn "wpctl" "set-volume" "-l" "1" "@DEFAULT_AUDIO_SINK@" "5%+";` | binds.kdl |
| XF86MonBrightnessDown | `spawn "brightnessctl" "-e4" "-n2" "set" "5%-";` | binds.kdl |
| XF86MonBrightnessUp | `spawn "brightnessctl" "-e4" "-n2" "set" "5%+";` | binds.kdl |
