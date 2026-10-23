pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common

Singleton {
    id: root

    property var entries: []
    property string error: ""
    property string category: "all"
    readonly property var categories: [
        {
            id: "all",
            title: qsTr("All emoji"),
            icon: "apps"
        },
        {
            id: "smileys",
            title: qsTr("Smileys and emotion"),
            icon: "sentiment_satisfied"
        },
        {
            id: "people",
            title: qsTr("People and body"),
            icon: "waving_hand"
        },
        {
            id: "nature",
            title: qsTr("Animals and nature"),
            icon: "pets"
        },
        {
            id: "food",
            title: qsTr("Food and drink"),
            icon: "restaurant"
        },
        {
            id: "travel",
            title: qsTr("Travel and places"),
            icon: "travel_explore"
        },
        {
            id: "activities",
            title: qsTr("Activities"),
            icon: "sports_soccer"
        },
        {
            id: "objects",
            title: qsTr("Objects"),
            icon: "lightbulb"
        },
        {
            id: "symbols",
            title: qsTr("Symbols"),
            icon: "favorite"
        },
        {
            id: "flags",
            title: qsTr("Flags"),
            icon: "flag"
        },
        {
            id: "components",
            title: qsTr("Skin tones and hair"),
            icon: "palette"
        }
    ]

    function setCategory(value) {
        if (!root.categories.some(entry => entry.id === value))
            return false;
        root.category = value;
        return true;
    }
    readonly property string language: Qt.uiLanguage
    readonly property bool copying: copier.running
    signal copied

    function matches(query) {
        let language = "en";
        if (root.language.startsWith("zh_TW") || root.language.startsWith("zh_Hant"))
            language = "zh_Hant";
        else if (root.language.startsWith("zh"))
            language = "zh";
        const words = String(query).trim().toLocaleLowerCase().split(/\s+/).filter(Boolean);
        const results = [];
        for (const entry of root.entries) {
            if (root.category !== "all" && entry.category !== root.category)
                continue;
            const haystack = (entry.emoji + " " + Object.values(entry.names).join(" ") + " "
                              + entry.keywords).toLocaleLowerCase();
            if (!words.every(word => haystack.includes(word)))
                continue;
            results.push({
                             id: "emoji:" + entry.emoji,
                             sourceId: entry.emoji,
                             provider: "emoji",
                             query: query,
                             title: entry.emoji + "  " + entry.names[language],
                             subtitle: language === "en" ? "" : entry.names.en,
                             icon: "sentiment_satisfied",
                             symbol: "sentiment_satisfied"
                         });
        }
        return results;
    }

    function copy(value) {
        if (copier.running || !root.entries.some(entry => entry.emoji === value))
            return false;
        root.error = "";
        copier.command = ["wl-copy", "--", value];
        copier.running = true;
        return true;
    }

    FileView {
        path: Paths.assetsDir + "/emoji/annotations.json"
        onLoaded: {
            try {
                const data = JSON.parse(text());
                if (!Array.isArray(data))
                    throw new Error("Invalid emoji catalog");
                root.entries = data;
                root.error = "";
            } catch (error) {
                root.error = qsTr("Could not load emoji catalog");
            }
        }
        onLoadFailed: root.error = qsTr("Could not load emoji catalog")
    }

    Process {
        id: copier
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0 && exitStatus === 0)
                root.copied();
            else
                root.error = qsTr("Could not copy emoji");
        }
    }
}
