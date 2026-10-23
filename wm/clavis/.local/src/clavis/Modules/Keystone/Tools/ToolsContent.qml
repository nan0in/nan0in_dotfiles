pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Window
import qs.Common
import qs.Widgets.common

Item {
    id: toolsRoot

    property bool vertical: false
    property string edge: "top"
    property string popupEdge: edge
    property bool retainForRecording: false
    readonly property int buttonSize: 48
    readonly property int buttonSpacing: 8
    readonly property int buttonsExtent: 408
    readonly property int crossExtent: 128
    property var toolsModel: [
        {
            "action": "screenshot",
            "icon": "screenshot_region",
            "tip": qsTr("Screenshot")
        },
        {
            "action": "screenshots",
            "icon": "photo_library",
            "tip": qsTr("Open screenshots")
        },
        {
            "action": "recordings",
            "icon": "video_library",
            "tip": qsTr("Open recordings")
        },
        {
            "action": "ocr",
            "icon": "document_scanner",
            "tip": qsTr("Extract text")
        },
        {
            "action": "qr",
            "icon": "qr_code_scanner",
            "tip": qsTr("Scan QR code")
        },
        {
            "action": "lens",
            "icon": "image_search",
            "tip": qsTr("Google Lens")
        },
        {
            "action": "mirror",
            "icon": "flip",
            "tip": qsTr("Mirror")
        },
        {
            "action": "color-picker",
            "icon": "colorize",
            "tip": qsTr("Color picker")
        },
        {
            "action": "record-video",
            "icon": "videocam",
            "tip": qsTr("Screen recording")
        },
        {
            "action": "record-gif",
            "icon": "gif",
            "tip": qsTr("Record GIF")
        },
        {
            "action": "audio-mic",
            "icon": "mic",
            "tip": qsTr("Record microphone")
        },
        {
            "action": "audio-system",
            "icon": "speaker",
            "tip": qsTr("Record system audio")
        }
    ]
    property int selectedIndex: 0

    signal requestHideKeystone
    signal recordingRequested

    function triggerSelected() {
        const tool = toolsModel[selectedIndex];
        if (!tool)
            return;

        const recordingTool = tool.action === "record-video" || tool.action === "record-gif" || tool.action
              === "audio-mic" || tool.action === "audio-system";
        if (recordingTool && retainForRecording)
            toolsRoot.recordingRequested();
        else
            toolsRoot.requestHideKeystone();
        switch (tool.action) {
        case "color-picker":
            toolsBackend.pickColor();
            break;
        case "record-video":
            toolsBackend.startRecord("video");
            break;
        case "record-gif":
            toolsBackend.startRecord("gif");
            break;
        case "audio-mic":
            toolsBackend.startAudio("mic");
            break;
        case "audio-system":
            toolsBackend.startAudio("system");
            break;
        default:
            toolsBackend.launchTool(tool.action);
        }
    }

    function stopRecording() {
        toolsBackend.stopRecord();
    }

    function stopAudio() {
        toolsBackend.stopAudio();
    }

    implicitWidth: vertical ? crossExtent : buttonsExtent
    implicitHeight: vertical ? buttonsExtent : crossExtent
    property bool keyboardActive: visible
    enabled: keyboardActive
    focus: keyboardActive
    onKeyboardActiveChanged: {
        if (keyboardActive) {
            selectedIndex = 0;
            forceActiveFocus();
        }
    }
    Keys.onLeftPressed: {
        selectedIndex = (selectedIndex - 1 + toolsModel.length) % toolsModel.length;
    }
    Keys.onRightPressed: {
        selectedIndex = (selectedIndex + 1) % toolsModel.length;
    }
    Keys.onUpPressed: {
        selectedIndex = (selectedIndex - toolGrid.columns + toolsModel.length) % toolsModel.length;
    }
    Keys.onDownPressed: {
        selectedIndex = (selectedIndex + toolGrid.columns) % toolsModel.length;
    }
    Keys.onReturnPressed: triggerSelected()
    Keys.onEnterPressed: triggerSelected()

    ToolsBackend {
        id: toolsBackend
    }

    Grid {
        id: toolGrid
        anchors.centerIn: parent
        spacing: toolsRoot.buttonSpacing
        columns: toolsRoot.vertical ? 2 : 7

        Repeater {
            model: toolsRoot.toolsModel

            IconButton {
                required property int index
                required property var modelData
                controlSize: toolsRoot.buttonSize
                iconName: modelData.icon
                iconSize: 22
                iconColor: Appearance.colors.colOnSurface
                selectedIconColor: Appearance.colors.colOnSurface
                accessibleName: modelData.tip
                selected: index === toolsRoot.selectedIndex
                selectedContainerColor: Appearance.colors.colLayer2Hover
                selectedHoverStateLayerColor: Appearance.colors.colLayer2Hover
                selectedPressedStateLayerColor: Appearance.colors.colLayer2Active
                hoverStateLayerColor: Appearance.colors.colLayer2Hover
                pressedStateLayerColor: Appearance.colors.colLayer2Active
                onPointerHoveredChanged: {
                    if (pointerHovered)
                        toolsRoot.selectedIndex = index;
                }
                onClicked: {
                    toolsRoot.selectedIndex = index;
                    toolsRoot.triggerSelected();
                }
            }
        }
    }
}
