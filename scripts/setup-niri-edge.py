#!/usr/bin/env python3
"""Build pinned niri-edge privately; select it for the next normal Niri login."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import tarfile

ROOT = Path(__file__).resolve().parents[1]
PACKAGE = ROOT / 'wm/niri-edge'
URL, COMMIT = (PACKAGE / 'UPSTREAM').read_text().splitlines()
HOME = Path.home()
CACHE = Path(os.environ.get('XDG_CACHE_HOME', HOME / '.cache')) / 'nan0in-niri-edge'
PREFIX = HOME / '.local/opt/niri-edge'
BINARY = PREFIX / 'bin/niri'
MANIFEST = PREFIX / 'installed.json'
CONFIG = Path(os.environ.get('XDG_CONFIG_HOME', HOME / '.config'))
PATCHES = sorted((PACKAGE / 'patches').glob('*.patch'))
BUILD_VERSION = '26.04 (clavis-native-1 b2aaeb3)'
PAIRS = [(PACKAGE / '.config/systemd/user' / name, CONFIG / 'systemd/user' / name)
         for name in ('niri.service.d/90-niri-edge.conf', 'clavis-shell.service.d/90-niri-edge.conf')]


def run(*argv, **kwargs):
    return subprocess.run(list(map(str, argv)), check=True, **kwargs)


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def owned(src, dst):
    return dst.is_symlink() and dst.resolve() == src.resolve()


def check_binary(require_patches=True):
    if not MANIFEST.is_file() or not BINARY.is_file():
        raise SystemExit('Build first: python3 scripts/setup-niri-edge.py build')
    data = json.loads(MANIFEST.read_text())
    if data.get('commit') != COMMIT or data.get('sha256') != digest(BINARY):
        raise SystemExit('Private binary differs from its pinned manifest; preserved.')
    if require_patches and data.get('patches') != {p.name: digest(p) for p in PATCHES}:
        raise SystemExit('Desktop patches changed; rebuild the private binary before selecting it.')


def private_clang(env):
    # Arch's runtime has LLVM but may omit libclang, which bindgen needs.
    candidates = list(Path('/usr/lib').glob('libclang.so*'))
    if env.get('LIBCLANG_PATH') or candidates:
        return
    deps = CACHE / 'build-deps'
    library = deps / 'usr/lib/libclang.so'
    if not library.exists():
        location = subprocess.check_output(
            ['pacman', '-Sp', '--print-format', '%l', '--nodeps', 'clang-libs'], text=True
        ).strip().splitlines()[-1]
        name = location.rsplit('/', 1)[-1]
        url = 'https://geo.mirror.pkgbuild.com/extra/os/x86_64/' + name
        for suffix in ('', '.sig'):
            target = CACHE / (name + suffix)
            if not target.exists():
                temp = target.with_name(target.name + '.download')
                run('curl', '--fail', '--location', '--retry', '3', '--proto', '=https',
                    '--output', temp, url + suffix)
                temp.replace(target)
        run('gpgv', '--keyring', '/etc/pacman.d/gnupg/pubring.gpg',
            CACHE / (name + '.sig'), CACHE / name)
        deps.mkdir(parents=True, exist_ok=True)
        run('tar', '-xf', CACHE / name, '-C', deps, 'usr')
    env['LIBCLANG_PATH'] = str(library.parent)
    resources = sorted((deps / 'usr/lib/clang').glob('*/include/stdbool.h'))
    if resources:
        env['BINDGEN_EXTRA_CLANG_ARGS'] = ('-resource-dir=' + str(resources[-1].parents[1])
                                           + ' ' + env.get('BINDGEN_EXTRA_CLANG_ARGS', '')).strip()


def build():
    if PREFIX.exists() and not MANIFEST.is_file():
        raise SystemExit('Existing unmanaged private prefix preserved: ' + str(PREFIX))
    if BINARY.exists():
        check_binary(require_patches=False)
    CACHE.mkdir(parents=True, exist_ok=True)
    source = CACHE / 'source'
    if not source.exists():
        run('git', 'clone', '--no-checkout', '--filter=blob:none', URL + '.git', source)
        run('git', '-C', source, 'checkout', '--detach', COMMIT)
    actual = subprocess.check_output(['git', '-C', str(source), 'rev-parse', 'HEAD'], text=True).strip()
    dirty = subprocess.check_output(['git', '-C', str(source), 'status', '--porcelain'], text=True)
    if actual != COMMIT or dirty:
        raise SystemExit('Source cache differs from the pinned clean checkout; preserved.')
    patches = {p.name: digest(p) for p in PATCHES}
    patch_id = hashlib.sha256(json.dumps(patches, sort_keys=True).encode()).hexdigest()[:16]
    custom = CACHE / ('desktop-source-' + patch_id)
    ownership = CACHE / ('desktop-source-' + patch_id + '.json')
    if custom.exists():
        if not ownership.is_file():
            raise SystemExit('Unmanaged patched source preserved: ' + str(custom))
        expected = json.loads(ownership.read_text())
        actual_files = {str(p.relative_to(custom)): digest(p) for p in custom.rglob('*') if p.is_file()}
        if actual_files != expected:
            raise SystemExit('Patched source was edited manually; preserved: ' + str(custom))
    else:
        archive = CACHE / ('source-' + COMMIT + '.tar')
        run('git', '-C', source, 'archive', '--format=tar', '-o', archive, COMMIT)
        custom.mkdir()
        with tarfile.open(archive) as stream:
            stream.extractall(custom, filter='data')
        for patch in PATCHES:
            run('git', '-C', custom, 'apply', '--check', patch)
            run('git', '-C', custom, 'apply', patch)
        ownership.write_text(json.dumps({str(p.relative_to(custom)): digest(p) for p in custom.rglob('*') if p.is_file()}, sort_keys=True))
    env = os.environ.copy()
    env.update(CARGO_TARGET_DIR=str(CACHE / 'target'), CARGO_BUILD_JOBS='6', NIRI_BUILD_VERSION_STRING=BUILD_VERSION)
    private_clang(env)
    run('cargo', 'build', '--locked', '--release', '--manifest-path', custom / 'Cargo.toml', env=env)
    BINARY.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(dir=BINARY.parent, delete=False) as stream:
        temp = Path(stream.name)
    try:
        shutil.copy2(CACHE / 'target/release/niri', temp)
        os.replace(temp, BINARY)
    finally:
        temp.unlink(missing_ok=True)
    shutil.copy2(source / 'LICENSE', PREFIX / 'LICENSE')
    MANIFEST.write_text(json.dumps({'url': URL, 'commit': COMMIT, 'sha256': digest(BINARY), 'patches': patches, 'version': BUILD_VERSION}, indent=2) + '\n')
    run(BINARY, '--version')
    print('Built privately. System niri, session and personal configuration unchanged.')


def select(enable):
    # Never replace a personal file, link or symlinked ancestor.
    for src, dst in PAIRS:
        if any(p.is_symlink() for p in dst.parents if p != CONFIG.parent):
            raise SystemExit('Linked configuration parent preserved: ' + str(dst))
        if os.path.lexists(dst) and not owned(src, dst):
            raise SystemExit('Personal drop-in preserved: ' + str(dst))
    if not enable:
        helper = ROOT / 'wm/clavis/.local/src/clavis/scripts/theme/window_appearance.py'
        profile = CONFIG / 'niri-clavis/config.kdl'
        if helper.is_file() and (profile.parent / 'clavis/window-appearance.kdl').exists():
            env = os.environ.copy()
            env.update(NIRI_CONFIG=str(profile), CLAVIS_CONFIG_HOME=str(profile.parent / 'settings'))
            run('python3', helper, json.dumps({'operation': 'apply', 'compatible': True}), env=env)
    if enable:
        check_binary()
        profile = CONFIG / 'niri-clavis/config.kdl'
        run(BINARY, 'validate', '-c', profile)
        for src, dst in PAIRS:
            dst.parent.mkdir(parents=True, exist_ok=True)
            if not owned(src, dst):
                dst.symlink_to(src)
    else:
        for src, dst in reversed(PAIRS):
            if owned(src, dst):
                dst.unlink()
    run('systemctl', '--user', 'daemon-reload')
    print(('niri-edge' if enable else 'Distribution niri') + ' selected for next login; no service restarted.')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=['build', 'enable', 'disable', 'check'])
    action = parser.parse_args().action
    if action == 'build':
        build()
    elif action in ('enable', 'disable'):
        select(action == 'enable')
    else:
        check_binary()
        print('Pinned private binary: ' + str(BINARY))
        for src, dst in PAIRS:
            print(('SELECTED ' if owned(src, dst) else 'NOT SELECTED ') + str(dst))
        run(BINARY, 'validate', '-c', CONFIG / 'niri-clavis/config.kdl')


if __name__ == '__main__':
    main()
