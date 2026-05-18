#!/usr/bin/env bash
sleep 2

# Mouse scroll workspace (global)
hyprctl keyword bind "SUPER,mouse_down,workspace,e+1"
hyprctl keyword bind "SUPER,mouse_up,workspace,e-1"

# Ctrl+left/right workspace
hyprctl keyword bind "SUPER CTRL,right,workspace,+1"
hyprctl keyword bind "SUPER CTRL,left,workspace,-1"

# Ctrl+hjkl focus
hyprctl keyword bind "SUPER CTRL,h,movefocus,l"
hyprctl keyword bind "SUPER CTRL,j,movefocus,d"
hyprctl keyword bind "SUPER CTRL,k,movefocus,u"
hyprctl keyword bind "SUPER CTRL,l,movefocus,r"

# Ctrl+Shift+hjkl move window
hyprctl keyword bind "SUPER CTRL SHIFT,h,movewindow,l"
hyprctl keyword bind "SUPER CTRL SHIFT,j,movewindow,d"
hyprctl keyword bind "SUPER CTRL SHIFT,k,movewindow,u"
hyprctl keyword bind "SUPER CTRL SHIFT,l,movewindow,r"

# Ctrl+Alt+B ambxst quit
hyprctl keyword bind "SUPER CTRL ALT,B,exec,ambxst quit"

# Page_Down/Up workspace
hyprctl keyword bind "SUPER,page_down,workspace,e+1"
hyprctl keyword bind "SUPER,page_up,workspace,e-1"

# Ctrl+r rotatesplit
hyprctl keyword bind "SUPER CTRL,r,layoutmsg,rotatesplit"

# Alt+1-9 silent move
for i in 1 2 3 4 5 6 7 8 9; do
  hyprctl keyword bind "SUPER ALT,$i,movetoworkspacesilent,$i"
done
hyprctl keyword bind "SUPER ALT,0,movetoworkspacesilent,10"

# Alt+V move to special
hyprctl keyword bind "SUPER ALT,V,movetoworkspace,special"

# Gestures
hyprctl keyword "gesture" "3, horizontal, workspace"
hyprctl keyword "gestures:workspace_swipe_distance" 300
hyprctl keyword "gestures:workspace_swipe_cancel_ratio" 0.5
