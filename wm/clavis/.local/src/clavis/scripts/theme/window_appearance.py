#!/usr/bin/env python3
"""Managed focus glow and RGB-only inactive dimming; no opacity substitution."""
from pathlib import Path
import argparse
import hashlib
import json
import os
import re
import subprocess
import sys
import tempfile
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/"lib"))
from clavis_paths import ClavisPaths

def state():
    paths=ClavisPaths.from_environment();path=paths.config_home/"window-appearance.json"
    value=json.loads(path.read_text()) if path.is_file() else {}
    prefs={"dim":0.08,"blur":True,"source":"wallpaper","color":"#bd93f9","lastWallpaperColor":"#bd93f9",**value}
    try:
        version=json.loads(subprocess.check_output(["niri","msg","--json","version"],text=True,timeout=5))["compositor"]
    except (OSError,subprocess.SubprocessError,ValueError,KeyError):version=""
    return paths,path,prefs,"clavis-native-1" in version

def atomic(path,text):
    path.parent.mkdir(parents=True,exist_ok=True);fd,tmp=tempfile.mkstemp(dir=path.parent,prefix=".clavis-window-")
    try:
        with os.fdopen(fd,"w") as stream:stream.write(text);stream.flush();os.fsync(stream.fileno())
        os.replace(tmp,path)
    finally:
        if os.path.lexists(tmp):os.unlink(tmp)

def main(request):
    paths,path,prefs,native=state()
    if request.get("compatible") is True:native=False
    if request.get("operation")=="apply":
        settings=request.get("settings",{})
        if not isinstance(settings,dict):raise ValueError("Invalid window appearance settings")
        dim=settings.get("dim",prefs["dim"]);source=settings.get("source",prefs["source"]);color=settings.get("color",prefs["color"])
        if isinstance(dim,bool) or not isinstance(dim,(int,float)) or not 0<=dim<=0.4:raise ValueError("Dimming must be between 0 and 40 percent")
        if source not in ("wallpaper","custom") or not isinstance(color,str) or not re.fullmatch(r"#[0-9a-fA-F]{6}",color):raise ValueError("Invalid glow color")
        blur=settings.get("blur",prefs["blur"])
        if not isinstance(blur,bool):raise ValueError("Invalid window blur preference")
        prefs.update(dim=dim,blur=blur,source=source,color=color.lower())
        wallpaper=request.get("wallpaper","")
        if source=="wallpaper" and isinstance(wallpaper,str) and Path(wallpaper).is_file():
            with tempfile.TemporaryDirectory(prefix="clavis-glow-") as tmp:
                config=Path(tmp)/"config.toml";config.write_text("[config]\nversion_check=false\n[templates]\n")
                result=subprocess.check_output(["matugen","--source-color-index","0","image",wallpaper,"--dry-run","--json","hex","--config",str(config)],text=True,timeout=25)
                prefs["lastWallpaperColor"]=json.loads(result)["colors"]["primary"]["dark"]["color"]
        chosen=prefs["lastWallpaperColor"] if source=="wallpaper" else prefs["color"]
        if not re.fullmatch(r"#[0-9a-fA-F]{6}",chosen):raise ValueError("Invalid wallpaper glow color")
        profile=Path(os.environ.get("NIRI_CONFIG",""))
        if not profile.is_absolute():raise ValueError("NIRI_CONFIG must name the active profile")
        fragment=profile.parent/"clavis/window-appearance.kdl";owner=paths.state_home/"window-appearance-owner.json"
        if fragment.is_symlink() or owner.is_symlink():raise ValueError("Linked personal window rules preserved")
        if fragment.exists():
            if not owner.is_file() or json.loads(owner.read_text()).get("sha256")!=hashlib.sha256(fragment.read_bytes()).hexdigest():raise ValueError("Manually edited window rules preserved")
        text='// Managed by Clavis window appearance; edit settings or use local.kdl.\nwindow-rule {\n    match is-focused=true\n    shadow { on; softness 22; spread 3; offset x=0 y=0; color "'+chosen+'55"; }\n}\n'
        text+='window-rule { background-effect { blur '+str(blur).lower()+'; }; }\n'
        if native:text+='window-rule {\n    match is-active=false\n    opacity 1.0\n    dim '+str(dim)+'\n}\n'
        else:text+='// RGB-only dimming takes effect after login with clavis-native-1.\n'
        with tempfile.TemporaryDirectory(prefix="clavis-window-validate-") as temporary:
            candidate=Path(temporary)/"config.kdl";candidate.write_text(text)
            validated=subprocess.run(["niri","validate","-c",str(candidate)],text=True,capture_output=True,timeout=15)
            if validated.returncode:raise ValueError(validated.stderr.strip() or "Window appearance validation failed")
        atomic(fragment,text);atomic(owner,json.dumps({"sha256":hashlib.sha256(fragment.read_bytes()).hexdigest()}));atomic(path,json.dumps(prefs,indent=2))
    return {"schemaVersion":1,"ok":True,"settings":prefs,"native":native}
if __name__=="__main__":
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument("request");args=parser.parse_args()
    try:print(json.dumps(main(json.loads(args.request))));sys.exit(0)
    except (OSError,ValueError,KeyError,subprocess.SubprocessError) as e:print(json.dumps({"schemaVersion":1,"ok":False,"error":str(e)}));sys.exit(1)
