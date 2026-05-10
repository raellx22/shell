pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services
import qs.utils
import qs.modules.controlcenter

StyledRect {
    id: root

    required property DrawerVisibilities visibilities

    function openSettings(pane: string): void {
        root.visibilities.dashboard = false;
        if (pane)
            WindowFactory.create(null, {
                "active": pane
            });
        else
            WindowFactory.create();
    }

    function networkRows(): var {
        if (!Nmcli.wifiEnabled) {
            return [{
                icon: "wifi_off",
                title: qsTr("Wi-Fi desligado"),
                subtitle: qsTr("Adaptador inativo")
            }];
        }

        const rows = [];
        const active = Nmcli.active;
        if (active) {
            rows.push({
                icon: Icons.getNetworkIcon(active.strength ?? 0, active.isSecure ?? false),
                title: active.ssid || qsTr("Conectado"),
                subtitle: qsTr("%1% de sinal").arg(active.strength ?? 0)
            });
        } else {
            rows.push({
                icon: Nmcli.scanning ? "wifi_find" : "wifi",
                title: Nmcli.scanning ? qsTr("Buscando redes") : qsTr("Sem conexão"),
                subtitle: qsTr("%1 redes visíveis").arg(Nmcli.networks.length)
            });
        }

        const networks = [...Nmcli.networks].filter(n => !n.active).sort((a, b) => b.strength - a.strength).slice(0, 2);
        for (const network of networks) {
            rows.push({
                icon: Icons.getNetworkIcon(network.strength, network.isSecure),
                title: network.ssid || qsTr("Rede sem nome"),
                subtitle: network.isSecure ? qsTr("Protegida") : qsTr("Aberta")
            });
        }
        return rows;
    }

    function bluetoothRows(): var {
        const adapter = Bluetooth.defaultAdapter; // qmllint disable unresolved-type
        if (!adapter) {
            return [{
                icon: "bluetooth_disabled",
                title: qsTr("Sem adaptador"),
                subtitle: qsTr("Bluetooth indisponível")
            }];
        }
        if (!adapter.enabled) {
            return [{
                icon: "bluetooth_disabled",
                title: qsTr("Bluetooth desligado"),
                subtitle: qsTr("Adaptador inativo")
            }];
        }

        const devices = [...Bluetooth.devices.values].sort((a, b) => (b.connected - a.connected) || (b.paired - a.paired) || a.name.localeCompare(b.name)).slice(0, 3); // qmllint disable unresolved-type
        if (devices.length === 0) {
            return [{
                icon: adapter.discovering ? "bluetooth_searching" : "bluetooth",
                title: adapter.discovering ? qsTr("Procurando") : qsTr("Nenhum dispositivo"),
                subtitle: qsTr("Nenhum pareado")
            }];
        }

        return devices.map(device => {
            let subtitle = device.connected ? qsTr("Conectado") : device.paired ? qsTr("Pareado") : qsTr("Disponível");
            if (device.connected && device.batteryAvailable)
                subtitle += qsTr(" · %1%").arg(Math.round(device.battery * 100));
            return {
                icon: Icons.getBluetoothIcon(device.icon),
                title: device.name || qsTr("Dispositivo"),
                subtitle: subtitle
            };
        });
    }

    function micRows(): var {
        const sources = [...Audio.sources].sort((a, b) => {
            if (Audio.source?.id === a.id)
                return -1;
            if (Audio.source?.id === b.id)
                return 1;
            return (a.description || a.name || "").localeCompare(b.description || b.name || "");
        });
        if (sources.length === 0) {
            return [{
                icon: "mic_off",
                title: qsTr("Sem entrada"),
                subtitle: qsTr("Nenhum microfone ativo")
            }];
        }

        return sources.slice(0, 3).map(source => {
            const selected = Audio.source?.id === source.id;
            return {
                icon: selected ? "radio_button_checked" : "radio_button_unchecked",
                title: source.description || source.name || qsTr("Microfone"),
                subtitle: selected ? qsTr("Entrada principal") : qsTr("Disponível"),
                selected: selected,
                source: source,
                action: "source"
            };
        });
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
            spacing: Tokens.spacing.small

            StyledText {
                Layout.fillWidth: true
                text: qsTr("Controles")
                font.pointSize: Tokens.font.size.normal
                font.weight: 500
                elide: Text.ElideRight
            }

            StyledText {
                text: qsTr("rápido")
                color: Colours.palette.m3outline
                font.pointSize: Tokens.font.size.small
                font.family: Tokens.font.family.mono
            }
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            rowSpacing: Tokens.spacing.small
            columnSpacing: Tokens.spacing.small

            ActionTile {
                icon: "wifi"
                label: qsTr("Wi-Fi")
                active: Nmcli.wifiEnabled
                settingsPane: "network"
                details: root.networkRows()
                onHoverStarted: Nmcli.getNetworks(() => {})
                onTriggered: Nmcli.toggleWifi()
                onSettingsRequested: root.openSettings(settingsPane)
            }

            ActionTile {
                icon: "bluetooth"
                label: qsTr("Bluetooth")
                active: Bluetooth.defaultAdapter?.enabled ?? false // qmllint disable unresolved-type
                settingsPane: "bluetooth"
                details: root.bluetoothRows()
                onTriggered: {
                    const adapter = Bluetooth.defaultAdapter; // qmllint disable unresolved-type
                    if (adapter)
                        adapter.enabled = !adapter.enabled;
                }
                onSettingsRequested: root.openSettings(settingsPane)
            }

            ActionTile {
                icon: "notifications_off"
                label: qsTr("Não perturbe")
                active: Notifs.dnd
                settingsPane: "notifications"
                onTriggered: Notifs.dnd = !Notifs.dnd
                onSettingsRequested: root.openSettings(settingsPane)
            }

            ActionTile {
                icon: "mic"
                label: qsTr("Microfone")
                active: !Audio.sourceMuted
                settingsPane: "audio"
                details: root.micRows()
                onTriggered: {
                    const audio = Audio.source?.audio;
                    if (audio)
                        audio.muted = !audio.muted;
                }
                onSettingsRequested: root.openSettings(settingsPane)
            }

            ActionTile {
                icon: "sports_esports"
                label: qsTr("Jogo")
                active: GameMode.enabled
                onTriggered: GameMode.enabled = !GameMode.enabled
            }

            ActionTile {
                icon: "bedtime"
                label: qsTr("Awake")
                active: IdleInhibitor.enabled
                onTriggered: IdleInhibitor.enabled = !IdleInhibitor.enabled
            }

            ActionTile {
                icon: "settings"
                label: qsTr("Ajustes")
                wide: true
                details: [{
                    icon: "tune",
                    title: qsTr("Caelestia Settings"),
                    subtitle: qsTr("Central completa")
                }]
                onTriggered: root.openSettings("")
                onSettingsRequested: root.openSettings("")
            }
        }
    }

    component ActionTile: StyledRect {
        id: tile

        required property string icon
        required property string label
        property bool active
        property bool wide
        property string settingsPane
        property var details: []
        property bool hoverOpen
        readonly property bool hasDetails: details.length > 0
        readonly property bool expanded: hasDetails && hoverOpen

        signal triggered
        signal settingsRequested
        signal hoverStarted

        Layout.fillWidth: true
        Layout.columnSpan: wide ? 2 : 1
        Layout.preferredHeight: Math.max(58, tileInner.implicitHeight + Tokens.padding.small * 2)
        radius: active || stateLayer.pressed ? Tokens.rounding.small : Tokens.rounding.normal
        color: active ? Colours.palette.m3secondaryContainer : Colours.layer(Colours.palette.m3surfaceContainerHighest, 2)

        onHasDetailsChanged: {
            if (!hasDetails)
                hoverOpen = false;
        }

        HoverHandler {
            id: tileHover

            onHoveredChanged: {
                if (hovered) {
                    closeDelay.stop();
                    if (!tile.hoverOpen) {
                        tile.hoverOpen = true;
                        tile.hoverStarted();
                    }
                } else {
                    closeDelay.restart();
                }
            }
        }

        Timer {
            id: closeDelay

            interval: 170
            repeat: false
            onTriggered: {
                if (!tileHover.hovered)
                    tile.hoverOpen = false;
            }
        }

        Connections {
            function onContainsMouseChanged(): void {
                if (stateLayer.containsMouse && !tile.hoverOpen) {
                    tile.hoverOpen = true;
                    tile.hoverStarted();
                }
            }

            target: stateLayer
        }

        StateLayer {
            id: stateLayer

            acceptedButtons: Qt.LeftButton | Qt.RightButton
            color: tile.active ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurfaceVariant
            onClicked: event => {
                if (event.button === Qt.RightButton && tile.settingsPane.length > 0)
                    tile.settingsRequested();
                else
                    tile.triggered();
            }
        }

        ColumnLayout {
            id: tileInner

            anchors.fill: parent
            anchors.margins: Tokens.padding.small
            spacing: Tokens.spacing.small

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 58 - Tokens.padding.small * 2
                spacing: Tokens.spacing.small

                MaterialIcon {
                    Layout.alignment: Qt.AlignVCenter
                    text: tile.icon
                    fill: tile.active ? 1 : 0
                    color: tile.active ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurfaceVariant
                    font.pointSize: Tokens.font.size.large
                }

                StyledText {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    text: tile.label
                    color: tile.active ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurfaceVariant
                    font.pointSize: Tokens.font.size.small
                    elide: Text.ElideRight
                }

                MaterialIcon {
                    visible: tile.settingsPane.length > 0 || tile.wide
                    Layout.alignment: Qt.AlignVCenter
                    text: "open_in_new"
                    color: Qt.alpha(tile.active ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurfaceVariant, tile.expanded ? 0.85 : 0)
                    font.pointSize: Tokens.font.size.small

                    Behavior on color {
                        CAnim {}
                    }
                }
            }

            Repeater {
                model: tile.expanded ? tile.details : []

                StyledRect {
                    id: detailRow

                    required property var modelData

                    Layout.fillWidth: true
                    implicitHeight: detailContent.implicitHeight + Tokens.padding.smaller * 2
                    radius: Tokens.rounding.small
                    color: Qt.alpha(tile.active ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurfaceVariant, modelData.selected ? 0.12 : 0)

                    StateLayer {
                        radius: Tokens.rounding.small
                        disabled: modelData.action !== "source" || modelData.selected
                        color: tile.active ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurfaceVariant
                        onClicked: {
                            if (modelData.action === "source" && modelData.source)
                                Audio.setAudioSource(modelData.source);
                        }
                    }

                    RowLayout {
                        id: detailContent

                        anchors.fill: parent
                        anchors.margins: Tokens.padding.smaller
                        spacing: Tokens.spacing.small

                        MaterialIcon {
                            Layout.alignment: Qt.AlignVCenter
                            text: detailRow.modelData.icon
                            color: tile.active ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurfaceVariant
                            font.pointSize: Tokens.font.size.normal
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            StyledText {
                                Layout.fillWidth: true
                                text: detailRow.modelData.title
                                color: tile.active ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurfaceVariant
                                font.pointSize: Tokens.font.size.small
                                elide: Text.ElideRight
                                maximumLineCount: 1
                            }

                            StyledText {
                                Layout.fillWidth: true
                                text: detailRow.modelData.subtitle
                                color: Qt.alpha(tile.active ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurfaceVariant, 0.72)
                                font.pointSize: Tokens.font.size.smaller
                                elide: Text.ElideRight
                                maximumLineCount: 1
                            }
                        }
                    }

                    Behavior on color {
                        CAnim {}
                    }
                }
            }
        }

        Behavior on Layout.preferredHeight {
            Anim {
                type: Anim.FastSpatial
            }
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
