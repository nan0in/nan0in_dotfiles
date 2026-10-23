#!/usr/bin/env bash
set -euo pipefail
[[ -n ${NIRI_SOCKET:-} && ${XDG_CURRENT_DESKTOP:-} == niri ]] || exit 0
state="${XDG_STATE_HOME:-$HOME/.local/state}/clavis"
mkdir -p "$state" "$HOME/Pictures/Screenshots"
exec >>"$state/startup.log" 2>&1
exec 9>"${XDG_RUNTIME_DIR:?}/niri-clavis-startup.lock"
flock -n 9 || exit 0
export PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:$PATH"
unset HYPRLAND_INSTANCE_SIGNATURE
export XDG_SESSION_DESKTOP=niri
export NIRI_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/niri-clavis/config.kdl"
vars=(NIRI_CONFIG WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE NIRI_SOCKET QT_QPA_PLATFORMTHEME QT_STYLE_OVERRIDE GTK_THEME QT_QPA_PLATFORM QT_IM_MODULE GTK_IM_MODULE XMODIFIERS XCURSOR_THEME XCURSOR_SIZE LANG LANGUAGE PATH)
[[ -n ${DISPLAY:-} ]] && vars+=(DISPLAY)
[[ -n ${YAZI_CONFIG_HOME:-} ]] && vars+=(YAZI_CONFIG_HOME)
dbus-update-activation-environment --systemd "${vars[@]}"
# Render the lightweight name animation before loading the full Shell.
# A manual Shell refresh skips it; a failed overlay never blocks login.
if ! systemctl --user is-active --quiet clavis-shell.service; then
 if systemctl --user start clavis-startup.service; then
  python3 "${XDG_CONFIG_HOME:-$HOME/.config}/niri-clavis/scripts/wait-startup.py" || true
 fi
fi
start_once() { local name="$1"; shift; if ! pgrep -u "$UID" -x "$name" >/dev/null; then "$@" 9>&- & fi; }
start_once fcitx5 fcitx5 -d
if ! pgrep -u "$UID" -f '^/usr/lib/polkit-kde-authentication-agent-1' >/dev/null; then
 /usr/lib/polkit-kde-authentication-agent-1 9>&- &
fi
systemctl --user start niri-idle.service niri-sleep-lock.service
systemctl --user start clavis-shell.service clavis-clipboard.service clavis-x11-minimize.service
sleep 2
start_once nm-applet nm-applet --indicator
start_once blueman-applet blueman-applet
start_once cc-switch /usr/bin/cc-switch
flock -u 9
