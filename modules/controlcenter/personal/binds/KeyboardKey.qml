pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services

StyledRect {
    id: root

    required property string keyLabel
    property string keyValue: keyLabel
    property real keyWidth: 1
    property real keyUnit: 48
    property bool modifier
    property bool active
    property bool captureActive

    readonly property int bindCount: HyprBinds.countBindsForKey(keyValue)
    readonly property bool hasBinds: bindCount > 0
    readonly property bool hovered: keyHover.hovered
    readonly property color idleColor: hasBinds ? Qt.alpha(Colours.palette.m3primaryContainer, 0.34) : Colours.layer(Colours.palette.m3surfaceContainer, 2)

    signal picked(string value)

    Layout.preferredWidth: Math.round(keyUnit * keyWidth)
    Layout.preferredHeight: Math.round(keyUnit)

    radius: Tokens.rounding.small
    color: {
        if (active)
            return Colours.palette.m3primaryContainer;
        if (captureActive)
            return Colours.palette.m3tertiaryContainer;
        if (keyHover.hovered)
            return Colours.layer(Colours.palette.m3surfaceContainer, 4);
        return idleColor;
    }
    border.color: {
        if (active)
            return Colours.palette.m3primary;
        if (captureActive)
            return Colours.palette.m3tertiary;
        if (hasBinds)
            return Qt.alpha(Colours.palette.m3primary, 0.24);
        return Qt.alpha(Colours.palette.m3outline, 0.16);
    }
    border.width: active || captureActive || hasBinds ? 1 : 0
    scale: active ? 1.025 : 1

    HoverHandler {
        id: keyHover

        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        onTapped: root.picked(root.keyValue)
    }

    StyledText {
        anchors.centerIn: parent
        width: parent.width - Tokens.padding.small * 2
        text: root.keyLabel
        color: root.active ? Colours.palette.m3onPrimaryContainer : Colours.palette.m3onSurface
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        font.pointSize: root.modifier ? Tokens.font.size.small : Tokens.font.size.normal
        font.weight: root.modifier || root.active ? 700 : 500
    }

    StyledRect {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: -3
        anchors.topMargin: -3
        width: Math.max(17, badgeText.implicitWidth + 8)
        height: 17
        radius: Tokens.rounding.full
        color: root.active ? Colours.palette.m3primary : Colours.palette.m3tertiaryContainer
        border.color: Qt.alpha(Colours.palette.m3surface, 0.55)
        border.width: 1
        visible: root.hasBinds

        StyledText {
            id: badgeText

            anchors.centerIn: parent
            text: root.bindCount.toString()
            color: root.active ? Colours.palette.m3onPrimary : Colours.palette.m3onTertiaryContainer
            font.pointSize: Tokens.font.size.smaller
            font.weight: 800
        }
    }

    ToolTip.visible: keyHover.hovered
    ToolTip.text: root.hasBinds ? qsTr("%1 atalho(s) em %2").arg(root.bindCount).arg(HyprBinds.displayKey(root.keyValue)) : qsTr("Sem atalhos em %1").arg(HyprBinds.displayKey(root.keyValue))
    ToolTip.delay: 450

    Behavior on color {
        CAnim {}
    }

    Behavior on border.color {
        CAnim {}
    }

    Behavior on scale {
        CAnim {}
    }
}
