pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.theme
import qs.modules.components
import qs.modules.globals
import Quickshell
import Quickshell.Io
import qs.config

Item {
    id: root

    property int maxContentWidth: 480
    readonly property int contentWidth: Math.min(width, maxContentWidth)
    readonly property real sideMargin: (width - contentWidth) / 2

    property string currentSection: ""
    property string selectedVariant: "bg"
    property var gtkThemes: []
    property var cursorThemes: []
    property var iconThemes: []
    property var qtThemes: ["kvantum", "kvantum-dark", "Fusion", "Breeze", "Windows"]
    property var cursorSizes: [8, 12, 16, 20, 24, 28, 32, 36, 40, 48, 56, 64]
    property string currentGtkTheme: "adw-gtk3"
    property string currentQtTheme: "kvantum"
    readonly property var iconThemeOptions: ["System Default"].concat(root.iconThemes)

    component SectionButton: StyledRect {
        id: sectionBtn
        required property string text
        required property string sectionId

        property bool isHovered: false

        variant: isHovered ? "focus" : "pane"
        Layout.fillWidth: true
        Layout.preferredHeight: 56
        radius: Styling.radius(0)

        RowLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 16

            Text {
                text: sectionBtn.text
                font.family: Config.theme.font
                font.pixelSize: Styling.fontSize(0)
                font.bold: true
                color: Colors.overBackground
                Layout.fillWidth: true
            }

            Text {
                text: Icons.caretRight
                font.family: Icons.font
                font.pixelSize: 20
                color: Colors.overSurfaceVariant
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: sectionBtn.isHovered = true
            onExited: sectionBtn.isHovered = false
            onClicked: root.currentSection = sectionBtn.sectionId
        }
    }

    component AppComboBox: ComboBox {
        id: comboRoot

        Layout.fillWidth: true
        Layout.preferredHeight: 40
        focusPolicy: Qt.NoFocus
        hoverEnabled: true

        background: Rectangle {
            color: comboRoot.hovered ? Colors.surfaceContainerHigh : Colors.surfaceContainer
            radius: Styling.radius(-2)
            border.color: comboRoot.popup.visible ? Styling.srItem("overprimary") : Colors.outlineVariant
            border.width: 1

            Behavior on color {
                enabled: Config.animDuration > 0
                ColorAnimation {
                    duration: Config.animDuration / 2
                }
            }

            Behavior on border.color {
                enabled: Config.animDuration > 0
                ColorAnimation {
                    duration: Config.animDuration / 2
                }
            }
        }

        contentItem: Text {
            leftPadding: 12
            rightPadding: 32
            text: comboRoot.displayText
            font.family: Config.theme.font
            font.pixelSize: Styling.fontSize(0)
            color: comboRoot.enabled ? Colors.overBackground : Colors.overSurfaceVariant
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        indicator: Text {
            x: comboRoot.width - width - 12
            anchors.verticalCenter: parent.verticalCenter
            text: Icons.caretDown
            font.family: Icons.font
            font.pixelSize: 18
            color: comboRoot.enabled ? Colors.overBackground : Colors.overSurfaceVariant
        }

        popup: Popup {
            y: comboRoot.height + 4
            width: comboRoot.width
            implicitHeight: Math.min(contentItem.implicitHeight + 8, 240)
            padding: 4

            background: Rectangle {
                color: Colors.surfaceContainerLow
                radius: Styling.radius(-1)
                border.color: Colors.outlineVariant
                border.width: 1
            }

            contentItem: ListView {
                clip: true
                implicitHeight: contentHeight
                model: comboRoot.popup.visible ? comboRoot.delegateModel : null
                currentIndex: comboRoot.highlightedIndex
                ScrollIndicator.vertical: ScrollIndicator {}
            }
        }

        delegate: ItemDelegate {
            id: delegateItem
            required property var modelData
            required property int index

            width: ListView.view.width
            height: 36
            highlighted: comboRoot.highlightedIndex === index

            background: Rectangle {
                color: delegateItem.highlighted ? Colors.surfaceContainerHigh : "transparent"
                radius: Styling.radius(-2)
            }

            contentItem: Text {
                text: delegateItem.modelData
                font.family: Config.theme.font
                font.pixelSize: Styling.fontSize(0)
                color: Colors.overBackground
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
        }
    }

    // Color picker state
    property bool colorPickerActive: false
    property var colorPickerColorNames: []
    property string colorPickerCurrentColor: ""
    property string colorPickerDialogTitle: ""
    property var colorPickerCallback: null

    function openColorPicker(colorNames, currentColor, dialogTitle, callback) {
        colorPickerColorNames = colorNames;
        colorPickerCurrentColor = currentColor;
        colorPickerDialogTitle = dialogTitle;
        colorPickerCallback = callback;
        colorPickerActive = true;
    }

    function closeColorPicker() {
        colorPickerActive = false;
        colorPickerCallback = null;
    }

    function handleColorSelected(color) {
        if (colorPickerCallback) {
            colorPickerCallback(color);
        }
        colorPickerCurrentColor = color;
    }

    function shellQuote(value: string): string {
        return "'" + value.replace(/'/g, "'\"'\"'") + "'";
    }

    function runGtkThemingUpdate(enabled: bool) {
        if (enabled) {
            gtkThemeProcess.command = ["bash", "-c", "gsettings set org.gnome.desktop.interface gtk-theme " + shellQuote(root.currentGtkTheme)];
            gtkThemeProcess.running = true;
            return;
        }

        gtkThemeProcess.command = ["bash", "-c", "gsettings reset org.gnome.desktop.interface gtk-theme"];
        gtkThemeProcess.running = true;
    }

    function runQtThemingUpdate(enabled: bool) {
        if (enabled) {
            let qtTheme = shellQuote(root.currentQtTheme);
            let command = "python3 -c \"from pathlib import Path\nimport configparser\nstyle = " + qtTheme + "\nfor name in ('qt5ct/qt5ct.conf', 'qt6ct/qt6ct.conf'):\n    path = Path.home() / '.config' / name\n    path.parent.mkdir(parents=True, exist_ok=True)\n    config = configparser.ConfigParser()\n    config.read(path)\n    appearance = dict(config['Appearance']) if 'Appearance' in config else {}\n    appearance['style'] = style\n    config['Appearance'] = appearance\n    with path.open('w') as f:\n        config.write(f)\"";
            qtThemeProcess.command = ["bash", "-c", command];
            qtThemeProcess.running = true;
        }
    }

    function runCursorUpdate() {
        cursorProcess.command = ["bash", "-c", "hyprctl setcursor " + shellQuote(Config.theme.cursorTheme) + " " + Config.theme.cursorSize];
        cursorProcess.running = true;
    }

    function runIconThemeUpdate() {
        let command = Config.theme.iconTheme.trim() === "" ? "gsettings reset org.gnome.desktop.interface icon-theme" : "gsettings set org.gnome.desktop.interface icon-theme " + shellQuote(Config.theme.iconTheme);
        iconThemeProcess.command = ["bash", "-c", command];
        iconThemeProcess.running = true;
    }

    function applyCursorTheme(themeName: string) {
        if (themeName !== "" && themeName !== Config.theme.cursorTheme) {
            GlobalStates.markThemeChanged();
            Config.theme.cursorTheme = themeName;
            root.runCursorUpdate();
        }
    }

    function applyIconTheme(themeName: string) {
        let newTheme = themeName === "System Default" ? "" : themeName;
        if (newTheme !== Config.theme.iconTheme) {
            GlobalStates.markThemeChanged();
            Config.theme.iconTheme = newTheme;
            root.runIconThemeUpdate();
        }
    }

    function applyGtkTheme(themeName: string) {
        if (themeName !== "" && themeName !== root.currentGtkTheme) {
            GlobalStates.markThemeChanged();
            root.currentGtkTheme = themeName;
            if (Config.theme.gtkThemingEnabled) {
                root.runGtkThemingUpdate(true);
            }
        }
    }

    function applyQtTheme(themeName: string) {
        if (themeName !== "" && themeName !== root.currentQtTheme) {
            GlobalStates.markThemeChanged();
            root.currentQtTheme = themeName;
            if (Config.theme.qtThemingEnabled) {
                root.runQtThemingUpdate(true);
            }
        }
    }

    Process {
        id: gtkThemeProcess
    }

    Process {
        id: cursorProcess
    }

    Process {
        id: iconThemeProcess
    }

    Process {
        id: qtThemeProcess
    }

    Process {
        id: gtkThemesQuery
        running: true
        command: ["bash", "-c", "find ~/.themes /usr/share/themes ~/.local/share/themes -maxdepth 1 -type d 2>/dev/null | xargs basename -a | sort -u"]
        stdout: StdioCollector {
            id: gtkThemesCollector
            onStreamFinished: {
                root.gtkThemes = text.trim().split("\n").filter(l => l);
            }
        }
    }

    Process {
        id: cursorThemesQuery
        running: true
        command: ["bash", "-c", "find ~/.icons /usr/share/icons ~/.local/share/icons -maxdepth 2 -type d -name cursors -exec dirname {} \\; 2>/dev/null | xargs basename -a | sort -u"]
        stdout: StdioCollector {
            id: cursorThemesCollector
            onStreamFinished: {
                root.cursorThemes = text.trim().split("\n").filter(l => l);
            }
        }
    }

    Process {
        id: iconThemesQuery
        running: true
        command: ["bash", "-c", "find ~/.icons /usr/share/icons ~/.local/share/icons -maxdepth 1 -type d -not -name default 2>/dev/null | xargs basename -a | sort -u"]
        stdout: StdioCollector {
            id: iconThemesCollector
            onStreamFinished: {
                root.iconThemes = text.trim().split("\n").filter(l => l);
            }
        }
    }

    Process {
        id: currentGtkThemeQuery
        running: true
        command: ["bash", "-c", "gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: {
                let value = text.trim();
                if (value.length >= 2) {
                    root.currentGtkTheme = value.replace(/^'|'$/g, "");
                }
            }
        }
    }

    Process {
        id: currentQtThemeQuery
        running: true
        command: ["bash", "-c", "python3 -c \"from pathlib import Path\nimport configparser\nfor name in ('qt6ct/qt6ct.conf', 'qt5ct/qt5ct.conf'):\n    path = Path.home() / '.config' / name\n    if path.exists():\n        config = configparser.ConfigParser()\n        config.read(path)\n        style = config.get('Appearance', 'style', fallback='').strip()\n        if style:\n            print(style)\n            break\n\" 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: {
                let value = text.trim();
                if (value !== "") {
                    root.currentQtTheme = value;
                }
            }
        }
    }

    FileView {
        id: wallpaperConfig
        // QUICKSHELL-GIT: path: Quickshell.cachePath("wallpapers.json")
        path: Quickshell.env("HOME") + "/.cache/ambxst/wallpapers.json"

        JsonAdapter {
            property string currentWall: ""
            property string wallPath: ""
            property string matugenScheme: "scheme-tonal-spot"
            property string activeColorPreset: ""
        }
    }

    // Convert sr property name to variant id (srBg -> bg, srPrimaryFocus -> primaryfocus)
    function srNameToId(srName: string): string {
        return srName.substring(2).toLowerCase();
    }

    // Dynamically generate allVariants from Config.theme properties starting with "sr"
    // Reads the label property from each variant config
    readonly property var allVariants: {
        let variants = [];
        let theme = Config.theme;

        // Get all property names from theme that start with "sr"
        for (let prop in theme) {
            if (prop.startsWith("sr") && theme[prop] && typeof theme[prop] === "object") {
                // Read label from the variant config itself, fallback to property name
                let label = theme[prop].label || prop.substring(2);
                variants.push({
                    id: srNameToId(prop),
                    label: label
                });
            }
        }

        return variants;
    }

    function getVariantLabel(variantId: string): string {
        for (var i = 0; i < allVariants.length; i++) {
            if (allVariants[i].id === variantId) {
                return allVariants[i].label;
            }
        }
        return variantId;
    }

    // Main content - single Flickable for everything, fills entire width
    Flickable {
        id: mainFlickable
        anchors.fill: parent
        contentHeight: mainColumn.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        interactive: !root.colorPickerActive

        // Horizontal slide + fade animation
        opacity: root.colorPickerActive ? 0 : 1
        transform: Translate {
            id: mainTranslate
            x: root.colorPickerActive ? -30 : 0

            Behavior on x {
                enabled: Config.animDuration > 0
                NumberAnimation {
                    duration: Config.animDuration / 2
                    easing.type: Easing.OutQuart
                }
            }
        }

        Behavior on opacity {
            enabled: Config.animDuration > 0
            NumberAnimation {
                duration: Config.animDuration / 2
                easing.type: Easing.OutQuart
            }
        }

        ColumnLayout {
            id: mainColumn
            width: mainFlickable.width
            spacing: 8

            // Header wrapper
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: titlebar.height

                PanelTitlebar {
                    id: titlebar
                    width: root.contentWidth
                    anchors.horizontalCenter: parent.horizontalCenter
                    title: root.currentSection === "" ? "Theme" : (root.currentSection.charAt(0).toUpperCase() + root.currentSection.slice(1))
                    statusText: GlobalStates.themeHasChanges ? "Unsaved changes" : ""
                    statusColor: Colors.error

                    actions: {
                        let baseActions = [
                            {
                                icon: Icons.arrowCounterClockwise,
                                tooltip: "Discard changes",
                                enabled: GlobalStates.themeHasChanges,
                                onClicked: function () {
                                    GlobalStates.discardThemeChanges();
                                }
                            },
                            {
                                icon: Icons.disk,
                                tooltip: "Apply changes",
                                enabled: GlobalStates.themeHasChanges,
                                onClicked: function () {
                                    GlobalStates.applyThemeChanges();
                                }
                            }
                        ];

                        if (root.currentSection !== "") {
                            return [
                                {
                                    icon: Icons.arrowLeft,
                                    tooltip: "Back",
                                    onClicked: function () {
                                        root.currentSection = "";
                                    }
                                }
                            ].concat(baseActions);
                        }

                        return baseActions;
                    }
                }
            }

            // Content wrapper - centered
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: contentColumn.implicitHeight

                ColumnLayout {
                    id: contentColumn
                    width: root.contentWidth
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 12

                    // ═══════════════════════════════════════════════════════════════
                    // MENU SECTION
                    // ═══════════════════════════════════════════════════════════════
                    ColumnLayout {
                        visible: root.currentSection === ""
                        Layout.fillWidth: true
                        spacing: 8

                        SectionButton {
                            text: "General"
                            sectionId: "general"
                        }
                        SectionButton {
                            text: "Shadow"
                            sectionId: "shadow"
                        }
                        SectionButton {
                            text: "Colors"
                            sectionId: "colors"
                        }
                        SectionButton {
                            text: "Applications"
                            sectionId: "applications"
                        }
                    }

                    // General section
                    Item {
                        visible: root.currentSection === "general"
                        Layout.fillWidth: true
                        Layout.preferredHeight: generalContent.implicitHeight

                        ColumnLayout {
                            id: generalContent
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            spacing: 8

                            Text {
                                text: "General"
                                font.family: Config.theme.font
                                font.pixelSize: Styling.fontSize(-1)
                                font.weight: Font.Medium
                                color: Colors.overSurfaceVariant
                                Layout.bottomMargin: -4
                            }

                            // Wallpaper Path
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Text {
                                    text: "Wallpapers"
                                    font.family: Config.theme.font
                                    font.pixelSize: Styling.fontSize(0)
                                    color: Colors.overBackground
                                    Layout.preferredWidth: 80
                                }

                                StyledRect {
                                    variant: "common"
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 32
                                    radius: Styling.radius(-2)

                                    TextInput {
                                        id: wallPathInput
                                        anchors.fill: parent
                                        anchors.margins: 8
                                        font.family: Config.theme.font
                                        font.pixelSize: Styling.fontSize(0)
                                        color: Colors.overBackground
                                        selectByMouse: true
                                        clip: true
                                        verticalAlignment: TextInput.AlignVCenter

                                        // Placeholder for default path
                                        Text {
                                            anchors.fill: parent
                                            verticalAlignment: Text.AlignVCenter
                                            text: "Default"
                                            font: parent.font
                                            color: Colors.overSurfaceVariant
                                            visible: !parent.text && !parent.activeFocus
                                        }

                                        text: wallpaperConfig.adapter.wallPath

                                        onEditingFinished: {
                                            if (wallpaperConfig.adapter.wallPath !== text) {
                                                wallpaperConfig.adapter.wallPath = text;
                                                wallpaperConfig.writeAdapter();
                                            }
                                        }
                                    }
                                }
                            }

                            // Tint Icons toggle
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Text {
                                    text: "Tint Icons"
                                    font.family: Config.theme.font
                                    font.pixelSize: Styling.fontSize(0)
                                    color: Colors.overBackground
                                    Layout.fillWidth: true
                                }

                                Switch {
                                    id: tintIconsSwitch
                                    checked: Config.theme.tintIcons

                                    readonly property bool configValue: Config.theme.tintIcons

                                    onConfigValueChanged: {
                                        if (checked !== configValue) {
                                            checked = configValue;
                                        }
                                    }

                                    onCheckedChanged: {
                                        if (checked !== Config.theme.tintIcons) {
                                            GlobalStates.markThemeChanged();
                                            Config.theme.tintIcons = checked;
                                        }
                                    }

                                    indicator: Rectangle {
                                        implicitWidth: 40
                                        implicitHeight: 20
                                        x: tintIconsSwitch.leftPadding
                                        y: parent.height / 2 - height / 2
                                        radius: height / 2
                                        color: tintIconsSwitch.checked ? Styling.srItem("overprimary") : Colors.surfaceBright
                                        border.color: tintIconsSwitch.checked ? Styling.srItem("overprimary") : Colors.outline

                                        Behavior on color {
                                            enabled: Config.animDuration > 0
                                            ColorAnimation {
                                                duration: Config.animDuration / 2
                                            }
                                        }

                                        Rectangle {
                                            x: tintIconsSwitch.checked ? parent.width - width - 2 : 2
                                            y: 2
                                            width: parent.height - 4
                                            height: width
                                            radius: width / 2
                                            color: tintIconsSwitch.checked ? Colors.background : Colors.overSurfaceVariant

                                            Behavior on x {
                                                enabled: Config.animDuration > 0
                                                NumberAnimation {
                                                    duration: Config.animDuration / 2
                                                    easing.type: Easing.OutCubic
                                                }
                                            }
                                        }
                                    }
                                    background: null
                                }
                            }

                            // Enable Corners toggle
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Text {
                                    text: "Enable Corners"
                                    font.family: Config.theme.font
                                    font.pixelSize: Styling.fontSize(0)
                                    color: Colors.overBackground
                                    Layout.fillWidth: true
                                }

                                Switch {
                                    id: enableCornersSwitch
                                    checked: Config.theme.enableCorners

                                    readonly property bool configValue: Config.theme.enableCorners

                                    onConfigValueChanged: {
                                        if (checked !== configValue) {
                                            checked = configValue;
                                        }
                                    }

                                    onCheckedChanged: {
                                        if (checked !== Config.theme.enableCorners) {
                                            GlobalStates.markThemeChanged();
                                            Config.theme.enableCorners = checked;
                                        }
                                    }

                                    indicator: Rectangle {
                                        implicitWidth: 40
                                        implicitHeight: 20
                                        x: enableCornersSwitch.leftPadding
                                        y: parent.height / 2 - height / 2
                                        radius: height / 2
                                        color: enableCornersSwitch.checked ? Styling.srItem("overprimary") : Colors.surfaceBright
                                        border.color: enableCornersSwitch.checked ? Styling.srItem("overprimary") : Colors.outline

                                        Behavior on color {
                                            enabled: Config.animDuration > 0
                                            ColorAnimation {
                                                duration: Config.animDuration / 2
                                            }
                                        }

                                        Rectangle {
                                            x: enableCornersSwitch.checked ? parent.width - width - 2 : 2
                                            y: 2
                                            width: parent.height - 4
                                            height: width
                                            radius: width / 2
                                            color: enableCornersSwitch.checked ? Colors.background : Colors.overSurfaceVariant

                                            Behavior on x {
                                                enabled: Config.animDuration > 0
                                                NumberAnimation {
                                                    duration: Config.animDuration / 2
                                                    easing.type: Easing.OutCubic
                                                }
                                            }
                                        }
                                    }
                                    background: null
                                }
                            }

                            // Animation Duration slider
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Text {
                                    text: "Animation"
                                    font.family: Config.theme.font
                                    font.pixelSize: Styling.fontSize(0)
                                    color: Colors.overBackground
                                    Layout.preferredWidth: 80
                                }

                                StyledSlider {
                                    id: animDurationSlider
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 20
                                    progressColor: Styling.srItem("overprimary")
                                    tooltipText: `${Math.round(value * 1000)}ms`
                                    scroll: true
                                    stepSize: 0.01  // 10ms steps (1/100 of 1000ms)
                                    snapMode: "always"

                                    readonly property real configValue: Config.theme.animDuration / 1000

                                    onConfigValueChanged: {
                                        if (Math.abs(value - configValue) > 0.001) {
                                            value = configValue;
                                        }
                                    }

                                    Component.onCompleted: value = configValue

                                    onValueChanged: {
                                        let newDuration = Math.round(value * 1000);
                                        if (newDuration !== Config.theme.animDuration) {
                                            GlobalStates.markThemeChanged();
                                            Config.theme.animDuration = newDuration;
                                        }
                                    }
                                }

                                Text {
                                    text: Config.theme.animDuration + "ms"
                                    font.family: Config.theme.font
                                    font.pixelSize: Styling.fontSize(0)
                                    color: Colors.overBackground
                                    horizontalAlignment: Text.AlignRight
                                    Layout.preferredWidth: 50
                                }
                            }

                            Separator {
                                Layout.fillWidth: true
                            }

                            Text {
                                text: "Fonts"
                                font.family: Config.theme.font
                                font.pixelSize: Styling.fontSize(-1)
                                font.weight: Font.Medium
                                color: Colors.overSurfaceVariant
                                Layout.bottomMargin: -4
                            }

                            // UI Font row
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Text {
                                    text: "UI Font"
                                    font.family: Config.theme.font
                                    font.pixelSize: Styling.fontSize(0)
                                    color: Colors.overBackground
                                    Layout.preferredWidth: 80
                                }

                                StyledRect {
                                    variant: "common"
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 32
                                    radius: Styling.radius(-2)

                                    TextInput {
                                        id: fontInput
                                        anchors.fill: parent
                                        anchors.margins: 8
                                        font.family: Config.theme.font
                                        font.pixelSize: Styling.fontSize(0)
                                        color: Colors.overBackground
                                        selectByMouse: true
                                        clip: true
                                        verticalAlignment: TextInput.AlignVCenter

                                        readonly property string configValue: Config.theme.font

                                        onConfigValueChanged: {
                                            if (text !== configValue) {
                                                text = configValue;
                                            }
                                        }

                                        Component.onCompleted: text = configValue

                                        onEditingFinished: {
                                            if (text !== Config.theme.font && text.trim() !== "") {
                                                GlobalStates.markThemeChanged();
                                                Config.theme.font = text.trim();
                                            }
                                        }
                                    }
                                }

                                StyledRect {
                                    variant: "common"
                                    Layout.preferredWidth: 60
                                    Layout.preferredHeight: 32
                                    radius: Styling.radius(-2)

                                    TextInput {
                                        id: fontSizeInput
                                        anchors.fill: parent
                                        anchors.margins: 8
                                        font.family: Config.theme.font
                                        font.pixelSize: Styling.fontSize(0)
                                        color: Colors.overBackground
                                        selectByMouse: true
                                        clip: true
                                        verticalAlignment: TextInput.AlignVCenter
                                        horizontalAlignment: TextInput.AlignHCenter
                                        validator: IntValidator {
                                            bottom: 8
                                            top: 32
                                        }

                                        readonly property int configValue: Config.theme.fontSize

                                        onConfigValueChanged: {
                                            if (text !== configValue.toString()) {
                                                text = configValue.toString();
                                            }
                                        }

                                        Component.onCompleted: text = configValue.toString()

                                        onEditingFinished: {
                                            let newSize = parseInt(text);
                                            if (!isNaN(newSize) && newSize >= 8 && newSize <= 32 && newSize !== Config.theme.fontSize) {
                                                GlobalStates.markThemeChanged();
                                                Config.theme.fontSize = newSize;
                                            }
                                        }
                                    }
                                }

                                Text {
                                    text: "px"
                                    font.family: Config.theme.font
                                    font.pixelSize: Styling.fontSize(0)
                                    color: Colors.overSurfaceVariant
                                }
                            }

                            // Mono Font row
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Text {
                                    text: "Mono Font"
                                    font.family: Config.theme.font
                                    font.pixelSize: Styling.fontSize(0)
                                    color: Colors.overBackground
                                    Layout.preferredWidth: 80
                                }

                                StyledRect {
                                    variant: "common"
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 32
                                    radius: Styling.radius(-2)

                                    TextInput {
                                        id: monoFontInput
                                        anchors.fill: parent
                                        anchors.margins: 8
                                        font.family: Config.theme.monoFont
                                        font.pixelSize: Styling.monoFontSize(0)
                                        color: Colors.overBackground
                                        selectByMouse: true
                                        clip: true
                                        verticalAlignment: TextInput.AlignVCenter

                                        readonly property string configValue: Config.theme.monoFont

                                        onConfigValueChanged: {
                                            if (text !== configValue) {
                                                text = configValue;
                                            }
                                        }

                                        Component.onCompleted: text = configValue

                                        onEditingFinished: {
                                            if (text !== Config.theme.monoFont && text.trim() !== "") {
                                                GlobalStates.markThemeChanged();
                                                Config.theme.monoFont = text.trim();
                                            }
                                        }
                                    }
                                }

                                StyledRect {
                                    variant: "common"
                                    Layout.preferredWidth: 60
                                    Layout.preferredHeight: 32
                                    radius: Styling.radius(-2)

                                    TextInput {
                                        id: monoFontSizeInput
                                        anchors.fill: parent
                                        anchors.margins: 8
                                        font.family: Config.theme.monoFont
                                        font.pixelSize: Styling.monoFontSize(0)
                                        color: Colors.overBackground
                                        selectByMouse: true
                                        clip: true
                                        verticalAlignment: TextInput.AlignVCenter
                                        horizontalAlignment: TextInput.AlignHCenter
                                        validator: IntValidator {
                                            bottom: 8
                                            top: 32
                                        }

                                        readonly property int configValue: Config.theme.monoFontSize

                                        onConfigValueChanged: {
                                            if (text !== configValue.toString()) {
                                                text = configValue.toString();
                                            }
                                        }

                                        Component.onCompleted: text = configValue.toString()

                                        onEditingFinished: {
                                            let newSize = parseInt(text);
                                            if (!isNaN(newSize) && newSize >= 8 && newSize <= 32 && newSize !== Config.theme.monoFontSize) {
                                                GlobalStates.markThemeChanged();
                                                Config.theme.monoFontSize = newSize;
                                            }
                                        }
                                    }
                                }

                                Text {
                                    text: "px"
                                    font.family: Config.theme.font
                                    font.pixelSize: Styling.fontSize(0)
                                    color: Colors.overSurfaceVariant
                                }
                            }

                            Separator {
                                Layout.fillWidth: true
                            }

                            Text {
                                text: "Roundness"
                                font.family: Config.theme.font
                                font.pixelSize: Styling.fontSize(-1)
                                font.weight: Font.Medium
                                color: Colors.overSurfaceVariant
                                Layout.bottomMargin: -4
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                StyledSlider {
                                    id: roundnessSlider
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 20
                                    progressColor: Styling.srItem("overprimary")
                                    tooltipText: `${Math.round(value * 20)}`
                                    scroll: true
                                    stepSize: 0.05  // 1/20 = 0.05 for integer steps in 0-20 range
                                    snapMode: "always"

                                    // Use a computed property that always reads from Config
                                    readonly property real configValue: Config.theme.roundness / 20

                                    // Sync value when configValue changes (e.g., after discard)
                                    onConfigValueChanged: {
                                        if (Math.abs(value - configValue) > 0.001) {
                                            value = configValue;
                                        }
                                    }

                                    Component.onCompleted: value = configValue

                                    onValueChanged: {
                                        let newRoundness = Math.round(value * 20);
                                        if (newRoundness !== Config.theme.roundness) {
                                            GlobalStates.markThemeChanged();
                                            Config.theme.roundness = newRoundness;
                                        }
                                    }
                                }

                                Text {
                                    text: Math.round(roundnessSlider.value * 20)
                                    font.family: Config.theme.font
                                    font.pixelSize: Styling.fontSize(0)
                                    color: Colors.overBackground
                                    horizontalAlignment: Text.AlignRight
                                    Layout.preferredWidth: 24
                                }
                            }
                        }
                    }

                    // Shadow section
                    Item {
                        visible: root.currentSection === "shadow"
                        Layout.fillWidth: true
                        Layout.preferredHeight: shadowContent.implicitHeight

                        ColumnLayout {
                            id: shadowContent
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            spacing: 8

                            Text {
                                text: "Shadow"
                                font.family: Config.theme.font
                                font.pixelSize: Styling.fontSize(-1)
                                font.weight: Font.Medium
                                color: Colors.overSurfaceVariant
                                Layout.bottomMargin: -4
                            }

                            // Opacity row
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Text {
                                    text: "Opacity"
                                    font.family: Config.theme.font
                                    font.pixelSize: Styling.fontSize(0)
                                    color: Colors.overBackground
                                    Layout.preferredWidth: 80
                                }

                                StyledSlider {
                                    id: shadowOpacitySlider
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 20
                                    progressColor: Styling.srItem("overprimary")
                                    tooltipText: `${Math.round(value * 100)}%`
                                    scroll: true
                                    stepSize: 0.01
                                    snapMode: "always"

                                    readonly property real configValue: Config.theme.shadowOpacity

                                    onConfigValueChanged: {
                                        if (Math.abs(value - configValue) > 0.001) {
                                            value = configValue;
                                        }
                                    }

                                    Component.onCompleted: value = configValue

                                    onValueChanged: {
                                        if (Math.abs(value - Config.theme.shadowOpacity) > 0.001) {
                                            GlobalStates.markThemeChanged();
                                            Config.theme.shadowOpacity = value;
                                        }
                                    }
                                }

                                Text {
                                    text: Math.round(shadowOpacitySlider.value * 100) + "%"
                                    font.family: Config.theme.font
                                    font.pixelSize: Styling.fontSize(0)
                                    color: Colors.overBackground
                                    horizontalAlignment: Text.AlignRight
                                    Layout.preferredWidth: 40
                                }
                            }

                            // Blur row
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Text {
                                    text: "Blur"
                                    font.family: Config.theme.font
                                    font.pixelSize: Styling.fontSize(0)
                                    color: Colors.overBackground
                                    Layout.preferredWidth: 80
                                }

                                StyledSlider {
                                    id: shadowBlurSlider
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 20
                                    progressColor: Styling.srItem("overprimary")
                                    tooltipText: `${(value * 4).toFixed(1)}`
                                    scroll: true
                                    stepSize: 0.01
                                    snapMode: "always"

                                    readonly property real configValue: Config.theme.shadowBlur / 4

                                    onConfigValueChanged: {
                                        if (Math.abs(value - configValue) > 0.001) {
                                            value = configValue;
                                        }
                                    }

                                    Component.onCompleted: value = configValue

                                    onValueChanged: {
                                        let newBlur = value * 4;
                                        if (Math.abs(newBlur - Config.theme.shadowBlur) > 0.01) {
                                            GlobalStates.markThemeChanged();
                                            Config.theme.shadowBlur = newBlur;
                                        }
                                    }
                                }

                                Text {
                                    text: Config.theme.shadowBlur.toFixed(1)
                                    font.family: Config.theme.font
                                    font.pixelSize: Styling.fontSize(0)
                                    color: Colors.overBackground
                                    horizontalAlignment: Text.AlignRight
                                    Layout.preferredWidth: 40
                                }
                            }

                            // Offset row (X and Y)
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Text {
                                    text: "Offset X"
                                    font.family: Config.theme.font
                                    font.pixelSize: Styling.fontSize(0)
                                    color: Colors.overBackground
                                    Layout.preferredWidth: 80
                                }

                                StyledSlider {
                                    id: shadowXOffsetSlider
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 20
                                    progressColor: Styling.srItem("overprimary")
                                    tooltipText: `${Math.round((value - 0.5) * 40)}`
                                    scroll: true
                                    stepSize: 0.025  // 1/40 for integer steps in -20 to +20 range
                                    snapMode: "always"

                                    readonly property real configValue: (Config.theme.shadowXOffset + 20) / 40

                                    onConfigValueChanged: {
                                        if (Math.abs(value - configValue) > 0.001) {
                                            value = configValue;
                                        }
                                    }

                                    Component.onCompleted: value = configValue

                                    onValueChanged: {
                                        let newOffset = Math.round((value - 0.5) * 40);
                                        if (newOffset !== Config.theme.shadowXOffset) {
                                            GlobalStates.markThemeChanged();
                                            Config.theme.shadowXOffset = newOffset;
                                        }
                                    }
                                }

                                Text {
                                    text: Config.theme.shadowXOffset
                                    font.family: Config.theme.font
                                    font.pixelSize: Styling.fontSize(0)
                                    color: Colors.overBackground
                                    horizontalAlignment: Text.AlignRight
                                    Layout.preferredWidth: 40
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Text {
                                    text: "Offset Y"
                                    font.family: Config.theme.font
                                    font.pixelSize: Styling.fontSize(0)
                                    color: Colors.overBackground
                                    Layout.preferredWidth: 80
                                }

                                StyledSlider {
                                    id: shadowYOffsetSlider
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 20
                                    progressColor: Styling.srItem("overprimary")
                                    tooltipText: `${Math.round((value - 0.5) * 40)}`
                                    scroll: true
                                    stepSize: 0.025  // 1/40 for integer steps in -20 to +20 range
                                    snapMode: "always"

                                    readonly property real configValue: (Config.theme.shadowYOffset + 20) / 40

                                    onConfigValueChanged: {
                                        if (Math.abs(value - configValue) > 0.001) {
                                            value = configValue;
                                        }
                                    }

                                    Component.onCompleted: value = configValue

                                    onValueChanged: {
                                        let newOffset = Math.round((value - 0.5) * 40);
                                        if (newOffset !== Config.theme.shadowYOffset) {
                                            GlobalStates.markThemeChanged();
                                            Config.theme.shadowYOffset = newOffset;
                                        }
                                    }
                                }

                                Text {
                                    text: Config.theme.shadowYOffset
                                    font.family: Config.theme.font
                                    font.pixelSize: Styling.fontSize(0)
                                    color: Colors.overBackground
                                    horizontalAlignment: Text.AlignRight
                                    Layout.preferredWidth: 40
                                }
                            }

                            // Color row
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Text {
                                    text: "Color"
                                    font.family: Config.theme.font
                                    font.pixelSize: Styling.fontSize(0)
                                    color: Colors.overBackground
                                    Layout.preferredWidth: 80
                                }

                                StyledRect {
                                    id: shadowColorButton
                                    variant: "common"
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 32
                                    radius: Styling.radius(-2)

                                    property bool isHovered: false

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 8
                                        anchors.rightMargin: 8
                                        spacing: 8

                                        Rectangle {
                                            Layout.preferredWidth: 16
                                            Layout.preferredHeight: 16
                                            radius: 4
                                            color: Config.resolveColor(Config.theme.shadowColor)
                                            border.width: 1
                                            border.color: Colors.outline
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: Config.theme.shadowColor
                                            font.family: Config.theme.font
                                            font.pixelSize: Styling.fontSize(0)
                                            color: shadowColorButton.item
                                            elide: Text.ElideRight
                                        }
                                    }

                                    Rectangle {
                                        anchors.fill: parent
                                        color: Styling.srItem("overprimary")
                                        radius: shadowColorButton.radius ?? 0
                                        opacity: shadowColorButton.isHovered ? 0.15 : 0

                                        Behavior on opacity {
                                            enabled: (Config.animDuration ?? 0) > 0
                                            NumberAnimation {
                                                duration: (Config.animDuration ?? 0) / 2
                                            }
                                        }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor

                                        onEntered: shadowColorButton.isHovered = true
                                        onExited: shadowColorButton.isHovered = false

                                        onClicked: {
                                            root.openColorPicker(Colors.availableColorNames, Config.theme.shadowColor, "Select Shadow Color", function (color) {
                                                GlobalStates.markThemeChanged();
                                                Config.theme.shadowColor = color;
                                            });
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Variant selector section
                    Item {
                        id: variantSelectorPane
                        visible: root.currentSection === "colors"
                        property string settingsSection: "colors"
                        Layout.fillWidth: true
                        Layout.preferredHeight: variantSelectorContent.implicitHeight

                        property bool variantExpanded: false

                        Behavior on Layout.preferredHeight {
                            enabled: (Config.animDuration ?? 0) > 0
                            NumberAnimation {
                                duration: (Config.animDuration ?? 0) / 2
                                easing.type: Easing.OutCubic
                            }
                        }

                        ColumnLayout {
                            id: variantSelectorContent
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            spacing: 8

                            Text {
                                text: "Variant"
                                font.family: Config.theme.font
                                font.pixelSize: Styling.fontSize(-1)
                                font.weight: Font.Medium
                                color: Colors.overSurfaceVariant
                                Layout.bottomMargin: -4
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                Layout.alignment: Qt.AlignTop

                                // Collapsed mode: horizontal scrollable row with scrollbar
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 4
                                    visible: !variantSelectorPane.variantExpanded

                                    Flickable {
                                        id: variantFlickable
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 32
                                        contentWidth: variantRow.width
                                        flickableDirection: Flickable.HorizontalFlick
                                        clip: true
                                        boundsBehavior: Flickable.StopAtBounds

                                        Row {
                                            id: variantRow
                                            spacing: 4

                                            Repeater {
                                                model: root.allVariants

                                                delegate: StyledRect {
                                                    id: variantTagRow
                                                    required property var modelData
                                                    required property int index

                                                    property bool isSelected: root.selectedVariant === modelData.id
                                                    property bool isHovered: false

                                                    variant: modelData.id
                                                    enableShadow: true

                                                    width: tagContentRow.width + 24 + (isSelected ? checkIconRow.width + 4 : 0)
                                                    height: 32
                                                    radius: isSelected ? Styling.radius(0) / 2 : Styling.radius(0)

                                                    Behavior on width {
                                                        enabled: (Config.animDuration ?? 0) > 0
                                                        NumberAnimation {
                                                            duration: (Config.animDuration ?? 0) / 3
                                                            easing.type: Easing.OutCubic
                                                        }
                                                    }

                                                    Item {
                                                        anchors.fill: parent
                                                        anchors.margins: 8

                                                        Row {
                                                            anchors.centerIn: parent
                                                            spacing: variantTagRow.isSelected ? 4 : 0

                                                            Item {
                                                                width: checkIconRow.visible ? checkIconRow.width : 0
                                                                height: checkIconRow.height
                                                                clip: true

                                                                Text {
                                                                    id: checkIconRow
                                                                    text: Icons.accept
                                                                    font.family: Icons.font
                                                                    font.pixelSize: 16
                                                                    color: variantTagRow.item
                                                                    visible: variantTagRow.isSelected
                                                                    opacity: variantTagRow.isSelected ? 1 : 0

                                                                    Behavior on opacity {
                                                                        enabled: (Config.animDuration ?? 0) > 0
                                                                        NumberAnimation {
                                                                            duration: (Config.animDuration ?? 0) / 3
                                                                            easing.type: Easing.OutCubic
                                                                        }
                                                                    }
                                                                }

                                                                Behavior on width {
                                                                    enabled: (Config.animDuration ?? 0) > 0
                                                                    NumberAnimation {
                                                                        duration: (Config.animDuration ?? 0) / 3
                                                                        easing.type: Easing.OutCubic
                                                                    }
                                                                }
                                                            }

                                                            Text {
                                                                id: tagContentRow
                                                                text: variantTagRow.modelData.label
                                                                font.family: Config.theme.font
                                                                font.pixelSize: Config.theme.fontSize
                                                                font.bold: true
                                                                color: variantTagRow.item

                                                                Behavior on color {
                                                                    enabled: (Config.animDuration ?? 0) > 0
                                                                    ColorAnimation {
                                                                        duration: (Config.animDuration ?? 0) / 3
                                                                        easing.type: Easing.OutCubic
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }

                                                    Rectangle {
                                                        anchors.fill: parent
                                                        color: Styling.srItem("overprimary")
                                                        radius: variantTagRow.radius ?? 0
                                                        opacity: variantTagRow.isHovered ? 0.15 : 0

                                                        Behavior on opacity {
                                                            enabled: (Config.animDuration ?? 0) > 0
                                                            NumberAnimation {
                                                                duration: (Config.animDuration ?? 0) / 2
                                                            }
                                                        }
                                                    }

                                                    MouseArea {
                                                        anchors.fill: parent
                                                        hoverEnabled: true
                                                        cursorShape: Qt.PointingHandCursor

                                                        onEntered: variantTagRow.isHovered = true
                                                        onExited: variantTagRow.isHovered = false

                                                        onClicked: root.selectedVariant = variantTagRow.modelData.id
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    ScrollBar {
                                        id: variantScrollBar
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 8
                                        orientation: Qt.Horizontal

                                        position: variantFlickable.contentWidth > 0 ? variantFlickable.contentX / variantFlickable.contentWidth : 0
                                        size: variantFlickable.contentWidth > 0 ? variantFlickable.width / variantFlickable.contentWidth : 1

                                        property bool scrollBarPressed: false

                                        background: Rectangle {
                                            implicitHeight: 8
                                            color: Colors.surface
                                            radius: 4
                                        }

                                        contentItem: Rectangle {
                                            implicitHeight: 8
                                            color: Styling.srItem("overprimary")
                                            radius: 4
                                        }

                                        onPressedChanged: {
                                            scrollBarPressed = pressed;
                                        }

                                        onPositionChanged: {
                                            if (scrollBarPressed && variantFlickable.contentWidth > variantFlickable.width) {
                                                variantFlickable.contentX = position * variantFlickable.contentWidth;
                                            }
                                        }
                                    }
                                }

                                // Expanded mode: Flow grid
                                Flow {
                                    id: variantsFlow
                                    Layout.fillWidth: true
                                    spacing: 4
                                    visible: variantSelectorPane.variantExpanded

                                    Repeater {
                                        model: root.allVariants

                                        delegate: StyledRect {
                                            id: variantTag
                                            required property var modelData
                                            required property int index

                                            property bool isSelected: root.selectedVariant === modelData.id
                                            property bool isHovered: false

                                            variant: modelData.id
                                            enableShadow: true

                                            width: tagContent.width + 24 + (isSelected ? checkIcon.width + 4 : 0)
                                            height: 32
                                            radius: isSelected ? Styling.radius(0) / 2 : Styling.radius(0)

                                            Behavior on width {
                                                enabled: (Config.animDuration ?? 0) > 0
                                                NumberAnimation {
                                                    duration: (Config.animDuration ?? 0) / 3
                                                    easing.type: Easing.OutCubic
                                                }
                                            }

                                            Item {
                                                anchors.fill: parent
                                                anchors.margins: 8

                                                Row {
                                                    anchors.centerIn: parent
                                                    spacing: variantTag.isSelected ? 4 : 0

                                                    Item {
                                                        width: checkIcon.visible ? checkIcon.width : 0
                                                        height: checkIcon.height
                                                        clip: true

                                                        Text {
                                                            id: checkIcon
                                                            text: Icons.accept
                                                            font.family: Icons.font
                                                            font.pixelSize: 16
                                                            color: variantTag.item
                                                            visible: variantTag.isSelected
                                                            opacity: variantTag.isSelected ? 1 : 0

                                                            Behavior on opacity {
                                                                enabled: (Config.animDuration ?? 0) > 0
                                                                NumberAnimation {
                                                                    duration: (Config.animDuration ?? 0) / 3
                                                                    easing.type: Easing.OutCubic
                                                                }
                                                            }
                                                        }

                                                        Behavior on width {
                                                            enabled: (Config.animDuration ?? 0) > 0
                                                            NumberAnimation {
                                                                duration: (Config.animDuration ?? 0) / 3
                                                                easing.type: Easing.OutCubic
                                                            }
                                                        }
                                                    }

                                                    Text {
                                                        id: tagContent
                                                        text: variantTag.modelData.label
                                                        font.family: Config.theme.font
                                                        font.pixelSize: Config.theme.fontSize
                                                        font.bold: true
                                                        color: variantTag.item

                                                        Behavior on color {
                                                            enabled: (Config.animDuration ?? 0) > 0
                                                            ColorAnimation {
                                                                duration: (Config.animDuration ?? 0) / 3
                                                                easing.type: Easing.OutCubic
                                                            }
                                                        }
                                                    }
                                                }
                                            }

                                            Rectangle {
                                                id: hoverOverlay
                                                anchors.fill: parent
                                                color: Styling.srItem("overprimary")
                                                radius: variantTag.radius ?? 0
                                                opacity: variantTag.isHovered ? 0.15 : 0

                                                Behavior on opacity {
                                                    enabled: (Config.animDuration ?? 0) > 0
                                                    NumberAnimation {
                                                        duration: (Config.animDuration ?? 0) / 2
                                                    }
                                                }
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor

                                                onEntered: variantTag.isHovered = true
                                                onExited: variantTag.isHovered = false

                                                onClicked: root.selectedVariant = variantTag.modelData.id
                                            }
                                        }
                                    }
                                }

                                // Toggle expand/collapse button
                                StyledRect {
                                    id: expandToggleButton
                                    variant: isHovered ? "focus" : "common"
                                    width: 32
                                    height: 32
                                    radius: Styling.radius(-2)
                                    Layout.alignment: Qt.AlignTop
                                    enableShadow: true

                                    property bool isHovered: false

                                    Text {
                                        anchors.centerIn: parent
                                        text: variantSelectorPane.variantExpanded ? Icons.caretUp : Icons.caretDown
                                        font.family: Icons.font
                                        font.pixelSize: 16
                                        color: expandToggleButton.item
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor

                                        onEntered: expandToggleButton.isHovered = true
                                        onExited: expandToggleButton.isHovered = false

                                        onClicked: variantSelectorPane.variantExpanded = !variantSelectorPane.variantExpanded
                                    }
                                }
                            }
                        }
                    }

                    // Editor section
                    Item {
                        visible: root.currentSection === "colors"
                        property string settingsSection: "colors"
                        Layout.fillWidth: true
                        Layout.preferredHeight: editorContent.implicitHeight

                        ColumnLayout {
                            id: editorContent
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            spacing: 8

                            Text {
                                text: "Editor - " + root.getVariantLabel(root.selectedVariant)
                                font.family: Config.theme.font
                                font.pixelSize: Styling.fontSize(-1)
                                font.weight: Font.Medium
                                color: Colors.overSurfaceVariant
                                Layout.bottomMargin: -4
                            }

                            VariantEditor {
                                Layout.fillWidth: true
                                variantId: root.selectedVariant
                                onClose: {}
                                onOpenColorPickerRequested: (colorNames, currentColor, dialogTitle, callback) => {
                                    root.openColorPicker(colorNames, currentColor, dialogTitle, callback);
                                }
                            }
                        }
                    }

                    // Applications section
                    Item {
                        visible: root.currentSection === "applications"
                        Layout.fillWidth: true
                        Layout.preferredHeight: applicationsContent.implicitHeight

                        ColumnLayout {
                            id: applicationsContent
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            spacing: 8

                            Text {
                                text: "Application Theming"
                                font.family: Config.theme.font
                                font.pixelSize: Styling.fontSize(-1)
                                font.weight: Font.Medium
                                color: Colors.overSurfaceVariant
                                Layout.bottomMargin: -4
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Text {
                                    text: "GTK Theme"
                                    font.family: Config.theme.font
                                    font.pixelSize: Styling.fontSize(0)
                                    color: Colors.overBackground
                                    Layout.fillWidth: true
                                }

                                Switch {
                                    id: gtkThemingSwitch
                                    checked: Config.theme.gtkThemingEnabled

                                    readonly property bool configValue: Config.theme.gtkThemingEnabled

                                    onConfigValueChanged: {
                                        if (checked !== configValue) {
                                            checked = configValue;
                                        }
                                    }

                                    onCheckedChanged: {
                                        if (checked !== Config.theme.gtkThemingEnabled) {
                                            GlobalStates.markThemeChanged();
                                            Config.theme.gtkThemingEnabled = checked;
                                            root.runGtkThemingUpdate(checked);
                                        }
                                    }

                                    indicator: Rectangle {
                                        implicitWidth: 40
                                        implicitHeight: 20
                                        x: gtkThemingSwitch.leftPadding
                                        y: parent.height / 2 - height / 2
                                        radius: height / 2
                                        color: gtkThemingSwitch.checked ? Styling.srItem("overprimary") : Colors.surfaceBright
                                        border.color: gtkThemingSwitch.checked ? Styling.srItem("overprimary") : Colors.outline

                                        Behavior on color {
                                            enabled: Config.animDuration > 0
                                            ColorAnimation {
                                                duration: Config.animDuration / 2
                                            }
                                        }

                                        Rectangle {
                                            x: gtkThemingSwitch.checked ? parent.width - width - 2 : 2
                                            y: 2
                                            width: parent.height - 4
                                            height: width
                                            radius: width / 2
                                            color: Colors.background

                                            Behavior on x {
                                                enabled: Config.animDuration > 0
                                                NumberAnimation {
                                                    duration: Config.animDuration / 2
                                                    easing.type: Easing.OutCubic
                                                }
                                            }
                                        }
                                    }

                                    background: null
                                }
                            }

                            AppComboBox {
                                model: root.gtkThemes
                                enabled: Config.theme.gtkThemingEnabled

                                currentIndex: {
                                    let idx = root.gtkThemes.indexOf(root.currentGtkTheme);
                                    return idx >= 0 ? idx : 0;
                                }

                                onActivated: (index) => {
                                    if (index >= 0 && index < root.gtkThemes.length) {
                                        root.applyGtkTheme(root.gtkThemes[index]);
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Text {
                                    text: "Qt Theme"
                                    font.family: Config.theme.font
                                    font.pixelSize: Styling.fontSize(0)
                                    color: Colors.overBackground
                                    Layout.fillWidth: true
                                }

                                Switch {
                                    id: qtThemingSwitch
                                    checked: Config.theme.qtThemingEnabled

                                    readonly property bool configValue: Config.theme.qtThemingEnabled

                                    onConfigValueChanged: {
                                        if (checked !== configValue) {
                                            checked = configValue;
                                        }
                                    }

                                    onCheckedChanged: {
                                        if (checked !== Config.theme.qtThemingEnabled) {
                                            GlobalStates.markThemeChanged();
                                            Config.theme.qtThemingEnabled = checked;
                                            root.runQtThemingUpdate(checked);
                                        }
                                    }

                                    indicator: Rectangle {
                                        implicitWidth: 40
                                        implicitHeight: 20
                                        x: qtThemingSwitch.leftPadding
                                        y: parent.height / 2 - height / 2
                                        radius: height / 2
                                        color: qtThemingSwitch.checked ? Styling.srItem("overprimary") : Colors.surfaceBright
                                        border.color: qtThemingSwitch.checked ? Styling.srItem("overprimary") : Colors.outline

                                        Behavior on color {
                                            enabled: Config.animDuration > 0
                                            ColorAnimation {
                                                duration: Config.animDuration / 2
                                            }
                                        }

                                        Rectangle {
                                            x: qtThemingSwitch.checked ? parent.width - width - 2 : 2
                                            y: 2
                                            width: parent.height - 4
                                            height: width
                                            radius: width / 2
                                            color: Colors.background

                                            Behavior on x {
                                                enabled: Config.animDuration > 0
                                                NumberAnimation {
                                                    duration: Config.animDuration / 2
                                                    easing.type: Easing.OutCubic
                                                }
                                            }
                                        }
                                    }

                                    background: null
                                }
                            }

                            AppComboBox {
                                model: root.qtThemes
                                enabled: Config.theme.qtThemingEnabled

                                currentIndex: {
                                    let idx = root.qtThemes.indexOf(root.currentQtTheme);
                                    return idx >= 0 ? idx : 0;
                                }

                                onActivated: (index) => {
                                    if (index >= 0 && index < root.qtThemes.length) {
                                        root.applyQtTheme(root.qtThemes[index]);
                                    }
                                }
                            }

                            Text {
                                text: "Cursor Theme"
                                font.family: Config.theme.font
                                font.pixelSize: Styling.fontSize(0)
                                color: Colors.overBackground
                                Layout.fillWidth: true
                            }

                            AppComboBox {
                                model: root.cursorThemes

                                currentIndex: {
                                    let idx = root.cursorThemes.indexOf(Config.theme.cursorTheme);
                                    return idx >= 0 ? idx : 0;
                                }

                                onActivated: (index) => {
                                    if (index >= 0 && index < root.cursorThemes.length) {
                                        root.applyCursorTheme(root.cursorThemes[index]);
                                    }
                                }
                            }

                            Text {
                                text: "Cursor Size"
                                font.family: Config.theme.font
                                font.pixelSize: Styling.fontSize(0)
                                color: Colors.overBackground
                                Layout.fillWidth: true
                            }

                            AppComboBox {
                                model: root.cursorSizes

                                currentIndex: {
                                    let idx = root.cursorSizes.indexOf(Config.theme.cursorSize);
                                    return idx >= 0 ? idx : 0;
                                }

                                onActivated: (index) => {
                                    if (index >= 0 && index < root.cursorSizes.length) {
                                        GlobalStates.markThemeChanged();
                                        Config.theme.cursorSize = root.cursorSizes[index];
                                        root.runCursorUpdate();
                                    }
                                }
                            }

                            Text {
                                text: "Icon Theme"
                                font.family: Config.theme.font
                                font.pixelSize: Styling.fontSize(0)
                                color: Colors.overBackground
                                Layout.fillWidth: true
                            }

                            AppComboBox {
                                model: root.iconThemeOptions

                                currentIndex: {
                                    let currentTheme = Config.theme.iconTheme && Config.theme.iconTheme.trim() !== "" ? Config.theme.iconTheme : "System Default";
                                    let idx = root.iconThemeOptions.indexOf(currentTheme);
                                    return idx >= 0 ? idx : 0;
                                }

                                onActivated: (index) => {
                                    if (index >= 0 && index < root.iconThemeOptions.length) {
                                        root.applyIconTheme(root.iconThemeOptions[index]);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Color picker view (shown when colorPickerActive)
    Item {
        id: colorPickerContainer
        anchors.fill: parent
        clip: true

        // Horizontal slide + fade animation (enters from right)
        opacity: root.colorPickerActive ? 1 : 0
        transform: Translate {
            id: pickerTranslate
            x: root.colorPickerActive ? 0 : 30

            Behavior on x {
                enabled: Config.animDuration > 0
                NumberAnimation {
                    duration: Config.animDuration / 2
                    easing.type: Easing.OutQuart
                }
            }
        }

        Behavior on opacity {
            enabled: Config.animDuration > 0
            NumberAnimation {
                duration: Config.animDuration / 2
                easing.type: Easing.OutQuart
            }
        }

        // Prevent interaction when hidden
        enabled: root.colorPickerActive

        // Block interaction with elements behind when active
        MouseArea {
            anchors.fill: parent
            enabled: root.colorPickerActive
            hoverEnabled: true
            acceptedButtons: Qt.AllButtons
            // Consume all mouse events to prevent pass-through
            onPressed: event => event.accepted = true
            onReleased: event => event.accepted = true
            onWheel: event => event.accepted = true
        }

        ColorPickerView {
            id: colorPickerContent
            anchors.fill: parent
            anchors.leftMargin: root.sideMargin
            anchors.rightMargin: root.sideMargin
            colorNames: root.colorPickerColorNames
            currentColor: root.colorPickerCurrentColor
            dialogTitle: root.colorPickerDialogTitle

            onColorSelected: color => root.handleColorSelected(color)
            onClosed: root.closeColorPicker()
        }
    }
}
