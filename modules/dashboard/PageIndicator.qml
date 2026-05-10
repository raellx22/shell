pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services

StyledRect {
    id: root

    required property int currentIndex
    required property var pages
    property bool showArrows: true

    readonly property int count: pages.length

    signal pageRequested(int index)
    signal previousRequested
    signal nextRequested

    visible: count > 1
    implicitWidth: visible ? controls.implicitWidth + Tokens.padding.small * 2 : 0
    implicitHeight: visible ? controls.implicitHeight + Tokens.padding.smaller * 2 : 0

    radius: Tokens.rounding.full
    color: Qt.alpha(Colours.palette.m3surfaceContainerHighest, 0.94)
    border.width: 1
    border.color: Qt.alpha(Colours.palette.m3outlineVariant, 0.42)

    ColumnLayout {
        id: controls

        anchors.centerIn: parent
        spacing: Tokens.spacing.small

        IconButton {
            Layout.alignment: Qt.AlignHCenter
            visible: root.showArrows
            icon: "keyboard_arrow_up"
            type: IconButton.Text
            disabled: root.currentIndex <= 0
            opacity: disabled ? 0.34 : 1
            onClicked: root.previousRequested()
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: Tokens.spacing.small

            Repeater {
                model: root.count

                delegate: Item {
                    id: dot

                    required property int index

                    readonly property bool current: index === root.currentIndex

                    Layout.alignment: Qt.AlignHCenter
                    implicitWidth: 28
                    implicitHeight: current ? 38 : 24

                    StyledRect {
                        anchors.centerIn: parent
                        implicitWidth: dot.current ? 9 : dotMouse.containsMouse ? 8 : 6
                        implicitHeight: dot.current ? 31 : dotMouse.containsMouse ? 22 : 8
                        radius: Tokens.rounding.full
                        color: dot.current ? Colours.palette.m3primary : dotMouse.containsMouse ? Colours.palette.m3secondary : Colours.palette.m3outline
                        opacity: dot.current || dotMouse.containsMouse ? 1 : 0.74

                        Behavior on implicitWidth {
                            Anim {
                                type: Anim.DefaultSpatial
                            }
                        }

                        Behavior on implicitHeight {
                            Anim {
                                type: Anim.DefaultSpatial
                            }
                        }

                        Behavior on color {
                            CAnim {}
                        }

                        Behavior on opacity {
                            Anim {}
                        }
                    }

                    CustomMouseArea {
                        id: dotMouse

                        property bool hovered: containsMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.pageRequested(dot.index)
                    }
                }
            }
        }

        IconButton {
            Layout.alignment: Qt.AlignHCenter
            visible: root.showArrows
            icon: "keyboard_arrow_down"
            type: IconButton.Text
            disabled: root.currentIndex >= root.count - 1
            opacity: disabled ? 0.34 : 1
            onClicked: root.nextRequested()
        }
    }

    Behavior on implicitHeight {
        Anim {
            type: Anim.DefaultSpatial
        }
    }
}
