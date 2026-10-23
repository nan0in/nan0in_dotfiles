#!/usr/bin/env python3
"""Lock this Wayland session with Clavis, acknowledging security before returning."""
import argparse
import fcntl
import json
import hashlib
import os
from pathlib import Path
import subprocess
import sys
import time


def ipc(method, timeout=0.4, owner=None):
    try:
        result = subprocess.run(
            ['qs', '-c', 'clavis', 'ipc', *(['--id', owner['id']] if owner else []),
             'call', 'lock', method],
            capture_output=True, text=True, timeout=timeout, check=False,
        )
        return result.stdout.strip() if result.returncode == 0 else None
    except (OSError, subprocess.TimeoutExpired):
        return None


def display(env):
    name = env.get('WAYLAND_DISPLAY', '')
    return name if name.startswith('/') else env.get('XDG_RUNTIME_DIR', '') + '/' + name


def swaylock_running():
    for process in Path('/proc').glob('[0-9]*'):
        try:
            if process.stat().st_uid != os.getuid() or (process / 'comm').read_text().strip() != 'swaylock':
                continue
            env = dict(entry.split('=', 1) for entry in (process / 'environ').read_bytes().decode(
                errors='surrogateescape').split('\0') if '=' in entry)
            if display(env) == display(os.environ):
                return True
        except (OSError, ValueError):
            continue
    return False


def process_token(pid):
    try:
        fields = Path(f'/proc/{pid}/stat').read_text().rpartition(')')[2].split()
        return None if fields[0] == 'Z' else fields[19]
    except (OSError, IndexError):
        return None


def session_owner():
    try:
        result = subprocess.run(['qs', '-c', 'clavis', 'list', '-j'],
                                capture_output=True, text=True, timeout=0.5, check=True)
        candidates = []
        for item in json.loads(result.stdout):
            pid = int(item['pid'])
            env = dict(entry.split('=', 1) for entry in Path(f'/proc/{pid}/environ').read_bytes()
                       .decode(errors='surrogateescape').split('\0') if '=' in entry)
            token = process_token(pid)
            if token and display(env) == display(os.environ) and env.get('NIRI_SOCKET') == os.environ.get('NIRI_SOCKET'):
                candidates.append({**item, 'token': token})
        return min(candidates, key=lambda item: item['launch_time']) if candidates else None
    except (OSError, ValueError, KeyError, TypeError, subprocess.SubprocessError):
        return None


def fallback():
    if swaylock_running():
        return 0
    print('Using independent swaylock recovery (password still required).', file=sys.stderr, flush=True)
    try:
        # -f acknowledges acquisition; never inherit the serialization FD.
        result = subprocess.run(['swaylock', '-f', '-c', '1e1e2e'], check=False).returncode
        print(f'Recovery lock acquisition exit status: {result}', file=sys.stderr, flush=True)
        return result
    except OSError as error:
        print(f'swaylock failed: {error}', file=sys.stderr)
        return 1


def guard_path(kind):
    suffix = hashlib.sha256(display(os.environ).encode()).hexdigest()[:16]
    return Path(os.environ['XDG_RUNTIME_DIR']) / f'clavis-lock-{kind}-{suffix}.lock'


def guard(kind):
    fd = os.open(guard_path(kind), os.O_CREAT | os.O_RDWR | os.O_CLOEXEC, 0o600)
    return os.fdopen(fd, 'w')


def start_watch(owner):
    if not owner:
        print('Lock acquired, but could not identify its owner for crash recovery.', file=sys.stderr)
        return
    log_path = Path(os.environ['XDG_RUNTIME_DIR']) / 'clavis-lock-watch.log'
    fd = os.open(log_path, os.O_CREAT | os.O_WRONLY | os.O_APPEND | os.O_CLOEXEC, 0o600)
    with os.fdopen(fd, 'a') as log:
        subprocess.Popen([sys.executable, str(Path(__file__).resolve()), '--watch',
                          owner['id'], str(owner['pid']), owner['token']],
                         stdin=subprocess.DEVNULL, stdout=log, stderr=log,
                         start_new_session=True, close_fds=True)


