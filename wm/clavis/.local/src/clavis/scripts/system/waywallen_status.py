#!/usr/bin/env python3
"""Read Waywallen's live selection; cache color sources without changing wallpapers."""
import fcntl
import hashlib
import json
import os
from pathlib import Path
import shlex
import shutil
import sqlite3
import subprocess
import tempfile
import time
import tomllib

IMAGES = {'.jpg', '.jpeg', '.png', '.webp', '.gif', '.bmp', '.avif'}
VIDEOS = {'.mp4', '.mkv', '.webm', '.mov', '.m4v', '.avi', '.ogv'}


def availability():
    home = Path.home()
    executable = home / '.local/bin/waywallen'
    command = str(executable) if executable.is_file() and os.access(executable, os.X_OK) else shutil.which('waywallen') or ''
    runtime = Path(os.environ.get('XDG_RUNTIME_DIR', '/nonexistent'))
    return dict(schemaVersion=1, available=bool(command), running=(runtime / 'waywallen/display.sock').is_socket(),
                command=command, title='', previewPath='', wallpaperId='', previewState='pending',
                previewSource='', displays=[], error='')


def live_selection():
    try:
        response = subprocess.check_output([
            'busctl', '--user', '--timeout=1', 'get-property', 'org.waywallen.waywallen.Daemon',
            '/org/waywallen/waywallen/Daemon', 'org.waywallen.waywallen.Daemon1', 'CurrentWallpaperId'
        ], text=True, stderr=subprocess.DEVNULL, timeout=2)
        fields = shlex.split(response)
        return fields[1] if len(fields) == 2 and fields[0] == 's' and fields[1] else ''
    except (OSError, ValueError, subprocess.SubprocessError):
        return ''


def cached_preview(identifier, source, video):
    stat = source.stat()
    key = hashlib.sha256(f'v2\0{identifier}\0{source}\0{stat.st_mtime_ns}\0{stat.st_size}'.encode()).hexdigest()[:32]
    cache = Path(os.environ.get('CLAVIS_CACHE_HOME', str(Path(os.environ.get('XDG_CACHE_HOME', str(Path.home() / '.cache'))) / 'clavis'))) / 'waywallen-previews'
    if cache.is_symlink():
        raise ValueError('Linked preview cache preserved')
    cache.mkdir(parents=True, exist_ok=True, mode=0o700)
    target = cache / f'color-{key}.png'
    failed = cache / f'color-{key}.failed'
    with (cache / '.lock').open('a') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        if target.is_file() and not target.is_symlink():
            with target.open('rb') as image:
                if image.read(8) == b'\x89PNG\r\n\x1a\n':
                    return str(target)
        if failed.is_file() and time.time() - failed.stat().st_mtime < 60:
            return ''
        if not shutil.which('ffmpeg'):
            # Existing still previews remain usable without the optional decoder.
            return str(source) if not video and source.suffix.lower() in {'.jpg', '.jpeg', '.png', '.webp'} else ''
        # Prefer a representative video frame over the first frame: many clips
        # fade in from black, and that black frame would become the theme color.
        if video:
            attempts = [
                ((), 'thumbnail=100,scale=512:512:force_original_aspect_ratio=decrease'),
                (('-ss', '1'), 'scale=512:512:force_original_aspect_ratio=decrease'),
                ((), 'scale=512:512:force_original_aspect_ratio=decrease'),
            ]
        else:
            attempts = [((), 'scale=512:512:force_original_aspect_ratio=decrease')]
        for seek, filter_spec in attempts:
            with tempfile.TemporaryDirectory(prefix='.frame-', dir=cache) as temporary:
                output = Path(temporary) / 'preview.png'
                command = ['ffmpeg', '-nostdin', '-hide_banner', '-loglevel', 'error',
                           '-protocol_whitelist', 'file,pipe', '-threads', '1']
                command += list(seek)
                command += ['-i', str(source), '-an', '-sn', '-dn', '-map', '0:v:0',
                            '-vf', filter_spec,
                            '-frames:v', '1', '-threads', '1', '-filter_threads', '1',
                            '-update', '1', str(output)]
                try:
                    result = subprocess.run(command, capture_output=True, timeout=20)
                    if result.returncode == 0 and output.is_file() and output.stat().st_size > 8:
                        os.chmod(output, 0o600)
                        os.replace(output, target)
                        failed.unlink(missing_ok=True)
                        # This dedicated cache owns only these generated PNG filenames.
                        owned = sorted(cache.glob('color-*.png'), key=lambda p: p.stat().st_mtime, reverse=True)
                        for old in owned[48:]:
                            if old != target and not old.is_symlink():
                                old.unlink()
                        return str(target)
                except (OSError, subprocess.SubprocessError):
                    continue
        failed.touch()
        return ''


