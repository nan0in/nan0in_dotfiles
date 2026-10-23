#!/usr/bin/env python3
"""Fetch pinned corpora and rebuild offline English/Japanese fortune files."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import urllib.request
import unicodedata

ROOT = Path(__file__).resolve().parents[1]
DEST = ROOT / 'config/.config/fortune'
JK = 'https://raw.githubusercontent.com/JKirchartz/fortunes/8c337f35a3956acf0609f955b0c536920bd46f92'
JA = 'https://raw.githubusercontent.com/sepTN/kotowaza/c6435b3e13937fbfb6d464410f68dccf76384264'
URLS = {
    'jargon.txt': 'https://www.gutenberg.org/ebooks/3008.txt.utf-8',
    'epigrams.txt': JK + '/epigrams_in_programming',
    'jung.txt': JK + '/jung',
    'fortunes-LICENSE': JK + '/LICENSE',
    'fortunes-README.md': JK + '/README.md',
    'kotowaza.json': JA + '/data/kotowaza.json',
    'kotowaza-LICENSE': JA + '/LICENSE',
    'kotowaza-README.md': JA + '/README.md',
}
SECURITY = re.compile(r'\b(security|passwords?|crypt\w*|intrud\w*|exploits?|vulnerab\w*|back.?door|crackers?|phreak\w*|trojans?|firewalls?|sniff\w*|spoof\w*|worms?|virus|viruses|privileg\w*)\b', re.I)


def records(text):
    return [x.strip() for x in re.split(r'^%\s*$', text, flags=re.M) if x.strip()]


def normalize(text):
    return ' '.join(text.split())


def build(stage, name, quotes):
    clean, seen = [], set()
    for text in quotes:
        text = ''.join(c for c in text if c in '\n\t' or not unicodedata.category(c).startswith('C'))
        key = normalize(text).casefold()
        if not key or key in seen or '\x1b' in text:
            continue
        seen.add(key)
        clean.append(text)
    if not clean:
        raise ValueError('Empty database: ' + name)
    path = stage / name
    path.write_text('\n%\n'.join(clean) + '\n', encoding='utf-8')
    subprocess.run(['strfile', '-s', str(path)], check=True)
    return len(clean)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--offline', action='store_true', help='Rebuild from the saved source snapshot')
    args = parser.parse_args()
    if not shutil.which('strfile'):
        raise SystemExit('Install fortune-mod / strfile first.')
    with tempfile.TemporaryDirectory(dir=DEST) as tmp:
        stage = Path(tmp)
        source = stage / 'sources'
        source.mkdir()
        manifest = {'sources': {}, 'counts': {}, 'notes': [
            'Jargon File 4.2.2 (2000): historical terminology, not current security guidance.',
            'Jargon: first definition paragraph only, at most 400 characters; not whole entries.',
            'Psychology: at most 12 short Jung quotations; upstream attributions are unverified.',
            'Security fortunes also include keyword-selected records from the preserved legacy database.',
            'Upstream collection licenses do not establish rights to every attributed quotation.'
        ]}
        for name, url in URLS.items():
            if args.offline:
                data = (DEST / 'extra/sources' / name).read_bytes()
            else:
                request = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0 (dotfiles-corpus)'})
                with urllib.request.urlopen(request, timeout=45) as response:
                    data = response.read()
            (source / name).write_bytes(data)
            manifest['sources'][name] = {'url': url, 'sha256': hashlib.sha256(data).hexdigest()}
        jargon = (source / 'jargon.txt').read_text(encoding='utf-8-sig')
        computer, security = [], []
        for match in re.finditer(r'^Node:([^,\n]+),[^\n]*\n(.*?)(?=^Node:|\Z)', jargon, flags=re.M | re.S):
            term, body = match.group(1), match.group(2).strip()
            header = match.group(0).splitlines()[0]
            if not body.startswith(term) or not re.search(r'Up:= [A-Z] =', header):
                continue
            parts = re.split(r'\n\s*\n', body, maxsplit=2)
            if len(parts) < 2:
                continue
            definition = normalize(parts[1])
            if not 20 <= len(definition) <= 400 or definition.endswith((',', ':', ';')):
                continue
            record = normalize(parts[0]) + '\n' + definition + '\n-- Jargon File 4.2.2 (definition excerpt)'
            (security if SECURITY.search(term + ' ' + definition) else computer).append(record)
        for quote in records((source / 'epigrams.txt').read_text()):
            text = re.sub(r'^EPIGRAMS IN PROGRAMMING\s*\d+\.\s*', '', quote)
            if len(normalize(text)) <= 400:
                computer.append(normalize(text) + '\n-- Alan J. Perlis, Epigrams in Programming (1982)')
        # Restrict keyword extraction to technical collections: "worm", "virus",
        # "exploit" and "privilege" have many non-security meanings elsewhere.
        for filename in ['computers', 'linux', 'debian', 'knghtbrd', 'perl']:
            path = DEST / 'legacy' / filename
            if not path.is_file():
                continue
            for quote in records(path.read_text(errors='replace')):
                if SECURITY.search(quote) and len(normalize(quote)) <= 300 and not quote.rstrip().endswith(('=', ':')):
                    security.append(quote + '\n[legacy/' + path.name + ']')
        psychology = [quote for quote in records((source / 'jung.txt').read_text())
                      if len(normalize(quote)) <= 180][:12]
        japanese = []
        for entry in json.loads((source / 'kotowaza.json').read_text()):
            japanese.append(entry['japanese'] + '\n' + entry['reading'] + '\n'
                            + entry['meaning']['en'] + '\n-- Kotowaza / Jepang.org')
        for name, data in [('en-computing', computer), ('en-security', security),
                           ('en-psychology', psychology), ('ja-kotowaza', japanese)]:
            manifest['counts'][name] = build(stage, name, data)
        (stage / 'manifest.json').write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + '\n')
        target = DEST / 'extra'
        target.mkdir(exist_ok=True)
        for path in stage.iterdir():
            if path.is_dir():
                shutil.copytree(path, target / path.name, dirs_exist_ok=True)
            else:
                shutil.copy2(path, target / path.name)
        print(json.dumps(manifest['counts'], ensure_ascii=False, indent=2))


if __name__ == '__main__':
    main()
