#!/usr/bin/env python3
"""Install verified Clavis runtime dependencies into an exclusive user prefix.

Arch Linux only. No sudo, pacman transaction, global PATH or keyboard permissions.
"""
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import tarfile
import urllib.request
from xml.sax.saxutils import escape

HOME = Path.home()
PREFIX = HOME / '.local/opt/nan0in-clavis-deps'
CACHE = Path(os.environ.get('XDG_CACHE_HOME', HOME / '.cache')) / 'nan0in-clavis-build'
M3_COMMIT = '8a6fe8961749887d677700b6508e0c9249968b7e'
VERSION = '2026.9.25'
SYSMON_SOURCE_SHA256 = '2956cd28b6ce7c8dcbb64661b71df159fa2f8e797c114761f9d6aec6e6327a75'


def run(*args):
    subprocess.run(list(map(str, args)), check=True)


def download(url, dest, checksum=None):
    # HTTPS only. Download to a temporary file, then atomically publish.
    if not url.startswith('https://'):
        raise ValueError('HTTPS required')
    if not dest.exists() or (checksum and digest(dest) != checksum):
        temp = dest.with_name(dest.name + '.download')
        run('curl', '--fail', '--location', '--retry', '3', '--proto', '=https',
            '--output', temp, url)
        if checksum and digest(temp) != checksum:
            raise ValueError('Checksum mismatch: ' + dest.name)
        temp.replace(dest)
    return dest


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def install_key_sysmon():
    # The wheel contains only Python; its dispatcher requires this native backend.
    archive = download(
        f'https://github.com/StatIndet/key-cli/releases/download/v{VERSION}/key-cli-{VERSION}.tar.gz',
        CACHE / f'key-cli-{VERSION}.tar.gz', SYSMON_SOURCE_SHA256)
    source = CACHE / f'key-cli-{VERSION}'
    if not source.exists():
        with tarfile.open(archive) as stream:
            stream.extractall(CACHE, filter='data')
    build = CACHE / f'key-cli-{VERSION}-native-build'
    # Place key-sysmon next to the private key entrypoint; no global PATH changes.
    run('cmake', '-S', source / 'native', '-B', build, '-G', 'Ninja',
        '-DCMAKE_BUILD_TYPE=Release', '-DBUILD_TESTING=OFF',
        '-DCMAKE_INSTALL_PREFIX=' + str(PREFIX / 'key-cli'))
    run('cmake', '--build', build, '--parallel', '4')
    run('cmake', '--install', build)
    return {'version': VERSION, 'source_sha256': SYSMON_SOURCE_SHA256}


