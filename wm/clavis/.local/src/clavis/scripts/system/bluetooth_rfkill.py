#!/usr/bin/env python3
"""Unblock Bluetooth on explicit enable; preserve Wi-Fi and hardware blocks."""
import json
from pathlib import Path
import subprocess


def unblock():
    try:
        subprocess.run(['rfkill', 'unblock', 'bluetooth'], check=True,
                       capture_output=True, timeout=5)
        devices = [p for p in Path('/sys/class/rfkill').glob('rfkill*')
                   if (p / 'type').read_text().strip() == 'bluetooth']
        if any((p / 'hard').read_text().strip() == '1' for p in devices):
            return dict(schemaVersion=1, ok=False, error='hardware_blocked')
        if any((p / 'soft').read_text().strip() == '1' for p in devices):
            return dict(schemaVersion=1, ok=False, error='software_blocked')
        return dict(schemaVersion=1, ok=True, error='')
    except (OSError, subprocess.SubprocessError):
        return dict(schemaVersion=1, ok=False, error='unblock_failed')


if __name__ == '__main__':
    result = unblock()
    print(json.dumps(result))
    raise SystemExit(0 if result['ok'] else 1)
