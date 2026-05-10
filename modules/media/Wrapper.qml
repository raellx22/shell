pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Caelestia.Config
import qs.components
import qs.services

Item {
    id: root

    required property ShellScreen screen

    readonly property bool hasPlayer: !!Players.active
    readonly property bool hasWindows: Hypr.toplevels.values.length > 0
    readonly property bool expanded: hasPlayer && hoverArea.containsMouse
    readonly property bool compact: hasPlayer && !expanded && !hasWindows
    readonly property bool tucked: hasPlayer && !expanded && hasWindows
    readonly property bool shouldOwnCorner: hasPlayer

    visible: hasPlayer || implicitHeight > 1
    implicitWidth: hasPlayer ? content.implicitWidth : 0
    implicitHeight: hasPlayer ? content.implicitHeight : 0
    opacity: hasPlayer ? 1 : 0
    z: 10

    Loader {
        id: content

        anchors.fill: parent

        active: root.hasPlayer || root.visible
        sourceComponent: Content {
            expanded: root.expanded
            compact: root.compact
            tucked: root.tucked
        }
    }

    MouseArea {
        id: hoverArea

        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }

    Behavior on implicitWidth {
        Anim {
            type: Anim.FastSpatial
        }
    }

    Behavior on implicitHeight {
        Anim {
            type: Anim.FastSpatial
        }
    }

    Behavior on opacity {
        Anim {
            duration: Tokens.anim.durations.normal
        }
    }
}
