pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.services

ColumnLayout {
    id: root

    property string activeKey: ""
    property var captureKeys: []
    readonly property real keyGap: 8
    readonly property real keyUnit: Math.max(42, Math.min(54, (width - keyGap * 13) / 15))

    signal keySelected(string keyName)

    function isActive(keyName: string): bool {
        return HyprBinds.canonicalKey(activeKey) === HyprBinds.canonicalKey(keyName);
    }

    function isCaptureActive(keyName: string): bool {
        for (const key of captureKeys) {
            if (HyprBinds.canonicalKey(key) === HyprBinds.canonicalKey(keyName))
                return true;
        }
        return false;
    }

    function selectKey(keyName: string): void {
        activeKey = keyName;
        keySelected(keyName);
    }

    spacing: keyGap

    RowLayout {
        Layout.fillWidth: true
        spacing: root.keyGap

        KeyboardKey { keyLabel: "`"; keyValue: "grave"; keyUnit: root.keyUnit; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: "1"; keyUnit: root.keyUnit; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: "2"; keyUnit: root.keyUnit; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: "3"; keyUnit: root.keyUnit; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: "4"; keyUnit: root.keyUnit; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: "5"; keyUnit: root.keyUnit; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: "6"; keyUnit: root.keyUnit; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: "7"; keyUnit: root.keyUnit; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: "8"; keyUnit: root.keyUnit; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: "9"; keyUnit: root.keyUnit; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: "0"; keyUnit: root.keyUnit; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: "-"; keyValue: "minus"; keyUnit: root.keyUnit; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: "="; keyValue: "equal"; keyUnit: root.keyUnit; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: "Backspace"; keyValue: "BackSpace"; keyWidth: 2; keyUnit: root.keyUnit; modifier: true; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: root.keyGap

        KeyboardKey { keyLabel: "Tab"; keyWidth: 1.5; keyUnit: root.keyUnit; modifier: true; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: "Q"; keyUnit: root.keyUnit; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: "W"; keyUnit: root.keyUnit; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: "E"; keyUnit: root.keyUnit; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: "R"; keyUnit: root.keyUnit; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: "T"; keyUnit: root.keyUnit; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: "Y"; keyUnit: root.keyUnit; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: "U"; keyUnit: root.keyUnit; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: "I"; keyUnit: root.keyUnit; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: "O"; keyUnit: root.keyUnit; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: "P"; keyUnit: root.keyUnit; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: "["; keyValue: "bracketleft"; keyUnit: root.keyUnit; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: "]"; keyValue: "bracketright"; keyUnit: root.keyUnit; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: "\\"; keyValue: "backslash"; keyWidth: 1.5; keyUnit: root.keyUnit; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: root.keyGap

        KeyboardKey { keyLabel: "Caps"; keyValue: "Caps_Lock"; keyWidth: 1.75; keyUnit: root.keyUnit; modifier: true; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: "A"; keyUnit: root.keyUnit; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: "S"; keyUnit: root.keyUnit; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: "D"; keyUnit: root.keyUnit; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: "F"; keyUnit: root.keyUnit; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: "G"; keyUnit: root.keyUnit; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: "H"; keyUnit: root.keyUnit; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: "J"; keyUnit: root.keyUnit; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: "K"; keyUnit: root.keyUnit; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: "L"; keyUnit: root.keyUnit; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: ";"; keyValue: "semicolon"; keyUnit: root.keyUnit; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: "'"; keyValue: "apostrophe"; keyUnit: root.keyUnit; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: "Enter"; keyValue: "Return"; keyWidth: 2.25; keyUnit: root.keyUnit; modifier: true; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: root.keyGap

        KeyboardKey { keyLabel: "Shift"; keyValue: "Shift_L"; keyWidth: 2.25; keyUnit: root.keyUnit; modifier: true; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: "Z"; keyUnit: root.keyUnit; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: "X"; keyUnit: root.keyUnit; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: "C"; keyUnit: root.keyUnit; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: "V"; keyUnit: root.keyUnit; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: "B"; keyUnit: root.keyUnit; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: "N"; keyUnit: root.keyUnit; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: "M"; keyUnit: root.keyUnit; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: ","; keyValue: "comma"; keyUnit: root.keyUnit; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: "."; keyValue: "period"; keyUnit: root.keyUnit; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: "/"; keyValue: "slash"; keyUnit: root.keyUnit; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: "Shift"; keyValue: "Shift_R"; keyWidth: 2.75; keyUnit: root.keyUnit; modifier: true; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: root.keyGap

        KeyboardKey { keyLabel: "Ctrl"; keyValue: "Control_L"; keyWidth: 1.5; keyUnit: root.keyUnit; modifier: true; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: "Super"; keyValue: "Super_L"; keyWidth: 1.25; keyUnit: root.keyUnit; modifier: true; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: "Alt"; keyValue: "Alt_L"; keyWidth: 1.25; keyUnit: root.keyUnit; modifier: true; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: "Space"; keyValue: "Space"; keyWidth: 6; keyUnit: root.keyUnit; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: "Alt"; keyValue: "Alt_R"; keyWidth: 1.25; keyUnit: root.keyUnit; modifier: true; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: "Fn"; keyValue: "Fn"; keyWidth: 1.25; keyUnit: root.keyUnit; modifier: true; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
        KeyboardKey { keyLabel: "Ctrl"; keyValue: "Control_R"; keyWidth: 1.5; keyUnit: root.keyUnit; modifier: true; active: root.isActive(keyValue); captureActive: root.isCaptureActive(keyValue); onPicked: keyName => root.selectKey(keyName) }
    }
}
