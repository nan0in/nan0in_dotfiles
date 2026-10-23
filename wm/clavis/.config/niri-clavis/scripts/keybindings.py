#!/usr/bin/env python3
"""Read the effective include graph; display bindings, never execute a selection."""
import argparse
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
UPSTREAM = Path.home() / '.local/src/clavis/scripts/system'
if not UPSTREAM.exists():
    UPSTREAM = ROOT.parents[1] / '.local/src/clavis/scripts/system'
sys.path.insert(0, str(UPSTREAM))
from niri_config import Graph, canonical, key_identity  # noqa: E402


def identity(key, mod='Super'):
    try:
        return key_identity(key, mod)
    except ValueError:
        parts = key.split('+')
        if not parts[-1].lower().startswith(('wheelscroll', 'touchpadscroll', 'tabletstylusbutton')):
            raise
        modifiers = key_identity('+'.join(parts[:-1] + ['F24']), mod).split(':')[0]
        return modifiers + ':' + parts[-1].lower()


def bindings(graph):
    effective = {}
    for path, section in graph.ordered:
        if section.name != 'binds':
            continue
        for node in section.nodes:
            action = ' '.join(canonical(child) for child in node.nodes)
            effective[identity(node.name)] = (node.name.replace('Mod+', 'Super+'), action, path.name)
    return sorted(effective.values())


def audit(graph):
    # Reuse the editor's modifier/keysym normalization (Ctrl/Control, Mod/Super).
    from niri_config import bindings as inspect_bindings
    _, mod = inspect_bindings(graph, ROOT / 'clavis/binds.kdl')
    groups = {}
    for path, section in graph.ordered:
        if section.name == 'binds':
            for node in section.nodes:
                groups.setdefault(identity(node.name, mod), []).append(dict(
                    key=node.name, action=' '.join(canonical(c) for c in node.nodes), source=str(path)))
    duplicates = [group for group in groups.values() if len(group) > 1]
    error = ''
    try:
        graph.validate()
    except ValueError as problem:
        error = str(problem)
    print(json.dumps(dict(keys=len(bindings(graph)), duplicates=duplicates,
                          valid=not error, error=error), ensure_ascii=False, indent=2))
    return 1 if duplicates or error else 0


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--markdown', action='store_true')
    parser.add_argument('--print', action='store_true', dest='print_only')
    parser.add_argument('--audit', action='store_true', help='validate and report duplicate keys; never executes actions')
    args = parser.parse_args()
    graph = Graph(ROOT / 'config.kdl')
    if args.audit:
        return audit(graph)
    rows = bindings(graph)
    if args.markdown:
        print('# 当前完整快捷键\n\n从 niri-clavis/config.kdl 的 include 链生成；同键后加载覆盖前加载。')
        print('\n只展示配置，不执行所选命令。修改配置后重新生成此文件。\n')
        print('| 按键 | 最终动作 | 来源 |\n|---|---|---|')
        for key, action, source in rows:
            print(f'| {key} | `{action.replace("|", "&#124;")}` | {source} |')
    elif args.print_only:
        for key, action, source in rows:
            print(f'{key:<30} {action} [{source}]')
    else:
        subprocess.run(['fuzzel', '--config', str(Path.home() / '.config/niri/fuzzel/fuzzel.ini'),
                        '--dmenu', '--width', '100', '--lines', '22',
                        '--prompt', f'全部快捷键 ({len(rows)}): '],
                       input='\n'.join(f'{key:<30} {action}' for key, action, _ in rows),
                       text=True, check=False)


if __name__ == '__main__':
    raise SystemExit(main())