def item_preview(identifier, row):
    name, preview, item_path, library = row
    base = Path(library)
    media = Path(item_path)
    if not media.is_absolute():
        media = base / media
    directory = media if media.is_dir() else media.parent
    is_image = media.is_file() and media.suffix.lower() in IMAGES
    is_video = media.is_file() and media.suffix.lower() in VIDEOS
    # The wallpaper itself is the authoritative color source. Database and
    # project previews can be cropped, letterboxed, or captured from a different
    # frame, so they are fallbacks rather than the first choice.
    if is_video:
        path = cached_preview(identifier, media, True)
        if path:
            return dict(title=name, previewPath=path, previewState='ready', previewSource='video-frame', wallpaperId=str(identifier))
    candidates = []
    if is_image:
        candidates.append((media, 'image'))
    if preview:
        candidate = Path(preview)
        candidates.append((candidate if candidate.is_absolute() else base / candidate, 'database-preview'))
    project = directory / 'project.json'
    if project.is_file() and project.stat().st_size <= 1024 * 1024:
        try:
            manifest = json.loads(project.read_text())
            if isinstance(manifest.get('preview'), str) and manifest['preview']:
                candidates.append((directory / manifest['preview'], 'project-preview'))
        except (OSError, ValueError, AttributeError):
            pass
    for suffix in ['jpg', 'png', 'gif', 'webp', 'jpeg']:
        candidates.append((directory / ('preview.' + suffix), 'project-preview'))
    for candidate, origin in candidates:
        if candidate.is_file() and candidate.suffix.lower() in IMAGES:
            path = cached_preview(identifier, candidate, False)
            if path:
                return dict(title=name, previewPath=path, previewState='ready', previewSource=origin, wallpaperId=str(identifier))
    return dict(title=name, previewPath='', previewState='unavailable', previewSource='', wallpaperId=str(identifier))


def status():
    result = availability()
    home = Path.home()
    config = Path(os.environ.get('XDG_CONFIG_HOME', home / '.config'))
    data = Path(os.environ.get('XDG_DATA_HOME', home / '.local/share'))
    path = config / 'waywallen/config.toml'
    database = data / 'waywallen/waywallen-v2.db'
    settings = tomllib.loads(path.read_text()) if path.is_file() else {}
    selected = live_selection()
    if selected:
        result['running'] = True
    selected = selected or str(settings.get('global', {}).get('last_wallpaper', ''))
    result['wallpaperId'] = selected
    display_ids = [(name, str(display['last_wallpaper'])) for name, display in settings.get('display', {}).items()
                   if name.startswith('layer-') and display.get('last_wallpaper')]
    if not database.is_file():
        result['previewState'] = 'unavailable' if selected else 'pending'
        return result
    records = {}
    with sqlite3.connect(database.as_uri() + '?mode=ro', uri=True, timeout=1) as connection:
        connection.execute('PRAGMA query_only=ON')
        for identifier in {selected, *(value for _, value in display_ids)}:
            row = connection.execute('SELECT i.display_name,i.preview_path,i.path,l.path FROM item i '
                                     'JOIN library l ON i.library_id=l.id WHERE i.id=?', (identifier,)).fetchone()
            records[identifier] = row
    # Release the read transaction before decoding any image/video.
    previews = {identifier: item_preview(identifier, row) if row else
                dict(title='', previewPath='', previewState='unavailable', previewSource='', wallpaperId=identifier)
                for identifier, row in records.items()}
    result.update(previews[selected])
    result['displays'] = [dict(display=name, **previews[identifier]) for name, identifier in display_ids]
    return result


if __name__ == '__main__':
    try:
        response = status()
    except (OSError, ValueError, sqlite3.Error) as error:
        response = availability()
        response.update(error=str(error), previewState='unavailable')
    print(json.dumps(response, ensure_ascii=False))
