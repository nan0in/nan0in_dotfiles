#!/usr/bin/env python3
"""Regenerate the local Unicode 16 / CLDR 47 catalog with complete RGI categories."""
import hashlib
import json
from pathlib import Path
import re
import urllib.request

ROOT = Path(__file__).resolve().parents[1]
GROUPS = {
    'Smileys & Emotion': ('smileys', '表情与情感', '表情與情感'),
    'People & Body': ('people', '人物与身体', '人物與身體'),
    'Component': ('components', '肤色与发型', '膚色與髮型'),
    'Animals & Nature': ('nature', '动物与自然', '動物與自然'),
    'Food & Drink': ('food', '食物与饮品', '食物與飲品'),
    'Travel & Places': ('travel', '旅行与地点', '旅行與地點'),
    'Activities': ('activities', '活动', '活動'),
    'Objects': ('objects', '物品', '物品'),
    'Symbols': ('symbols', '符号', '符號'),
    'Flags': ('flags', '旗帜', '旗幟'),
}


def main():
    hashes = {}

    def download(url):
        with urllib.request.urlopen(url, timeout=30) as response:
            raw = response.read()
        hashes[url] = hashlib.sha256(raw).hexdigest()
        return raw

    annotations = {}
    for lang in ['en', 'zh', 'zh-Hant']:
        table = {}
        for suffix, section, directory in [('', 'annotations', 'annotations'), ('-derived', 'annotationsDerived', 'annotationsDerived')]:
            url = f'https://raw.githubusercontent.com/unicode-org/cldr-json/47.0.0/cldr-json/cldr-annotations{suffix}-full/{directory}/{lang}/annotations.json'
            data = json.loads(download(url))[section]['annotations']
            table.update({key.replace('\ufe0f', ''): value for key, value in data.items()})
        annotations[lang.replace('-', '_')] = table

    url = 'https://unicode.org/Public/emoji/16.0/emoji-test.txt'
    lines = download(url).decode().splitlines()
    result = []
    group = subgroup = ''
    for line in lines:
        if line.startswith('# group: '):
            group = line.removeprefix('# group: ')
        elif line.startswith('# subgroup: '):
            subgroup = line.removeprefix('# subgroup: ')
        elif ';' in line:
            codepoints, _, status = line.partition(';')
            if status.split('#', 1)[0].strip() not in ('fully-qualified', 'component'):
                continue
            emoji = ''.join(chr(int(code, 16)) for code in codepoints.split())
            english = re.split(r' E[0-9.]+ ', status.split('#', 1)[1], maxsplit=1)[1]
            names = {}
            category, zh, hant = GROUPS[group]
            words = {english, group, zh, hant}
            for lang, table in annotations.items():
                entry = table.get(emoji.replace('\ufe0f', ''), {})
                names[lang] = (entry.get('tts') or [english])[0]
                words.update(entry.get('default', []))
                words.add(names[lang])
            result.append({'emoji': emoji, 'names': names, 'keywords': ' '.join(sorted(words)), 'category': category, 'subgroup': subgroup})
    if len(result) < 3700 or len({item['emoji'] for item in result}) != len(result):
        raise RuntimeError('Incomplete or duplicated Unicode catalog')
    assets = ROOT / 'assets/emoji'
    (assets / 'annotations.json').write_text(json.dumps(result, ensure_ascii=False, separators=(',', ':')) + '\n')
    (assets / 'UPSTREAM.json').write_text(json.dumps({
        'project': 'Unicode Emoji + CLDR', 'version': 'Emoji 16.0 / CLDR 47.0.0',
        'license': 'Unicode-3.0', 'count': len(result), 'sources': hashes,
    }, ensure_ascii=False, indent=2) + '\n')
    print(f'Generated {len(result)} emoji in {len(GROUPS)} categories')


if __name__ == '__main__':
    main()
