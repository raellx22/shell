pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services
import qs.utils

StyledRect {
    id: root

    readonly property var monitor: Brightness.getMonitor("active")

    implicitHeight: layout.implicitHeight + Tokens.padding.large * 2
    radius: Tokens.rounding.normal
    color: Colours.tPalette.m3surfaceContainer

    ColumnLayout {
        id: layout

        anchors.fill: parent
        anchors.margins: Tokens.padding.large
        spacing: Tokens.spacing.normal

        StyledText {
            Layout.fillWidth: true
            text: qsTr("Sistema")
            font.pointSize: Tokens.font.size.normal
            font.weight: 500
            elide: Text.ElideRight
        }

        SliderRow {
            icon: Icons.getVolumeIcon(Audio.volume, Audio.muted)
            label: qsTr("Volume")
            value: Audio.volume
            to: GlobalConfig.services.maxVolume
            onMoved: value => Audio.setVolume(value)
            onIconClicked: {
                const audio = Audio.sink?.audio;
                if (audio)
                    audio.muted = !audio.muted;
            }
        }

        SliderRow {
            icon: Icons.getMicVolumeIcon(Audio.sourceVolume, Audio.sourceMuted)
            label: qsTr("Microfone")
            value: Audio.sourceVolume
            to: GlobalConfig.services.maxVolume
            onMoved: value => Audio.setSourceVolume(value)
            onIconClicked: {
                const audio = Audio.source?.audio;
                if (audio)
                    audio.muted = !audio.muted;
            }
        }

        SliderRow {
            icon: `brightness_${Math.round((root.monitor?.brightness ?? 0) * 6) + 1}`
            label: qsTr("Brilho")
            value: root.monitor?.brightness ?? 0
            to: 1
            onMoved: value => root.monitor?.setBrightness(value)
            onIconClicked: {
                if (root.monitor)
                    root.monitor.setBrightness(Math.min(1, root.monitor.brightness + GlobalConfig.services.brightnessIncrement));
            }
        }
    }

    component SliderRow: RowLayout {
        id: row

        required property string icon
        required property string label
        required property real value
        property real to: 1

        signal moved(real value)
        signal iconClicked

        Layout.fillWidth: true
        spacing: Tokens.spacing.normal

        IconButton {
            Layout.alignment: Qt.AlignVCenter
            icon: row.icon
            type: IconButton.Tonal
            padding: Tokens.padding.smaller
            onClicked: row.iconClicked()
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.smaller

            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spacing.small

                StyledText {
                    Layout.fillWidth: true
                    text: row.label
                    color: Colours.palette.m3onSurfaceVariant
                    font.pointSize: Tokens.font.size.small
                    elide: Text.ElideRight
                }

                StyledText {
                    text: `${Math.round(row.value * 100)}%`
                    color: Colours.palette.m3outline
                    font.pointSize: Tokens.font.size.small
                    font.family: Tokens.font.family.mono
                }
            }

            StyledSlider {
                Layout.fillWidth: true
                implicitHeight: 28
                value: row.value
                to: row.to
                onMoved: row.moved(value)
            }
        }
    }
}
