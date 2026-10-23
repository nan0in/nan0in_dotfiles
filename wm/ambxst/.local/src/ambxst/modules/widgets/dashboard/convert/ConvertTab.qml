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
    property string normalizedQuery: ""
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

    function normalizeUnit(unit) {
        const lower = unit.toLowerCase();
        if (lower === "c" || lower === "degc" || lower === "celsius" || lower === "°c") return "celsius";
        if (lower === "f" || lower === "degf" || lower === "fahrenheit" || lower === "°f") return "fahrenheit";
        return unit;
    }

    function normalizeQuery(text) {
        let query = text.trim().replace(/\s+/g, " ");
        query = query.replace(/\s*(->|=>)\s*/g, " to ");
        if (query.length === 0) return "";

        const lower = query.toLowerCase();
        if (/\b(to|in)\b/.test(lower)) return query;

        const parts = query.split(" ");
        if (parts.length >= 3) {
            const target = normalizeUnit(parts[parts.length - 1]);
            const sourceParts = parts.slice(0, parts.length - 1);
            if (sourceParts.length >= 2) {
                sourceParts[sourceParts.length - 1] = normalizeUnit(sourceParts[sourceParts.length - 1]);
            }
            return sourceParts.join(" ") + " to " + target;
        }

        return query;
    }

    function scheduleEvaluation() {
        evalTimer.restart();
    }

    function evaluateNow() {
        const query = normalizeQuery(searchText);
        normalizedQuery = query;
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
                root.errorText = qalcProcess.errorBuffer.trim() || "Invalid conversion";
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
            placeholderText: "10 USD to CNY"
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
                    visible: root.normalizedQuery.length > 0 && root.normalizedQuery !== root.searchText.trim()
                    text: root.normalizedQuery
                    color: Colors.outline
                    font.family: Config.theme.font
                    font.pixelSize: Config.theme.fontSize - 2
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    text: root.resultText.length > 0 ? root.resultText : (root.evaluating ? "Converting..." : (root.errorText.length > 0 ? root.errorText : ""))
                    color: root.errorText.length > 0 ? Colors.error : Colors.overBackground
                    font.family: root.resultText.length > 0 ? Config.theme.monoFont : Config.theme.font
                    font.pixelSize: root.resultText.length > 0 ? 24 : Config.theme.fontSize
                    wrapMode: Text.Wrap
                    textFormat: Text.PlainText
                }

                Text {
                    Layout.fillWidth: true
                    visible: root.searchText.trim().length === 0
                    text: "Try: 5 km mi, 25 c f, 1 GiB MB, 10 USD CNY"
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
