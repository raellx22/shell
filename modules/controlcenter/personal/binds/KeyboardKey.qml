import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.utils
import qs.components.misc
import Caelestia
import Caelestia.Config

StyledRect {
    id: root

    property string keyLabel: ""
    property string keyValue: keyLabel
    property int keyWidth: 1
    property bool isMod: false
    property bool isActive: false

    signal clicked(string value)

    // Binds state
    readonly property int bindCount: Services.HyprBinds ? Services.HyprBinds.countBindsForKey(keyValue) : 0
    readonly property bool hasBinds: bindCount > 0

    Layout.fillWidth: true
    Layout.preferredWidth: keyWidth * 48
    Layout.preferredHeight: 48
    
    radius: Tokens.radius.small

    // Dynamic color based on states
    color: {
        if (isActive) return Colours.palette.m3primaryContainer;
        if (hasBinds) return Qt.rgba(Colours.palette.m3primaryContainer.r, Colours.palette.m3primaryContainer.g, Colours.palette.m3primaryContainer.b, 0.5);
        return Colours.palette.m3surfaceContainerHigh;
    }

    border.color: hasBinds && !isActive ? Colours.palette.m3primary : "transparent"
    border.width: hasBinds && !isActive ? 1 : 0

    StateLayer {
        id: stateLayer
        anchors.fill: parent
        hoverColor: Colours.palette.m3onSurface
        pressColor: Colours.palette.m3onSurface
        radius: root.radius

        TapHandler {
            onTapped: root.clicked(root.keyValue)
        }
    }

    StyledText {
        anchors.centerIn: parent
        text: root.keyLabel
        font.pointSize: Tokens.font.size.normal
        font.weight: root.isMod ? 600 : 400
        color: root.isActive ? Colours.palette.m3onPrimaryContainer : Colours.palette.m3onSurface
    }

    // Badge showing bind count
    Rectangle {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: -4
        anchors.rightMargin: -4
        
        width: 16
        height: 16
        radius: 8
        color: Colours.palette.m3error
        visible: root.hasBinds && !root.isMod

        StyledText {
            anchors.centerIn: parent
            text: root.bindCount
            font.pointSize: Tokens.font.size.tiny
            color: Colours.palette.m3onError
        }
    }

    // Tooltip
    ToolTip.visible: stateLayer.hovered && root.hasBinds
    ToolTip.text: qsTr("%1 atalhos").arg(root.bindCount)
    ToolTip.delay: 300
}
