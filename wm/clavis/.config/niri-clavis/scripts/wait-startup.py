#!/usr/bin/env python3
"""Wait briefly for the startup overlay's first rendered frame, not a fixed sleep."""
from pathlib import Path
import subprocess
import time

path = Path.home() / '.local/src/clavis/Startup.qml'
deadline = time.monotonic() + 3
while time.monotonic() < deadline:
    try:
        result = subprocess.run(['qs', '-p', str(path), 'ipc', 'call', 'startup-overlay', 'presented'],
                                capture_output=True, text=True, timeout=.5, check=False)
        if result.returncode == 0 and result.stdout.strip() == 'true':
            raise SystemExit(0)
    except (OSError, subprocess.TimeoutExpired):
        pass
    time.sleep(.05)
print('Startup overlay did not acknowledge a frame; continuing desktop startup.')
raise SystemExit(1)
