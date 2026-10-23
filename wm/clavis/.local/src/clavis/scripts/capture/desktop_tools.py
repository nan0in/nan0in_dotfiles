#!/usr/bin/env python3
"""User-triggered local desktop tools; never upload captured images."""
import argparse
import fcntl
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import time

PNG_IEND = b'\x00\x00\x00\x00IEND\xaeB`\x82'


def run(*argv, **kwargs):
    return subprocess.run(list(map(str, argv)), check=True, **kwargs)


def notify(message):
    try:
        subprocess.run(['notify-send', '-a', 'Clavis', '--', message], check=False, timeout=3)
    except (OSError, subprocess.TimeoutExpired):
        pass


def open_directory(path):
    path = Path(path).expanduser()
    if not path.is_absolute():
        raise ValueError('Expected an absolute directory')
    path.mkdir(parents=True, exist_ok=True)
    # Respect the system directory association (also edited by Clavis settings).
    # Use a URI so Unicode, spaces and leading punctuation stay one argument.
    if shutil.which('gio'):
        try:
            run('gio', 'open', path.as_uri(), timeout=15)
            return
        except (OSError, subprocess.SubprocessError):
            pass
    # Fallbacks only: normal selection remains the system default, not hardcoded.
    for command in ['nautilus', 'thunar', 'dolphin']:
        if not shutil.which(command):
            continue
        try:
            run(command, path, timeout=15)
            return
        except (OSError, subprocess.SubprocessError):
            continue
    raise RuntimeError('No working file manager: select one in Settings > Default applications')


def niri_region_capture(image):
    """Fallback selector for systems without slurp/grim.

    niri's screenshot UI has no cancellation event, so keep the wait short.
    slurp is the normal path because it returns immediately on cancel.
    """
    try:
        run('niri', 'msg', 'action', 'screenshot', '--path', image, timeout=10,
            capture_output=True)
    except (OSError, subprocess.SubprocessError) as error:
        print(f'Clavis desktop tool: niri screenshot unavailable: {error}', file=sys.stderr)
        return False
    deadline = time.monotonic() + 45
    while time.monotonic() < deadline:
        try:
            if image.is_file() and image.stat().st_size > len(PNG_IEND):
                with image.open('rb') as stream:
                    stream.seek(-len(PNG_IEND), os.SEEK_END)
                    if stream.read() == PNG_IEND:
                        return True
        except OSError:
            pass
        time.sleep(.15)
    return False


def select_region():
    """Return a slurp geometry, None for a normal cancel, or False to fall back."""
    if not (shutil.which('slurp') and shutil.which('grim')):
        return False
    try:
        selection = subprocess.run(['slurp', '-d'], capture_output=True, text=True, timeout=120)
    except (OSError, subprocess.TimeoutExpired) as error:
        print(f'Clavis desktop tool: slurp failed: {error}', file=sys.stderr)
        return False
    if selection.returncode == 0 and selection.stdout.strip():
        return selection.stdout.strip()
    # A non-zero exit with no error text is a normal cancellation.
    if selection.returncode != 0 and selection.stderr.strip():
        print(f'Clavis desktop tool: slurp failed: {selection.stderr.strip()}', file=sys.stderr)
        return False
    return None


def recognize(kind, image):
    if kind == 'ocr':
        result = run('tesseract', image, 'stdout', '-l', 'chi_sim+eng',
                     capture_output=True, text=True, timeout=90)
    else:
        result = subprocess.run(['zbarimg', '--quiet', '--raw', str(image)],
                                capture_output=True, text=True, timeout=15)
        if result.returncode == 4:
            return ''
        if result.returncode != 0:
            raise RuntimeError(f'zbarimg failed: {result.stderr.strip()}')
    return result.stdout.strip()


