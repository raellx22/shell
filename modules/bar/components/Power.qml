import QtQuick
import Caelestia.Config
import qs.components
import qs.services

Item {
    id: root

    required property Item bar
    required property var popouts

    readonly property bool expanded: popouts.hasCurrent && popouts.currentName === "power"

    function togglePowerMenu(): void {
        if (root.expanded) {
            root.popouts.hasCurrent = false;
            return;
        }

        root.popouts.currentName = "power";
        root.popouts.currentCenter = Qt.binding(() => root.mapToItem(root.bar, 0, root.height / 2).y);
        root.popouts.hasCurrent = true;
    }

    implicitWidth: icon.implicitHeight + Tokens.padding.small * 2
    implicitHeight: icon.implicitHeight

    StateLayer {
        // Cursed workaround to make the height larger than the parent
        anchors.fill: undefined
        anchors.centerIn: parent
        implicitWidth: implicitHeight
        implicitHeight: icon.implicitHeight + Tokens.padding.small * 2
        radius: Tokens.rounding.full
        color: root.expanded ? Colours.palette.m3onErrorContainer : Colours.palette.m3error
        onClicked: root.togglePowerMenu()
    }

    MaterialIcon {
        id: icon

        anchors.centerIn: parent
        anchors.horizontalCenterOffset: -1

        text: "power_settings_new"
        color: root.expanded ? Colours.palette.m3onErrorContainer : Colours.palette.m3error
        font.bold: true
        font.pointSize: Tokens.font.size.normal

        Behavior on color {
            CAnim {}
        }
    }
}
