//@ pragma UseQApplication

import QtQuick
import Quickshell
import qs.Services
import qs.Modules.Keystone.Tools

ShellRoot {
    Component.onCompleted: I18nService.initialize()
    MirrorWindow {
        onVisibleChanged: if (!visible)
                              Qt.quit()
    }
}
