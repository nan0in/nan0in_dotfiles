#!/usr/bin/env bash
# Non-destructive installer for the optional Clavis stow-style package.
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
source_dir="$root/wm/clavis/.local/src/clavis"
deps="$HOME/.local/opt/nan0in-clavis-deps"
case "${1:-check}" in
    check)
        exec python3 "$root/scripts/clavis-links.py" check "$root"
        ;;
    install|uninstall)
        python3 "$root/scripts/clavis-links.py" "$1" "$root"
        systemctl --user daemon-reload
        if [[ $1 == uninstall ]]; then
            profile="${XDG_CONFIG_HOME:-$HOME/.config}/niri-clavis/config.kdl"
            if systemctl --user show-environment | grep -Fxq "NIRI_CONFIG=$profile"; then
                systemctl --user unset-environment NIRI_CONFIG
            fi
        fi
        ;;
    build)
        export PKG_CONFIG_PATH="$deps/lib/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
        export LD_LIBRARY_PATH="$deps/lib:$deps/usr/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
        cmake -S "$source_dir" -B "$source_dir/build" -G Ninja -DCMAKE_BUILD_TYPE=RelWithDebInfo "-DCMAKE_CXX_FLAGS=-I$deps/include" \
            "-DCLAVIS_COMMIT=$(tail -n 1 "$root/wm/clavis/UPSTREAM")"
        cmake --build "$source_dir/build" --parallel 4
        python3 "$source_dir/scripts/release.py" bundle-resources --cache "${XDG_CACHE_HOME:-$HOME/.cache}/nan0in-clavis-build/resources"
        ;;
    deps)
        exec python3 "$root/scripts/clavis-deps.py"
        ;;
    appearance)
        exec python3 "$root/scripts/clavis-appearance.py" apply
        ;;
    migrate-outputs)
        exec python3 "$root/scripts/clavis-outputs.py" migrate
        ;;
    migrate-bindings)
        exec python3 "$root/scripts/clavis-bindings.py" migrate
        ;;
    repair-sysmon)
        exec python3 "$root/scripts/clavis-deps.py" --sysmon-only
        ;;
    *) echo 'Usage: setup-clavis.sh {check|install|uninstall|deps|build|repair-sysmon|appearance|migrate-bindings|migrate-outputs}' >&2; exit 2 ;;
esac
