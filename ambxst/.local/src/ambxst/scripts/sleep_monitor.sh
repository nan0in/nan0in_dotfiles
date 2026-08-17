#!/usr/bin/env bash

LOCKFILE="/tmp/ambxst_sleep_monitor.lock"
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

# Sleep Monitor - Executes commands before and after sleep
CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/ambxst/config/system.json"

get_cmd() {
	local type=$1
	if [ -f "$CONFIG_FILE" ]; then
		if [ "$type" == "before" ]; then
			jq -r '.idle.general.before_sleep_cmd // "loginctl lock-session"' "$CONFIG_FILE"
		else
			jq -r '.idle.general.after_sleep_cmd // "ambxst screen on"' "$CONFIG_FILE"
		fi
	else
		if [ "$type" == "before" ]; then
			echo "loginctl lock-session"
		else
			echo "ambxst screen on"
		fi
	fi
}

# Monitor logind's PrepareForSleep signal.
coproc DBUS_MONITOR { dbus-monitor --system "type='signal',interface='org.freedesktop.login1.Manager',member='PrepareForSleep'"; }
while read -r line <&"${DBUS_MONITOR[0]}"; do
	if ! echo "$line" | grep -q "boolean"; then
		continue
	fi
	if echo "$line" | grep -q "true"; then
		# Going to sleep
		echo "SUSPEND"
		CMD=$(get_cmd "before")
		if [ -n "$CMD" ]; then
			eval "$CMD" &
		fi
	elif echo "$line" | grep -q "false"; then
		# Waking up
		echo "WAKE"
		CMD=$(get_cmd "after")
		if [ -n "$CMD" ]; then
			eval "$CMD" &
		fi
	fi
done
