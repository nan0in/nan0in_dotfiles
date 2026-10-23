#!/usr/bin/env python3
"""Discover installed appearance choices and update only explicitly selected keys."""
import argparse
import configparser
import datetime
import json
import os
from pathlib import Path
import re
import shutil
import stat
import signal
import subprocess
import sys
import tempfile
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/"lib"))
from clavis_paths import ClavisPaths

def read(path):
    ini=configparser.RawConfigParser(strict=False);ini.optionxform=str
    if path.is_file():ini.read(path,encoding="utf-8")
    return ini

def field(path,group,key,default=""):
    return read(path).get(group,key,fallback=default)

def roots():
    home=Path.home();data=Path(os.environ.get("XDG_DATA_HOME",home/".local/share"))
    return [home/".themes",data/"themes",Path("/usr/local/share/themes"),Path("/usr/share/themes")]

def choices():
    themes={};icons={}
    for root in roots():
        if not root.is_dir():continue
        for p in sorted(root.iterdir()):
            if p.name in themes or not (p/"gtk-3.0/gtk.css").is_file():continue
            meta=read(p/"index.theme");comment=meta.get("Desktop Entry","Comment",fallback="")
            themes[p.name]={"value":p.name,"label":p.name,"description":comment or "Installed GTK 3 theme"}
    home=Path.home();data=Path(os.environ.get("XDG_DATA_HOME",home/".local/share"))
    for root in [home/".icons",data/"icons",Path("/usr/local/share/icons"),Path("/usr/share/icons")]:
        if not root.is_dir():continue
        for p in sorted(root.iterdir()):
            if p.name in icons or not (p/"index.theme").is_file():continue
            meta=read(p/"index.theme")
            if not meta.has_section("Icon Theme") or meta.get("Icon Theme","Directories",fallback="")=="":continue
            icons[p.name]={"value":p.name,"label":meta.get("Icon Theme","Name",fallback=p.name),"description":meta.get("Icon Theme","Comment",fallback="Installed icon theme")}
    qt=[{"value":"Fusion","label":"Fusion","description":"Qt built-in cross-platform widget style"},{"value":"Windows","label":"Windows","description":"Qt built-in classic widget style"}]
    plugins=[Path("/usr/lib/qt6/plugins/styles"),home/".local/opt/nan0in-clavis-deps/usr/lib/qt6/plugins/styles"]
    for name,needle,description in [("kvantum","kvantum","SVG-based Kvantum style; keeps the selected Kvantum theme"),("Breeze","breeze","KDE Breeze widget style")]:
        if any(root.is_dir() and any(needle in x.name.lower() for x in root.iterdir()) for root in plugins):qt.append({"value":name,"label":name,"description":description})
    palettes={}
    cfg=Path(os.environ.get("XDG_CONFIG_HOME",home/".config"))
    for root in [cfg/"qt6ct/colors",Path("/usr/share/qt6ct/colors")]:
        if root.is_dir():
            for p in root.glob("*.conf"):palettes[str(p)]={"value":str(p),"label":p.stem,"description":"Installed Qt widget color palette"}
    current=field(cfg/"qt6ct/qt6ct.conf","Appearance","color_scheme_path")
    if current and Path(current).is_file():palettes.setdefault(current,{"value":current,"label":Path(current).stem,"description":"Current personal Qt widget palette"})
    kvantum={}
    for root in [cfg/"Kvantum",data/"Kvantum",Path("/usr/share/Kvantum")]:
        if root.is_dir():
            for path in root.glob("*/*.kvconfig"):
                kvantum.setdefault(path.stem,{"value":path.stem,"label":path.stem,"description":"Installed Kvantum SVG theme; independent of the Qt color palette"})
    return {"gtk":list(themes.values()),"icons":list(icons.values()),"qtStyle":qt,"qtPalette":list(palettes.values()),"qtTheme":list(kvantum.values())}

