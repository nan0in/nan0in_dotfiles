import QtQuick
import QtQuick.Layouts
import QtMultimedia
import Quickshell
import qs.Common
import qs.Widgets.common

FloatingWindow {
    id: root

    property bool previewRequested: false
    readonly property bool cameraActive: camera.active
    readonly property int cameraCount: devices.videoInputs.length
    visible: true
    title: qsTr("Mirror")
    implicitWidth: 640
    implicitHeight: 520
    color: Appearance.colors.colLayer0
    onVisibleChanged: if (!visible)
                          previewRequested = false

    MediaDevices {
        id: devices
    }
    CaptureSession {
        camera: Camera {
            id: camera
            cameraDevice: devices.defaultVideoInput
            active: root.previewRequested && root.visible && root.cameraCount > 0
        }
        videoOutput: preview
        // No microphone, recorder, image capture or network output.
    }
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        VideoOutput {
            id: preview
            Layout.fillWidth: true
            Layout.fillHeight: true
            mirrored: true
            fillMode: VideoOutput.PreserveAspectFit
            Text {
                anchors.centerIn: parent
                width: parent.width - 24
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                color: Appearance.colors.colOnSurface
                text: camera.errorString || (root.cameraCount === 0 ? qsTr("No camera available") :
                                                                      !root.previewRequested ? qsTr(
                                                                                                   "Start camera preview") :
                                                                                               "")
                visible: text.length > 0
            }
        }
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 16
            IconButton {
                iconName: root.previewRequested ? "stop" : "play_arrow"
                accessibleName: root.previewRequested ? qsTr("Stop preview") : qsTr("Start preview")
                enabled: root.cameraCount > 0
                onClicked: root.previewRequested = !root.previewRequested
            }
            IconButton {
                iconName: "flip"
                accessibleName: qsTr("Mirror video")
                selected: preview.mirrored
                onClicked: preview.mirrored = !preview.mirrored
            }
            IconButton {
                iconName: "close"
                accessibleName: qsTr("Close")
                onClicked: root.visible = false
            }
        }
    }
}
