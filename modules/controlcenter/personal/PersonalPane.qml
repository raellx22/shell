pragma ComponentBehavior: Bound

import ".."
import "../components"
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Caelestia.Config
import qs.components
import qs.components.containers
import qs.components.controls
import qs.components.effects
import qs.components.filedialog
import qs.services
import qs.utils

Item {
    id: root

    required property Session session

    property int activePageIndex
    property int activeHyprGroupIndex
    property int activeMonitorIndex

    readonly property string defaultMediaGif: "root:/assets/bongocat.gif"
    readonly property string defaultSessionGif: "root:/assets/kurukuru.gif"
    readonly property var pages: [
        {
            id: "home",
            label: qsTr("Início"),
            icon: "space_dashboard"
        },
        {
            id: "hyprland",
            label: qsTr("Hyprland"),
            icon: "tune"
        },
        {
            id: "monitors",
            label: qsTr("Monitores"),
            icon: "display_settings"
        },
        {
            id: "binds",
            label: qsTr("Atalhos"),
            icon: "keyboard"
        },
        {
            id: "rules",
            label: qsTr("Regras"),
            icon: "rule"
        },
        {
            id: "startup",
            label: qsTr("Inicialização"),
            icon: "rocket_launch"
        },
        {
            id: "profiles",
            label: qsTr("Perfis"),
            icon: "workspaces"
        }
    ]

    property string mediaGif: GlobalConfig.paths.mediaGif ?? defaultMediaGif
    property string sessionGif: GlobalConfig.paths.sessionGif ?? defaultSessionGif

    function currentPage(): var {
        return pages[Math.max(0, Math.min(activePageIndex, pages.length - 1))];
    }

    function activateSubpage(): void {
        if (!session.subpage)
            return;
        const index = pages.findIndex(page => page.id === session.subpage);
        if (index >= 0)
            activePageIndex = index;
    }

    function currentHyprGroup(): var {
        const groups = HyprConfig.optionGroups;
        if (!groups || groups.length === 0)
            return null;
        return groups[Math.max(0, Math.min(activeHyprGroupIndex, groups.length - 1))];
    }

    function optionCount(group: var): int {
        let total = 0;
        if (!group)
            return total;
        for (const section of group.sections)
            total += section.options.length;
        return total;
    }

    function groupIcon(group: var): string {
        return ({
            general: "window",
            decoration: "palette",
            animations: "animation",
            input: "keyboard",
            cursor: "ads_click",
            gestures: "touch_app",
            dwindle: "grid_view",
            master: "view_column",
            scrolling: "view_carousel",
            xwayland: "desktop_windows",
            ecosystem: "hub",
            monitor_globals: "display_settings",
            misc: "more_horiz"
        })[group?.id] ?? "tune";
    }

    function categoryPillWidth(containerWidth: real): int {
        const gap = Tokens.spacing.small;
        const columns = containerWidth >= 720 ? 3 : containerWidth >= 460 ? 2 : 1;
        return Math.max(120, Math.floor((containerWidth - gap * (columns - 1)) / columns));
    }

    function monitorCardWidth(containerWidth: real): int {
        const gap = Tokens.spacing.normal;
        const columns = containerWidth >= 700 ? 2 : 1;
        return Math.max(220, Math.floor((containerWidth - gap * (columns - 1)) / columns));
    }

    function monitors(): var {
        return Hypr.monitors.values ?? [];
    }

    function monitorData(monitor: var): var {
        return monitor?.lastIpcObject ?? monitor ?? {};
    }

    function currentMonitor(): var {
        const list = monitors();
        if (list.length === 0)
            return null;
        return list[Math.max(0, Math.min(activeMonitorIndex, list.length - 1))];
    }

    function monitorLogicalWidth(data: var): int {
        const transform = data?.transform ?? 0;
        const width = data?.width ?? 1920;
        const height = data?.height ?? 1080;
        return transform % 2 === 1 ? height : width;
    }

    function monitorLogicalHeight(data: var): int {
        const transform = data?.transform ?? 0;
        const width = data?.width ?? 1920;
        const height = data?.height ?? 1080;
        return transform % 2 === 1 ? width : height;
    }

    function monitorBounds(list: var): var {
        let minX = Infinity;
        let minY = Infinity;
        let maxX = -Infinity;
        let maxY = -Infinity;
        for (const monitor of list) {
            const data = monitorData(monitor);
            const x = data.x ?? 0;
            const y = data.y ?? 0;
            const width = monitorLogicalWidth(data);
            const height = monitorLogicalHeight(data);
            minX = Math.min(minX, x);
            minY = Math.min(minY, y);
            maxX = Math.max(maxX, x + width);
            maxY = Math.max(maxY, y + height);
        }
        if (minX === Infinity) {
            return {
                minX: 0,
                minY: 0,
                width: 1920,
                height: 1080
            };
        }
        return {
            minX: minX,
            minY: minY,
            width: maxX - minX,
            height: maxY - minY
        };
    }

    function formatRefresh(rate: var): string {
        const value = Number(rate ?? 0);
        if (value <= 0)
            return qsTr("desconhecido");
        return `${value.toFixed(value >= 100 ? 0 : 2)} Hz`;
    }

    function transformName(transform: int): string {
        return ({
            0: qsTr("normal"),
            1: qsTr("90°"),
            2: qsTr("180°"),
            3: qsTr("270°"),
            4: qsTr("invertido"),
            5: qsTr("invertido 90°"),
            6: qsTr("invertido 180°"),
            7: qsTr("invertido 270°")
        })[transform] ?? qsTr("desconhecido");
    }

    function parseMode(mode: string): var {
        const match = String(mode).match(/^(\d+)x(\d+)@([0-9.]+)Hz$/);
        if (!match)
            return null;
        return {
            resolution: `${match[1]} x ${match[2]}`,
            refresh: `${Number(match[3]).toFixed(Number(match[3]) >= 100 ? 0 : 2)} Hz`,
            raw: mode
        };
    }

    function uniqueModeOptions(modes: var, field: string): var {
        const seen = {};
        const result = [];
        for (const mode of modes ?? []) {
            const parsed = parseMode(mode);
            if (!parsed || seen[parsed[field]])
                continue;
            seen[parsed[field]] = true;
            result.push({
                label: parsed[field],
                value: parsed[field]
            });
        }
        return result;
    }

    function transformOptions(): var {
        return [0, 1, 2, 3].map(value => ({
            label: transformName(value),
            value: value
        }));
    }

    function scaleOptions(): var {
        return [0.75, 1, 1.25, 1.5, 1.75, 2].map(value => ({
            label: `${value}x`,
            value: value
        }));
    }

    function saveMediaGif(path: string): void {
        mediaGif = path;
        GlobalConfig.paths.mediaGif = path;
    }

    function saveSessionGif(path: string): void {
        sessionGif = path;
        GlobalConfig.paths.sessionGif = path;
    }

    anchors.fill: parent
    Component.onCompleted: activateSubpage()

    Connections {
        function onSubpageChanged(): void {
            root.activateSubpage();
        }

        target: root.session
    }

    SplitPaneLayout {
        anchors.fill: parent

        leftWidthRatio: 0.33
        leftMinimumWidth: 300
        leftContent: Component {
            PersonalSidebar {}
        }
        rightContent: Component {
            Loader {
                anchors.fill: parent

                sourceComponent: {
                    const page = root.currentPage();
                    if (page.id === "home")
                        return overviewComponent;
                    if (page.id === "hyprland")
                        return hyprOptionsComponent;
                    if (page.id === "monitors")
                        return monitorsComponent;
                    return placeholderComponent;
                }
            }
        }
    }

    Component {
        id: overviewComponent

        StyledFlickable {
            id: overviewFlickable

            flickableDirection: Flickable.VerticalFlick
            contentHeight: overviewLayout.height

            StyledScrollBar.vertical: StyledScrollBar {
                flickable: overviewFlickable
            }

            ColumnLayout {
                id: overviewLayout

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                spacing: Tokens.spacing.normal

                PageHeader {
                    title: qsTr("Meu Caelestia")
                    icon: "auto_awesome"
                }

                SectionContainer {
                    Layout.fillWidth: true
                    alignTop: true
                    contentSpacing: Tokens.spacing.normal

                    StyledText {
                        text: qsTr("Mídias animadas")
                        font.pointSize: Tokens.font.size.normal
                        font.weight: 500
                    }

                    MediaPathRow {
                        title: qsTr("GIF do dashboard")
                        value: root.mediaGif
                        fallbackValue: root.defaultMediaGif
                        onAccepted: path => root.saveMediaGif(path)
                    }

                    MediaPathRow {
                        title: qsTr("GIF da sessão")
                        value: root.sessionGif
                        fallbackValue: root.defaultSessionGif
                        onAccepted: path => root.saveSessionGif(path)
                    }
                }
            }
        }
    }

    Component {
        id: hyprOptionsComponent

        StyledFlickable {
            id: hyprFlickable

            anchors.fill: parent

            flickableDirection: Flickable.VerticalFlick
            contentHeight: hyprLayout.height

            StyledScrollBar.vertical: StyledScrollBar {
                flickable: hyprFlickable
            }

            ColumnLayout {
                id: hyprLayout

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                spacing: Tokens.spacing.normal

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spacing.normal

                    PageHeader {
                        Layout.fillWidth: true
                        title: qsTr("Hyprland")
                        icon: "tune"
                        compact: true
                    }

                    IconTextButton {
                        icon: "restart_alt"
                        text: qsTr("Resetar")
                        type: IconTextButton.Text
                        onClicked: HyprConfig.resetDefaults()
                    }
                }

                Flow {
                    id: hyprCategoryFlow

                    Layout.fillWidth: true
                    Layout.preferredHeight: childrenRect.height
                    spacing: Tokens.spacing.small

                    Repeater {
                        model: HyprConfig.optionGroups

                        NavPill {
                            required property int index
                            required property var modelData

                            width: root.categoryPillWidth(hyprCategoryFlow.width)
                            height: implicitHeight
                            icon: root.groupIcon(modelData)
                            label: modelData.label
                            active: root.activeHyprGroupIndex === index
                            trailing: root.optionCount(modelData).toString()
                            onSelected: root.activeHyprGroupIndex = index
                        }
                    }
                }

                PageHeader {
                    Layout.fillWidth: true
                    title: root.currentHyprGroup()?.label ?? qsTr("Hyprland")
                    icon: "settings"
                    compact: true
                }

                HyprGroup {
                    group: root.currentHyprGroup()
                }
            }
        }
    }

    Component {
        id: placeholderComponent

        Item {
            ColumnLayout {
                anchors.centerIn: parent
                spacing: Tokens.spacing.normal

                MaterialIcon {
                    Layout.alignment: Qt.AlignHCenter
                    text: root.currentPage().icon
                    color: Colours.palette.m3primary
                    font.pointSize: Tokens.font.size.extraLarge
                    fill: 1
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: root.currentPage().label
                    font.pointSize: Tokens.font.size.large
                    font.weight: 500
                }
            }
        }
    }

    Component {
        id: monitorsComponent

        StyledFlickable {
            id: monitorFlickable

            anchors.fill: parent

            flickableDirection: Flickable.VerticalFlick
            contentHeight: monitorLayout.height

            StyledScrollBar.vertical: StyledScrollBar {
                flickable: monitorFlickable
            }

            ColumnLayout {
                id: monitorLayout

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                spacing: Tokens.spacing.normal

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spacing.normal

                    PageHeader {
                        Layout.fillWidth: true
                        title: qsTr("Monitores")
                        icon: "display_settings"
                        compact: true
                    }

                    IconTextButton {
                        icon: "refresh"
                        text: qsTr("Atualizar")
                        type: IconTextButton.Text
                        onClicked: Hypr.refreshMonitors()
                    }
                }

                MonitorCanvas {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 260
                }

                Flow {
                    id: monitorCardFlow

                    Layout.fillWidth: true
                    Layout.preferredHeight: childrenRect.height
                    spacing: Tokens.spacing.normal

                    Repeater {
                        model: root.monitors()

                        MonitorCard {
                            required property int index
                            required property var modelData

                            width: root.monitorCardWidth(monitorCardFlow.width)
                            monitor: modelData
                            selected: root.currentMonitor()?.name === modelData.name
                            onPicked: root.activeMonitorIndex = index
                        }
                    }
                }
            }
        }
    }

    component PersonalSidebar: StyledFlickable {
        id: sidebar

        flickableDirection: Flickable.VerticalFlick
        contentHeight: sidebarLayout.height

        StyledScrollBar.vertical: StyledScrollBar {
            flickable: sidebar
        }

        ColumnLayout {
            id: sidebarLayout

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            spacing: Tokens.spacing.normal

            PageHeader {
                Layout.fillWidth: true
                title: qsTr("Meu Caelestia")
                icon: "auto_awesome"
            }

            Repeater {
                model: root.pages

                NavPill {
                    required property int index
                    required property var modelData

                    Layout.fillWidth: true
                    icon: modelData.icon
                    label: modelData.label
                    active: root.activePageIndex === index
                    onSelected: root.activePageIndex = index
                }
            }
        }
    }

    component PageHeader: RowLayout {
        id: pageHeader

        required property string title
        required property string icon
        property bool compact

        spacing: Tokens.spacing.small

        MaterialIcon {
            text: pageHeader.icon
            color: Colours.palette.m3primary
            font.pointSize: pageHeader.compact ? Tokens.font.size.large : Tokens.font.size.extraLarge
            fill: 1
        }

        StyledText {
            Layout.fillWidth: true
            text: pageHeader.title
            font.pointSize: pageHeader.compact ? Tokens.font.size.normal : Tokens.font.size.large
            font.weight: 600
        }
    }

    component NavPill: StyledRect {
        id: navPill

        required property string icon
        required property string label
        property bool active
        property string trailing: ""

        signal selected

        implicitHeight: navRow.implicitHeight + Tokens.padding.normal * 2
        radius: Tokens.rounding.normal
        color: Qt.alpha(Colours.palette.m3secondaryContainer, active ? 1 : 0)

        StateLayer {
            color: navPill.active ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurface
            onClicked: navPill.selected()
        }

        RowLayout {
            id: navRow

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: Tokens.padding.normal
            spacing: Tokens.spacing.small

            MaterialIcon {
                text: navPill.icon
                color: navPill.active ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurfaceVariant
                font.pointSize: Tokens.font.size.large
                fill: navPill.active ? 1 : 0
            }

            StyledText {
                Layout.fillWidth: true
                text: navPill.label
                color: navPill.active ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurface
                elide: Text.ElideRight
            }

            StyledText {
                visible: navPill.trailing.length > 0
                text: navPill.trailing
                color: navPill.active ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3outline
                font.pointSize: Tokens.font.size.small
            }
        }

        Behavior on color {
            CAnim {}
        }
    }

    component MonitorCanvas: StyledRect {
        id: canvasRoot

        readonly property var monitorList: root.monitors()

        radius: Tokens.rounding.normal
        color: Colours.layer(Colours.palette.m3surfaceContainer, 1)
        border.color: Qt.alpha(Colours.palette.m3outline, 0.22)
        border.width: 1

        Item {
            id: monitorViewport

            readonly property var bounds: root.monitorBounds(canvasRoot.monitorList)
            readonly property real scaleFactor: {
                const availableWidth = Math.max(1, width - Tokens.padding.large * 2);
                const availableHeight = Math.max(1, height - Tokens.padding.large * 2);
                return Math.min(availableWidth / bounds.width, availableHeight / bounds.height);
            }
            readonly property point offset: Qt.point((width - bounds.width * scaleFactor) / 2 - bounds.minX * scaleFactor, (height - bounds.height * scaleFactor) / 2 - bounds.minY * scaleFactor)

            anchors.fill: parent
            anchors.margins: Tokens.padding.large

            Repeater {
                model: canvasRoot.monitorList

                MonitorTile {
                    required property int index
                    required property var modelData

                    monitor: modelData
                    selected: root.currentMonitor()?.name === modelData.name
                    canvasScale: monitorViewport.scaleFactor
                    canvasOffset: monitorViewport.offset
                    onPicked: root.activeMonitorIndex = index
                }
            }
        }
    }

    component MonitorTile: StyledRect {
        id: monitorTile

        required property var monitor
        required property real canvasScale
        required property point canvasOffset
        property bool selected
        readonly property var monitorInfo: root.monitorData(monitor)

        signal picked

        x: (monitorInfo.x ?? 0) * canvasScale + canvasOffset.x
        y: (monitorInfo.y ?? 0) * canvasScale + canvasOffset.y
        width: Math.max(96, root.monitorLogicalWidth(monitorInfo) * canvasScale)
        height: Math.max(64, root.monitorLogicalHeight(monitorInfo) * canvasScale)
        radius: Tokens.rounding.small
        color: Qt.alpha(Colours.palette.m3primaryContainer, selected ? 0.9 : hoverHandler.hovered ? 0.55 : 0.34)
        border.color: selected ? Colours.palette.m3primary : Qt.alpha(Colours.palette.m3outline, 0.45)
        border.width: selected ? 2 : 1

        HoverHandler {
            id: hoverHandler
        }

        StateLayer {
            color: Colours.palette.m3onSurface
            onClicked: monitorTile.picked()
        }

        ColumnLayout {
            anchors.centerIn: parent
            width: Math.max(1, parent.width - Tokens.padding.large)
            spacing: Tokens.spacing.small

            MaterialIcon {
                Layout.alignment: Qt.AlignHCenter
                text: "desktop_windows"
                color: Colours.palette.m3primary
                font.pointSize: Tokens.font.size.large
                fill: selected ? 1 : 0
            }

            StyledText {
                Layout.fillWidth: true
                text: monitor.name ?? monitorInfo.name ?? qsTr("Monitor")
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideMiddle
                font.weight: 600
            }

            StyledText {
                Layout.fillWidth: true
                text: `${root.monitorLogicalWidth(monitorInfo)}x${root.monitorLogicalHeight(monitorInfo)}`
                color: Colours.palette.m3outline
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: Tokens.font.size.small
                elide: Text.ElideRight
            }
        }
    }

    component MonitorCard: SectionContainer {
        id: monitorCard

        required property var monitor
        property bool selected
        property string activeOption: ""
        readonly property var monitorInfo: root.monitorData(monitor)

        signal picked

        function optionTitle(): string {
            return ({
                resolution: qsTr("Resolução"),
                refresh: qsTr("Taxa de atualização"),
                scale: qsTr("Escala"),
                transform: qsTr("Orientação"),
                workspace: qsTr("Workspace ativo"),
                vrr: qsTr("VRR")
            })[activeOption] ?? "";
        }

        function optionItems(): var {
            if (activeOption === "resolution")
                return root.uniqueModeOptions(monitorInfo.availableModes, "resolution");
            if (activeOption === "refresh")
                return root.uniqueModeOptions(monitorInfo.availableModes, "refresh");
            if (activeOption === "scale")
                return root.scaleOptions();
            if (activeOption === "transform")
                return root.transformOptions();
            if (activeOption === "workspace")
                return [{
                    label: monitorInfo.activeWorkspace?.name ? qsTr("Workspace %1").arg(monitorInfo.activeWorkspace.name) : qsTr("Sem workspace"),
                    value: monitorInfo.activeWorkspace?.name ?? ""
                }];
            if (activeOption === "vrr")
                return [{
                    label: qsTr("Ligado"),
                    value: true
                }, {
                    label: qsTr("Desligado"),
                    value: false
                }];
            return [];
        }

        function isCurrentOption(value: var): bool {
            if (activeOption === "resolution")
                return value === `${root.monitorLogicalWidth(monitorInfo)} x ${root.monitorLogicalHeight(monitorInfo)}`;
            if (activeOption === "refresh")
                return value === root.formatRefresh(monitorInfo.refreshRate);
            if (activeOption === "scale")
                return Number(value) === Number(monitorInfo.scale ?? 1);
            if (activeOption === "transform")
                return Number(value) === Number(monitorInfo.transform ?? 0);
            if (activeOption === "workspace")
                return value === (monitorInfo.activeWorkspace?.name ?? "");
            if (activeOption === "vrr")
                return Boolean(value) === Boolean(monitorInfo.vrr);
            return false;
        }

        function toggleOption(option: string): void {
            activeOption = activeOption === option ? "" : option;
            monitorCard.picked();
        }

        contentSpacing: Tokens.spacing.normal
        alignTop: true

        TapHandler {
            onTapped: monitorCard.picked()
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.normal

            MaterialIcon {
                text: monitorInfo.focused ? "filter_center_focus" : "desktop_windows"
                color: selected ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
                font.pointSize: Tokens.font.size.large
                fill: selected || monitorInfo.focused ? 1 : 0
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                StyledText {
                    Layout.fillWidth: true
                    text: monitor.name ?? monitorInfo.name ?? qsTr("Monitor")
                    font.pointSize: Tokens.font.size.normal
                    font.weight: 600
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    text: monitorInfo.description ?? monitorInfo.model ?? qsTr("Sem descrição")
                    color: Colours.palette.m3outline
                    font.pointSize: Tokens.font.size.small
                    elide: Text.ElideRight
                }
            }
        }

        Flow {
            Layout.fillWidth: true
            Layout.preferredHeight: childrenRect.height
            spacing: Tokens.spacing.small

            StatusChip {
                icon: "straighten"
                active: monitorCard.activeOption === "resolution"
                text: `${root.monitorLogicalWidth(monitorInfo)} x ${root.monitorLogicalHeight(monitorInfo)}`
                onClicked: monitorCard.toggleOption("resolution")
            }

            StatusChip {
                icon: "speed"
                active: monitorCard.activeOption === "refresh"
                text: root.formatRefresh(monitorInfo.refreshRate)
                onClicked: monitorCard.toggleOption("refresh")
            }

            StatusChip {
                icon: "zoom_out_map"
                active: monitorCard.activeOption === "scale"
                text: `${monitorInfo.scale ?? 1}x`
                onClicked: monitorCard.toggleOption("scale")
            }

            StatusChip {
                icon: "screen_rotation"
                active: monitorCard.activeOption === "transform"
                text: root.transformName(monitorInfo.transform ?? 0)
                onClicked: monitorCard.toggleOption("transform")
            }

            StatusChip {
                icon: "workspaces"
                active: monitorCard.activeOption === "workspace"
                text: monitorInfo.activeWorkspace?.name ? qsTr("ws %1").arg(monitorInfo.activeWorkspace.name) : qsTr("sem workspace")
                onClicked: monitorCard.toggleOption("workspace")
            }

            StatusChip {
                active: monitorCard.activeOption === "vrr"
                icon: monitorInfo.vrr ? "sync" : "sync_disabled"
                text: monitorInfo.vrr ? qsTr("VRR") : qsTr("sem VRR")
                onClicked: monitorCard.toggleOption("vrr")
            }
        }

        MonitorOptionTray {
            Layout.fillWidth: true
            title: monitorCard.optionTitle()
            items: monitorCard.optionItems()
            visible: monitorCard.activeOption !== ""
            currentTest: value => monitorCard.isCurrentOption(value)
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.small

            MonitorMetric {
                label: qsTr("Posição")
                value: `${monitorInfo.x ?? 0}, ${monitorInfo.y ?? 0}`
            }

            MonitorMetric {
                label: qsTr("Formato")
                value: monitorInfo.currentFormat ?? qsTr("desconhecido")
            }

            MonitorMetric {
                label: qsTr("Modos")
                value: qsTr("%1 disponíveis").arg(monitorInfo.availableModes?.length ?? 0)
            }
        }
    }

    component StatusChip: StyledRect {
        id: statusChip

        required property string icon
        required property string text
        property bool active

        signal clicked

        implicitWidth: chipRow.implicitWidth + Tokens.padding.normal * 2
        implicitHeight: chipRow.implicitHeight + Tokens.padding.small * 2
        radius: Tokens.rounding.full
        color: active ? Qt.alpha(Colours.palette.m3primaryContainer, 0.92) : hoverHandler.hovered ? Colours.layer(Colours.palette.m3surfaceContainer, 3) : Colours.layer(Colours.palette.m3surfaceContainer, 2)

        HoverHandler {
            id: hoverHandler

            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            onTapped: statusChip.clicked()
        }

        RowLayout {
            id: chipRow

            anchors.centerIn: parent
            spacing: Tokens.spacing.small

            MaterialIcon {
                text: statusChip.icon
                color: statusChip.active ? Colours.palette.m3onPrimaryContainer : Colours.palette.m3primary
                font.pointSize: Tokens.font.size.small
            }

            StyledText {
                text: statusChip.text
                color: statusChip.active ? Colours.palette.m3onPrimaryContainer : Colours.palette.m3onSurfaceVariant
                font.pointSize: Tokens.font.size.small
            }
        }

        Behavior on color {
            CAnim {}
        }
    }

    component MonitorOptionTray: StyledRect {
        id: optionTray

        required property string title
        property var items: []
        property var currentTest: null

        function isCurrent(value: var): bool {
            return currentTest ? currentTest(value) : false;
        }

        implicitHeight: optionTrayLayout.implicitHeight + Tokens.padding.normal * 2
        radius: Tokens.rounding.normal
        color: Colours.layer(Colours.palette.m3surfaceContainer, 3)

        ColumnLayout {
            id: optionTrayLayout

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: Tokens.padding.normal
            spacing: Tokens.spacing.small

            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spacing.small

                MaterialIcon {
                    text: "tune"
                    color: Colours.palette.m3primary
                    font.pointSize: Tokens.font.size.small
                }

                StyledText {
                    Layout.fillWidth: true
                    text: optionTray.title
                    font.pointSize: Tokens.font.size.small
                    font.weight: 600
                }
            }

            Flow {
                Layout.fillWidth: true
                Layout.preferredHeight: childrenRect.height
                spacing: Tokens.spacing.small

                Repeater {
                    model: optionTray.items

                    TextButton {
                        required property var modelData

                        text: modelData.label
                        checked: optionTray.isCurrent(modelData.value)
                        toggle: false
                        type: checked ? TextButton.Filled : TextButton.Tonal
                    }
                }
            }
        }
    }

    component MonitorMetric: RowLayout {
        required property string label
        required property string value

        spacing: Tokens.spacing.normal

        StyledText {
            Layout.fillWidth: true
            text: label
            color: Colours.palette.m3outline
            font.pointSize: Tokens.font.size.small
        }

        StyledText {
            text: value
            horizontalAlignment: Text.AlignRight
            font.pointSize: Tokens.font.size.small
            elide: Text.ElideLeft
        }
    }

    component MediaPathRow: SectionContainer {
        id: rowRoot

        required property string title
        required property string value
        required property string fallbackValue

        signal accepted(string path)

        contentSpacing: Tokens.spacing.normal

        RowLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.normal

            StyledRect {
                Layout.preferredWidth: 84
                Layout.preferredHeight: 64

                radius: Tokens.rounding.small
                color: Colours.layer(Colours.palette.m3surfaceContainer, 2)
                clip: true

                AnimatedImage {
                    anchors.fill: parent
                    anchors.margins: Tokens.padding.small

                    source: Paths.absolutePath(rowRoot.value)
                    fillMode: Image.PreserveAspectFit
                    playing: true
                    cache: false
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Tokens.spacing.small

                StyledText {
                    text: rowRoot.title
                    font.pointSize: Tokens.font.size.normal
                    font.weight: 500
                }

                StyledInputField {
                    Layout.fillWidth: true

                    text: rowRoot.value
                    horizontalAlignment: TextInput.AlignLeft
                    onEditingFinished: rowRoot.accepted(text)
                }
            }

            IconTextButton {
                icon: "folder_open"
                text: qsTr("Escolher")
                type: IconTextButton.Tonal
                onClicked: picker.open()
            }

            IconTextButton {
                icon: "restart_alt"
                text: qsTr("Resetar")
                type: IconTextButton.Text
                onClicked: rowRoot.accepted(rowRoot.fallbackValue)
            }
        }

        FileDialog {
            id: picker

            title: qsTr("Selecionar GIF")
            filterLabel: qsTr("GIFs")
            filters: ["gif", "webp"]
            onAccepted: path => rowRoot.accepted(path)
        }
    }

    component HyprGroup: ColumnLayout {
        required property var group

        Layout.fillWidth: true
        spacing: Tokens.spacing.small

        StyledText {
            text: group.label
            color: Colours.palette.m3primary
            font.pointSize: Tokens.font.size.normal
            font.weight: 500
        }

        Repeater {
            model: group.sections

            ColumnLayout {
                required property var modelData

                Layout.fillWidth: true
                spacing: Tokens.spacing.small

                StyledText {
                    text: modelData.label
                    color: Colours.palette.m3outline
                    font.pointSize: Tokens.font.size.small
                }

                Repeater {
                    model: modelData.options

                    HyprOptionRow {
                        required property var modelData

                        option: modelData
                    }
                }
            }
        }
    }

    component HyprOptionRow: Loader {
        id: optionLoader

        required property var option

        function optionComponent(): Component {
            if (option.type === "bool")
                return boolOptionComponent;
            if (option.type === "int" || option.type === "float")
                return sliderOptionComponent;
            if (option.type === "choice")
                return choiceOptionComponent;
            return textOptionComponent;
        }

        Layout.fillWidth: true
        active: HyprConfig.enabledFor(option)
        sourceComponent: optionComponent()

        Component {
            id: boolOptionComponent

            SwitchRow {
                label: optionLoader.option.label
                checked: HyprConfig.valueFor(optionLoader.option.key)
                onToggled: checked => HyprConfig.setOption(optionLoader.option.key, checked)
            }
        }

        Component {
            id: sliderOptionComponent

            SliderInput {
                Layout.fillWidth: true

                property real currentValue: 0

                function refreshValue(): void {
                    const nextValue = Number(HyprConfig.valueFor(optionLoader.option.key));
                    if (currentValue !== nextValue)
                        currentValue = nextValue;
                }

                label: optionLoader.option.label
                value: currentValue
                from: optionLoader.option.min
                to: optionLoader.option.max
                stepSize: optionLoader.option.step
                suffix: optionLoader.option.suffix ?? ""
                decimals: optionLoader.option.type === "float" ? 2 : 0
                validator: optionLoader.option.type === "float" ? doubleValidator : intValidator
                formatValueFunction: val => optionLoader.option.type === "float" ? Number(val).toFixed(2) : Math.round(val).toString()
                parseValueFunction: text => optionLoader.option.type === "float" ? parseFloat(text) : parseInt(text)
                onValueModified: newValue => {
                    currentValue = newValue;
                    HyprConfig.setOption(optionLoader.option.key, newValue);
                }
                Component.onCompleted: refreshValue()

                IntValidator {
                    id: intValidator

                    bottom: optionLoader.option.min
                    top: optionLoader.option.max
                }

                Connections {
                    function onRevisionChanged(): void {
                        refreshValue();
                    }

                    target: HyprConfig
                }

                DoubleValidator {
                    id: doubleValidator

                    bottom: optionLoader.option.min
                    top: optionLoader.option.max
                    decimals: 2
                }
            }
        }

        Component {
            id: choiceOptionComponent

            SectionContainer {
                Layout.fillWidth: true
                contentSpacing: Tokens.spacing.small

                StyledText {
                    text: optionLoader.option.label
                    font.pointSize: Tokens.font.size.normal
                    font.weight: 500
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spacing.small

                    Repeater {
                        model: optionLoader.option.values ?? []

                        TextButton {
                            required property int index
                            required property var modelData

                            function optionId(): string {
                                if (modelData.id !== undefined)
                                    return String(modelData.id);
                                return String(index);
                            }

                            Layout.fillWidth: true
                            text: modelData.label ?? optionId()
                            checked: String(HyprConfig.valueFor(optionLoader.option.key)) === optionId()
                            toggle: false
                            type: TextButton.Tonal
                            onClicked: HyprConfig.setOption(optionLoader.option.key, optionId())
                        }
                    }
                }
            }
        }

        Component {
            id: textOptionComponent

            StyledRect {
                Layout.fillWidth: true
                implicitHeight: row.implicitHeight + Tokens.padding.large * 2
                radius: Tokens.rounding.normal
                color: Colours.layer(Colours.palette.m3surfaceContainer, 2)

                RowLayout {
                    id: row

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: Tokens.padding.large
                    spacing: Tokens.spacing.normal

                    StyledText {
                        Layout.fillWidth: true
                        text: optionLoader.option.label
                    }

                    StyledInputField {
                        Layout.preferredWidth: Math.min(260, Math.max(120, row.width * 0.42))

                        text: String(HyprConfig.valueFor(optionLoader.option.key) ?? "")
                        horizontalAlignment: TextInput.AlignLeft
                        onEditingFinished: HyprConfig.setOption(optionLoader.option.key, text)
                    }
                }
            }
        }
    }
}