def patch(text,group,key,value):
    # Preserve every unrelated line (including fonts, comments and ordering).
    lines=text.splitlines(keepends=True);start=None;end=len(lines)
    for i,line in enumerate(lines):
        if line.strip()=="["+group+"]":start=i+1;break
    if start is None:return text+("\n" if text and not text.endswith("\n") else "")+"["+group+"]\n"+key+"="+value+"\n"
    for i in range(start,len(lines)):
        if lines[i].lstrip().startswith("["):end=i;break
    indices=[i for i in range(start,end) if re.match(r"\s*"+re.escape(key)+r"\s*=",lines[i])]
    if len(indices)>1:raise ValueError("Duplicate setting preserved: "+key)
    line=key+"="+value+"\n"
    if indices:lines[indices[0]]=line
    else:
        if end>0 and not lines[end-1].endswith("\n"):lines[end-1]+="\n"
        lines.insert(end,line)
    return "".join(lines)

def gtk_setting_snapshot(kind,value):
    key={"gtk":"gtk-theme","icons":"icon-theme"}.get(kind)
    if not key or not shutil.which("gsettings"):return []
    schemas=subprocess.check_output(["gsettings","list-schemas"],text=True,timeout=5).splitlines()
    schema="org.gnome.desktop.interface"
    if schema not in schemas:return []
    if subprocess.check_output(["gsettings","writable",schema,key],text=True,timeout=5).strip()!="true":
        raise ValueError("GTK setting is read-only: "+key)
    before=subprocess.check_output(["gsettings","get",schema,key],text=True,timeout=5).strip()
    literal="'"+value.replace("\\","\\\\").replace("'","\\'")+"'"
    return [{"schema":schema,"key":key,"before":before,"after":literal}]

def patch_xsettings(text,key,value):
    lines=text.splitlines(keepends=True)
    indices=[i for i,line in enumerate(lines) if re.match(r"\s*"+re.escape(key)+r"\s+",line)]
    if len(indices)>1:raise ValueError("Duplicate XSettings entry preserved: "+key)
    line=key+" "+json.dumps(value,ensure_ascii=False)+"\n"
    if indices:lines[indices[0]]=line
    else:
        if lines and not lines[-1].endswith("\n"):lines[-1]+="\n"
        lines.append(line)
    return "".join(lines)

def reload_xsettings(config):
    # Limit discovery to relevant user-service cgroups, not a global /proc scan.
    try:
        listing=subprocess.check_output(["systemctl","--user","list-units","--type=service","--plain","--no-legend"],text=True,timeout=3)
        units=[line.split()[0] for line in listing.splitlines() if line.split() and (line.split()[0]=="xsettingsd.service" or "org.kde.kded6@" in line.split()[0])]
        for unit in units:
            group=subprocess.check_output(["systemctl","--user","show",unit,"--value","-p","ControlGroup"],text=True,timeout=3).strip()
            if not group.startswith("/user.slice/"):continue
            for pid in (Path("/sys/fs/cgroup"+group)/"cgroup.procs").read_text().split():
                proc=Path("/proc")/pid
                if proc.stat().st_uid!=os.getuid() or (proc/"comm").read_text().strip()!="xsettingsd":continue
                environment=dict(entry.split("=",1) for entry in (proc/"environ").read_text().split("\0") if "=" in entry)
                daemon_config=Path(environment.get("XDG_CONFIG_HOME",str(Path(environment.get("HOME","/nonexistent"))/".config")))
                argv=(proc/"cmdline").read_bytes().split(b"\0")
                # Custom -c daemons belong to their own configuration owner.
                if daemon_config==config and not any(x in argv for x in (b"-c",b"--config")):
                    os.kill(int(pid),signal.SIGHUP)
    except (OSError,subprocess.SubprocessError):
        pass  # New processes/login still use the persisted settings.

