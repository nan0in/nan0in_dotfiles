#!/usr/bin/env bash

LOCKFILE="/tmp/ambxst_loginlock.lock"
if [ -e "$LOCKFILE" ]; then
	PID=$(cat "$LOCKFILE")
	if kill -0 "$PID" 2>/dev/null; then
		exit 0
	fi
fi
echo $$ >"$LOCKFILE"

PARENT_PID="${AMBXST_PARENT_PID:-$PPID}"
WATCHDOG_PID=""

cleanup() {
	rm -f "$LOCKFILE"
	if [ -n "${DBUS_MONITOR_PID:-}" ]; then
		kill "$DBUS_MONITOR_PID" 2>/dev/null || true
	fi
	if [ -n "$WATCHDOG_PID" ]; then
		kill "$WATCHDOG_PID" 2>/dev/null || true
	fi
}
trap cleanup EXIT INT TERM

watch_parent() {
	while kill -0 "$PARENT_PID" 2>/dev/null; do
		sleep 1
	done
	kill -TERM "$$" 2>/dev/null || true
}
watch_parent &
WATCHDOG_PID=$!

CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/ambxst/config/system.json"

get_lock_cmd() {
	if [ -f "$CONFIG_FILE" ]; then
		jq -r '.idle.general.lock_cmd // "ambxst lock"' "$CONFIG_FILE"
	else
		echo "ambxst lock"
	fi
}

coproc DBUS_MONITOR { dbus-monitor --system "type='signal',interface='org.freedesktop.login1.Session',member='Lock'"; }
while read -r line <&"${DBUS_MONITOR[0]}"; do
	if echo "$line" | grep -q "member=Lock"; then
		COMMAND=$(get_lock_cmd)
		if [ -n "$COMMAND" ]; then
			eval "$COMMAND" &
		fi
	fi
done
