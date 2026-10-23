import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services

Item {
    id: backendRoot

    function launchTool(action) {
        if (action === "mirror")
            return ApplicationService.launchCommand(["qs", "-p", Paths.shareRoot + "/Camera.qml",
                                                     "--no-duplicate"]);

        if (!["screenshot", "screenshots", "recordings", "ocr", "qr", "lens"].includes(action))
            return false;

        const command = ["python3", Paths.captureScriptsDir + "/desktop_tools.py", action, "--copied-message",
                         qsTr("Copied to clipboard"), "--empty-message", qsTr("No text or QR code found"),
                         "--error-message", qsTr("Tool failed; check the desktop tool log")];
        if (action === "recordings")
            command.push("--directory", UiPreferences.recordingVideoDirectory);

        return ApplicationService.launchCommand(command);
    }

    function pickColor() {
        if (colorPickerProcess.running)
            return;

        colorPickerProcess.running = true;
    }

    function finishColorPicker(output, exitCode, errorText) {
        let color = "";
        try {
            const picked = JSON.parse(String(output || "").trim());
            if (picked && Array.isArray(picked.rgb) && picked.rgb.length === 3) {
                const channels = picked.rgb.map(value => {
                    const channel = Math.round(Math.max(0, Math.min(1, Number(value) || 0)) * 255);
                    return channel.toString(16).padStart(2, "0");
                });
                color = "#" + channels.join("");
            }
        } catch (error) {
            console.warn("Could not parse niri pick-color output:", error);
        }
        // A cancelled pick is not an error and must leave the clipboard untouched.
        if (color === "") {
            if (exitCode !== 0 && String(errorText || "").trim() !== "")
                NotificationManager.addLocal(qsTranslate("ToolsContent", "Color picker"), qsTr(
                                                 "Tool failed; check the desktop tool log"), "");

            return;
        }
        Quickshell.execDetached(["wl-copy", "--", color]);
        NotificationManager.addLocal(qsTranslate("ToolsContent", "Color picker"), qsTr("Copied to clipboard")
                                     + ": " + color, "");
    }

    function startRecord(mode) {
        RecordingService.start(mode, {
                                   "audio": "none",
                                   "fps": 60,
                                   "output": mode === "gif" ? UiPreferences.recordingGifDirectory :
                                                              UiPreferences.recordingVideoDirectory
                               });
    }

    function stopRecord() {
        RecordingService.stop();
    }

    function startAudio(source) {
        return AudioRecordingService.start(source, {
                                               "output": source === "system"
                                                         ? UiPreferences.recordingSystemAudioDirectory :
                                                           UiPreferences.recordingMicrophoneDirectory
                                           });
    }

    function stopAudio() {
        return AudioRecordingService.stop();
    }

    Process {
        id: colorPickerProcess

        // niri owns the picker under Wayland; hyprpicker only exists on Hyprland.
        command: ["niri", "msg", "-j", "pick-color"]
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0 && colorPickerStderr.text.trim() !== "")
                console.warn("niri pick-color failed:", colorPickerStderr.text.trim());

            backendRoot.finishColorPicker(colorPickerStdout.text, exitCode, colorPickerStderr.text);
        }

        stdout: StdioCollector {
            id: colorPickerStdout
        }

        stderr: StdioCollector {
            id: colorPickerStderr
        }
    }
}