def write_updates(updates,external=()):
    paths=ClavisPaths.from_environment();backup=paths.state_home/"appearance-backups"/datetime.datetime.now().strftime("%Y%m%d-%H%M%S-%f")
    for path,_ in updates:
        if path.is_symlink() or any(x.is_symlink() for x in path.parents if x!=Path.home()):raise ValueError("Linked personal configuration preserved: "+str(path))
        if path.exists() and not path.is_file():raise ValueError("Non-file configuration preserved: "+str(path))
    originals={p:p.read_bytes() if p.exists() else None for p,_ in updates};backup.mkdir(parents=True,mode=0o700)
    (backup/"manifest.json").write_text(json.dumps({str(p):raw is not None for p,raw in originals.items()}))
    for i,(path,text) in enumerate(updates):
        if originals[path] is not None:(backup/str(i)).write_bytes(originals[path])
    (backup/"gsettings.json").write_text(json.dumps(list(external),indent=2))
    # Validate everything before publishing; rollback this operation if any write fails.
    done=[];external_done=[]
    try:
        for path,text in updates:
            path.parent.mkdir(parents=True,exist_ok=True);fd,tmp=tempfile.mkstemp(dir=path.parent,prefix=".clavis-appearance-")
            try:
                with os.fdopen(fd,"w") as f:f.write(text);f.flush();os.fsync(f.fileno());os.fchmod(f.fileno(),stat.S_IMODE(path.stat().st_mode) if path.exists() else 0o600)
                os.replace(tmp,path);done.append(path)
            finally:
                if os.path.lexists(tmp):os.unlink(tmp)
        for row in external:
            subprocess.run(["gsettings","set",row["schema"],row["key"],row["after"]],check=True,capture_output=True,text=True,timeout=5)
            external_done.append(row)
    except Exception:
        for row in reversed(external_done):
            subprocess.run(["gsettings","set",row["schema"],row["key"],row["before"]],check=False,capture_output=True,text=True,timeout=5)
        for path in reversed(done):
            raw=originals[path]
            if raw is None:path.unlink()
            else:path.write_bytes(raw)
        raise

def status():
    cfg=Path(os.environ.get("XDG_CONFIG_HOME",Path.home()/".config"));opts=choices()
    current={"gtk":field(cfg/"gtk-3.0/settings.ini","Settings","gtk-theme-name"),"icons":field(cfg/"gtk-3.0/settings.ini","Settings","gtk-icon-theme-name"),"qtStyle":field(cfg/"qt6ct/qt6ct.conf","Appearance","style"),"qtPalette":field(cfg/"qt6ct/qt6ct.conf","Appearance","color_scheme_path"),"qtTheme":field(cfg/"Kvantum/kvantum.kvconfig","General","theme")}
    return {"schemaVersion":1,"ok":True,"choices":opts,"current":current}

def apply(kind,value):
    if not isinstance(value,str) or any(ord(x)<32 for x in value):raise ValueError("Invalid appearance value")
    options=choices()
    if kind not in options or value not in [x["value"] for x in options[kind]]:raise ValueError("Select an installed appearance option")
    cfg=Path(os.environ.get("XDG_CONFIG_HOME",Path.home()/".config"));updates=[]
    keys=[]
    if kind=="gtk":keys=[(cfg/"gtk-3.0/settings.ini","Settings","gtk-theme-name",value)]
    elif kind=="icons":keys=[(cfg/"gtk-3.0/settings.ini","Settings","gtk-icon-theme-name",value),(cfg/"qt6ct/qt6ct.conf","Appearance","icon_theme",value)]
    elif kind=="qtTheme":keys=[(cfg/"Kvantum/kvantum.kvconfig","General","theme",value)]
    elif kind=="qtStyle":keys=[(cfg/"qt6ct/qt6ct.conf","Appearance","style",value)]
    elif kind=="qtPalette":keys=[(cfg/"qt6ct/qt6ct.conf","Appearance","color_scheme_path",value),(cfg/"qt6ct/qt6ct.conf","Appearance","custom_palette","true")]
    texts={}
    for path,group,key,val in keys:texts[path]=patch(texts.get(path,path.read_text() if path.is_file() else ""),group,key,val)
    xsettings=cfg/"xsettingsd/xsettingsd.conf"
    if kind in ("gtk","icons") and xsettings.is_file():
        texts[xsettings]=patch_xsettings(xsettings.read_text(),"Net/ThemeName" if kind=="gtk" else "Net/IconThemeName",value)
    external=gtk_setting_snapshot(kind,value)
    write_updates(list(texts.items()),external)
    if kind in ("gtk","icons") and xsettings.is_file():reload_xsettings(cfg)
    return status()

def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument("request");args=parser.parse_args()
    try:
        req=json.loads(args.request);result=apply(req.get("kind"),req.get("value")) if req.get("operation")=="apply" else status();print(json.dumps(result,ensure_ascii=False));return 0
    except (OSError,ValueError,configparser.Error,subprocess.SubprocessError) as e:print(json.dumps({"schemaVersion":1,"ok":False,"error":str(e)}));return 1
if __name__=="__main__":sys.exit(main())
