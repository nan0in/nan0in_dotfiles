import QtQuick

// Session-lock surfaces cannot parent native IME popups. Keep this input a
// plain focus item, not a TextInput, while retaining the existing password UI.
FocusScope {
    id: root
    property string text: ""
    property bool readOnly: false
    property int maximumLength: 4096
    signal accepted

    focus: true
    activeFocusOnTab: true
    Accessible.role: Accessible.EditableText
    Accessible.passwordEdit: true
    Accessible.name: qsTr("Password")

    function removeLastCharacter() {
        const last = root.text.charCodeAt(root.text.length - 1);
        const previous = root.text.charCodeAt(root.text.length - 2);
        const pair = last >= 0xdc00 && last <= 0xdfff && previous >= 0xd800 && previous <= 0xdbff;
        root.text = root.text.slice(0, Math.max(0, root.text.length - (pair ? 2 : 1)));
    }

    Keys.onPressed: event => {
        if (root.readOnly) {
            event.accepted = true;
            return;
        }
        const control = (event.modifiers & Qt.ControlModifier) !== 0;
        const alt = (event.modifiers & Qt.AltModifier) !== 0;
        const group = (event.modifiers & Qt.GroupSwitchModifier) !== 0;
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            if (!event.isAutoRepeat)
                root.accepted();
        } else if (event.key === Qt.Key_Escape || (control && !alt && !group && event.key === Qt.Key_U)) {
            root.text = "";
        } else if (event.key === Qt.Key_Backspace) {
            if (control && !alt && !group)
                root.text = root.text.replace(/\s*\S+\s*$/, "");
            else
                root.removeLastCharacter();
        } else if (control && !alt && !group && event.key === Qt.Key_W) {
            root.text = root.text.replace(/\s*\S+\s*$/, "");
        } else if (event.text && !/[\x00-\x1f\x7f]/.test(event.text) && !(event.modifiers & Qt.MetaModifier)
                   && (!control || alt || group) && (!alt || control || group)) {
            let value = root.text + event.text;
            let length = Math.min(value.length, root.maximumLength);
            const last = value.charCodeAt(length - 1);
            if (length < value.length && last >= 0xd800 && last <= 0xdbff)
                length--;
            root.text = value.slice(0, length);
        } else {
            event.accepted = false;
            return;
        }
        event.accepted = true;
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.IBeamCursor
        onPressed: root.forceActiveFocus()
    }
}
