#!/usr/bin/env python3
"""Apply Material/Fusion Dracula Qt styling with reversible, targeted changes."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import tempfile

ROOT = Path(__file__).resolve().parents[1]
HOME = Path.home()
CONFIG = Path(os.environ.get('XDG_CONFIG_HOME', HOME / '.config'))
STATE = Path(os.environ.get('XDG_STATE_HOME', HOME / '.local/state')) / 'clavis'
TARGET = CONFIG / 'qt6ct/qt6ct.conf'
PALETTE = ROOT / 'wm/clavis/assets/dracula-qt/Dracula.conf'
MANIFEST = STATE / 'appearance-install.json'
KEYS = {'style': 'Fusion', 'custom_palette': 'true', 'color_scheme_path': str(PALETTE)}


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def atomic_write(path, content, mode):
    with tempfile.NamedTemporaryFile(dir=path.parent, delete=False) as stream:
        temp = Path(stream.name)
    try:
        temp.write_bytes(content)
        temp.chmod(mode)
        os.replace(temp, path)
    finally:
        temp.unlink(missing_ok=True)


def replace_section(text, section, values):
    match = re.search(r'(?ms)^\[' + re.escape(section) + r'\]\n(.*?)(?=^\[|\Z)', text)
    if not match:
        return text.rstrip() + '\n\n[' + section + ']\n' + ''.join(f'{k} = {v}\n' for k, v in values.items())
    body = match[1]
    for key, value in values.items():
        pattern = r'(?m)^' + re.escape(key) + r'\s*=.*$'
        if re.search(pattern, body):
            body = re.sub(pattern, lambda _: key + ' = ' + value, body)
        else:
            body += key + ' = ' + value + '\n'
    return text[:match.start(1)] + body + text[match.end(1):]


def records(manifest):
    if not manifest:
        return {}
    return manifest.get('files') or {str(TARGET): {'backup': manifest['backup'],
                                                 'applied_sha256': manifest['applied_sha256']}}


def regular_target(path, missing=False):
    if any(p.is_symlink() for p in [path, *path.parents]):
        raise SystemExit('Linked personal configuration preserved: ' + str(path))
    if path.exists() and not path.is_file() or not missing and not path.is_file():
        raise SystemExit('Missing or special configuration preserved: ' + str(path))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=['apply', 'restore'])
    parser.add_argument('--style', choices=['material', 'fusion'], default='material')
    args = parser.parse_args()
    regular_target(TARGET)
    STATE.mkdir(parents=True, exist_ok=True)
    manifest = json.loads(MANIFEST.read_text()) if MANIFEST.exists() else None
    if args.action == 'restore':
        previous = records(manifest)
        if not previous:
            raise SystemExit('No applied appearance record.')
        for name, entry in previous.items():
            path = Path(name)
            regular_target(path)
            if digest(path) != entry['applied_sha256']:
                raise SystemExit('Preferences changed; retained for manual comparison: ' + name)
        for name, entry in previous.items():
            path = Path(name)
            if entry['backup']:
                backup = Path(entry['backup'])
                atomic_write(path, backup.read_bytes(), backup.stat().st_mode & 0o777)
            else:
                path.unlink()
        if manifest.get('previous_manifest'):
            atomic_write(MANIFEST, (json.dumps(manifest['previous_manifest'], indent=2) + '\n').encode(), 0o600)
        else:
            MANIFEST.unlink()
        print('Previous Qt preferences restored. Applications and theme assets retained.')
        return
    keys = dict(KEYS, style='kvantum' if args.style == 'material' else 'Fusion')
    old = {TARGET: TARGET.read_bytes()}
    updated = {TARGET: replace_section(old[TARGET].decode(), 'Appearance', keys).encode()}
    # KDE apps can replace qt6ct's palette with their automatic Breeze fallback.
    # Give Dolphin an explicit scheme and readable, app-specific dark icons.
    dolphin = CONFIG / 'dolphinrc'
    regular_target(dolphin, missing=True)
    old[dolphin] = dolphin.read_bytes() if dolphin.exists() else None
    text = replace_section((old[dolphin] or b'').decode(), 'UiSettings', {'ColorScheme': 'ClavisDracula'})
    updated[dolphin] = replace_section(text, 'Icons', {'Theme': 'breeze-dark'}).encode()
    scheme = ROOT / 'wm/clavis/assets/dracula-qt/ClavisDracula.colors'
    data_home = Path(os.environ.get('XDG_DATA_HOME', HOME / '.local/share'))
    links = {data_home / 'color-schemes/ClavisDracula.colors': scheme}
    if not Path('/usr/share/icons/breeze-dark/index.theme').is_file():
        raise SystemExit('Dolphin dark icon theme is missing: breeze-dark')
    theme = ROOT / 'wm/clavis/assets/material-dracula/ClavisMaterialDracula'
    link = CONFIG / 'Kvantum/ClavisMaterialDracula'
    if args.style == 'material':
        kvantum = CONFIG / 'Kvantum/kvantum.kvconfig'
        regular_target(kvantum, missing=True)
        if not all((theme / ('ClavisMaterialDracula.' + ext)).is_file() for ext in ['svg', 'kvconfig']):
            raise SystemExit('Material theme assets missing.')
        links[link] = theme
        old[kvantum] = kvantum.read_bytes() if kvantum.exists() else None
        text = (old[kvantum] or b'').decode()
        updated[kvantum] = replace_section(text, 'General', {'theme': 'ClavisMaterialDracula'}).encode()
    for link, asset in links.items():
        if not asset.exists():
            raise SystemExit('Missing appearance asset: ' + str(asset))
        if any(parent.is_symlink() for parent in link.parents):
            raise SystemExit('Linked theme parent preserved: ' + str(link))
        if os.path.lexists(link) and not (link.is_symlink() and link.resolve() == asset.resolve()):
            raise SystemExit('Existing personal theme preserved: ' + str(link))
    if all(old[path] == value for path, value in updated.items()):
        for link, asset in links.items():
            if not os.path.lexists(link):
                link.parent.mkdir(parents=True, exist_ok=True)
                link.symlink_to(asset)
        print('Requested Qt style already selected.')
        return
    backup_dir = Path(tempfile.mkdtemp(prefix='qt-before-' + args.style + '-', dir=STATE))
    previous_is_current = bool(manifest) and all(Path(name).is_file() and digest(Path(name)) == entry['applied_sha256']
                                               for name, entry in records(manifest).items())
    saved = {}
    for path, data in old.items():
        backup = backup_dir / path.name
        if data is not None:
            backup.write_bytes(data)
            backup.chmod(path.stat().st_mode & 0o777)
        saved[str(path)] = {'backup': str(backup) if data is not None else None,
                            'applied_sha256': hashlib.sha256(updated[path]).hexdigest()}
    applied = []
    try:
        for link, asset in links.items():
            if not os.path.lexists(link):
                link.parent.mkdir(parents=True, exist_ok=True)
                link.symlink_to(asset)
        for path, value in updated.items():
            current = path.read_bytes() if path.exists() else None
            if current != old[path]:
                raise RuntimeError('Preferences changed during application: ' + str(path))
            path.parent.mkdir(parents=True, exist_ok=True)
            atomic_write(path, value, path.stat().st_mode & 0o777 if path.exists() else 0o600)
            applied.append(path)
        record = dict(style=args.style, files=saved, previous_manifest=manifest if previous_is_current else None)
        atomic_write(MANIFEST, (json.dumps(record, indent=2) + '\n').encode(), 0o600)
    except BaseException:
        for path in reversed(applied):
            if path.read_bytes() == updated[path]:
                if old[path] is None:
                    path.unlink()
                else:
                    atomic_write(path, old[path], Path(saved[str(path)]['backup']).stat().st_mode & 0o777)
        raise
    print('Qt ' + args.style + ' Dracula selected; Dolphin dark scheme/icons aligned. Fonts and unrelated preferences retained.')


if __name__ == '__main__':
    main()
