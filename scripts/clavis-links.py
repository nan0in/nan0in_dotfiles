#!/usr/bin/env python3
"""Install owned links and a writable profile; preserve locally edited files."""
import hashlib
import json
import os
from pathlib import Path
import shutil
import sys
import tempfile
import subprocess


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def atomic_link(src, dst):
    tmp = dst.with_name(dst.name + '.clavis-new')
    if os.path.lexists(tmp):
        raise RuntimeError(f'Temporary path exists: {tmp}')
    tmp.symlink_to(src, target_is_directory=src.is_dir())
    os.replace(tmp, dst)


def main():
    action, root = sys.argv[1], Path(sys.argv[2]).resolve()
    if action not in ('check', 'install', 'uninstall'):
        raise SystemExit('Unknown action')
    home = Path.home()
    config = Path(os.environ.get('XDG_CONFIG_HOME', home / '.config'))
    package = root / 'wm/clavis'
    profile = config / 'niri-clavis'
    seed = package / '.config/niri-clavis'
    state = Path(os.environ.get('XDG_STATE_HOME', home / '.local/state')) / 'clavis'
    manifest = state / 'profile-install.json'
    pairs = [
        (package / '.local/src/clavis', home / '.local/src/clavis'),
        (package / '.local/src/clavis', config / 'quickshell/clavis'),
        (package / '.config/systemd/user/clavis-shell.service', config / 'systemd/user/clavis-shell.service'),
        (package / '.config/systemd/user/clavis-startup.service', config / 'systemd/user/clavis-startup.service'),
        (package / '.config/systemd/user/clavis-clipboard.service', config / 'systemd/user/clavis-clipboard.service'),
        (package / '.config/systemd/user/clavis-x11-minimize.service', config / 'systemd/user/clavis-x11-minimize.service'),
        (package / '.config/systemd/user/niri.service.d/80-clavis.conf', config / 'systemd/user/niri.service.d/80-clavis.conf'),
        (package / '.config/systemd/user/niri-idle.service.d/80-clavis.conf', config / 'systemd/user/niri-idle.service.d/80-clavis.conf'),
        (package / '.config/systemd/user/niri-sleep-lock.service.d/80-clavis.conf', config / 'systemd/user/niri-sleep-lock.service.d/80-clavis.conf'),
    ]

    def owned(src, dst):
        legacy = root / src.relative_to(root / 'wm')
        return dst.is_symlink() and dst.resolve() in (src.resolve(), legacy.resolve())

    legacy_profile = profile.is_symlink() and profile.resolve() in (seed, root / 'clavis/.config/niri-clavis')
    conflicts = [str(dst) for src, dst in pairs if os.path.lexists(dst) and not owned(src, dst)]
    if os.path.lexists(profile) and not legacy_profile and (profile.is_symlink() or not profile.is_dir() or not manifest.exists()):
        conflicts.append(str(profile))
    if conflicts:
        raise SystemExit('Existing paths preserved; nothing changed:\n' + '\n'.join(conflicts))
    if action == 'check':
        for src, dst in pairs:
            print(('OWNED  ' if owned(src, dst) else 'NEW    ') + str(dst))
        print(('MIGRATE' if legacy_profile else 'PROFILE') + ' ' + str(profile))
        return
    if action == 'uninstall':
        for src, dst in reversed(pairs):
            if owned(src, dst):
                dst.unlink()
        print('Removed only owned links. Writable profile, personal settings and source retained.')
        return

    old = json.loads(manifest.read_text()) if manifest.exists() else {'files': {}}
    if old.get('path', str(profile)) != str(profile):
        raise SystemExit('Profile location changed; existing deployment preserved.')
    state.mkdir(parents=True, exist_ok=True)
    # Replace only our historical directory link, never a personal file/directory.
    if legacy_profile:
        staging = Path(tempfile.mkdtemp(prefix='niri-clavis-', dir=profile.parent))
        shutil.copytree(profile if profile.exists() else seed, staging, dirs_exist_ok=True)
        # Rollback copy is independent of the live QML/FileView writers.
        backup = Path(tempfile.mkdtemp(prefix='profile-backup-', dir=state))
        shutil.copytree(staging, backup, dirs_exist_ok=True)
        profile.unlink()
        try:
            staging.rename(profile)
        except BaseException:
            profile.symlink_to(seed)
            raise
        old = {'files': {str(p.relative_to(seed)): digest(p) for p in seed.rglob('*')
                         if p.is_file() and 'settings' not in p.relative_to(seed).parts}}
    profile.mkdir(parents=True, exist_ok=True)
    files = dict(old['files'])
    for src in sorted(seed.rglob('*')):
        relative = src.relative_to(seed)
        if not src.is_file() or '__pycache__' in relative.parts:
            continue
        dst = profile / relative
        key = str(relative)
        runtime = relative.parts[0] in ('settings', 'clavis') or key == 'local.kdl'
        if any(p.is_symlink() for p in [dst, *dst.parents] if p != profile.parent):
            print('PRESERVE linked path ' + str(dst))
            continue
        if os.path.lexists(dst):
            if dst.is_symlink() or not dst.is_file():
                print('PRESERVE ' + str(dst))
                continue
            if runtime or files.get(key) != digest(dst):
                print('PRESERVE ' + str(dst))
                continue
        dst.parent.mkdir(parents=True, exist_ok=True)
        # Atomic replacement, preserving source executable bits.
        with tempfile.NamedTemporaryFile(dir=dst.parent, delete=False) as stream:
            temp = Path(stream.name)
        try:
            shutil.copy2(src, temp)
            if key == 'clavis/yazi.kdl':
                temp.write_bytes(temp.read_bytes().replace(b'@CLAVIS_YAZI_HOME@', str(profile / 'settings/yazi').encode()))
            os.replace(temp, dst)
        finally:
            temp.unlink(missing_ok=True)
        files[key] = digest(dst)
    for src, dst in pairs:
        dst.parent.mkdir(parents=True, exist_ok=True)
        if not owned(src, dst) or dst.resolve() != src.resolve():
            atomic_link(src, dst)
    manifest.write_text(json.dumps({'path': str(profile), 'files': files}, indent=2) + '\n')
    environment = os.environ.copy()
    environment['CLAVIS_CONFIG_HOME'] = str(profile / 'settings')
    for name, action_args in [('install_material_theme.py', []), ('yazi_theme.py', ['prepare'])]:
        helper = package / '.local/src/clavis/scripts/theme' / name
        if helper.is_file():
            result = subprocess.run([sys.executable, str(helper), *action_args], env=environment, check=False)
            if result.returncode:
                print('PRESERVE existing resource; review helper output: ' + name)
    print('Installed. Existing personal edits preserved. No compositor or Shell restarted.')


if __name__ == '__main__':
    main()
