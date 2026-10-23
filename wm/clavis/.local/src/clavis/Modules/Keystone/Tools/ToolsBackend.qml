import QtQuick
import Quickshell.Io
import qs.Common
import qs.Services

Item {
    id: backendRoot

    function launchTool(action) {
        if (action === "mirror")
            return ApplicationService.launchCommand(["qs", "-p", Paths.shareRoot + "/Camera.qml",
                                                     "--no-duplicate"]);
        if (!["calculator", "converter", "screenshot", "screenshots", "recordings", "ocr", "qr",
              "lens"].includes(action))
            return false;
        const command = ["python3", Paths.captureScriptsDir + "/desktop_tools.py", action, "--copied-message",
                         qsTr("Copied to clipboard"), "--empty-message", qsTr("No text or QR code found"),
                         "--error-message", qsTr("Tool failed; check the desktop tool log")];
        if (action === "recordings")
            command.push("--directory", UiPreferences.recordingVideoDirectory);
        return ApplicationService.launchCommand(command);
    }

    function pickColor() {
        colorPickerProcess.running = false;
        colorPickerProcess.running = true;
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

        command: ["hyprpicker", "-a"]
    }
}
