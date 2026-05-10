pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.components.misc
import qs.services

StyledRect {
    id: root

    signal openDetails

    function percent(value: real): string {
        return qsTr("%1%").arg(Math.round(Math.max(0, Math.min(1, value)) * 100));
    }

    function displayTemp(temp: real): string {
        if (temp <= 0)
            return qsTr("--");
        const value = Math.ceil(GlobalConfig.services.useFahrenheitPerformance ? temp * 1.8 + 32 : temp);
        return qsTr("%1°%2").arg(value).arg(GlobalConfig.services.useFahrenheitPerformance ? "F" : "C");
    }

    function formatUsage(used: real, total: real): string {
        const usedFmt = SystemUsage.formatKib(used);
        const totalFmt = SystemUsage.formatKib(total);
        return qsTr("%1 / %2 %3").arg(usedFmt.value.toFixed(1)).arg(Math.floor(totalFmt.value)).arg(totalFmt.unit);
    }

    function formatSpeed(bytes: real): string {
        const fmt = NetworkUsage.formatBytes(bytes ?? 0);
        return qsTr("%1 %2").arg(fmt.value.toFixed(1)).arg(fmt.unit);
    }

    radius: Tokens.rounding.normal
    color: Colours.tPalette.m3surfaceContainer
    implicitHeight: content.implicitHeight + Tokens.padding.large * 2

    Ref {
        service: SystemUsage
    }

    Ref {
        service: NetworkUsage
    }

    StateLayer {
        radius: parent.radius
        color: Colours.palette.m3primary
        onClicked: root.openDetails()
    }

    ColumnLayout {
        id: content

        anchors.fill: parent
        anchors.margins: Tokens.padding.large
        spacing: Tokens.spacing.normal

        RowLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.small

            StyledRect {
                Layout.alignment: Qt.AlignVCenter
                implicitWidth: 34
                implicitHeight: 34
                radius: Tokens.rounding.full
                color: Qt.alpha(Colours.palette.m3primary, 0.16)

                MaterialIcon {
                    anchors.centerIn: parent
                    text: "speed"
                    color: Colours.palette.m3primary
                    font.pointSize: Tokens.font.size.normal
                    font.weight: 600
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                StyledText {
                    Layout.fillWidth: true
                    text: qsTr("Performance")
                    color: Colours.palette.m3onSurface
                    font.pointSize: Tokens.font.size.normal
                    font.weight: 500
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    text: qsTr("Resumo do sistema")
                    color: Colours.palette.m3outline
                    font.pointSize: Tokens.font.size.small
                    elide: Text.ElideRight
                }
            }

            RowLayout {
                spacing: Tokens.spacing.smaller

                StyledText {
                    text: qsTr("detalhes")
                    color: Colours.palette.m3primary
                    font.pointSize: Tokens.font.size.small
                    font.family: Tokens.font.family.mono
                }

                MaterialIcon {
                    text: "chevron_right"
                    color: Colours.palette.m3primary
                    font.pointSize: Tokens.font.size.normal
                    font.weight: 600
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.normal

            HeroMetric {
                Layout.fillWidth: true
                icon: "memory"
                title: qsTr("CPU")
                value: root.percent(SystemUsage.cpuPerc)
                subtitle: root.displayTemp(SystemUsage.cpuTemp)
                percentage: SystemUsage.cpuPerc
                accent: Colours.palette.m3primary
            }

            HeroMetric {
                Layout.fillWidth: true
                icon: "memory_alt"
                title: qsTr("RAM")
                value: root.percent(SystemUsage.memPerc)
                subtitle: root.formatUsage(SystemUsage.memUsed, SystemUsage.memTotal)
                percentage: SystemUsage.memPerc
                accent: Colours.palette.m3secondary
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.normal

            LinearMetric {
                Layout.fillWidth: true
                icon: "hard_disk"
                title: qsTr("Disco")
                value: root.percent(SystemUsage.storagePerc)
                percentage: SystemUsage.storagePerc
                accent: Colours.palette.m3tertiary
            }

            LinearMetric {
                Layout.fillWidth: true
                icon: "desktop_windows"
                title: qsTr("GPU")
                value: SystemUsage.gpuType === "NONE" ? qsTr("--") : root.percent(SystemUsage.gpuPerc)
                percentage: SystemUsage.gpuType === "NONE" ? 0 : SystemUsage.gpuPerc
                accent: Colours.palette.m3secondary
            }
        }

        NetworkMetric {
            Layout.fillWidth: true
            download: root.formatSpeed(NetworkUsage.downloadSpeed)
            upload: root.formatSpeed(NetworkUsage.uploadSpeed)
        }
    }

    component HeroMetric: StyledRect {
        id: metric

        required property string icon
        required property string title
        required property string value
        required property string subtitle
        required property real percentage
        required property color accent

        color: Colours.layer(Colours.palette.m3surfaceContainerHigh, 2)
        radius: Tokens.rounding.small
        implicitHeight: metricContent.implicitHeight + Tokens.padding.normal * 2

        RowLayout {
            id: metricContent

            anchors.fill: parent
            anchors.margins: Tokens.padding.normal
            spacing: Tokens.spacing.normal

            Item {
                Layout.preferredWidth: 52
                Layout.preferredHeight: 52

                CircularProgress {
                    anchors.fill: parent
                    value: metric.percentage
                    strokeWidth: Tokens.padding.smaller
                    fgColour: metric.accent
                    bgColour: Qt.alpha(metric.accent, 0.18)
                }

                MaterialIcon {
                    anchors.centerIn: parent
                    text: metric.icon
                    color: metric.accent
                    font.pointSize: Tokens.font.size.normal
                    font.weight: 600
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                StyledText {
                    text: metric.title
                    color: Colours.palette.m3outline
                    font.pointSize: Tokens.font.size.small
                    font.family: Tokens.font.family.mono
                }

                StyledText {
                    Layout.fillWidth: true
                    text: metric.value
                    color: Colours.palette.m3onSurface
                    font.pointSize: Tokens.font.size.large
                    font.weight: 600
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    text: metric.subtitle
                    color: Colours.palette.m3onSurfaceVariant
                    font.pointSize: Tokens.font.size.small
                    elide: Text.ElideRight
                }
            }
        }
    }

    component LinearMetric: StyledRect {
        id: metric

        required property string icon
        required property string title
        required property string value
        required property real percentage
        required property color accent

        color: Colours.layer(Colours.palette.m3surfaceContainerHigh, 1)
        radius: Tokens.rounding.small
        implicitHeight: metricContent.implicitHeight + Tokens.padding.normal * 2

        ColumnLayout {
            id: metricContent

            anchors.fill: parent
            anchors.margins: Tokens.padding.normal
            spacing: Tokens.spacing.small

            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spacing.small

                MaterialIcon {
                    text: metric.icon
                    color: metric.accent
                    font.pointSize: Tokens.font.size.normal
                    font.weight: 600
                }

                StyledText {
                    Layout.fillWidth: true
                    text: metric.title
                    color: Colours.palette.m3onSurfaceVariant
                    font.pointSize: Tokens.font.size.small
                    elide: Text.ElideRight
                }

                StyledText {
                    text: metric.value
                    color: Colours.palette.m3onSurface
                    font.pointSize: Tokens.font.size.small
                    font.weight: 600
                }
            }

            StyledRect {
                Layout.fillWidth: true
                implicitHeight: 6
                radius: Tokens.rounding.full
                color: Qt.alpha(metric.accent, 0.16)

                StyledRect {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: parent.width * Math.max(0, Math.min(1, metric.percentage))
                    radius: parent.radius
                    color: metric.accent
                }
            }
        }
    }

    component NetworkMetric: StyledRect {
        id: metric

        required property string download
        required property string upload

        color: Colours.layer(Colours.palette.m3surfaceContainerHigh, 1)
        radius: Tokens.rounding.small
        implicitHeight: networkContent.implicitHeight + Tokens.padding.normal * 2

        ColumnLayout {
            id: networkContent

            anchors.fill: parent
            anchors.margins: Tokens.padding.normal
            spacing: Tokens.spacing.small

            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spacing.small

                MaterialIcon {
                    text: "swap_vert"
                    color: Colours.palette.m3primary
                    font.pointSize: Tokens.font.size.normal
                    font.weight: 600
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    StyledText {
                        Layout.fillWidth: true
                        text: qsTr("Rede")
                        color: Colours.palette.m3onSurfaceVariant
                        font.pointSize: Tokens.font.size.small
                        elide: Text.ElideRight
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: qsTr("Tráfego atual")
                        color: Colours.palette.m3outline
                        font.pointSize: Tokens.font.size.small
                        elide: Text.ElideRight
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spacing.normal

                SpeedPill {
                    Layout.fillWidth: true
                    icon: "download"
                    label: qsTr("Down")
                    value: metric.download
                    accent: Colours.palette.m3tertiary
                }

                SpeedPill {
                    Layout.fillWidth: true
                    icon: "upload"
                    label: qsTr("Up")
                    value: metric.upload
                    accent: Colours.palette.m3secondary
                }
            }
        }
    }

    component SpeedPill: StyledRect {
        id: pill

        required property string icon
        required property string label
        required property string value
        required property color accent

        color: Qt.alpha(pill.accent, 0.12)
        radius: Tokens.rounding.small
        implicitHeight: pillContent.implicitHeight + Tokens.padding.small * 2

        RowLayout {
            id: pillContent

            anchors.fill: parent
            anchors.margins: Tokens.padding.small
            spacing: Tokens.spacing.small

            MaterialIcon {
                Layout.alignment: Qt.AlignVCenter
                text: pill.icon
                color: pill.accent
                font.pointSize: Tokens.font.size.normal
                font.weight: 600
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                StyledText {
                    Layout.fillWidth: true
                    text: pill.label
                    color: Colours.palette.m3outline
                    font.pointSize: Tokens.font.size.smaller
                    font.family: Tokens.font.family.mono
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    text: pill.value
                    color: Colours.palette.m3onSurface
                    font.pointSize: Tokens.font.size.small
                    font.weight: 600
                    elide: Text.ElideRight
                }
            }
        }
    }
}
