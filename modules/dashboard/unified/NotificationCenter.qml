pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services
import qs.modules.sidebar as Sidebar

StyledRect {
    id: root

    required property var props

    radius: Tokens.rounding.normal
    color: Colours.tPalette.m3surfaceContainer

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Tokens.padding.large
        spacing: Tokens.spacing.normal

        RowLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.small

            StyledText {
                Layout.fillWidth: true
                text: qsTr("Notificações")
                font.pointSize: Tokens.font.size.normal
                font.weight: 500
                elide: Text.ElideRight
            }

            StyledText {
                text: qsTr("centro")
                color: Colours.palette.m3outline
                font.pointSize: Tokens.font.size.small
                font.family: Tokens.font.family.mono
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Sidebar.NotifDock {
                props: root.props
            }
        }
    }
}