def watch(owner):
    # Survives a Shell crash/restart and never releases a compositor lock.
    with guard('watch') as handle:
        try:
            fcntl.flock(handle, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            return 0
        while Path(os.environ['NIRI_SOCKET']).exists():
            if process_token(owner['pid']) != owner['token']:
                print('Clavis lock owner exited; starting authenticated recovery.', flush=True)
                with guard('entry') as entry:
                    fcntl.flock(entry, fcntl.LOCK_EX)
                    # Do not compete with a replacement locker already acquired.
                    if ipc('isSecure') == 'true':
                        return 0
                    return fallback()
            # Pin to the original instance: a restarted Shell reporting false
            # does not prove that the compositor was unlocked by the dead one.
            if ipc('isLocked', owner=owner) == 'false':
                return 0
            time.sleep(0.5)
    return 0


def wait_presented(owner, timeout=2):
    if ipc('isPresented', owner=owner) == 'true':
        return True
    # The compositor is secure, but its surface may not have committed a frame.
    ipc('redraw', owner=owner)
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        if ipc('isPresented', timeout=min(0.4, max(0.01, deadline - time.monotonic())),
               owner=owner) == 'true':
            return True
        time.sleep(0.1)
    return False


def lock(for_sleep=False):
    if swaylock_running():
        return 0
    owner = session_owner()
    if ipc('isSecure', owner=owner) == 'true':
        start_watch(owner)
        if not wait_presented(owner, 1):
            print('Clavis lock is secure but its surface has not presented yet.', file=sys.stderr)
        return 0
    # Sleep bypasses screenshot capture, avoiding a slow/dead powered-down output.
    requested = ipc('openForSleep' if for_sleep else 'open', owner=owner)
    if requested in ('LOCKED', 'ALREADY_LOCKED'):
        deadline = time.monotonic() + 2.5
        while time.monotonic() < deadline:
            if ipc('isSecure', timeout=min(0.4, max(0.01, deadline - time.monotonic())), owner=owner) == 'true':
                start_watch(owner)
                # niri is secure as soon as it has a lock surface, but the
                # surface can still be waiting for its first buffer. Wait for
                # presentation before returning so suspend does not expose the
                # compositor's red lock backdrop.
                if wait_presented(owner, 2):
                    return 0
                print('Clavis lock is secure but its surface has not presented yet.', file=sys.stderr)
                return 1
            time.sleep(0.1)
        cancelled = ipc('cancelPending', owner=owner)
        if ipc('isSecure', owner=owner) == 'true':
            start_watch(owner)
            return 0
        if cancelled == 'false':
            start_watch(owner)
            print('Clavis owns the session lock but has not confirmed secure state.', file=sys.stderr)
            return 1
    return fallback()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    modes = parser.add_mutually_exclusive_group()
    modes.add_argument('--sleep', action='store_true', help='lock without desktop capture')
    modes.add_argument('--recover', action='store_true', help='use the independent password locker')
    modes.add_argument('--resume', action='store_true', help='redraw an existing lock after resume')
    modes.add_argument('--watch', nargs=3, metavar=('ID', 'PID', 'TOKEN'), help=argparse.SUPPRESS)
    args = parser.parse_args()
    if not all(os.environ.get(name) for name in ('XDG_RUNTIME_DIR', 'NIRI_SOCKET', 'WAYLAND_DISPLAY')):
        print('Lock entry requires a niri Wayland session.', file=sys.stderr)
        return 1
    if args.resume:
        owner = session_owner()
        ipc('redraw', owner=owner)
        # Give the compositor a moment to finish reinitializing output buffers.
        time.sleep(1)
        ipc('redraw', owner=owner)
        return 0
    if args.watch:
        instance, pid, token = args.watch
        return watch({'id': instance, 'pid': int(pid), 'token': token})
    with guard('entry') as handle:
        fcntl.flock(handle, fcntl.LOCK_EX)
        return fallback() if args.recover else lock(args.sleep)


if __name__ == '__main__':
    sys.exit(main())
