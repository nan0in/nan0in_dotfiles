pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services

Singleton {
    id: root
    property var settings: ({
                                dim: 0.08,
                                blur: true,
                                source: "wallpaper",
                                color: "#bd93f9"
                            })
    property bool ready: false
    property bool nativeRuntimeReady: false
    property string error: ""
    readonly property bool busy: operation.running
    function setValue(name, value) {
        root.settings = Object.assign({}, root.settings, {
                                          [name]: value
                                      });
        applyTimer.restart();
    }
    function apply() {
        if (root.busy) {
            applyTimer.restart();
            return;
        }
        root.invoke({
                        operation: "apply",
                        settings: root.settings,
                        wallpaper: ThemeService.activeWallpaperColorSource
                    });
    }
    function invoke(request) {
        operation.command = ["python3", Paths.scriptPath("theme", "window_appearance.py"), JSON.stringify(
                                 request)];
        operation.running = true;
    }
    function initialize() {
        if (!root.ready && !root.busy)
            root.invoke({
                            operation: "status"
                        });
    }
    Component.onCompleted: root.invoke({
                                           operation: "status"
                                       })
    Timer {
        id: applyTimer
        interval: 200
        onTriggered: root.apply()
    }
    Connections {
        target: ThemeService
        function onActiveWallpaperColorSourceChanged() {
            if (root.ready && root.settings.source === "wallpaper")
                applyTimer.restart();
        }
    }
    Process {
        id: operation
        stdout: StdioCollector {
            id: output
        }
        stderr: StdioCollector {
            id: diagnostic
        }
        onExited: code => {
            try {
                const response = JSON.parse(output.text);
                if (code !== 0 || response.schemaVersion !== 1 || !response.ok)
                    throw new Error(response.error || diagnostic.text);
                if (!applyTimer.running)
                    root.settings = response.settings;
                root.nativeRuntimeReady = response.native;
                root.error = "";
                if (!root.ready) {
                    root.ready = true;
                    applyTimer.restart();
                }
            } catch (e) {
                root.error = String(e);
            }
        }
    }
}
