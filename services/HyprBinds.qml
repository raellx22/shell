pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.utils

Singleton {
    id: root

    property var bindsData: []
    // Map from key -> array of binds
    property var keyToBinds: ({})
    property int revision: 0

    function refresh() {
        bindsProcess.running = true;
    }

    function parseBinds(jsonStr) {
        try {
            const data = JSON.parse(jsonStr);
            const map = {};
            for (const b of data) {
                const k = String(b.key).toUpperCase();
                if (!map[k]) map[k] = [];
                map[k].push(b);
            }
            bindsData = data;
            keyToBinds = map;
            revision++;
        } catch (e) {
            console.warn("HyprBinds: Failed to parse binds JSON", e);
        }
    }

    function getBindsForKey(keyName) {
        revision; // trigger reactivity
        return keyToBinds[String(keyName).toUpperCase()] || [];
    }

    function countBindsForKey(keyName) {
        return getBindsForKey(keyName).length;
    }

    Process {
        id: bindsProcess
        command: ["hyprctl", "binds", "-j"]
        
        stdout: StdioCollector {
            onStreamFinished: {
                if (text && text.trim().length > 0) {
                    root.parseBinds(text);
                }
            }
        }
    }

    // Refresh initially
    Component.onCompleted: refresh()

    // Assuming we might want to refresh when hypr config is reloaded
    // We can hook into Hypr.qml configReloaded if needed, but for now we expose refresh()
}
