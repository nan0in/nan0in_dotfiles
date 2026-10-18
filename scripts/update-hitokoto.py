#!/usr/bin/env python3
"""Download a pinned Hitokoto snapshot and build an offline fortune database."""
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import urllib.request

ROOT = Path(__file__).resolve().parents[1]
DEST = ROOT / "home/.local/share/fortunes/hitokoto"
REPO = "hitokoto-osc/sentences-bundle"
CATEGORIES = {"a": "动画", "b": "漫画", "c": "游戏", "d": "文学", "i": "诗词"}


def fetch(url):
    request = urllib.request.Request(url, headers={"User-Agent": "dotfiles-hitokoto"})
    with urllib.request.urlopen(request, timeout=45) as response:
        return response.read()


def clean(value):
    return " ".join(str(value or "").split())


def main():
    if not shutil.which("strfile"):
        raise SystemExit("Install fortune-mod (strfile) before updating.")
    commit = json.loads(fetch(f"https://api.github.com/repos/{REPO}/commits/master"))["sha"]
    base = f"https://raw.githubusercontent.com/{REPO}/{commit}"
    DEST.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(dir=DEST.parent) as directory:
        stage = Path(directory)
        raw = stage / "upstream"
        raw.mkdir()
        manifest = {"repository": f"https://github.com/{REPO}", "commit": commit,
                    "filter": "Chinese text; 2..60 characters; no control characters; deduplicated",
                    "categories": {}, "sha256": {}}
        seen = set()
        for key, name in CATEGORIES.items():
            content = fetch(f"{base}/sentences/{key}.json")
            (raw / f"{key}.json").write_bytes(content)
            manifest["sha256"][f"upstream/{key}.json"] = hashlib.sha256(content).hexdigest()
            quotes = []
            for entry in json.loads(content):
                original = entry.get("hitokoto", "")
                text = clean(original)
                if (not 2 <= len(text) <= 60 or not re.search(r"[\u3400-\u9fff]", text)
                        or any(ord(c) < 32 and c not in "\n\r\t" for c in original)
                        or "\x7f" in original or text in seen):
                    continue
                seen.add(text)
                source = clean(entry.get("from"))[:60]
                author = clean(entry.get("from_who"))[:30]
                attribution = " · ".join(x for x in (author, source) if x)
                quotes.append(text + (f"\n—— {attribution}" if attribution else ""))
            if not quotes:
                raise ValueError(f"Empty category: {key}")
            output = stage / key
            output.write_text("\n%\n".join(quotes) + "\n", encoding="utf-8")
            subprocess.run(["strfile", "-s", str(output)], check=True)
            manifest["categories"][key] = {"name": name, "count": len(quotes)}
        (stage / "LICENSE").write_bytes(fetch(f"{base}/LICENSE"))
        (stage / "UPSTREAM_README.md").write_bytes(fetch(f"{base}/README.md"))
        (stage / "manifest.json").write_text(
            json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        # All downloads and indexes must succeed before touching the installed data.
        DEST.mkdir(parents=True, exist_ok=True)
        for path in stage.iterdir():
            if path.is_dir():
                shutil.copytree(path, DEST / path.name, dirs_exist_ok=True)
            else:
                shutil.copy2(path, DEST / path.name)
    print(json.dumps(manifest, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
