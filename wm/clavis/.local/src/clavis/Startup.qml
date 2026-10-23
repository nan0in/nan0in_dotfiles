//@ pragma UseQApplication
//@ pragma Env QT_WAYLAND_DISABLE_WINDOWDECORATION=1

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Modules.Startup

ShellRoot {
    StartupCover {
        id: cover
        onFinishedChanged: if (finished)
                               Qt.quit()
    }
    IpcHandler {
        target: "startup-overlay"
        function presented(): bool {
            return cover.presented;
        }
    }
    Timer {
        interval: 150
        running: !cover.ready && !cover.finished
        repeat: true
        triggeredOnStart: true
        onTriggered: if (!probe.running)
                         probe.running = true
    }
    Process {
        id: probe
        command: ["timeout", "1", "qs", "-c", "clavis", "ipc", "call", "startup-shell", "ready"]
        stdout: StdioCollector {
            id: result
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0 && exitStatus === 0 && result.text.trim() === "true")
                cover.ready = true;
        }
    }
}
