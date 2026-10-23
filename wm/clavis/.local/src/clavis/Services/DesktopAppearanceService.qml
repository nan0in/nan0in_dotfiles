pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services

Singleton {
    id: root
    property var choices: ({
                               gtk: [],
                               icons: [],
                               qtStyle: [],
                               qtPalette: [],
                               qtTheme: []
                           })
    property var current: ({})
    readonly property var descriptions: ({
                                             "Material-inspired rounded Dracula skin; preserves personal fonts":
                                             qsTr("Material-inspired rounded Dracula skin; preserves personal fonts"),
                                             "Installed GTK 3 theme": qsTr("Installed GTK 3 theme"),
                                             "Installed icon theme": qsTr("Installed icon theme"),
                                             "Qt built-in cross-platform widget style": qsTr(
                                                                                            "Qt built-in cross-platform widget style"),
                                             "Qt built-in classic widget style": qsTr(
                                                                                     "Qt built-in classic widget style"),
                                             "SVG-based Kvantum style; keeps the selected Kvantum theme": qsTr(
                                                                                                              "SVG-based Kvantum style; keeps the selected Kvantum theme"),
                                             "KDE Breeze widget style": qsTr("KDE Breeze widget style"),
                                             "Installed Qt widget color palette": qsTr(
                                                                                      "Installed Qt widget color palette"),
                                             "Current personal Qt widget palette": qsTr(
                                                                                       "Current personal Qt widget palette"),
                                             "Installed Kvantum SVG theme; independent of the Qt color palette":
                                             qsTr("Installed Kvantum SVG theme; independent of the Qt color palette")
                                         })
    property string error: ""
    readonly property bool busy: operation.running
    function invoke(request) {
        if (root.busy)
            return;
        operation.command = ["python3", Paths.scriptPath("theme", "desktop_appearance.py"), JSON.stringify(
                                 request)];
        operation.running = true;
    }
    function refresh() {
        root.invoke({
                        operation: "status"
                    });
    }
    function apply(kind, value) {
        root.invoke({
                        operation: "apply",
                        kind: kind,
                        value: value
                    });
    }
    function description(kind) {
        const selected = (root.choices[kind] || []).find(item => item.value === root.current[kind]);
        return selected ? (root.descriptions[selected.description] || selected.description) : "";
    }
    Component.onCompleted: root.refresh()
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
                if (response.schemaVersion !== 1 || !response.ok || code !== 0)
                    throw new Error(response.error || diagnostic.text);
                root.choices = response.choices;
                root.current = response.current;
                root.error = "";
            } catch (e) {
                root.error = String(e);
            }
        }
    }
}
