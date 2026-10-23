import QtQuick
import QtQuick.Window
import Quickshell
import Quickshell.Wayland

Scope {
    id: root

    property bool presented: false
    property bool ready: false
    property bool failed: false
    property bool writingDone: false
    property bool timedOut: false
    property bool finished: false
    property real progress: 0
    property real fade: 1
    readonly property string userName: Quickshell.env("CLAVIS_STARTUP_NAME") || Quickshell.env("USER")
                                       || Quickshell.env("LOGNAME")

    NumberAnimation on progress {
        from: 0
        to: 1
        duration: 1100
        easing.type: Easing.InOutSine
        onFinished: root.writingDone = true
    }

    NumberAnimation {
        target: root
        property: "fade"
        from: 1
        to: 0
        duration: 300
        running: (root.ready && root.writingDone) || root.failed || root.timedOut
        onFinished: root.finished = true
    }

    Timer {
        interval: 15000
        running: !root.ready && !root.failed && !root.finished
        onTriggered: {
            console.warn("Desktop readiness timed out; releasing startup cover");
            root.timedOut = true;
        }
    }

    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: panel
            required property var modelData
            screen: modelData
            visible: !root.finished
            color: "transparent"
            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            mask: Region {}
            WlrLayershell.namespace: "clavis-startup"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            WlrLayershell.exclusionMode: ExclusionMode.Ignore

            Connections {
                target: panel.contentItem.Window.window
                function onFrameSwapped() {
                    root.presented = true;
                }
            }

            Rectangle {
                anchors.fill: parent
                color: "#282a36"
                opacity: root.fade

                Item {
                    anchors.centerIn: parent
                    width: Math.min(nameMetrics.advanceWidth, parent.width * 0.85)
                    height: 140
                    Item {
                        width: parent.width * root.progress
                        height: parent.height
                        clip: true
                        Text {
                            text: root.userName
                            textFormat: Text.PlainText
                            font: nameMetrics.font
                            color: "#f8f8f2"
                        }
                    }
                    Rectangle {
                        x: Math.max(0, parent.width * root.progress - width)
                        y: 94
                        width: 16
                        height: 3
                        radius: 1.5
                        color: "#bd93f9"
                        visible: !root.writingDone
                    }
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width * root.progress
                        height: 1
                        color: "#bd93f9"
                        opacity: 0.4
                    }
                }
                TextMetrics {
                    id: nameMetrics
                    text: root.userName
                    font.family: "Segoe Script"
                    font.pixelSize: 72
                }
            }
        }
    }
}
