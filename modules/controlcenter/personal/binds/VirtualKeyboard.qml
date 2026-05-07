import QtQuick
import QtQuick.Layouts
import Caelestia

ColumnLayout {
    id: root

    spacing: 8
    
    // Properties to communicate with BindsPage
    property string activeKey: ""
    signal keySelected(string keyName)

    function handleKeyClick(val) {
        activeKey = val;
        keySelected(val);
    }

    // Row 1
    RowLayout {
        spacing: 8
        Layout.fillWidth: true
        
        KeyboardKey { keyLabel: "`"; keyValue: "grave"; isActive: root.activeKey === "grave"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: "1"; isActive: root.activeKey === "1"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: "2"; isActive: root.activeKey === "2"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: "3"; isActive: root.activeKey === "3"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: "4"; isActive: root.activeKey === "4"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: "5"; isActive: root.activeKey === "5"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: "6"; isActive: root.activeKey === "6"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: "7"; isActive: root.activeKey === "7"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: "8"; isActive: root.activeKey === "8"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: "9"; isActive: root.activeKey === "9"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: "0"; isActive: root.activeKey === "0"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: "-"; keyValue: "minus"; isActive: root.activeKey === "minus"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: "="; keyValue: "equal"; isActive: root.activeKey === "equal"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: "Backspace"; keyValue: "BackSpace"; keyWidth: 2; isMod: true; isActive: root.activeKey === "BackSpace"; onClicked: handleKeyClick(keyValue) }
    }

    // Row 2
    RowLayout {
        spacing: 8
        Layout.fillWidth: true
        
        KeyboardKey { keyLabel: "Tab"; keyWidth: 1.5; isMod: true; isActive: root.activeKey === "Tab"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: "Q"; isActive: root.activeKey === "Q"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: "W"; isActive: root.activeKey === "W"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: "E"; isActive: root.activeKey === "E"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: "R"; isActive: root.activeKey === "R"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: "T"; isActive: root.activeKey === "T"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: "Y"; isActive: root.activeKey === "Y"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: "U"; isActive: root.activeKey === "U"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: "I"; isActive: root.activeKey === "I"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: "O"; isActive: root.activeKey === "O"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: "P"; isActive: root.activeKey === "P"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: "["; keyValue: "bracketleft"; isActive: root.activeKey === "bracketleft"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: "]"; keyValue: "bracketright"; isActive: root.activeKey === "bracketright"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: "\\"; keyValue: "backslash"; keyWidth: 1.5; isActive: root.activeKey === "backslash"; onClicked: handleKeyClick(keyValue) }
    }

    // Row 3
    RowLayout {
        spacing: 8
        Layout.fillWidth: true
        
        KeyboardKey { keyLabel: "Caps"; keyValue: "Caps_Lock"; keyWidth: 1.75; isMod: true; isActive: root.activeKey === "Caps_Lock"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: "A"; isActive: root.activeKey === "A"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: "S"; isActive: root.activeKey === "S"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: "D"; isActive: root.activeKey === "D"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: "F"; isActive: root.activeKey === "F"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: "G"; isActive: root.activeKey === "G"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: "H"; isActive: root.activeKey === "H"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: "J"; isActive: root.activeKey === "J"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: "K"; isActive: root.activeKey === "K"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: "L"; isActive: root.activeKey === "L"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: ";"; keyValue: "semicolon"; isActive: root.activeKey === "semicolon"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: "'"; keyValue: "apostrophe"; isActive: root.activeKey === "apostrophe"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: "Enter"; keyValue: "Return"; keyWidth: 2.25; isMod: true; isActive: root.activeKey === "Return"; onClicked: handleKeyClick(keyValue) }
    }

    // Row 4
    RowLayout {
        spacing: 8
        Layout.fillWidth: true
        
        KeyboardKey { keyLabel: "Shift"; keyValue: "Shift_L"; keyWidth: 2.25; isMod: true; isActive: root.activeKey === "Shift_L"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: "Z"; isActive: root.activeKey === "Z"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: "X"; isActive: root.activeKey === "X"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: "C"; isActive: root.activeKey === "C"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: "V"; isActive: root.activeKey === "V"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: "B"; isActive: root.activeKey === "B"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: "N"; isActive: root.activeKey === "N"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: "M"; isActive: root.activeKey === "M"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: ","; keyValue: "comma"; isActive: root.activeKey === "comma"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: "."; keyValue: "period"; isActive: root.activeKey === "period"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: "/"; keyValue: "slash"; isActive: root.activeKey === "slash"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: "Shift"; keyValue: "Shift_R"; keyWidth: 2.75; isMod: true; isActive: root.activeKey === "Shift_R"; onClicked: handleKeyClick(keyValue) }
    }

    // Row 5
    RowLayout {
        spacing: 8
        Layout.fillWidth: true
        
        KeyboardKey { keyLabel: "Ctrl"; keyValue: "Control_L"; keyWidth: 1.5; isMod: true; isActive: root.activeKey === "Control_L"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: "Super"; keyValue: "SUPER"; keyWidth: 1.25; isMod: true; isActive: root.activeKey === "SUPER"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: "Alt"; keyValue: "Alt_L"; keyWidth: 1.25; isMod: true; isActive: root.activeKey === "Alt_L"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: "Space"; keyValue: "space"; keyWidth: 6; isActive: root.activeKey === "space"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: "Alt"; keyValue: "Alt_R"; keyWidth: 1.25; isMod: true; isActive: root.activeKey === "Alt_R"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: "Fn"; keyValue: "Fn"; keyWidth: 1.25; isMod: true; isActive: root.activeKey === "Fn"; onClicked: handleKeyClick(keyValue) }
        KeyboardKey { keyLabel: "Ctrl"; keyValue: "Control_R"; keyWidth: 1.5; isMod: true; isActive: root.activeKey === "Control_R"; onClicked: handleKeyClick(keyValue) }
    }
}
