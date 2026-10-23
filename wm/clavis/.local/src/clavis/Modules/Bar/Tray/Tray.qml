pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Components
import qs.Services
import qs.Widgets.common

TopBarPill {
    id: root

    property bool trayOverflowOpen: false
    property bool vertical: false
    property string edge: "top"
    property var barVisualItem: null
    property var activeMenu: null
    property var screen: null
    property real overflowSurfacePadding: 10
    readonly property var pinnedItems: TrayService.pinnedItems
    readonly property var unpinnedItems: TrayService.unpinnedItems
    readonly property var foldedWindows: DockService.foldedWindows
    readonly property bool hasOverflow: root.unpinnedItems.length > 0 || root.foldedWindows.length > 0
    readonly property bool foldingHostActive: root.visible && !!root.QsWindow.window
                                              && root.QsWindow.window.visible

    property bool _foldingRegistered: false

    function syncFoldingHost() {
        if (root._foldingRegistered === root.foldingHostActive)
            return;
        root._foldingRegistered = root.foldingHostActive;
        DockService.foldingHostCount = Math.max(0, DockService.foldingHostCount + (root._foldingRegistered ? 1 :
                                                                                                             -1));
    }
    onFoldingHostActiveChanged: root.syncFoldingHost()
    Component.onCompleted: root.syncFoldingHost()
    Component.onDestruction: {
        if (root._foldingRegistered)
            DockService.foldingHostCount = Math.max(0, DockService.foldingHostCount - 1);
    }

    implicitHeight: vertical ? content.implicitHeight + 2 * root.pillPadding : root.pillThickness
    implicitWidth: vertical ? root.pillThickness : content.implicitWidth + 2 * root.pillPadding

    onHasOverflowChanged: {
        if (!root.hasOverflow)
            root.trayOverflowOpen = false;
    }

    Connections {
        target: WidgetState
        function onTransientSurfacesDismissRequested() {
            root.trayOverflowOpen = false;
            root.closeActiveMenu();
        }
    }

    function setActiveMenu(window) {
        if (root.activeMenu && root.activeMenu !== window && typeof root.activeMenu.close === "function")
            root.activeMenu.close();
        root.activeMenu = window;
    }

    function releaseActiveMenu(window) {
        if (!window || root.activeMenu === window)
            root.activeMenu = null;
    }

    function closeActiveMenu() {
        if (root.activeMenu && typeof root.activeMenu.close === "function")
            root.activeMenu.close();
        root.activeMenu = null;
    }

    GridLayout {
        id: content

        anchors.centerIn: parent
        rowSpacing: Sizes.barItemSpacing
        columnSpacing: Sizes.barItemSpacing
        columns: root.vertical ? 1 : Math.max(1, root.pinnedItems.length + 1)

        RippleButton {
            id: trayOverflowButton

            visible: root.hasOverflow
            toggled: root.trayOverflowOpen
            implicitWidth: Sizes.barControlCircleSize
            implicitHeight: Sizes.barControlCircleSize
            buttonRadius: Appearance.rounding.full
            containerColor: root.trayOverflowOpen ? Appearance.colors.colSecondaryContainer : "transparent"
            stateLayerColor: root.trayOverflowOpen ? Appearance.colors.colSecondaryContainerHover :
                                                     Appearance.colors.colSecondaryContainer
            pressedStateLayerColor: Appearance.colors.colSecondaryContainerActive
            rippleColor: Appearance.colors.colOnSecondaryContainer
            Layout.alignment: Qt.AlignVCenter
            releaseAction: () => {
                if (root.trayOverflowOpen) {
                    root.trayOverflowOpen = false;
                    root.closeActiveMenu();
                    return;
                }

                root.closeActiveMenu();
                root.trayOverflowOpen = true;
            }

            Accessible.name: qsTr("Folded applications and tray")
            PopupToolTip {
                extraVisibleCondition: trayOverflowButton.pointerHovered && !root.trayOverflowOpen
                text: qsTr("Folded applications and tray")
            }

            contentItem: MaterialSymbol {
                anchors.centerIn: parent
                text: "expand_more"
                iconSize: Sizes.barIconSize
                color: root.trayOverflowOpen || trayOverflowButton.pointerHovered
                       ? Appearance.colors.colOnSecondaryContainer : Appearance.colors.colOnLayer0
                rotation: (root.edge === "bottom" ? 180 : root.edge === "left" ? -90 : root.edge === "right"
                                                                                 ? 90 : 0) + (
                              root.trayOverflowOpen ? 180 : 0)

                Behavior on rotation {
                    NumberAnimation {
                        duration: Appearance.animation.expressiveEffects.duration
                        easing.type: Appearance.animation.expressiveEffects.type
                        easing.bezierCurve: Appearance.animation.expressiveEffects.bezierCurve
                    }
                }
                Behavior on color {
                    ColorAnimation {
                        duration: Appearance.animation.expressiveEffects.duration
                        easing.type: Appearance.animation.expressiveEffects.type
                        easing.bezierCurve: Appearance.animation.expressiveEffects.bezierCurve
                    }
                }
            }
        }

        Repeater {
            model: root.pinnedItems

            delegate: TrayItem {
                screen: root.screen
                edge: root.edge
                barVisualItem: root.barVisualItem
                Layout.alignment: Qt.AlignVCenter
                onMenuOpened: window => root.setActiveMenu(window)
                onMenuClosed: root.releaseActiveMenu(null)
            }
        }
    }

    PopupWindow {
        id: overflowPopup

        // Layer-shell windows do not expose reliable global coordinates on
        // Wayland. Let the compositor place the popup relative to its real
        // parent surface, as TrayMenu already does.
        visible: root.trayOverflowOpen && !WidgetState.sessionLocked && root.hasOverflow
        color: "transparent"
        implicitWidth: overflowSurface.implicitWidth
        implicitHeight: overflowSurface.implicitHeight
        grabFocus: ThemeService.isNiriSession

        readonly property real crossPadding: Math.max(0, (root.barVisualItem ? ((root.vertical
                                                                                 ? root.barVisualItem.width :
                                                                                   root.barVisualItem.height)
                                                                                - (root.vertical
                                                                                   ? trayOverflowButton.width :
                                                                                     trayOverflowButton.height))
                                                                               / 2 : 0) + Sizes.barPopupGap
                                                      - root.overflowSurfacePadding)

        anchor {
            item: trayOverflowButton
            rect.x: root.vertical ? -overflowPopup.crossPadding : 0
            rect.y: root.vertical ? 0 : -overflowPopup.crossPadding
            rect.width: trayOverflowButton.width + (root.vertical ? overflowPopup.crossPadding * 2 : 0)
            rect.height: trayOverflowButton.height + (root.vertical ? 0 : overflowPopup.crossPadding * 2)
            edges: root.edge === "bottom" ? Edges.Top : root.edge === "left" ? Edges.Right : root.edge
                                                                               === "right" ? Edges.Left :
                                                                                             Edges.Bottom
            gravity: root.edge === "bottom" ? Edges.Top : root.edge === "left" ? Edges.Right : root.edge
                                                                                 === "right" ? Edges.Left :
                                                                                               Edges.Bottom
            adjustment: root.vertical ? PopupAdjustment.SlideY : PopupAdjustment.SlideX
        }

        onVisibleChanged: {
            if (visible)
                Qt.callLater(() => overflowKeyScope.forceActiveFocus());
            else
                root.trayOverflowOpen = false;
        }

        PanelWindow {
            visible: overflowPopup.visible && ThemeService.isNiriSession
            screen: root.screen
            color: "transparent"
            exclusiveZone: 0
            WlrLayershell.layer: root.QsWindow.window ? root.QsWindow.window.WlrLayershell.layer :
                                                        WlrLayer.Top
            WlrLayershell.namespace: "clavis-shell-tray-overflow-backdrop"
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                onClicked: {
                    root.trayOverflowOpen = false;
                    root.closeActiveMenu();
                }
            }
        }

        FocusScope {
            id: overflowKeyScope

            anchors.fill: parent
            focus: overflowPopup.visible

            Keys.onEscapePressed: event => {
                root.trayOverflowOpen = false;
                root.closeActiveMenu();
                event.accepted = true;
            }

            Item {
                id: overflowSurface

                implicitWidth: popupBackground.implicitWidth + root.overflowSurfacePadding * 2
                implicitHeight: popupBackground.implicitHeight + root.overflowSurfacePadding * 2
                width: implicitWidth
                height: implicitHeight

                StyledRectangularShadow {
                    target: popupBackground
                    opacity: popupBackground.opacity
                }

                Rectangle {
                    id: popupBackground

                    readonly property real popupPadding: 4

                    x: root.overflowSurfacePadding
                    y: root.overflowSurfacePadding
                    implicitWidth: overflowLayout.implicitWidth + popupPadding * 2
                    implicitHeight: overflowLayout.implicitHeight + popupPadding * 2
                    color: BlurService.backgroundColor(Appearance.colors.colLayer0)
                    radius: 18
                    border.width: 1
                    border.color: Appearance.colors.colLayer0Border
                    clip: true
                    opacity: overflowPopup.visible ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation {
                            alwaysRunToEnd: true
                            duration: Appearance.animation.expressiveEffects.duration
                            easing.type: Appearance.animation.expressiveEffects.type
                            easing.bezierCurve: Appearance.animation.expressiveEffects.bezierCurve
                        }
                    }
                    Behavior on implicitWidth {
                        NumberAnimation {
                            alwaysRunToEnd: true
                            duration: Appearance.animation.elementResize.duration
                            easing.type: Appearance.animation.elementResize.type
                            easing.bezierCurve: Appearance.animation.elementResize.bezierCurve
                        }
                    }
                    Behavior on implicitHeight {
                        NumberAnimation {
                            alwaysRunToEnd: true
                            duration: Appearance.animation.elementResize.duration
                            easing.type: Appearance.animation.elementResize.type
                            easing.bezierCurve: Appearance.animation.elementResize.bezierCurve
                        }
                    }

                    ColumnLayout {
                        id: overflowLayout
                        anchors.centerIn: parent
                        spacing: 6

                        GridLayout {
                            visible: root.unpinnedItems.length > 0
                            Layout.alignment: Qt.AlignHCenter
                            columns: Math.max(1, Math.ceil(Math.sqrt(root.unpinnedItems.length)))
                            columnSpacing: 10
                            rowSpacing: 10
                            Repeater {
                                model: root.unpinnedItems
                                delegate: TrayItem {
                                    screen: root.screen
                                    edge: root.edge
                                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                                    onMenuOpened: window => root.setActiveMenu(window)
                                    onMenuClosed: root.releaseActiveMenu(null)
                                }
                            }
                        }

                        Rectangle {
                            visible: root.unpinnedItems.length > 0 && root.foldedWindows.length > 0
                            Layout.fillWidth: true
                            implicitHeight: 1
                            color: Appearance.colors.colLayer0Border
                        }

                        StyledFlickable {
                            visible: root.foldedWindows.length > 0
                            Layout.preferredWidth: Math.min(304, Math.max(160, (root.screen ? root.screen.width :
                                                                                              320) - 48))
                            Layout.preferredHeight: Math.min(foldedColumn.implicitHeight, Math.max(80, (
                                                                                                       root.screen
                                                                                                       ? root.screen.height :
                                                                                                         600) * 0.55))
                            contentWidth: width
                            contentHeight: foldedColumn.implicitHeight
                            clip: true

                            ColumnLayout {
                                id: foldedColumn
                                width: parent.width
                                spacing: 2

                                Repeater {
                                    model: root.foldedWindows
                                    delegate: RippleButton {
                                        id: restoreButton
                                        required property var modelData
                                        Layout.fillWidth: true
                                        implicitHeight: 44
                                        buttonRadius: 12
                                        Accessible.name: qsTr("Restore %1").arg(modelData.foldName)
                                        releaseAction: () => {
                                            if (DockService.focusWindow(restoreButton.modelData.id,
                                                                        root.screen ? root.screen.name : ""))
                                                root.trayOverflowOpen = false;
                                        }
                                        contentItem: RowLayout {
                                            spacing: 10
                                            ThemeIcon {
                                                Layout.leftMargin: 10
                                                Layout.preferredWidth: 24
                                                Layout.preferredHeight: 24
                                                iconSource: ApplicationService.iconSource(
                                                                restoreButton.modelData.foldIcon
                                                                || "application-x-executable")
                                            }
                                            Text {
                                                Layout.fillWidth: true
                                                Layout.rightMargin: 10
                                                text: restoreButton.modelData.foldName
                                                textFormat: Text.PlainText
                                                elide: Text.ElideRight
                                                font.family: Fonts.ui
                                                font.pixelSize: 13
                                                color: Appearance.colors.colOnSurface
                                            }
                                        }
                                        PopupToolTip {
                                            extraVisibleCondition: restoreButton.pointerHovered
                                            text: restoreButton.modelData.foldName
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        CompositorBlurRegion {
            targetWindow: overflowPopup
            backgroundItem: popupBackground
        }
    }
}
