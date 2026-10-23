pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Clavis.Niri
import qs.Common
import qs.Services

Singleton {
    id: root
    property var outputs: []
    property string source: ""
    property string target: ""
    property string error: ""
    property bool stopping: false
    readonly property bool active: mirror.running
    onSourceChanged: {
        if (!root.active && root.target === root.source)
            root.target = (root.outputs.find(output => output.value !== root.source) || {}).value || "";
    }
    function refresh() {
        root.outputs = Niri.outputSnapshot().filter(output => output.enabled && output.name).map(output => ({
            value: output.name,
            label: output.name
        }));
        if (!root.outputs.some(output => output.value === root.source))
            root.source = root.outputs.length ? root.outputs[0].value : "";
        if (!root.outputs.some(output => output.value === root.target) || root.target === root.source)
            root.target = (root.outputs.find(output => output.value !== root.source) || {}).value || "";
        if (root.active && (!root.outputs.some(output => output.value === mirror.sourceName) ||
                            !root.outputs.some(output => output.value === mirror.targetName)))
            root.stop();
    }
    function start() {
        if (root.active || root.source === root.target || !root.outputs.some(output => output.value
                                                                                       === root.source) ||
                !root.outputs.some(output => output.value === root.target) || WidgetState.sessionLocked)
            return false;
        root.error = "";
        root.stopping = false;
        mirror.sourceName = root.source;
        mirror.targetName = root.target;
        mirror.command = [Quickshell.env("CLAVIS_WL_MIRROR") || "wl-mirror", "--fullscreen-output",
                          root.target, "--scaling", "fit", "--title", "Clavis Projection", root.source];
        mirror.running = true;
        return true;
    }
    function stop() {
        root.stopping = true;
        mirror.running = false;
    }
    Component.onCompleted: root.refresh()
    Connections {
        target: Niri
        function onOutputsChanged() {
            root.refresh();
        }
        function onConnectedChanged() {
            if (!Niri.connected)
                root.stop();
            root.refresh();
        }
    }
    Connections {
        target: WidgetState
        function onSessionLockedChanged() {
            if (WidgetState.sessionLocked)
                root.stop();
        }
    }
    Process {
        id: mirror
        property string sourceName: ""
        property string targetName: ""
        stderr: StdioCollector {
            id: diagnostic
        }
        onExited: code => {
            if (code !== 0 && !root.stopping)
                root.error = diagnostic.text.trim() || qsTr("Projection stopped unexpectedly");
        }
    }
}
