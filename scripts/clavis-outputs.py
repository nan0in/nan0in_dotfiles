#!/usr/bin/env python3
"""Move legacy output blocks verbatim into the writable Clavis output fragment."""
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
import niri_outputs  # noqa: E402


def plan(profile):
    main = profile / 'config.kdl'
    graph = config.Graph(main)
    legacy, managed = profile / 'personal-base.kdl', profile / 'clavis/outputs.kdl'
    config.safe_target(legacy)
    config.safe_target(managed)
    moved = [node for path, node in graph.ordered if path == legacy and node.name == 'output']
    if not moved:
        return graph, {}, 0
    if any(node.name == 'output' and path != legacy for path, node in graph.ordered):
        raise ValueError('Output blocks also exist outside personal-base.kdl; preserved for manual merge')
    identifiers = [node.args[0].lower() for node in moved if len(node.args) == 1 and isinstance(node.args[0], str)]
    if len(identifiers) != len(moved) or len(set(identifiers)) != len(identifiers):
        raise ValueError('Ambiguous or duplicated output identifiers; preserved')
    text = graph.files[legacy]
    destination = graph.files.get(managed, '')
    blocks = [text[node.source_start:node.source_end] for node in moved]
    for node in reversed(moved):
        text = text[:node.source_start] + text[node.source_end:]
    replacements = {legacy: text, managed: destination.rstrip() + '\n\n' + '\n'.join(blocks)}
    candidate = config.Graph(main, replacements=replacements)
    candidate.validate()
    before = niri_outputs.inspect(graph, config.path_key(managed))
    after = niri_outputs.inspect(candidate, config.path_key(managed))
    if [(r['identifier'], r['settings']) for r in before] != [(r['identifier'], r['settings']) for r in after]:
        raise ValueError('Output settings changed during migration; preserved')
    return graph, replacements, len(moved)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=('check', 'migrate'))
    parser.add_argument('--profile', type=Path, default=Path.home() / '.config/niri-clavis')
    args = parser.parse_args()
    profile = args.profile.absolute()
    config.safe_target(profile / 'config.kdl')
    with config.configuration_lock(profile / 'config.kdl'):
        graph, replacements, count = plan(profile)
        print(f'{count} output blocks ready for verbatim migration')
        if args.action == 'check' or not replacements:
            return
        state = Path(os.environ.get('XDG_STATE_HOME', Path.home() / '.local/state')) / 'clavis'
        state.mkdir(parents=True, exist_ok=True)
        backup = Path(tempfile.mkdtemp(prefix='outputs-backup-', dir=state))
        for path in replacements:
            dst = backup / path.relative_to(profile)
            dst.parent.mkdir(parents=True, exist_ok=True)
            dst.write_text(graph.files.get(path, ''))
        graph.unchanged()
        published = []
        try:
            # Destination first: any intermediate duplicate has identical settings.
            for path in sorted(replacements, key=lambda p: p != profile / 'clavis/outputs.kdl'):
                if config.read_text(path) != graph.files.get(path, ''):
                    raise ValueError('Configuration changed during migration: ' + str(path))
                config.replace_file(path, replacements[path])
                published.append(path)
            config.Graph(profile / 'config.kdl').validate()
        except BaseException:
            for path in reversed(published):
                if config.read_text(path) == replacements[path]:
                    config.replace_file(path, graph.files.get(path, ''))
            raise
        manifest = state / 'profile-install.json'
        if manifest.exists():
            record = json.loads(manifest.read_text())
            if record.get('path') == str(profile):
                (backup / 'profile-install-before.json').write_text(manifest.read_text())
                for path, value in replacements.items():
                    relative = str(path.relative_to(profile))
                    previous = hashlib.sha256(graph.files.get(path, '').encode()).hexdigest()
                    # Migration must not adopt earlier personal edits into managed ownership.
                    if record['files'].get(relative) == previous:
                        record['files'][relative] = hashlib.sha256(value.encode()).hexdigest()
                manifest.write_text(json.dumps(record, indent=2) + '\n')
        print('Preserved output parameters and all other profile text. Backup: ' + str(backup))


if __name__ == '__main__':
    main()
