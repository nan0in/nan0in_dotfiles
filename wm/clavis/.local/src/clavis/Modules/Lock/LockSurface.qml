import QtQuick
import Quickshell.Wayland
import qs.Common
import qs.Services

WlSessionLockSurface {
    id: root

    required property WlSessionLock lock
    // Quickshell creates the surface component itself, so this cannot be a
    // required property; the inline LockSurface instance supplies the value.
    property var lockRoot: null
    property var context: null
    property var snapshotProvider: null
    // Freeze the selection for this lock session.
    property string style: "default"
    readonly property color baseColor: root.style === "caelestia" ? Appearance.colors.colLayer0Base :
                                                                    "#15191D"

    property bool presented: false
    property int revision: root.lockRoot ? root.lockRoot.presentationRevision : 0

    color: root.baseColor
    onVisibleChanged: {
        root.presented = false;
        if (visible)
            presentedTimer.restart();
    }
    onRevisionChanged: {
        root.presented = false;
        if (root.visible)
            presentedTimer.restart();
    }

    // Commit a simple frame before the richer lock UI initializes. niri paints
    // its red lock backdrop when a lock surface has no buffer; this keeps the
    // transition neutral even if the QML scene is still loading.
    Rectangle {
        anchors.fill: parent
        color: root.baseColor
    }

    Loader {
        anchors.fill: parent
        sourceComponent: root.style === "caelestia" ? caelestia : defaultStyle
    }

    // Resume can invalidate the surface buffer. A sub-percent opacity change
    // dirties the scene and makes the compositor receive a fresh frame without
    // a visible flash.
    Rectangle {
        anchors.fill: parent
        color: root.baseColor
        opacity: 0.001 + (root.revision % 2) * 0.001
    }

    Timer {
        id: presentedTimer

        interval: 150
        repeat: false
        running: root.visible && !root.presented
        onTriggered: {
            if (!root.visible)
                return;

            root.presented = true;
            if (root.lockRoot)
                root.lockRoot.notePresented(root.screen ? root.screen.name : "");
        }
    }

    Component {
        id: caelestia

        CaelestiaLock {
            lock: root.lock
            context: root.context
            snapshotProvider: root.snapshotProvider
            screen: root.screen
        }
    }

    Component {
        id: defaultStyle

        DefaultLock {
            snapshotProvider: root.snapshotProvider
            lock: root.lock
            context: root.context
            screen: root.screen
        }
    }
}