def capture_text(kind, image_path=None):
    if image_path:
        image = Path(image_path).expanduser()
        if not image.is_absolute() or not image.is_file():
            raise ValueError('Expected an absolute image path')
        return recognize(kind, image)
    selection = select_region()
    if selection is None:
        return None
    if selection is False:
        with tempfile.TemporaryDirectory(prefix='clavis-tool-',
                                         dir=os.environ['XDG_RUNTIME_DIR']) as directory:
            image = Path(directory) / 'region.png'
            if not niri_region_capture(image):
                return None
            return recognize(kind, image)
    with tempfile.TemporaryDirectory(prefix='clavis-tool-', dir=os.environ['XDG_RUNTIME_DIR']) as directory:
        image = Path(directory) / 'region.png'
        run('grim', '-g', selection, image, timeout=15)
        return recognize(kind, image)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=['ocr', 'qr', 'screenshots', 'recordings', 'screenshot', 'lens', 'folder'])
    parser.add_argument('--directory')
    parser.add_argument('--image', help='Read this image instead of selecting a region (ocr/qr only)')
    parser.add_argument('--copied-message', default='Copied to clipboard')
    parser.add_argument('--empty-message', default='No text or QR code found')
    parser.add_argument('--error-message', default='Tool failed; check the desktop tool log')
    args = parser.parse_args()
    if args.image and args.action not in ('ocr', 'qr'):
        raise ValueError('--image is only valid for ocr and qr')
    if not os.environ.get('NIRI_SOCKET'):
        raise RuntimeError('Use this tool inside niri')
    runtime = Path(os.environ['XDG_RUNTIME_DIR'])
    # Repeated clicks must not create overlapping region selectors.
    lock_name = 'selection' if args.action in ('ocr', 'qr', 'screenshot') and not args.image else args.action
    with (runtime / f'clavis-desktop-tool-{lock_name}.lock').open('a') as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            return
        if not args.image:
            time.sleep(.35)  # Let Keystone close before selecting pixels.
        if args.action in ('ocr', 'qr'):
            text = capture_text(args.action, args.image)
            if text is None:
                return
            if text:
                run('wl-copy', '--', input=text, text=True, timeout=5)
            notify(args.copied_message if text else args.empty_message)
        elif args.action == 'folder':
            open_directory(args.directory or Path.home())
        elif args.action in ('screenshots', 'recordings'):
            if args.action == 'screenshots':
                pictures = subprocess.check_output(['xdg-user-dir', 'PICTURES'], text=True, timeout=5).strip()
                directory = str(Path(pictures) / 'Screenshots')
            else:
                directory = args.directory
            if not directory:
                raise ValueError('No recording directory configured')
            open_directory(directory)
        elif args.action == 'screenshot':
            config = Path(os.environ.get('NIRI_CONFIG', ''))
            if not config.is_absolute():
                raise ValueError('NIRI_CONFIG must point to the active profile')
            run('python3', config.parent / 'scripts/screenshot.py', 'menu')
        elif args.action == 'lens':
            # A browser file picker is intentional: image upload remains manual.
            run('xdg-open', 'https://lens.google/', timeout=15)


if __name__ == '__main__':
    try:
        main()
    except (OSError, ValueError, RuntimeError, subprocess.SubprocessError) as error:
        print(f'Clavis desktop tool: {error}', file=sys.stderr)
        try:
            state = Path(os.environ.get('CLAVIS_STATE_HOME') or
                         str(Path(os.environ.get('XDG_STATE_HOME', str(Path.home() / '.local/state'))) / 'clavis'))
            state.mkdir(parents=True, exist_ok=True)
            with (state / 'desktop-tools.log').open('a') as log:
                log.write(time.strftime('%Y-%m-%d %H:%M:%S ') + str(error) + '\n')
        except OSError:
            pass
        # The caller supplies translated messages without exposing OCR contents.
        try:
            message = sys.argv[sys.argv.index('--error-message') + 1]
            subprocess.run(['notify-send', '-a', 'Clavis', '--', message], timeout=5, check=False)
        except (OSError, ValueError, IndexError, subprocess.SubprocessError):
            pass
        raise SystemExit(1)