def main():
    if sys.argv[1:] not in ([], ['--sysmon-only']):
        raise SystemExit('Usage: clavis-deps.py [--sysmon-only]')
    marker = PREFIX / '.nan0in-clavis-managed'
    if PREFIX.exists() and not marker.is_file():
        raise SystemExit('Existing unmanaged dependency directory preserved: ' + str(PREFIX))
    PREFIX.mkdir(parents=True, exist_ok=True)
    marker.touch(exist_ok=True)
    CACHE.mkdir(parents=True, exist_ok=True)
    if sys.argv[1:] == ['--sysmon-only']:
        if not (PREFIX / 'key-cli/bin/key').is_file():
            raise SystemExit('Install private key-cli first with setup-clavis.sh deps.')
        manifest = PREFIX / 'installed.json'
        installed = json.loads(manifest.read_text()) if manifest.exists() else {}
        installed['key_sysmon'] = install_key_sysmon()
        manifest.write_text(json.dumps(installed, indent=2) + '\n')
        print('Private system monitor installed; no service restarted.')
        return
    installed = {}
    for package in ('qt6-lottie', 'maplibre-native-qt', 'cliphist', 'ttf-material-symbols-variable', 'wl-mirror'):
        location = subprocess.check_output(
            ['pacman', '-Sp', '--print-format', '%l', '--nodeps', package], text=True
        ).strip().splitlines()[-1]
        name = location.rsplit('/', 1)[-1]
        # HTTPS fallback avoids the machine's failing first HTTP mirror.
        url = 'https://geo.mirror.pkgbuild.com/extra/os/x86_64/' + name
        archive = download(url, CACHE / name)
        signature = download(url + '.sig', CACHE / (name + '.sig'))
        run('gpgv', '--keyring', '/etc/pacman.d/gnupg/pubring.gpg', signature, archive)
        run('tar', '-xf', archive, '-C', PREFIX, 'usr')
        installed[package] = {'archive': name, 'sha256': digest(archive)}
    tools = CACHE / 'tools'
    if not (tools / 'bin/python').exists():
        run('uv', 'venv', tools)
    run('uv', 'pip', 'install', '--python', tools / 'bin/python', 'meson==1.12.1')
    archive = download('https://github.com/LukashonakV/cava/archive/1.0.0.tar.gz',
                       CACHE / 'libcava-1.0.0.tar.gz',
                       '437df0a29e52e555357a06238f4c5cbe6d51b5dd4225700cb7adbb19d8bb9474')
    if not (CACHE / 'cava-1.0.0').exists():
        with tarfile.open(archive) as stream:
            stream.extractall(CACHE, filter='data')
    meson = tools / 'bin/meson'
    if not (CACHE / 'cava-build/meson-private/coredata.dat').exists():
        run(meson, 'setup', CACHE / 'cava-build', CACHE / 'cava-1.0.0',
            '-Dcava_font=false', '--prefix=' + str(PREFIX), '--libdir=lib')
    run(meson, 'compile', '-C', CACHE / 'cava-build', '-j', '4')
    run(meson, 'install', '-C', CACHE / 'cava-build')
    m3 = CACHE / 'm3shapes'
    if not m3.exists():
        run('git', 'clone', 'https://github.com/soramanew/m3shapes.git', m3)
        run('git', '-C', m3, 'checkout', '--detach', M3_COMMIT)
    if subprocess.check_output(['git', '-C', str(m3), 'rev-parse', 'HEAD'], text=True).strip() != M3_COMMIT:
        raise SystemExit('M3Shapes cache has another revision; preserved without modification.')
    run('cmake', '-S', m3, '-B', CACHE / 'm3shapes-build', '-G', 'Ninja',
        '-DCMAKE_BUILD_TYPE=Release', '-DCMAKE_INSTALL_PREFIX=' + str(PREFIX),
        '-DCMAKE_INSTALL_LIBDIR=lib')
    run('cmake', '--build', CACHE / 'm3shapes-build', '--parallel', '4')
    run('cmake', '--install', CACHE / 'm3shapes-build')
    base = 'https://github.com/StatIndet/key-cli/releases/download/v' + VERSION + '/'
    sums = download(base + 'SHA256SUMS', CACHE / ('key-cli-' + VERSION + '-SHA256SUMS'))
    name = 'key_cli-' + VERSION + '-py3-none-any.whl'
    expected = next(line.split()[0] for line in sums.read_text().splitlines()
                    if line.split()[-1].lstrip('*') == name)
    wheel = download(base + name, CACHE / name, expected)
    if not (PREFIX / 'key-cli/bin/python').exists():
        run('uv', 'venv', PREFIX / 'key-cli')
    run('uv', 'pip', 'install', '--python', PREFIX / 'key-cli/bin/python', wheel)
    installed['key_sysmon'] = install_key_sysmon()
    (PREFIX / 'fontconfig.conf').write_text(
        '<?xml version="1.0"?><!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">'
        '<fontconfig><include>/etc/fonts/fonts.conf</include><dir>'
        + escape(str(PREFIX / 'usr/share/fonts')) + '</dir></fontconfig>\n')
    installed.update(libcava='1.0.0', m3shapes=M3_COMMIT, key_cli=VERSION)
    (PREFIX / 'installed.json').write_text(json.dumps(installed, indent=2) + '\n')
    print('Private dependencies installed at', PREFIX)


if __name__ == '__main__':
    main()
