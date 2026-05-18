#!/usr/bin/env sh

set -eu

log_file=/tmp/ambxst-tray-recover.log

log() {
  printf '%s %s\n' "$(date '+%F %T')" "$*" >> "$log_file"
}

# 先停掉托盘相关进程，再按面板 -> applet 的顺序重启，
# 尽量让 StatusNotifier 项重新注册到 ambxst/quickshell 上。
pkill -TERM -f 'qs -p /home/nan0in27/.local/src/ambxst/shell.qml' 2>/dev/null || true
sleep 1
pkill -KILL -f 'qs -p /home/nan0in27/.local/src/ambxst/shell.qml' 2>/dev/null || true
pkill axctl 2>/dev/null || true
pkill nm-applet 2>/dev/null || true
pkill blueman-applet 2>/dev/null || true
pkill cc-switch 2>/dev/null || true

nohup ambxst >/tmp/ambxst.log 2>&1 &
sleep 2
nm-applet --indicator >/dev/null 2>&1 &
sleep 1
blueman-applet >/dev/null 2>&1 &
sleep 1
/usr/bin/cc-switch >/dev/null 2>&1 &

# 如果旧的 quickshell 进程卡在 D 状态并继续占着
# org.kde.StatusNotifierWatcher，这里会检测失败。
# 那种情况下新的托盘宿主无法接管，只能重启系统清掉旧进程。
if ! busctl --user call org.kde.StatusNotifierWatcher /StatusNotifierWatcher org.freedesktop.DBus.Properties Get ss org.kde.StatusNotifierWatcher RegisteredStatusNotifierItems >/dev/null 2>&1; then
  log "StatusNotifierWatcher is still unresponsive; a stale quickshell watcher may be stuck in D state. Reboot is required."
  exit 1
fi

log "Tray recovery completed successfully."
