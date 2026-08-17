#!/usr/bin/env bash

PIPE="${1:-/tmp/ambxst_ipc.pipe}"
PARENT_PID="${AMBXST_PARENT_PID:-$PPID}"
WATCHDOG_PID=""

cleanup() {
	rm -f "$PIPE"
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

rm -f "$PIPE"
mkfifo "$PIPE"

while IFS= read -r line < "$PIPE"; do
	printf '%s\n' "$line"
done
