#!/usr/bin/env python3
"""Select Yazi colors in an independent config overlay; never write into dotfiles."""
from pathlib import Path
import argparse
import fcntl
import json
import os
import sys
import tempfile
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "lib"))
from clavis_paths import ClavisPaths

def link(path, target):
    temp=path.with_name(path.name+".clavis-link")
    if os.path.lexists(temp):
        raise ValueError("Temporary selector already exists: "+str(temp))
    try:
        temp.symlink_to(target)
        os.replace(temp,path)
    finally:
        if temp.is_symlink():temp.unlink()

def select(action):
    paths=ClavisPaths.from_environment()
    original=Path(os.environ.get("CLAVIS_YAZI_BASE",str(paths.home/".config/yazi"))).absolute()
    overlay=paths.config_home/"yazi"
    if original.resolve()==overlay.resolve():raise ValueError("Yazi base and overlay must differ")
    marker=overlay/".clavis-yazi.json"
    overlay.parent.mkdir(parents=True,exist_ok=True)
    with (overlay.parent/".yazi-theme.lock").open("a") as lock:
        fcntl.flock(lock,fcntl.LOCK_EX)
        if overlay.is_symlink():raise ValueError("Existing linked Yazi overlay preserved")
        if overlay.exists() and not marker.is_file():raise ValueError("Unmanaged Yazi overlay preserved")
        if not overlay.exists():
            overlay.mkdir()
            marker.write_text(json.dumps({"schemaVersion":1,"base":str(original)}))
        metadata=json.loads(marker.read_text())
        if metadata.get("schemaVersion")!=1 or metadata.get("base")!=str(original):raise ValueError("Yazi base changed; overlay preserved")
        # Newly added user configuration files remain accessible without copies.
        if original.is_dir():
            for child in original.iterdir():
                if child.name in ("theme.toml",".clavis-yazi.json"):continue
                destination=overlay/child.name
                if not os.path.lexists(destination):destination.symlink_to(child)
        theme=overlay/"theme.toml";generated=Path(os.environ.get("CLAVIS_GENERATED_HOME",str(paths.data_home/"profiles/default/generated")))/"yazi/theme.toml"
        base=original/"theme.toml"
        if action=="prepare" and os.path.lexists(theme):return overlay
        owned=theme.is_symlink() and os.readlink(theme) in (str(base),str(generated))
        if os.path.lexists(theme) and not owned:raise ValueError("Yazi theme changed manually; selector preserved")
        if action=="apply":
            if not generated.is_file():raise ValueError("Generated Yazi colors are missing")
            link(theme,generated)
        else:
            link(theme,base)
        return overlay

def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument("action",choices=["prepare","apply","restore"]);args=parser.parse_args()
    try:print(select(args.action));return 0
    except (OSError,ValueError,KeyError) as error:print("Yazi theme: "+str(error),file=sys.stderr);return 1
if __name__=="__main__":sys.exit(main())
