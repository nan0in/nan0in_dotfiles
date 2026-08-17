import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import qs.config
import qs.modules.components
import qs.modules.globals
import qs.modules.theme

Item {
    id: root
    focus: true

    property real leftPanelWidth: 0
    property string prefixIcon: ""
    property string searchText: ""
    property string resultText: ""
    property string errorText: ""
    property bool evaluating: false

    signal backspaceOnEmpty

    onSearchTextChanged: {
        if (searchInput.text !== searchText) {
            searchInput.text = searchText;
        }
        scheduleEvaluation();
    }

    function focusSearchInput() {
        searchInput.focusInput();
    }

    function scheduleEvaluation() {
        evalTimer.restart();
    }

    function evaluateNow() {
        const query = searchText.trim();
        if (query.length === 0) {
            resultText = "";
            errorText = "";
            evaluating = false;
            return;
        }

        evaluating = true;
        resultText = "";
        errorText = "";
        qalcProcess.buffer = "";
        qalcProcess.errorBuffer = "";
        qalcProcess.command = ["qalc", "-t", query];
        qalcProcess.running = true;
    }

    Timer {
        id: evalTimer
        interval: 120
        repeat: false
        onTriggered: root.evaluateNow()
    }

    Process {
        id: qalcProcess
        running: false
        property string buffer: ""
        property string errorBuffer: ""

        stdout: SplitParser {
            onRead: data => qalcProcess.buffer += data + "\n"
        }

        stderr: SplitParser {
            onRead: data => qalcProcess.errorBuffer += data + "\n"
        }

        onExited: (exitCode, exitStatus) => {
            root.evaluating = false;
            if (exitCode === 0) {
                root.resultText = qalcProcess.buffer.trim();
                root.errorText = "";
            } else {
                root.resultText = "";
                root.errorText = qalcProcess.errorBuffer.trim() || "Invalid expression";
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        SearchInput {
            id: searchInput
            Layout.fillWidth: true
            prefixIcon: root.prefixIcon
            placeholderText: "2 + 2"
            text: root.searchText
            clearOnEscape: false
            onSearchTextChanged: text => {
                if (root.searchText !== text) {
                    root.searchText = text;
                }
            }
            onBackspaceOnEmpty: root.backspaceOnEmpty()
            onEscapePressed: Visibilities.setActiveModule("")
            onAccepted: root.evaluateNow()
        }

        StyledRect {
            Layout.fillWidth: true
            Layout.fillHeight: true
            variant: "pane"
            radius: Styling.radius(2)

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 8

                Text {
                    Layout.fillWidth: true
                    text: root.resultText.length > 0 ? root.resultText : (root.evaluating ? "Calculating..." : (root.errorText.length > 0 ? root.errorText : ""))
                    color: root.errorText.length > 0 ? Colors.error : Colors.overBackground
                    font.family: root.resultText.length > 0 ? Config.theme.monoFont : Config.theme.font
                    font.pixelSize: root.resultText.length > 0 ? 26 : Config.theme.fontSize
                    wrapMode: Text.Wrap
                    textFormat: Text.PlainText
                }

                Text {
                    Layout.fillWidth: true
                    visible: root.searchText.trim().length === 0
                    text: "Try: sqrt(144), 15% of 240, 2^10, 1/3"
                    color: Colors.outline
                    font.family: Config.theme.font
                    font.pixelSize: Config.theme.fontSize - 1
                    wrapMode: Text.Wrap
                }

                Item {
                    Layout.fillHeight: true
                }
            }
        }
    }
}
