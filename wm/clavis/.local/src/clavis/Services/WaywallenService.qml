pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services

Singleton {
    id: root

    property var snapshot: ({})
    readonly property bool available: snapshot.available === true
    readonly property bool running: snapshot.running === true
    readonly property string title: String(snapshot.title || "")
    readonly property string previewPath: String(snapshot.previewPath || "")
    readonly property string previewError: snapshot.previewState === "unavailable" ? qsTr(
                                                                                         "This wallpaper has no readable preview; keeping the previous colors") :
                                                                                     ""
    property string actionError: ""
    readonly property string error: root.actionError || String(snapshot.error || "")

    function refresh() {
        if (!probe.running)
            probe.running = true;
    }

    property bool launchRequested: false

    function cycle(action) {
        const method = action === "next" ? "Next" : action === "previous" ? "Previous" : "";
        if (!root.running || method === "" || cycleProcess.running)
            return false;
        root.actionError = "";
        cycleProcess.command = ["busctl", "--user", "call", "org.waywallen.waywallen.Daemon",
                                "/org/waywallen/waywallen/Daemon", "org.waywallen.waywallen.Daemon1", method];
        cycleProcess.running = true;
        return true;
    }

    function ensureRunning() {
        if (!root.available)
            return false;
        root.actionError = "";
        if (root.running) {
            root.resume();
        } else if (!root.launchRequested) {
            root.launchRequested = ApplicationService.launchCommand([String(root.snapshot.command),
                                                                     "--no-ui"]);
            launchTimeout.restart();
        }
        return true;
    }

    function resume() {
        if (root.running && !resumeProcess.running) {
            resumeProcess.running = true;
        }
    }

    function reconcileSelection() {
        if (PersonalizationConfig.ready && PersonalizationConfig.desktopWallpaperBackend === "waywallen")
            root.ensureRunning();
    }

    onAvailableChanged: root.reconcileSelection()
    onRunningChanged: {
        if (root.running) {
            root.launchRequested = false;
            launchTimeout.stop();
            if (PersonalizationConfig.desktopWallpaperBackend === "waywallen")
                root.resume();
        }
    }

    Connections {
        target: PersonalizationConfig
        function onReadyChanged() {
            root.reconcileSelection();
        }
        function onDesktopWallpaperBackendChanged() {
            root.reconcileSelection();
        }
    }

    function openManager() {
        if (root.available && root.snapshot.command)
            ApplicationService.launchCommand([String(root.snapshot.command)]);
    }

    Component.onCompleted: root.refresh()

    Timer {
        interval: 5000
        repeat: true
        running: true
        onTriggered: root.refresh()
    }

    Timer {
        id: launchTimeout
        interval: 8000
        onTriggered: {
            root.launchRequested = false;
            root.refresh();
        }
    }

    Process {
        id: resumeProcess
        command: ["busctl", "--user", "call", "org.waywallen.waywallen.Daemon",
            "/org/waywallen/waywallen/Daemon", "org.waywallen.waywallen.Daemon1", "Resume"]
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0 || exitStatus !== 0)
                root.actionError = qsTr("Could not resume Waywallen wallpaper");
        }
    }

    Process {
        id: cycleProcess
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0 || exitStatus !== 0)
                root.actionError = qsTr("Could not change Waywallen wallpaper");
            root.refresh();
        }
    }

    Process {
        id: probe
        command: ["python3", Paths.scriptPath("system", "waywallen_status.py")]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const result = JSON.parse(this.text);
                    if (result.schemaVersion !== 1)
                        throw new Error("Unsupported Waywallen bridge schema");
                    root.snapshot = result;
                } catch (error) {
                    root.snapshot = {
                        error: qsTr("Could not read Waywallen status")
                    };
                }
            }
        }
    }
}
