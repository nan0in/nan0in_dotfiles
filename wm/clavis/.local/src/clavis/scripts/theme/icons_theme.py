#!/usr/bin/env python3
"""Recolor Nautilus folder icons to follow the generated Matugen primary."""
from __future__ import annotations

import argparse
import fcntl
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "lib"))
from clavis_paths import ClavisPaths

OVERLAY_NAME = "Tela-Matugen"
MARKER = ".clavis-folder-icons"
BASE_THEMES = ("Tela", "Tela-dark", "Tela-light")
SOURCE_COLOR = re.compile(r"#5294e2", re.IGNORECASE)
PRIMARY_COLOR = re.compile(r"#[0-9a-fA-F]{6}")


def xdg_config(paths: ClavisPaths) -> Path:
    return Path(os.environ.get("XDG_CONFIG_HOME", paths.home / ".config"))


def xdg_data(paths: ClavisPaths) -> Path:
    return Path(os.environ.get("XDG_DATA_HOME", paths.home / ".local/share"))


def icon_dirs(paths: ClavisPaths) -> list[Path]:
    return [
        xdg_data(paths) / "icons",
        paths.home / ".icons",
        Path("/usr/local/share/icons"),
        Path("/usr/share/icons"),
    ]


def find_theme(paths: ClavisPaths, name: str) -> Path | None:
    for base in icon_dirs(paths):
        candidate = base / name
        if (candidate / "index.theme").is_file():
            return candidate
    return None


def gsettings_theme() -> str:
    try:
        result = subprocess.run(
            ["gsettings", "get", "org.gnome.desktop.interface", "icon-theme"],
            check=True,
            capture_output=True,
            text=True,
            timeout=5,
        )
    except (OSError, subprocess.SubprocessError):
        return ""
    return result.stdout.strip().strip("'\"")


def gsettings_set_theme(name: str) -> None:
    try:
        subprocess.run(
            ["gsettings", "set", "org.gnome.desktop.interface", "icon-theme", name],
            check=True,
            capture_output=True,
            text=True,
            timeout=5,
        )
    except (OSError, subprocess.SubprocessError):
        pass


def settings_ini_theme(paths: ClavisPaths) -> str:
    for name in ("gtk-4.0", "gtk-3.0"):
        ini = xdg_config(paths) / name / "settings.ini"
        try:
            lines = ini.read_text(errors="replace").splitlines()
        except OSError:
            continue
        for line in lines:
            if line.strip().startswith("gtk-icon-theme-name="):
                return line.split("=", 1)[1].strip()
    return ""


def current_theme(paths: ClavisPaths) -> str:
    return gsettings_theme() or settings_ini_theme(paths)


def read_primary(paths: ClavisPaths) -> str:
    generated = os.environ.get("CLAVIS_GENERATED_HOME")
    candidates = []
    if generated:
        candidates.append(Path(generated) / "clavis/icon-primary")
    candidates.append(xdg_data(paths) / "clavis/profiles/default/generated/clavis/icon-primary")
    for candidate in candidates:
        try:
            value = candidate.read_text().strip()
        except OSError:
            continue
        if PRIMARY_COLOR.fullmatch(value):
            return value.lower()
    raise ValueError("generated primary color is missing; enable the icons template first")


def inherits(index: Path) -> str:
    try:
        text = index.read_text(errors="replace")
    except OSError:
        return ""
    for line in text.splitlines():
        if line.startswith("Inherits="):
            return line.split("=", 1)[1].split(",")[0].strip()
    return ""


def managed(target: Path) -> bool:
    return (target / MARKER).is_file()


def resolve_base(paths: ClavisPaths, theme: str) -> str:
    state = paths.state_home / "folder-icons" / "base-theme"
    try:
        saved = state.read_text().strip()
    except OSError:
        saved = ""
    if saved in BASE_THEMES:
        return saved
    if theme in BASE_THEMES:
        return theme
    if theme == OVERLAY_NAME:
        overlay = find_theme(paths, OVERLAY_NAME)
        if overlay is not None and managed(overlay):
            parent = inherits(overlay / "index.theme")
            if parent in BASE_THEMES:
                return parent
    return ""


