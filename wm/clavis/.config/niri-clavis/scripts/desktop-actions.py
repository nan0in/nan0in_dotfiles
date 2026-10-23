#!/usr/bin/env python3
"""Personal desktop actions; config-local helper, never a PATH/session command."""
import argparse
import fcntl
import hashlib
import json
import os
from pathlib import Path
import shutil
import signal
import subprocess
import sys
import tempfile
import time

HOME = Path.home()
PROFILE = Path(__file__).resolve().parents[1]
DEPS = HOME / '.local/opt/nan0in-clavis-deps'
KEY = DEPS / 'key-cli/bin/key'


def run(*argv, **kwargs):
    return subprocess.run(list(map(str, argv)), check=True, **kwargs)


def query(name):
    return json.loads(subprocess.check_output(['niri', 'msg', '-j', name], text=True))


def action(*args):
    run('niri', 'msg', 'action', *args, stdout=subprocess.DEVNULL)


def notify(message):
    try:
        subprocess.run(['notify-send', '-a', 'niri', '-t', '1800', message], check=False, timeout=3)
    except (OSError, subprocess.TimeoutExpired):
        pass  # The action must still work when the notification Shell is down.


def float_workspace():
    workspace = next((w for w in query('workspaces') if w['is_focused']), None)
    windows = [w for w in query('windows') if workspace and w['workspace_id'] == workspace['id']]
    if not windows:
        notify('当前工作区没有窗口')
        return
    focused = next((w for w in windows if w['is_focused']), None)
    # Mixed workspaces converge to floating; all-floating workspaces return to tiling.
    tiled = all(w['is_floating'] for w in windows)
    for window in windows:
        action('move-window-to-tiling' if tiled else 'move-window-to-floating', '--id', window['id'])
    if focused:
        action('focus-window', '--id', focused['id'])
    notify('工作区恢复平铺' if tiled else '工作区切换为整体浮动')


def notes():
    directory = Path(os.environ.get('XDG_DATA_HOME', HOME / '.local/share')) / 'niri-clavis'
    directory.mkdir(parents=True, exist_ok=True)
    path = directory / 'notes.md'
    try:
        with path.open('x') as stream:
            stream.write('# 随手记\n\n')
        path.chmod(0o600)
    except FileExistsError:
        pass
    run('kitty', '--class', 'niri-notes', 'nvim', path)


def folder():
    run('python3', PROFILE.parent / 'quickshell/clavis/scripts/capture/desktop_tools.py',
        'folder', '--directory', HOME)


def emoji():
    run('qs', '-c', 'clavis', 'ipc', 'call', 'spotlight', 'command', 'emoji')


def record():
    status = json.loads(subprocess.check_output([str(KEY), 'record', 'status', '--json'], text=True))
    if status.get('schemaVersion') != 1 or not status.get('ok'):
        raise RuntimeError('录屏状态协议异常')
    state = status.get('state')
    if state in ('recording', 'paused'):
        run(KEY, 'record', 'stop', '--json')
        notify('录屏已停止并请求保存')
    elif state in ('idle', 'completed', 'error'):
        run(KEY, 'record', 'start', '--target', 'region', '--audio', 'none', '--json')
        notify('区域录屏已请求启动（不采集音频）；再次按同键停止')
    else:
        notify('录屏正在切换状态，请稍后再试')


def ocr():
    runtime = os.environ['XDG_RUNTIME_DIR']
    with tempfile.TemporaryDirectory(prefix='niri-ocr-', dir=runtime) as directory:
        image = Path(directory) / 'capture.png'
        if shutil.which('slurp') and shutil.which('grim'):
            selection = subprocess.run(['slurp', '-d'], capture_output=True, text=True, timeout=120)
            if selection.returncode != 0 or not selection.stdout.strip():
                return  # Cancellation must release the lock immediately.
            run('grim', '-g', selection.stdout.strip(), image, timeout=15)
        else:
            action('screenshot', '--path', image)
            deadline = time.monotonic() + 45
            while time.monotonic() < deadline:
                if image.exists() and image.read_bytes().endswith(b'\x00\x00\x00\x00IEND\xaeB`\x82'):
                    break
                time.sleep(.15)
            else:
                return
        result = subprocess.check_output(
            ['tesseract', str(image), 'stdout', '-l', 'chi_sim+eng'],
            text=True, stderr=subprocess.PIPE, timeout=90)
        if result.strip():
            run('wl-copy', input=result, text=True)
            notify('OCR 文字已复制（简体中文 + 英文）')
        else:
            notify('未识别到文字')


def recover_tray():
    run('systemctl', '--user', 'restart', 'clavis-shell.service')
    targets = {'nm-applet': ['nm-applet', '--indicator'],
               'blueman-applet': ['blueman-applet'], 'cc-switch': ['/usr/bin/cc-switch']}
    ours = os.environ.get('WAYLAND_DISPLAY')
    runtime = os.environ.get('XDG_RUNTIME_DIR')
    for entry in Path('/proc').glob('[0-9]*'):
        try:
            name = (entry / 'comm').read_text().strip()
            if entry.stat().st_uid != os.getuid() or name not in targets:
                continue
            env = dict(v.split('=', 1) for v in (entry / 'environ').read_bytes().decode(
                errors='replace').split('\0') if '=' in v)
            if env.get('WAYLAND_DISPLAY') == ours and env.get('XDG_RUNTIME_DIR') == runtime:
                os.kill(int(entry.name), signal.SIGTERM)
        except (OSError, ValueError):
            continue
    time.sleep(2)
    # Start via niri, preserving the current compositor's session environment.
    for argv in targets.values():
        action('spawn', '--', *argv)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=['float-workspace', 'notes', 'emoji', 'record', 'ocr', 'recover-tray', 'folder'])
    args = parser.parse_args()
    if not os.environ.get('NIRI_SOCKET'):
        raise SystemExit('请在 niri 会话中使用')
    os.environ['PATH'] = f'{DEPS}/key-cli/bin:{DEPS}/usr/bin:' + os.environ['PATH']
    os.environ['CLAVIS_KEY'] = str(KEY)
    # Serialize repeated presses per compositor and action, without blocking a second press.
    suffix = hashlib.sha256(os.environ['NIRI_SOCKET'].encode()).hexdigest()[:12]
    lock_path = Path(os.environ['XDG_RUNTIME_DIR']) / f'niri-clavis-{args.action}-{suffix}.lock'
    with lock_path.open('a') as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            return
        globals()[args.action.replace('-', '_')]()


if __name__ == '__main__':
    try:
        main()
    except (OSError, ValueError, RuntimeError, subprocess.SubprocessError) as error:
        print(f'niri action: {error}', file=sys.stderr)
        notify('操作未完成；请查看 Clavis 使用文档排障')
        raise SystemExit(1)
