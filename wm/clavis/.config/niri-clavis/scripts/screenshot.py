#!/usr/bin/env python3
"""Capture with niri/grim; annotate natively in Satty, with optional Spectacle."""
import argparse
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import time

PROFILE = Path(__file__).resolve().parents[1]
PNG_END = b'\x00\x00\x00\x00IEND\xaeB`\x82'


def notify(text):
    subprocess.run(['notify-send', '-a', '截图', text], check=False)


def complete_png(path):
    try:
        with path.open('rb') as stream:
            if stream.read(8) != b'\x89PNG\r\n\x1a\n':
                return False
            stream.seek(-12, 2)
            return stream.read() == PNG_END
    except (OSError, ValueError):
        return False


def choose():
    choices = [
        ('选取区域 → Satty 编辑', 'region', 0, False),
        ('当前窗口 → Satty 编辑', 'window', 0, False),
        ('当前屏幕 → Satty 编辑', 'screen', 0, False),
        ('全部屏幕 → Satty 编辑', 'desktop', 0, False),
        ('5 秒后选区（适合展开菜单）', 'region', 5, False),
        ('5 秒后截当前屏幕，包含鼠标', 'screen', 5, True),
        ('选取区域 → 备用 Spectacle 编辑', 'spectacle', 0, False),
    ]
    result = subprocess.run(['fuzzel', '--dmenu', '--prompt', '截图: ', '--lines', str(len(choices))],
                            input='\n'.join(c[0] for c in choices), text=True, capture_output=True, check=False)
    return next((c[1:] for c in choices if c[0] == result.stdout.strip()), None)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('kind', choices=['region', 'window', 'screen', 'desktop', 'menu'], nargs='?', default='region')
    parser.add_argument('--delay', type=float, default=0)
    parser.add_argument('--pointer', action='store_true')
    parser.add_argument('--editor', choices=['spectacle', 'satty'], default='satty')
    args = parser.parse_args()
    if not os.environ.get('NIRI_SOCKET'):
        raise SystemExit('请在 niri 会话中使用')
    if args.kind == 'menu':
        selection = choose()
        if not selection:
            return
        args.kind, args.delay, args.pointer = selection
        if args.kind == 'spectacle':
            args.kind, args.editor = 'region', 'spectacle'
    if not 0 <= args.delay <= 60:
        raise SystemExit('延迟范围为 0…60 秒')
    if args.delay:
        notify(f'{args.delay:g} 秒后开始截图')
        time.sleep(args.delay)
    with tempfile.TemporaryDirectory(prefix='clavis-shot-', dir=os.environ['XDG_RUNTIME_DIR']) as directory:
        image = Path(directory) / 'capture.png'
        if args.kind == 'desktop':
            command = ['grim', *(['-c'] if args.pointer else []), str(image)]
        else:
            action = {'region': 'screenshot', 'window': 'screenshot-window', 'screen': 'screenshot-screen'}[args.kind]
            command = ['niri', 'msg', 'action', action, '--show-pointer', str(args.pointer).lower(), '--path', str(image)]
        result = subprocess.run(command, capture_output=True, text=True, check=False, timeout=120)
        if result.returncode:
            notify('截图未完成：' + result.stderr.strip()[:160])
            return
        deadline = time.monotonic() + 120
        while not complete_png(image):
            if time.monotonic() >= deadline:
                return  # Cancelled: never open an editor with an old screenshot.
            time.sleep(.1)
        if args.editor == 'spectacle' and shutil.which('spectacle') and os.environ.get('DISPLAY'):
            # A separate editor keeps the temporary image alive until this editor exits.
            command = ['spectacle', '--new-instance', '--edit-existing', str(image)]
        else:
            command = ['satty', '--config', str(Path.home() / '.config/niri/satty/config.toml'), '--filename', str(image)]
        editor_env = os.environ.copy()
        if args.editor == "spectacle" and command[0] == "spectacle" and editor_env.get("DISPLAY"):
            # Spectacle 6.8 checks KWin even for imported images on its Wayland backend.
            # Use only its XWayland image editor; capture remains native niri/grim.
            editor_env.update(QT_QPA_PLATFORM="xcb", XDG_SESSION_TYPE="x11")
        subprocess.run(command, check=True, env=editor_env)


if __name__ == '__main__':
    try:
        main()
    except subprocess.TimeoutExpired:
        pass
    except (OSError, subprocess.CalledProcessError) as error:
        print(error)
        notify('截图编辑异常；Super+Alt+Print 保留原生截图入口')
