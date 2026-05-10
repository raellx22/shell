import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.effects
import qs.components.filedialog
import qs.components.images
import qs.services
import qs.utils

Item {
    id: root

    required property DrawerVisibilities visibilities
    required property FileDialog facePicker
    readonly property string defaultProfileGif: "root:/assets/bongocat.gif"
    readonly property string profileGif: Config.paths.mediaGif ?? ""
    readonly property bool useAnimatedProfile: profileGif.length > 0 && profileGif !== defaultProfileGif

    implicitWidth: 268
    implicitHeight: 118

    StyledClippingRect {
        id: avatar

        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        implicitWidth: 104
        implicitHeight: 104

        radius: Tokens.rounding.large
        color: Colours.layer(Colours.palette.m3surfaceContainerHigh, 2)

        StyledRect {
            anchors.fill: parent
            anchors.margins: 1

            radius: parent.radius - 1
            color: Qt.alpha(Colours.palette.m3primary, root.useAnimatedProfile ? 0.10 : 0.05)
        }

        StyledClippingRect {
            id: mediaFrame

            anchors.margins: Tokens.padding.smaller
            anchors.fill: parent

            radius: avatar.radius - Tokens.padding.smaller
            color: Colours.layer(Colours.palette.m3surfaceContainerHighest, 2)

            MaterialIcon {
                anchors.centerIn: parent

                text: "person"
                fill: 1
                grade: 200
                color: Colours.palette.m3outline
                font.pointSize: Tokens.font.size.extraLarge * 2
                visible: !root.useAnimatedProfile && pfp.status !== Image.Ready
            }

            AnimatedImage {
                id: profileGifImage

                anchors.fill: parent

                visible: root.useAnimatedProfile
                playing: visible
                source: visible ? Paths.absolutePath(root.profileGif) : ""
                asynchronous: true
                cache: false
                fillMode: AnimatedImage.PreserveAspectCrop
            }

            CachingImage {
                id: pfp

                anchors.fill: parent

                visible: !root.useAnimatedProfile
                path: `${Paths.home}/.face`
                fillMode: Image.PreserveAspectCrop
            }
        }

        MouseArea {
            id: avatarMouse

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.visibilities.launcher = false;
                root.facePicker.open();
            }

            StyledRect {
                anchors.fill: parent

                radius: avatar.radius
                color: Qt.alpha(Colours.palette.m3scrim, 0.46)
                opacity: avatarMouse.containsMouse ? 1 : 0

                Behavior on opacity {
                    Anim {
                        duration: Tokens.anim.durations.expressiveFastSpatial
                    }
                }
            }

            ColumnLayout {
                anchors.centerIn: parent
                spacing: Tokens.spacing.smaller

                scale: avatarMouse.containsMouse ? 1 : 0.86
                opacity: avatarMouse.containsMouse ? 1 : 0

                StyledRect {
                    Layout.alignment: Qt.AlignHCenter
                    implicitWidth: 44
                    implicitHeight: 44
                    radius: Tokens.rounding.full
                    color: Colours.palette.m3primary

                    MaterialIcon {
                        id: selectIcon

                        anchors.centerIn: parent
                        anchors.horizontalCenterOffset: -font.pointSize * 0.02

                        text: "add_photo_alternate"
                        color: Colours.palette.m3onPrimary
                        font.pointSize: Tokens.font.size.large
                    }
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("Trocar")
                    color: Colours.palette.m3onPrimary
                    font.pointSize: Tokens.font.size.smaller
                    font.weight: 600
                }

                Behavior on scale {
                    Anim {
                        type: Anim.FastSpatial
                    }
                }

                Behavior on opacity {
                    Anim {
                        duration: Tokens.anim.durations.expressiveFastSpatial
                    }
                }
            }
        }
    }

    ColumnLayout {
        id: info

        anchors.left: avatar.right
        anchors.leftMargin: Tokens.spacing.normal
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: Tokens.spacing.small

        StyledText {
            Layout.preferredWidth: info.width
            text: SysInfo.user || qsTr("Usuario")
            color: Colours.palette.m3onSurface
            font.pointSize: Tokens.font.size.large
            font.weight: 600
            elide: Text.ElideRight
        }

        InfoLine {
            iconSource: SysInfo.osLogo
            text: SysInfo.osPrettyName || SysInfo.osName
            colour: Colours.palette.m3primary
        }

        InfoLine {
            icon: "select_window_2"
            text: SysInfo.wm
            colour: Colours.palette.m3secondary
        }

        InfoLine {
            id: uptime

            icon: "timer"
            text: qsTr("up %1").arg(SysInfo.uptime)
            colour: Colours.palette.m3tertiary
        }
    }

    component InfoLine: Item {
        id: line

        property string icon: ""
        property string iconSource: ""
        required property string text
        required property color colour

        Layout.fillWidth: true
        implicitWidth: iconSlot.implicitWidth + textItem.implicitWidth + textItem.anchors.leftMargin
        implicitHeight: Math.max(iconSlot.implicitHeight, textItem.implicitHeight)

        Item {
            id: iconSlot

            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

            implicitWidth: Tokens.sizes.dashboard.infoIconSize
            implicitHeight: Math.max(materialIcon.implicitHeight, colouredIcon.implicitHeight)

            ColouredIcon {
                id: colouredIcon

                anchors.centerIn: parent
                visible: line.iconSource.length > 0
                source: line.iconSource
                implicitSize: Math.floor(Tokens.font.size.normal * 1.25)
                colour: line.colour
            }

            MaterialIcon {
                id: materialIcon

                anchors.centerIn: parent
                visible: line.iconSource.length === 0
                fill: 1
                text: line.icon
                color: line.colour
                font.pointSize: Tokens.font.size.normal
            }
        }

        StyledText {
            id: textItem

            anchors.verticalCenter: iconSlot.verticalCenter
            anchors.left: iconSlot.right
            anchors.leftMargin: Tokens.spacing.small
            text: line.text
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: Tokens.font.size.small

            width: Math.max(0, line.width - iconSlot.width - anchors.leftMargin)
            elide: Text.ElideRight
        }
    }
}
