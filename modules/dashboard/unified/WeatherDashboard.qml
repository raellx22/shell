pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services

Item {
    id: root

    readonly property int panelHeight: 616
    readonly property var hourlyItems: firstItems(Weather.hourlyForecast, 8)
    readonly property var dailyItems: firstItems(Weather.forecast, 7)
    property int minuteTick

    function firstItems(items: var, count: int): var {
        const out = [];
        const list = items ?? [];
        for (let i = 0; i < Math.min(count, list.length); i++)
            out.push(list[i]);
        return out;
    }

    function tempFor(item: var, prefix: string): string {
        if (!item)
            return qsTr("--");
        const key = GlobalConfig.services.useFahrenheit ? `${prefix}F` : `${prefix}C`;
        return qsTr("%1°").arg(item[key] ?? "--");
    }

    function hourLabel(hour: int): string {
        const date = new Date();
        date.setHours(hour, 0, 0, 0);
        return Qt.formatTime(date, GlobalConfig.services.useTwelveHourClock ? "h AP" : "HH:mm");
    }

    function shortDay(dateText: string, index: int): string {
        if (index === 0)
            return qsTr("Hoje");
        const date = new Date(String(dateText).replace(/-/g, "/"));
        return date.toLocaleDateString(Qt.locale(), "ddd");
    }

    function dayProgress(): real {
        root.minuteTick;
        if (!Weather.cc?.sunrise || !Weather.cc?.sunset)
            return 0.5;

        const sunrise = new Date(String(Weather.cc.sunrise).replace(" ", "T")).getTime();
        const sunset = new Date(String(Weather.cc.sunset).replace(" ", "T")).getTime();
        const now = Date.now();
        if (Number.isNaN(sunrise) || Number.isNaN(sunset) || sunset <= sunrise)
            return 0.5;
        return Math.max(0, Math.min(1, (now - sunrise) / (sunset - sunrise)));
    }

    implicitWidth: layout.implicitWidth
    implicitHeight: root.panelHeight

    Component.onCompleted: Weather.reload()

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: root.minuteTick++
    }

    RowLayout {
        id: layout

        spacing: Tokens.spacing.normal

        ColumnLayout {
            Layout.preferredWidth: 392
            Layout.preferredHeight: root.panelHeight
            spacing: Tokens.spacing.normal

            HeroWeather {
                Layout.fillWidth: true
                Layout.preferredHeight: 356
            }

            SunCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }

        ColumnLayout {
            Layout.preferredWidth: 686
            Layout.preferredHeight: root.panelHeight
            spacing: Tokens.spacing.normal

            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spacing.normal

                DetailMetric {
                    Layout.fillWidth: true
                    icon: "device_thermostat"
                    label: qsTr("Sensacao")
                    value: Weather.feelsLike
                    accent: Colours.palette.m3primary
                }

                DetailMetric {
                    Layout.fillWidth: true
                    icon: "water_drop"
                    label: qsTr("Umidade")
                    value: qsTr("%1%").arg(Weather.humidity)
                    accent: Colours.palette.m3secondary
                }

                DetailMetric {
                    Layout.fillWidth: true
                    icon: "air"
                    label: qsTr("Vento")
                    value: Weather.windSpeed ? qsTr("%1 km/h").arg(Math.round(Weather.windSpeed)) : qsTr("--")
                    accent: Colours.palette.m3tertiary
                }
            }

            ForecastBand {
                Layout.fillWidth: true
                title: qsTr("Proximas horas")
                subtitle: Weather.city || qsTr("Atualizando local")
                modelData: root.hourlyItems
                hourly: true
            }

            ForecastBand {
                Layout.fillWidth: true
                Layout.fillHeight: true
                title: qsTr("Semana")
                subtitle: qsTr("Previsao de 7 dias")
                modelData: root.dailyItems
                hourly: false
            }
        }
    }

    component Card: StyledRect {
        radius: Tokens.rounding.normal
        color: Colours.tPalette.m3surfaceContainer
    }

    component HeroWeather: Card {
        id: hero

        clip: true
        color: Qt.alpha(Colours.palette.m3primaryContainer, 0.42)

        StyledRect {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.rightMargin: -54
            anchors.topMargin: -42
            implicitWidth: 210
            implicitHeight: 210
            radius: Tokens.rounding.full
            color: Qt.alpha(Colours.palette.m3primary, 0.10)
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Tokens.padding.large
            spacing: Tokens.spacing.normal

            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spacing.normal

                StyledRect {
                    Layout.alignment: Qt.AlignVCenter
                    implicitWidth: 46
                    implicitHeight: 46
                    radius: Tokens.rounding.full
                    color: Qt.alpha(Colours.palette.m3primary, 0.16)

                    MaterialIcon {
                        anchors.centerIn: parent
                        text: "cloud"
                        color: Colours.palette.m3primary
                        font.pointSize: Tokens.font.size.large
                        font.weight: 600
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    StyledText {
                        Layout.fillWidth: true
                        text: qsTr("Clima")
                        color: Colours.palette.m3onSurface
                        font.pointSize: Tokens.font.size.normal
                        font.weight: 600
                        elide: Text.ElideRight
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: new Date().toLocaleDateString(Qt.locale(), "dddd, d MMMM")
                        color: Colours.palette.m3onSurfaceVariant
                        font.pointSize: Tokens.font.size.small
                        font.capitalization: Font.Capitalize
                        elide: Text.ElideRight
                    }
                }

                IconButton {
                    icon: "refresh"
                    type: IconButton.Text
                    onClicked: Weather.reload()
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                MaterialIcon {
                    id: weatherIcon

                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: Weather.icon
                    color: Colours.palette.m3primary
                    fill: 1
                    font.pointSize: 72
                    animate: true
                }

                ColumnLayout {
                    anchors.left: weatherIcon.right
                    anchors.leftMargin: Tokens.spacing.large
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: -Tokens.spacing.small

                    StyledText {
                        Layout.fillWidth: true
                        text: Weather.temp
                        color: Colours.palette.m3onSurface
                        font.pointSize: 42
                        font.weight: 600
                        elide: Text.ElideRight
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: Weather.description
                        color: Colours.palette.m3primary
                        font.pointSize: Tokens.font.size.large
                        font.weight: 500
                        elide: Text.ElideRight
                    }

                    StyledText {
                        Layout.fillWidth: true
                        Layout.topMargin: Tokens.spacing.small
                        text: Weather.city || qsTr("Localizacao automatica")
                        color: Colours.palette.m3onSurfaceVariant
                        font.pointSize: Tokens.font.size.small
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }

    component SunCard: Card {
        id: sunCard

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Tokens.padding.large
            spacing: Tokens.spacing.normal

            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spacing.normal

                StyledText {
                    Layout.fillWidth: true
                    text: qsTr("Ciclo do dia")
                    color: Colours.palette.m3onSurface
                    font.pointSize: Tokens.font.size.normal
                    font.weight: 600
                    elide: Text.ElideRight
                }

                StyledText {
                    text: `${Math.round(root.dayProgress() * 100)}%`
                    color: Colours.palette.m3primary
                    font.pointSize: Tokens.font.size.small
                    font.family: Tokens.font.family.mono
                }
            }

            SunArc {
                Layout.fillWidth: true
                Layout.preferredHeight: 112
                progress: root.dayProgress()
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spacing.normal

                AstroTime {
                    Layout.fillWidth: true
                    icon: "wb_twilight"
                    label: qsTr("Nascer")
                    value: Weather.sunrise
                }

                AstroTime {
                    Layout.fillWidth: true
                    icon: "bedtime"
                    label: qsTr("Por")
                    value: Weather.sunset
                }
            }
        }
    }

    component SunArc: Canvas {
        id: arc

        required property real progress

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        onProgressChanged: requestPaint()

        onPaint: {
            const ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);

            const stroke = 7;
            const pad = stroke + 16;
            const cx = width / 2;
            const cy = height - pad;
            const radius = Math.max(0, Math.min(width / 2 - pad, height - pad - 8));
            const start = Math.PI;
            const end = Math.PI * 2;

            ctx.lineWidth = stroke;
            ctx.lineCap = "round";

            ctx.beginPath();
            ctx.strokeStyle = Qt.alpha(Colours.palette.m3outline, 0.26);
            ctx.arc(cx, cy, radius, start, end);
            ctx.stroke();

            ctx.beginPath();
            ctx.strokeStyle = Colours.palette.m3primary;
            ctx.arc(cx, cy, radius, start, start + Math.PI * Math.max(0.04, Math.min(1, progress)));
            ctx.stroke();
        }

        MaterialIcon {
            readonly property real angle: Math.PI + Math.PI * Math.max(0.04, Math.min(0.96, arc.progress))
            readonly property real iconPad: 23
            readonly property real radiusValue: Math.max(0, Math.min(arc.width / 2 - iconPad, arc.height - iconPad - 8))

            x: arc.width / 2 + Math.cos(angle) * radiusValue - width / 2
            y: arc.height - iconPad + Math.sin(angle) * radiusValue - height / 2
            text: "wb_sunny"
            color: Colours.palette.m3tertiary
            fill: 1
            font.pointSize: Tokens.font.size.large

            Behavior on x {
                Anim {
                    type: Anim.DefaultSpatial
                }
            }

            Behavior on y {
                Anim {
                    type: Anim.DefaultSpatial
                }
            }
        }
    }

    component AstroTime: StyledRect {
        id: astro

        required property string icon
        required property string label
        required property string value

        color: Colours.layer(Colours.palette.m3surfaceContainerHigh, 2)
        radius: Tokens.rounding.small
        implicitHeight: astroRow.implicitHeight + Tokens.padding.normal * 2

        RowLayout {
            id: astroRow

            anchors.fill: parent
            anchors.margins: Tokens.padding.normal
            spacing: Tokens.spacing.normal

            MaterialIcon {
                Layout.alignment: Qt.AlignVCenter
                text: astro.icon
                color: Colours.palette.m3tertiary
                font.pointSize: Tokens.font.size.large
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                StyledText {
                    Layout.fillWidth: true
                    text: astro.label
                    color: Colours.palette.m3outline
                    font.pointSize: Tokens.font.size.small
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    text: astro.value
                    color: Colours.palette.m3onSurface
                    font.pointSize: Tokens.font.size.normal
                    font.weight: 600
                    elide: Text.ElideRight
                }
            }
        }
    }

    component DetailMetric: Card {
        id: metric

        required property string icon
        required property string label
        required property string value
        required property color accent

        implicitHeight: 116

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Tokens.padding.normal
            spacing: Tokens.spacing.small

            StyledRect {
                Layout.alignment: Qt.AlignHCenter
                implicitWidth: 36
                implicitHeight: 36
                radius: Tokens.rounding.full
                color: Qt.alpha(metric.accent, 0.16)

                MaterialIcon {
                    anchors.centerIn: parent
                    text: metric.icon
                    color: metric.accent
                    font.pointSize: Tokens.font.size.normal
                    font.weight: 600
                }
            }

            StyledText {
                Layout.fillWidth: true
                text: metric.value
                color: Colours.palette.m3onSurface
                font.pointSize: Tokens.font.size.large
                font.weight: 600
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
            }

            StyledText {
                Layout.fillWidth: true
                text: metric.label
                color: Colours.palette.m3outline
                font.pointSize: Tokens.font.size.small
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
            }
        }
    }

    component ForecastBand: Card {
        id: band

        required property string title
        required property string subtitle
        required property var modelData
        required property bool hourly

        implicitHeight: content.implicitHeight + Tokens.padding.large * 2

        ColumnLayout {
            id: content

            anchors.fill: parent
            anchors.margins: Tokens.padding.large
            spacing: Tokens.spacing.normal

            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spacing.normal

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    StyledText {
                        Layout.fillWidth: true
                        text: band.title
                        color: Colours.palette.m3onSurface
                        font.pointSize: Tokens.font.size.normal
                        font.weight: 600
                        elide: Text.ElideRight
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: band.subtitle
                        color: Colours.palette.m3outline
                        font.pointSize: Tokens.font.size.small
                        elide: Text.ElideRight
                    }
                }

                StyledText {
                    text: band.hourly ? qsTr("8 blocos") : qsTr("7 dias")
                    color: Colours.palette.m3primary
                    font.pointSize: Tokens.font.size.small
                    font.family: Tokens.font.family.mono
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spacing.small

                Repeater {
                    model: band.modelData

                    ForecastTile {
                        required property int index
                        required property var modelData

                        Layout.fillWidth: true
                        hourly: band.hourly
                        active: index === 0
                        time: band.hourly ? root.hourLabel(modelData.hour) : root.shortDay(modelData.date, index)
                        icon: modelData.icon
                        value: band.hourly ? root.tempFor(modelData, "temp") : `${root.tempFor(modelData, "maxTemp")} / ${root.tempFor(modelData, "minTemp")}`
                    }
                }
            }
        }
    }

    component ForecastTile: StyledRect {
        id: tile

        required property bool hourly
        required property bool active
        required property string time
        required property string icon
        required property string value

        color: active ? Qt.alpha(Colours.palette.m3primary, 0.15) : Colours.layer(Colours.palette.m3surfaceContainerHigh, 2)
        radius: Tokens.rounding.small
        implicitHeight: hourly ? 112 : 132

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Tokens.padding.normal
            spacing: Tokens.spacing.small

            StyledText {
                Layout.fillWidth: true
                text: tile.time
                color: tile.active ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
                font.pointSize: Tokens.font.size.small
                font.weight: tile.active ? 600 : 500
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
            }

            MaterialIcon {
                Layout.alignment: Qt.AlignHCenter
                text: tile.icon
                color: tile.active ? Colours.palette.m3primary : Colours.palette.m3secondary
                font.pointSize: tile.hourly ? Tokens.font.size.extraLarge : 28
                animate: tile.active
            }

            StyledText {
                Layout.fillWidth: true
                text: tile.value
                color: Colours.palette.m3onSurface
                font.pointSize: Tokens.font.size.small
                font.weight: 600
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
            }
        }

        Behavior on color {
            CAnim {}
        }
    }
}
