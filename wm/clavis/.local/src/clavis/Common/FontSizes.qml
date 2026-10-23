pragma Singleton
import QtQuick

QtObject {
    id: root
    readonly property var defaults: ({
                                         "tooltip": 16,
                                         "activeTitle": 11,
                                         "activeInitial": 13,
                                         "media": 13,
                                         "volume": 16,
                                         "battery": 16,
                                         "brightness": 16,
                                         "microphone": 12,
                                         "weather": 12,
                                         "barLabel": 12,
                                         "sysMonitor": 14
                                     })
    property var values: root.defaults

    function normalized(input) {
        const result = {};
        for (const key of Object.keys(root.defaults)) {
            const value = input && input[key];
            const number = Number(value);
            result[key] = value === null || value === undefined || value === "" || !isFinite(number)
                    ? root.defaults[key] : Math.max(8, Math.min(32, Math.round(number)));
        }
        return result;
    }

    function size(key) {
        return root.values[key] === undefined ? root.defaults[key] : root.values[key];
    }
}
