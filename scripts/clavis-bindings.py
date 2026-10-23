#!/usr/bin/env python3
"""Consolidate legacy profile bindings into the UI-owned fragment, with backup."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import sys
import tempfile

REPO = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REPO / 'wm/clavis/.local/src/clavis/scripts/system'))
import niri_config as config  # noqa: E402


def identity(key):
    try:
        return config.key_identity(key)
    except ValueError:
        # niri pseudo-buttons have no XKB keysym. Still normalize modifiers.
        parts = key.split('+')
        if not parts[-1].lower().startswith(('wheelscroll', 'touchpadscroll', 'tabletstylusbutton')):
            raise
        return config.key_identity('+'.join(parts[:-1] + ['F24'])).split(':')[0] + ':' + parts[-1].lower()


def plan(profile):
    graph = config.Graph(profile / 'config.kdl')
    managed = profile / 'clavis/binds.kdl'
    legacy = [profile / 'personal-base.kdl', profile / 'shell-binds.kdl']
    paths = set(legacy + [managed])
    selected = {}
    replacements = {}
    count = 0
    for path, section in graph.ordered:
        if path not in paths or section.name != 'binds':
            continue
        for node in section.nodes:
            selected[identity(node.name)] = node
            count += 1
    for path in paths:
        config.safe_target(path)
        text = graph.files[path]
        sections = [node for node in graph.documents[path].nodes if node.name == 'binds']
        if path in legacy and not sections:
            continue
        for section in reversed(sections):
            text = text[:section.source_start] + text[section.source_end:]
        if path == managed:
            nodes = sorted(selected.values(), key=lambda n: n.name.lower())
            text = text.rstrip() + '\n\n' + config.render(config.kdl.Node('binds', nodes=nodes))
        replacements[path] = text
    # No-op on an already consolidated profile: never reformat later UI edits.
    if not any(path in replacements for path in legacy):
        return graph, {}, count, len(selected)
    config.Graph(profile / 'config.kdl', replacements=replacements).validate()
    return graph, replacements, count, len(selected)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=('check', 'migrate'))
    parser.add_argument('--profile', type=Path, default=Path.home() / '.config/niri-clavis')
    args = parser.parse_args()
    profile = args.profile.absolute()
    config.safe_target(profile / 'config.kdl')
    with config.configuration_lock(profile / 'config.kdl'):
        graph, replacements, before, after = plan(profile)
        print(f'{before} definitions -> {after} keys; {before-after} shadowed definitions removed')
        if args.action == 'check' or not replacements:
            return
        state = Path(os.environ.get('XDG_STATE_HOME', Path.home() / '.local/state')) / 'clavis'
        state.mkdir(parents=True, exist_ok=True)
        backup = Path(tempfile.mkdtemp(prefix='bindings-backup-', dir=state))
        for path in replacements:
            dst = backup / path.relative_to(profile)
            dst.parent.mkdir(parents=True, exist_ok=True)
            dst.write_text(graph.files[path])
        graph.unchanged()
        published = []
        try:
            # Install the complete destination before retiring the legacy sections.
            ordered = sorted(replacements, key=lambda p: p != profile / 'clavis/binds.kdl')
            for path in ordered:
                if config.read_text(path) != graph.files[path]:
                    raise ValueError('Configuration changed during migration: ' + str(path))
                config.replace_file(path, replacements[path])
                published.append(path)
            config.Graph(profile / 'config.kdl').validate()
        except BaseException:
            for path in reversed(published):
                if config.read_text(path) == replacements[path]:
                    config.replace_file(path, graph.files[path])
            raise
        manifest = state / 'profile-install.json'
        if manifest.exists():
            record = json.loads(manifest.read_text())
            if record.get('path') == str(profile):
                for path, value in replacements.items():
                    relative = str(path.relative_to(profile))
                    old_hash = hashlib.sha256(graph.files[path].encode()).hexdigest()
                    if record['files'].get(relative) == old_hash:
                        record['files'][relative] = hashlib.sha256(value.encode()).hexdigest()
                config.replace_file(manifest, json.dumps(record, indent=2) + '\n')
        print('Backup: ' + str(backup))
        print('Consolidated. Settings may now edit/delete defaults; no processes restarted.')


if __name__ == '__main__':
    main()
