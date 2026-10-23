#!/usr/bin/env python3
"""Install an owned, font-neutral GTK 3 skin without replacing an existing theme."""
from pathlib import Path
import hashlib
import json
import os
import sys
root=Path(__file__).resolve().parents[2]
home=Path.home();data=Path(os.environ.get("XDG_DATA_HOME",home/".local/share"))
base=next((x for x in [Path("/usr/share/themes/adw-gtk3-dark/gtk-3.0/gtk.css"),home/".themes/Dracula-alt-style/gtk-3.0/gtk.css",data/"themes/Dracula-alt-style/gtk-3.0/gtk.css"] if x.is_file()),None)
if base is None:raise SystemExit("Install a Dracula GTK 3 base theme first")
target=data/"themes/Clavis-Material-Dracula";marker=target/".clavis-owned.json"
css=(root/"assets/themes/material-dracula.css.in").read_text().replace("@BASE_CSS@",base.as_uri())
files={"gtk-3.0/gtk.css":css,"gtk-3.0/gtk-dark.css":css,"index.theme":"[Desktop Entry]\nType=X-GNOME-Metatheme\nName=Clavis Material Dracula\nComment=Material-inspired rounded Dracula skin; preserves personal fonts\n[X-GNOME-Metatheme]\nGtkTheme=Clavis-Material-Dracula\n"}
if target.is_symlink():raise SystemExit("Linked personal theme preserved")
if target.exists():
    if not marker.is_file():raise SystemExit("Existing personal theme preserved")
    manifest=json.loads(marker.read_text())
    for rel,digest in manifest.items():
        p=target/rel
        if p.is_symlink() or not p.is_file() or hashlib.sha256(p.read_bytes()).hexdigest()!=digest:raise SystemExit("Modified theme preserved: "+str(p))
for rel,text in files.items():
    p=target/rel;p.parent.mkdir(parents=True,exist_ok=True);p.write_text(text)
marker.write_text(json.dumps({rel:hashlib.sha256((target/rel).read_bytes()).hexdigest() for rel in files}))
print(target)
