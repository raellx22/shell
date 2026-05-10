pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services

StyledRect {
    id: root

    readonly property string elapsedText: {
        const elapsed = Recorder.elapsed;
        const hours = Math.floor(elapsed / 3600);
        const mins = Math.floor((elapsed % 3600) / 60);
        const secs = Math.floor(elapsed % 60).toString().padStart(2, "0");
        return hours > 0 ? `${hours}:${mins.toString().padStart(2, "0")}:${secs}` : `${mins}:${secs}`;
    }

    implicitHeight: layout.implicitHeight + Tokens.padding.large * 2
    radius: Tokens.rounding.normal
    color: Colours.tPalette.m3surfaceContainer

    ColumnLayout {
        id: layout

        anchors.fill: parent
        anchors.margins: Tokens.padding.large
        spacing: Tokens.spacing.normal

        RowLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.normal

            StyledRect {
                Layout.alignment: Qt.AlignVCenter
                implicitWidth: 40
                implicitHeight: 40
                radius: Tokens.rounding.full
                color: Recorder.running ? Colours.palette.m3errorContainer : Colours.palette.m3secondaryContainer

                MaterialIcon {
                    anchors.centerIn: parent
                    text: "screen_record"
                    color: Recorder.running ? Colours.palette.m3onErrorContainer : Colours.palette.m3onSecondaryContainer
                    fill: Recorder.running ? 1 : 0
                    font.pointSize: Tokens.font.size.large
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                StyledText {
                    Layout.fillWidth: true
                    text: qsTr("Gravação")
                    font.pointSize: Tokens.font.size.normal
                    font.weight: 500
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    text: Recorder.running ? (Recorder.paused ? qsTr("Pausada %1").arg(root.elapsedText) : qsTr("Gravando %1").arg(root.elapsedText)) : qsTr("Pronta para iniciar")
                    color: Colours.palette.m3onSurfaceVariant
                    font.pointSize: Tokens.font.size.small
                    elide: Text.ElideRight
                }
            }
        }

        Loader {
            Layout.fillWidth: true
            Layout.preferredHeight: implicitHeight
            active: true
            sourceComponent: Recorder.running ? runningControls : startControls
        }
    }

    Component {
        id: startControls

        RowLayout {
            spacing: Tokens.spacing.small

            IconTextButton {
                Layout.fillWidth: true
                icon: "fullscreen"
                text: qsTr("Tela")
                type: IconTextButton.Tonal
                onClicked: Recorder.start()
            }

            IconTextButton {
                Layout.fillWidth: true
                icon: "screenshot_region"
                text: qsTr("Área")
                type: IconTextButton.Tonal
                onClicked: Recorder.start(["-r"])
            }

            IconButton {
                icon: "volume_up"
                type: IconButton.Tonal
                onClicked: Recorder.start(["-s"])
            }
        }
    }

    Component {
        id: runningControls

        RowLayout {
            spacing: Tokens.spacing.small

            IconTextButton {
                Layout.fillWidth: true
                icon: Recorder.paused ? "play_arrow" : "pause"
                text: Recorder.paused ? qsTr("Retomar") : qsTr("Pausar")
                type: IconTextButton.Tonal
                onClicked: Recorder.togglePause()
            }

            IconTextButton {
                Layout.fillWidth: true
                icon: "stop"
                text: qsTr("Parar")
                activeColour: Colours.palette.m3error
                activeOnColour: Colours.palette.m3onError
                inactiveColour: Colours.palette.m3error
                inactiveOnColour: Colours.palette.m3onError
                onClicked: Recorder.stop()
            }
        }
    }
}