def iter_places(base: Path):
    """Yield places directories, including @2x/@3x symlink variants."""
    for child in base.iterdir():
        if not child.is_dir():
            continue
        places = child / "places"
        if places.is_dir():
            yield places


def build_theme(base: Path, target: Path, primary: str) -> int:
    target.parent.mkdir(parents=True, exist_ok=True)
    temp = Path(tempfile.mkdtemp(prefix=f".{target.name}.", dir=target.parent))
    count = 0
    try:
        index = (base / "index.theme").read_text(errors="replace").splitlines()
        rendered = []
        for line in index:
            if line.startswith("Name="):
                rendered.append(f"Name={OVERLAY_NAME}")
            elif line.startswith("Inherits="):
                rendered.append(f"Inherits={base.name}")
            else:
                rendered.append(line)
        (temp / "index.theme").write_text("\n".join(rendered) + "\n")
        (temp / MARKER).write_text("managed by Clavis\n")

        for places in iter_places(base):
            for source in places.glob("*folder*.svg"):
                relative = source.relative_to(base)
                if "symbolic" in relative.parts:
                    continue
                try:
                    data = source.read_text(errors="replace")
                except OSError:
                    continue
                destination = temp / relative
                destination.parent.mkdir(parents=True, exist_ok=True)
                destination.write_text(SOURCE_COLOR.sub(primary, data))
                count += 1

        if target.is_symlink() or (target.exists() and not target.is_dir()):
            raise ValueError(f"{target} is not a regular directory")
        if target.exists():
            if not managed(target):
                raise ValueError(f"{target} is not managed by Clavis")
            shutil.rmtree(target)
        os.replace(temp, target)
    finally:
        if temp.exists():
            shutil.rmtree(temp, ignore_errors=True)
    return count


def update_cache(target: Path) -> None:
    if shutil.which("gtk-update-icon-cache"):
        subprocess.run(
            ["gtk-update-icon-cache", "-f", "-t", str(target)],
            check=False,
            capture_output=True,
            text=True,
            timeout=30,
        )


def apply(paths: ClavisPaths, base_name: str, primary: str) -> int:
    base = find_theme(paths, base_name)
    if base is None:
        print(f"Folder icons: icon theme '{base_name}' not found; skipped", file=sys.stderr)
        return 0
    target = icon_dirs(paths)[0] / OVERLAY_NAME
    state = paths.state_home / "folder-icons"
    state.mkdir(parents=True, exist_ok=True)
    with (state / "lock").open("a") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        count = build_theme(base, target, primary)
        update_cache(target)
        (state / "base-theme").write_text(base_name + "\n")
        (state / "last-primary").write_text(primary + "\n")
    if current_theme(paths) in (*BASE_THEMES, OVERLAY_NAME):
        gsettings_set_theme(OVERLAY_NAME)
    return count


def restore(paths: ClavisPaths) -> int:
    state = paths.state_home / "folder-icons"
    state.mkdir(parents=True, exist_ok=True)
    with (state / "lock").open("a") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        try:
            base_name = (state / "base-theme").read_text().strip()
        except OSError:
            base_name = ""
        target = icon_dirs(paths)[0] / OVERLAY_NAME
        is_managed = target.is_dir() and managed(target)
        if base_name in BASE_THEMES and is_managed and current_theme(paths) == OVERLAY_NAME:
            gsettings_set_theme(base_name)
        if is_managed:
            shutil.rmtree(target)
    if state.is_dir():
        shutil.rmtree(state, ignore_errors=True)
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=("apply", "restore"))
    args = parser.parse_args()
    paths = ClavisPaths.from_environment()
    try:
        if args.action == "restore":
            return restore(paths)
        theme = current_theme(paths)
        base_name = resolve_base(paths, theme)
        if not base_name:
            print(
                f"Folder icons: active icon theme '{theme or 'unknown'}' is not a managed Tela variant; skipped",
                file=sys.stderr,
            )
            return 0
        primary = read_primary(paths)
        apply(paths, base_name, primary)
        return 0
    except (OSError, ValueError) as error:
        print(f"Folder icons: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
