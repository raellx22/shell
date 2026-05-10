pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Caelestia.Config
import qs.components
import qs.services

Item {
    id: root

    required property PopoutState popouts

    readonly property var actions: [
        {
            id: "logout",
            icon: Config.session.icons.logout,
            label: qsTr("Sair"),
            command: Config.session.commands.logout
        },
        {
            id: "shutdown",
            icon: Config.session.icons.shutdown,
            label: qsTr("Desligar"),
            command: Config.session.commands.shutdown
        },
        {
            id: "hibernate",
            icon: Config.session.icons.hibernate,
            label: qsTr("Hibernar"),
            command: Config.session.commands.hibernate
        },
        {
            id: "reboot",
            icon: Config.session.icons.reboot,
            label: qsTr("Reiniciar"),
            command: Config.session.commands.reboot
        }
    ]

    function run(command: var): void {
        root.popouts.hasCurrent = false;
        Quickshell.execDetached(command);
    }

    implicitWidth: layout.implicitWidth + Tokens.padding.normal * 2
    implicitHeight: layout.implicitHeight + Tokens.padding.normal * 2

    RowLayout {
        id: layout

        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: Tokens.spacing.small

        Repeater {
            model: root.actions

            PowerAction {
                required property var modelData

                icon: modelData.icon
                label: modelData.label
                danger: modelData.id === "shutdown"
                onTriggered: root.run(modelData.command)
            }
        }
    }

    component PowerAction: StyledRect {
        id: action

        required property string icon
        required property string label
        property bool danger
        property real holdProgress
        property real wavePhase
        property bool completed
        readonly property int holdDuration: danger ? 1200 : 950
        readonly property color fillColour: danger ? Colours.palette.m3error : Colours.palette.m3primary
        readonly property color foreground: danger ? Colours.palette.m3onErrorContainer : Colours.palette.m3onSurfaceVariant
        readonly property color activeForeground: danger ? Colours.palette.m3onError : Colours.palette.m3onPrimary
        readonly property real waveY: height * (1 - holdProgress)
        readonly property real waveAmp: Math.min(7, height * 0.08)

        signal triggered

        function startHold(): void {
            completed = false;
            holdProgress = 0;
            wavePhase = 0;
            waveAnim.restart();
            holdAnim.restart();
        }

        function cancelHold(): void {
            if (completed)
                return;
            holdAnim.stop();
            waveAnim.stop();
            holdProgress = 0;
            wavePhase = 0;
        }

        function completeHold(): void {
            if (!stateLayer.pressed)
                return;
            completed = true;
            waveAnim.stop();
            holdProgress = 1;
            triggered();
        }

        Layout.preferredWidth: 78
        Layout.preferredHeight: content.implicitHeight + Tokens.padding.normal * 2

        clip: true
        radius: stateLayer.pressed ? Tokens.rounding.small : Tokens.rounding.normal
        color: danger ? Colours.palette.m3errorContainer : Colours.layer(Colours.palette.m3surfaceContainerHighest, 2)

        Shape {
            anchors.fill: parent
            opacity: action.holdProgress > 0 ? 0.88 : 0
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                strokeWidth: 0
                strokeColor: "transparent"
                fillColor: Qt.alpha(action.fillColour, action.danger ? 0.62 : 0.42)

                startX: 0
                startY: action.height

                PathLine {
                    x: 0
                    y: action.waveY + Math.sin(action.wavePhase) * action.waveAmp
                }

                PathCubic {
                    control1X: action.width * 0.18
                    control1Y: action.waveY - Math.sin(action.wavePhase + 0.8) * action.waveAmp
                    control2X: action.width * 0.34
                    control2Y: action.waveY + Math.sin(action.wavePhase + 1.5) * action.waveAmp
                    x: action.width * 0.5
                    y: action.waveY + Math.sin(action.wavePhase + 2.1) * action.waveAmp
                }

                PathCubic {
                    control1X: action.width * 0.66
                    control1Y: action.waveY - Math.sin(action.wavePhase + 2.8) * action.waveAmp
                    control2X: action.width * 0.82
                    control2Y: action.waveY + Math.sin(action.wavePhase + 3.5) * action.waveAmp
                    x: action.width
                    y: action.waveY + Math.sin(action.wavePhase + 4.2) * action.waveAmp
                }

                PathLine {
                    x: action.width
                    y: action.height
                }

                PathLine {
                    x: 0
                    y: action.height
                }
            }

            Behavior on opacity {
                Anim {
                    type: Anim.StandardSmall
                }
            }
        }

        StateLayer {
            id: stateLayer

            color: action.holdProgress > 0.7 ? action.activeForeground : action.foreground
            stateOpacity: pressed ? 0.05 : containsMouse ? 0.08 : 0
            onPressedChanged: {
                if (pressed)
                    action.startHold();
                else
                    action.cancelHold();
            }
            onContainsMouseChanged: {
                if (!containsMouse && pressed)
                    action.cancelHold();
            }
        }

        ColumnLayout {
            id: content

            anchors.centerIn: parent
            width: parent.width - Tokens.padding.small * 2
            spacing: Tokens.spacing.smaller

            MaterialIcon {
                Layout.alignment: Qt.AlignHCenter
                text: action.icon
                color: action.holdProgress > 0.72 ? action.activeForeground : action.foreground
                font.pointSize: Tokens.font.size.large
                font.weight: 500
            }

            StyledText {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: stateLayer.pressed ? qsTr("Segure") : action.label
                color: action.holdProgress > 0.72 ? action.activeForeground : action.foreground
                font.pointSize: Tokens.font.size.smaller
                elide: Text.ElideRight
                maximumLineCount: 1
            }
        }

        NumberAnimation {
            id: holdAnim

            target: action
            property: "holdProgress"
            from: 0
            to: 1
            duration: action.holdDuration
            easing: Tokens.anim.standard
            onFinished: action.completeHold()
        }

        NumberAnimation {
            id: waveAnim

            target: action
            property: "wavePhase"
            from: 0
            to: Math.PI * 2
            duration: 720
            loops: Animation.Infinite
        }

        Behavior on radius {
            Anim {
                type: Anim.FastSpatial
            }
        }

        Behavior on color {
            CAnim {}
        }
    }
}
