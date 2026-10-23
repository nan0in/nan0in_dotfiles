import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam
import Quickshell.Wayland
import qs.Common
import qs.Services

Scope {
    id: root

    readonly property bool active: sessionLocked || capturePending
    readonly property bool secure: sessionLock.secure
    readonly property bool presented: active && Object.keys(presentedScreens).length > 0
    property bool sessionLocked: false
    property bool capturePending: false
    property int activeCaptureRequestId: 0
    property string sessionStyle: "default"
    property var presentedScreens: ({})
    property int presentationRevision: 0

    signal unlocked
    signal secured

    function syncSessionLock() {
        // Quickshell 0.3.1 can omit lockStateChanged after unlocking. Sample
        // the native state after our operations, not only its notifications.
        sessionLocked = sessionLock.locked;
    }

    function notePresented(screenName) {
        if (!active)
            return;

        const next = Object.assign({}, presentedScreens);
        next[screenName || "default"] = true;
        presentedScreens = next;
    }

    function redraw() {
        if (!active)
            return;

        // Resume can lose the committed lock buffer. Reset the presentation
        // marker and dirty the scene twice so the compositor gets a new frame.
        presentedScreens = ({});
        presentationRevision++;
        Qt.callLater(() => {
            if (active)
                presentationRevision++;
        });
    }

    function isPresented() {
        return presented;
    }

    function open(skipCapture = false) {
        if (sessionLock.locked)
            return "ALREADY_LOCKED";

        if (capturePending) {
            if (skipCapture) {
                preLockCapture.cancel();
                preLockCapture.clear();
                activeCaptureRequestId = 0;
                Qt.callLater(() => {
                    return root.finishCapture(0);
                });
            }
            return "ALREADY_LOCKED";
        }
        sessionStyle = PersonalizationConfig.lockScreenStyle;
        internalContext.authRevealed = false;
        internalContext.currentText = "";
        internalContext.unlockInProgress = false;
        internalContext.showFailure = false;
        presentedScreens = ({});
        presentationRevision++;
        capturePending = true;
        WidgetState.closeAllPopups();
        ControlCenterService.close();
        ShortcutMapService.close();
        PowerMenuService.close();
        if (skipCapture) {
            preLockCapture.clear();
            // Sleep must not wait for desktop capture on powering-down outputs.
            activeCaptureRequestId = 0;
            Qt.callLater(() => {
                return root.finishCapture(0);
            });
        } else {
            activeCaptureRequestId = preLockCapture.capture();
        }
        return "LOCKED";
    }

    function isLocked() {
        return sessionLock.locked || capturePending;
    }

    // Cancel only pre-lock capture. Never release an acquired session lock.
    function cancelPending() {
        if (sessionLock.locked)
            return false;

        capturePending = false;
        activeCaptureRequestId = 0;
        preLockCapture.cancel();
        preLockCapture.clear();
        return true;
    }

    function finishCapture(captureRequestId) {
        if (!capturePending || captureRequestId !== activeCaptureRequestId)
            return;

        sessionLock.locked = true;
        root.syncSessionLock();
        capturePending = false;
    }

    Component.onCompleted: {
        Qt.callLater(root.syncSessionLock);
        const sessionId = Quickshell.env("XDG_SESSION_ID");
        if (sessionId)
            Qt.callLater(() => {
                return lockedHintProcess.running = true;
            });
    }
    onActiveChanged: {
        if (!root.active)
            presentedScreens = ({});

        SystemIdentityService.setUptimeConsumer("lock-screen", root.active);
        SystemMonitorService.setConsumerModules("lock-screen", root.active ? ["cpu", "memory", "disk"] : []);
    }
    Component.onDestruction: {
        preLockCapture.cancel();
        preLockCapture.clear();
        SystemIdentityService.setUptimeConsumer("lock-screen", false);
        SystemMonitorService.clearConsumer("lock-screen");
    }

    // The delayed callback resolves this id only after the component is
    // complete, so it is safe even when the Process is declared later.
    Process {
        id: lockedHintProcess

        // A shell restart must not leave niri showing its red lock backdrop.
        // If logind says the session is still locked, re-acquire the lock.
        command: ["loginctl", "show-session", Quickshell.env("XDG_SESSION_ID") || "", "-p", "LockedHint",
            "--value"]

        stdout: StdioCollector {
            id: lockedHintOutput

            onStreamFinished: {
                if (!root.sessionLocked && !root.capturePending && lockedHintOutput.text.trim() === "yes")
                    Qt.callLater(() => {
                        return root.open(true);
                    });
            }
        }
    }

    Binding {
        target: WindowPreviewService
        property: "suspended"
        value: root.active
    }

    Binding {
        target: WidgetState
        property: "sessionLocked"
        value: root.active
    }

    PreLockCapture {
        id: preLockCapture

        onCompleted: captureRequestId => {
            return root.finishCapture(captureRequestId);
        }
    }

    Scope {
        id: internalContext

        property bool authRevealed: false
        property string currentText: ""
        property bool unlockInProgress: false
        property bool showFailure: false

        signal unlockFailed

        function tryUnlock() {
            if (currentText === "" || unlockInProgress)
                return;

            internalContext.unlockInProgress = true;
            pam.start();
        }

        function finishUnlock() {
            if (!sessionLock.locked)
                return;

            sessionLock.locked = false;
            root.syncSessionLock();
            root.unlocked();
            Qt.callLater(preLockCapture.clear);
        }

        PamContext {
            id: pam

            configDirectory: Paths.shellDir + "/Modules/Lock/pam"
            config: "password.conf"
            onPamMessage: {
                if (this.responseRequired)
                    this.respond(internalContext.currentText);
            }
            onCompleted: result => {
                if (result == PamResult.Success) {
                    internalContext.currentText = "";
                    internalContext.showFailure = false;
                    sessionLock.unlock();
                } else {
                    internalContext.currentText = "";
                    internalContext.showFailure = true;
                    internalContext.unlockFailed();
                }
                internalContext.unlockInProgress = false;
            }
        }
    }

    WlSessionLock {
        id: sessionLock

        signal unlock

        onLockStateChanged: root.syncSessionLock()
        onSecureStateChanged: {
            // The secure notification may arrive before the native manager
            // clears its lock object. Re-read after that call has returned.
            Qt.callLater(root.syncSessionLock);
            if (secure)
                root.secured();
        }

        LockSurface {
            lock: sessionLock
            lockRoot: root
            context: internalContext
            snapshotProvider: preLockCapture
            style: root.sessionStyle
        }
    }
}
