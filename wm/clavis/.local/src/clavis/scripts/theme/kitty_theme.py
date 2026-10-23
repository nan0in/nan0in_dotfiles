#!/usr/bin/env python3
"""Select generated Kitty colors without overwriting the user's theme."""
from __future__ import annotations

import argparse
import base64
import fcntl
import hashlib
import json
import os
from pathlib import Path
import stat
import subprocess
import sys
import tempfile

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "lib"))
from clavis_paths import ClavisPaths


def atomic_write(path: Path, data: bytes, mode: int = 0o600) -> None:
    fd, name = tempfile.mkstemp(prefix="." + path.name, dir=path.parent)
    try:
        with os.fdopen(fd, "wb") as stream:
            stream.write(data)
            stream.flush()
            os.fsync(stream.fileno())
            os.fchmod(stream.fileno(), mode)
        os.replace(name, path)
    finally:
        if os.path.lexists(name):
            os.unlink(name)


def replace_link(path: Path, target: str) -> None:
    fd, name = tempfile.mkstemp(prefix="." + path.name, dir=path.parent)
    os.close(fd)
    os.unlink(name)
    try:
        os.symlink(target, name)
        os.replace(name, path)
    finally:
        if os.path.lexists(name):
            os.unlink(name)


def select_theme(action: str) -> bool:
    paths = ClavisPaths.from_environment()
    # Match the builtin registry output, not the shell settings namespace.
    config = paths.home / ".config"
    current = config / "kitty/current-theme.conf"
    generated = config / "kitty/themes/Matugen.conf"
    key = hashlib.sha256(str(current).encode()).hexdigest()[:16]
    state = paths.state_home / "kitty-theme" / key
    state.mkdir(parents=True, exist_ok=True)
    with (state / "lock").open("a") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        snapshot = state / "original.json"
        managed = current.is_symlink() and os.readlink(current) == str(generated)
        if action == "restore":
            if not snapshot.exists():
                return False
            original = json.loads(snapshot.read_text())
            # Respect a theme selected manually while Matugen was enabled.
            if managed:
                kind = original["kind"]
                if kind == "link":
                    replace_link(current, original["target"])
                elif kind == "file":
                    atomic_write(current, base64.b64decode(original["data"]), original["mode"])
                elif kind == "missing":
                    current.unlink()
                else:
                    raise ValueError("Invalid Kitty theme snapshot")
            snapshot.unlink()
            return managed
        if not generated.is_file():
            raise ValueError("Generated Kitty theme is missing")
        if snapshot.exists() and not managed:
            raise ValueError("Kitty theme changed manually; disable the template before enabling it again")
        if not snapshot.exists():
            if managed:
                raise ValueError("Original Kitty theme snapshot is missing; select a theme before enabling")
            if current.is_symlink():
                original = {"kind": "link", "target": os.readlink(current)}
            elif current.exists():
                if not current.is_file():
                    raise ValueError("Kitty current theme is not a regular file or symlink")
                original = {"kind": "file", "data": base64.b64encode(current.read_bytes()).decode(),
                            "mode": stat.S_IMODE(current.stat().st_mode)}
            else:
                original = {"kind": "missing"}
            atomic_write(snapshot, json.dumps(original).encode())
        replace_link(current, str(generated))
        return True


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=("apply", "restore"))
    args = parser.parse_args()
    try:
        if select_theme(args.action):
            subprocess.run(["pkill", "-USR1", "-x", "kitty"], check=False, capture_output=True)
        return 0
    except (OSError, ValueError, KeyError) as error:
        print(f"Kitty theme: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
