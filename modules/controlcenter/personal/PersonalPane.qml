pragma ComponentBehavior: Bound

import ".."
import "../components"
import "binds"
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

    function captureMonitorState(): void {
        MonitorConfig.captureOriginalState(monitors());
    }

    function vrrLabel(vrrValue: int): string {
        if (vrrValue === 1)
            return qsTr("VRR ativo");
        if (vrrValue === 2)
            return qsTr("VRR fullscreen");
        return qsTr("VRR desativado");
    }

    function vrrOptions(): var {
        return [
            { label: qsTr("Ativar VRR"), value: 1 },
            { label: qsTr("Apenas fullscreen"), value: 2 },
            { label: qsTr("Desativar VRR"), value: 0 }
        ];
    }

    function positionOptions(): var {
        return [
            { label: qsTr("À direita"), value: "right" },
            { label: qsTr("À esquerda"), value: "left" },
            { label: qsTr("Acima"), value: "above" },
            { label: qsTr("Abaixo"), value: "below" }
        ];
    }

    function positionLabel(pos: string): string {
        return ({
            right: qsTr("À direita"),
            left: qsTr("À esquerda"),
            above: qsTr("Acima"),
            below: qsTr("Abaixo")
        })[pos] ?? qsTr("Posição");
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
                    if (page.id === "binds")
                        return bindsComponent;
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

        Item {
            id: monitorsRoot

            anchors.fill: parent

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
                            onClicked: {
                                Hypr.refreshMonitors();
                                root.captureMonitorState();
                            }
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

                Component.onCompleted: root.captureMonitorState()
            }

            // ─── Popup overlay backdrop ────────────────────────────────
            Rectangle {
                anchors.fill: parent
                color: Qt.alpha(Colours.palette.m3scrim, 0.45)
                visible: opacity > 0
                opacity: MonitorConfig.hasPending || MonitorConfig.isPreviewing ? 1 : 0
                z: 10

                Behavior on opacity {
                    NumberAnimation {
                        duration: Tokens.anim.durations.normal
                        easing.type: Easing.OutCubic
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {}
                }
            }

            // ─── Action bar popup (pending changes) ────────────────────
            MonitorActionBar {
                anchors.centerIn: parent
                width: Math.min(parent.width - Tokens.padding.large * 4, 420)
                visible: MonitorConfig.hasPending && !MonitorConfig.isPreviewing
                z: 11
                scale: visible ? 1.0 : 0.92

                Behavior on scale {
                    NumberAnimation {
                        duration: Tokens.anim.durations.normal
                        easing.type: Easing.OutBack
                    }
                }
            }

            // ─── Confirm overlay popup (preview active) ────────────────
            MonitorConfirmOverlay {
                anchors.centerIn: parent
                width: Math.min(parent.width - Tokens.padding.large * 4, 460)
                visible: MonitorConfig.isPreviewing
                z: 11
                scale: visible ? 1.0 : 0.92

                Behavior on scale {
                    NumberAnimation {
                        duration: Tokens.anim.durations.normal
                        easing.type: Easing.OutBack
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
        property bool anyDragging: false

        radius: Tokens.rounding.normal
        color: Colours.layer(Colours.palette.m3surfaceContainer, 1)
        border.color: Qt.alpha(Colours.palette.m3outline, 0.22)
        border.width: 1
        clip: true

        // Recalculate bounds considering pending positions
        function effectiveBounds(): var {
            MonitorConfig.revision;
            let minX = Infinity;
            let minY = Infinity;
            let maxX = -Infinity;
            let maxY = -Infinity;
            for (const monitor of monitorList) {
                const name = monitor?.name ?? root.monitorData(monitor)?.name ?? "";
                const pos = MonitorConfig.getMonitorPosition(name);
                const size = MonitorConfig.getLogicalSize(name);
                // Fall back to live data if service has no data yet
                const x = pos?.x ?? (root.monitorData(monitor)?.x ?? 0);
                const y = pos?.y ?? (root.monitorData(monitor)?.y ?? 0);
                const w = size?.w ?? root.monitorLogicalWidth(root.monitorData(monitor));
                const h = size?.h ?? root.monitorLogicalHeight(root.monitorData(monitor));
                minX = Math.min(minX, x);
                minY = Math.min(minY, y);
                maxX = Math.max(maxX, x + w);
                maxY = Math.max(maxY, y + h);
            }
            if (minX === Infinity) {
                return { minX: 0, minY: 0, width: 1920, height: 1080 };
            }
            return { minX: minX, minY: minY, width: maxX - minX, height: maxY - minY };
        }

        Item {
            id: monitorViewport

            readonly property var bounds: canvasRoot.effectiveBounds()
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
                    canvasParent: canvasRoot
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
        property StyledRect canvasParent: null
        property bool selected
        readonly property var monitorInfo: root.monitorData(monitor)
        readonly property string monName: monitor.name ?? monitorInfo.name ?? ""

        // Drag state
        property bool isDragging: false
        property point originalLogical: Qt.point(0, 0)
        property point snappedLogical: Qt.point(0, 0)
        property bool isValidPosition: true

        signal picked

        // Rest position: where the tile sits when not being dragged
        readonly property real restX: {
            MonitorConfig.revision;
            const pos = MonitorConfig.getMonitorPosition(monName);
            return (pos?.x ?? (monitorInfo.x ?? 0)) * canvasScale + canvasOffset.x;
        }
        readonly property real restY: {
            MonitorConfig.revision;
            const pos = MonitorConfig.getMonitorPosition(monName);
            return (pos?.y ?? (monitorInfo.y ?? 0)) * canvasScale + canvasOffset.y;
        }

        // Bind x/y to rest position only when not dragging
        onRestXChanged: if (!isDragging) x = restX
        onRestYChanged: if (!isDragging) y = restY
        Component.onCompleted: { x = restX; y = restY; }
        width: Math.max(96, root.monitorLogicalWidth(monitorInfo) * canvasScale)
        height: Math.max(64, root.monitorLogicalHeight(monitorInfo) * canvasScale)
        radius: Tokens.rounding.small
        color: {
            if (!isValidPosition)
                return Qt.alpha(Colours.palette.m3errorContainer, 0.65);
            if (isDragging)
                return Qt.alpha(Colours.palette.m3primaryContainer, 0.95);
            return Qt.alpha(Colours.palette.m3primaryContainer, selected ? 0.9 : dragArea.containsMouse ? 0.55 : 0.34);
        }
        border.color: {
            if (!isValidPosition)
                return Colours.palette.m3error;
            if (isDragging)
                return Colours.palette.m3primary;
            return selected ? Colours.palette.m3primary : Qt.alpha(Colours.palette.m3outline, 0.45);
        }
        border.width: isDragging ? 3 : selected ? 2 : 1
        z: isDragging ? 100 : (selected ? 2 : 1)

        Behavior on color {
            CAnim {}
        }

        // Snap preview ghost — shows where monitor will land
        Rectangle {
            id: snapPreview
            visible: monitorTile.isDragging && monitorTile.isValidPosition
            x: monitorTile.snappedLogical.x * monitorTile.canvasScale + monitorTile.canvasOffset.x - monitorTile.x
            y: monitorTile.snappedLogical.y * monitorTile.canvasScale + monitorTile.canvasOffset.y - monitorTile.y
            width: parent.width
            height: parent.height
            radius: Tokens.rounding.small
            color: "transparent"
            border.color: Colours.palette.m3primary
            border.width: 2
            opacity: 0.55
        }

        MouseArea {
            id: dragArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: monitorTile.isDragging ? Qt.ClosedHandCursor : (root.monitors().length > 1 ? Qt.OpenHandCursor : Qt.PointingHandCursor)
            drag.target: root.monitors().length > 1 ? monitorTile : null
            drag.axis: Drag.XAndYAxis
            drag.threshold: 0

            onPressed: mouse => {
                monitorTile.picked();
                if (root.monitors().length <= 1) return;
                monitorTile.isDragging = true;
                if (canvasParent) canvasParent.anyDragging = true;
                const pos = MonitorConfig.getMonitorPosition(monitorTile.monName);
                monitorTile.originalLogical = Qt.point(pos.x, pos.y);
                monitorTile.snappedLogical = monitorTile.originalLogical;
                monitorTile.isValidPosition = true;
            }

            onPositionChanged: mouse => {
                if (!monitorTile.isDragging) return;
                // Convert pixel position back to logical coordinates
                const logX = Math.round((monitorTile.x - monitorTile.canvasOffset.x) / monitorTile.canvasScale);
                const logY = Math.round((monitorTile.y - monitorTile.canvasOffset.y) / monitorTile.canvasScale);
                const size = MonitorConfig.getLogicalSize(monitorTile.monName);
                const snapped = MonitorConfig.snapToEdges(monitorTile.monName, logX, logY, size.w, size.h);
                monitorTile.snappedLogical = Qt.point(snapped.x, snapped.y);
                monitorTile.isValidPosition = !MonitorConfig.checkOverlap(monitorTile.monName, snapped.x, snapped.y, size.w, size.h);
            }

            onReleased: {
                if (!monitorTile.isDragging) return;
                monitorTile.isDragging = false;
                if (canvasParent) canvasParent.anyDragging = false;

                if (root.monitors().length <= 1) return;

                const finalX = monitorTile.snappedLogical.x;
                const finalY = monitorTile.snappedLogical.y;

                // Check overlap at final position — if overlapping, revert
                const size = MonitorConfig.getLogicalSize(monitorTile.monName);
                if (MonitorConfig.checkOverlap(monitorTile.monName, finalX, finalY, size.w, size.h)) {
                    monitorTile.isValidPosition = true;
                    return;
                }

                // Only commit if position actually changed
                if (finalX === monitorTile.originalLogical.x && finalY === monitorTile.originalLogical.y)
                    return;

                MonitorConfig.setDragPosition(monitorTile.monName, finalX, finalY);
            }

            onClicked: {
                if (!monitorTile.isDragging)
                    monitorTile.picked();
            }
        }

        ColumnLayout {
            anchors.centerIn: parent
            width: Math.max(1, parent.width - Tokens.padding.large)
            spacing: Tokens.spacing.small

            MaterialIcon {
                Layout.alignment: Qt.AlignHCenter
                text: "desktop_windows"
                color: isDragging ? Colours.palette.m3primary : (isValidPosition ? Colours.palette.m3primary : Colours.palette.m3error)
                font.pointSize: Tokens.font.size.large
                fill: selected || isDragging ? 1 : 0
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
                vrr: qsTr("VRR"),
                position: qsTr("Posição relativa ao principal")
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
                return root.vrrOptions();
            if (activeOption === "position")
                return root.positionOptions();
            return [];
        }

        readonly property string monName: monitor.name ?? monitorInfo.name ?? ""

        function effectiveRes(): string {
            const pending = MonitorConfig.pendingValueFor(monName, "resolution");
            return pending ?? `${root.monitorLogicalWidth(monitorInfo)} x ${root.monitorLogicalHeight(monitorInfo)}`;
        }

        function effectiveRefresh(): string {
            const pending = MonitorConfig.pendingValueFor(monName, "refresh");
            return pending ?? root.formatRefresh(monitorInfo.refreshRate);
        }

        function effectiveScale(): var {
            const pending = MonitorConfig.pendingValueFor(monName, "scale");
            return pending ?? (monitorInfo.scale ?? 1);
        }

        function effectiveTransform(): int {
            const pending = MonitorConfig.pendingValueFor(monName, "transform");
            return pending !== null ? Number(pending) : (monitorInfo.transform ?? 0);
        }

        function effectiveVrr(): int {
            const pending = MonitorConfig.pendingValueFor(monName, "vrr");
            return pending !== null ? Number(pending) : (monitorInfo.vrr ?? 0);
        }

        function effectivePosition(): string {
            const pending = MonitorConfig.pendingValueFor(monName, "relativePosition");
            return pending ?? "";
        }

        function isCurrentOption(value: var): bool {
            MonitorConfig.revision;
            if (activeOption === "resolution")
                return value === effectiveRes();
            if (activeOption === "refresh")
                return value === effectiveRefresh();
            if (activeOption === "scale")
                return Number(value) === Number(effectiveScale());
            if (activeOption === "transform")
                return Number(value) === effectiveTransform();
            if (activeOption === "workspace")
                return value === (monitorInfo.activeWorkspace?.name ?? "");
            if (activeOption === "vrr")
                return Number(value) === effectiveVrr();
            if (activeOption === "position")
                return value === effectivePosition();
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
                pending: MonitorConfig.hasPendingFor(monitorCard.monName, "resolution")
                text: monitorCard.effectiveRes()
                onClicked: monitorCard.toggleOption("resolution")
            }

            StatusChip {
                icon: "speed"
                active: monitorCard.activeOption === "refresh"
                pending: MonitorConfig.hasPendingFor(monitorCard.monName, "refresh")
                text: monitorCard.effectiveRefresh()
                onClicked: monitorCard.toggleOption("refresh")
            }

            StatusChip {
                icon: "zoom_out_map"
                active: monitorCard.activeOption === "scale"
                pending: MonitorConfig.hasPendingFor(monitorCard.monName, "scale")
                text: `${monitorCard.effectiveScale()}x`
                onClicked: monitorCard.toggleOption("scale")
            }

            StatusChip {
                icon: "screen_rotation"
                active: monitorCard.activeOption === "transform"
                pending: MonitorConfig.hasPendingFor(monitorCard.monName, "transform")
                text: root.transformName(monitorCard.effectiveTransform())
                onClicked: monitorCard.toggleOption("transform")
            }

            StatusChip {
                icon: "workspaces"
                active: monitorCard.activeOption === "workspace"
                text: monitorInfo.activeWorkspace?.name ? qsTr("ws %1").arg(monitorInfo.activeWorkspace.name) : qsTr("sem workspace")
                onClicked: monitorCard.toggleOption("workspace")
            }

            StatusChip {
                visible: root.monitors().length > 1 && MonitorConfig.primaryMonitor !== monitorCard.monName
                icon: monitorCard.effectivePosition() ? "swap_horiz" : "open_with"
                active: monitorCard.activeOption === "position"
                pending: MonitorConfig.hasPendingFor(monitorCard.monName, "relativePosition")
                text: monitorCard.effectivePosition() ? root.positionLabel(monitorCard.effectivePosition()) : qsTr("Posição")
                onClicked: monitorCard.toggleOption("position")
            }

            StatusChip {
                active: monitorCard.activeOption === "vrr"
                pending: MonitorConfig.hasPendingFor(monitorCard.monName, "vrr")
                icon: monitorCard.effectiveVrr() === 1 ? "sync" : monitorCard.effectiveVrr() === 2 ? "sync_lock" : "sync_disabled"
                text: root.vrrLabel(monitorCard.effectiveVrr())
                accentColor: monitorCard.effectiveVrr() === 1 ? Colours.palette.m3primary : monitorCard.effectiveVrr() === 2 ? Colours.palette.m3tertiary : Colours.palette.m3outline
                onClicked: monitorCard.toggleOption("vrr")
            }

            StatusChip {
                visible: root.monitors().length > 1
                icon: MonitorConfig.primaryMonitor === monitorCard.monName ? "star" : "star_outline"
                active: MonitorConfig.primaryMonitor === monitorCard.monName
                text: MonitorConfig.primaryMonitor === monitorCard.monName ? qsTr("Principal") : qsTr("Definir principal")
                accentColor: Colours.palette.m3tertiary
                onClicked: MonitorConfig.setPrimaryMonitor(monitorCard.monName)
            }
        }

        MonitorOptionTray {
            Layout.fillWidth: true
            title: monitorCard.optionTitle()
            items: monitorCard.optionItems()
            visible: monitorCard.activeOption !== ""
            currentTest: value => monitorCard.isCurrentOption(value)
            monitorName: monitorCard.monName
            optionField: monitorCard.activeOption
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
        property bool pending: false
        property color accentColor: Colours.palette.m3primaryContainer

        signal clicked

        implicitWidth: chipRow.implicitWidth + Tokens.padding.normal * 2
        implicitHeight: chipRow.implicitHeight + Tokens.padding.small * 2
        radius: Tokens.rounding.full
        color: pending
            ? Qt.alpha(Colours.palette.m3tertiaryContainer, active ? 0.92 : 0.65)
            : active
                ? Qt.alpha(accentColor, 0.92)
                : hoverHandler.hovered
                    ? Colours.layer(Colours.palette.m3surfaceContainer, 3)
                    : Colours.layer(Colours.palette.m3surfaceContainer, 2)
        border.color: pending ? Qt.alpha(Colours.palette.m3tertiary, 0.6) : "transparent"
        border.width: pending ? 1 : 0

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

            Rectangle {
                visible: statusChip.pending
                width: 6
                height: 6
                radius: 3
                color: Colours.palette.m3tertiary
            }

            MaterialIcon {
                text: statusChip.icon
                color: statusChip.pending
                    ? Colours.palette.m3onTertiaryContainer
                    : statusChip.active
                        ? Colours.palette.m3onPrimaryContainer
                        : Colours.palette.m3primary
                font.pointSize: Tokens.font.size.small
            }

            StyledText {
                text: statusChip.text
                color: statusChip.pending
                    ? Colours.palette.m3onTertiaryContainer
                    : statusChip.active
                        ? Colours.palette.m3onPrimaryContainer
                        : Colours.palette.m3onSurfaceVariant
                font.pointSize: Tokens.font.size.small
                font.weight: statusChip.pending ? 600 : 400
            }
        }

        Behavior on color {
            CAnim {}
        }

        Behavior on border.color {
            CAnim {}
        }
    }

    component MonitorOptionTray: StyledRect {
        id: optionTray

        required property string title
        property var items: []
        property var currentTest: null
        property string monitorName: ""
        property string optionField: ""

        function isCurrent(value: var): bool {
            return currentTest ? currentTest(value) : false;
        }

        function handleOptionSelected(value: var): void {
            if (monitorName && optionField && optionField !== "workspace") {
                MonitorConfig.setPending(monitorName, optionField, value);
            }
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
                        onClicked: optionTray.handleOptionSelected(modelData.value)
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

    component MonitorActionBar: StyledRect {
        id: actionBar

        implicitHeight: actionBarLayout.implicitHeight + Tokens.padding.large * 2
        radius: Tokens.rounding.large
        color: Colours.layer(Colours.palette.m3surfaceContainer, 2)
        border.color: Qt.alpha(Colours.palette.m3tertiary, 0.35)
        border.width: 1
        opacity: visible ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: Tokens.anim.durations.normal
                easing.type: Easing.OutCubic
            }
        }

        ColumnLayout {
            id: actionBarLayout

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: Tokens.padding.large
            spacing: Tokens.spacing.large

            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spacing.normal

                MaterialIcon {
                    text: "info"
                    color: Colours.palette.m3tertiary
                    font.pointSize: Tokens.font.size.extraLarge
                    fill: 1
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    StyledText {
                        Layout.fillWidth: true
                        text: qsTr("Mudanças pendentes")
                        font.pointSize: Tokens.font.size.normal
                        font.weight: 600
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: qsTr("Aplique o preview para testar ou descarte para cancelar.")
                        color: Colours.palette.m3outline
                        font.pointSize: Tokens.font.size.small
                        wrapMode: Text.WordWrap
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignRight
                spacing: Tokens.spacing.normal

                IconTextButton {
                    icon: "close"
                    text: qsTr("Descartar")
                    type: IconTextButton.Text
                    onClicked: MonitorConfig.revertChanges()
                }

                IconTextButton {
                    icon: "play_arrow"
                    text: qsTr("Aplicar preview")
                    type: IconTextButton.Filled
                    onClicked: MonitorConfig.applyPreview(root.monitors())
                }
            }
        }
    }

    component MonitorConfirmOverlay: StyledRect {
        id: confirmOverlay

        implicitHeight: confirmLayout.implicitHeight + Tokens.padding.large * 2
        radius: Tokens.rounding.normal
        color: Colours.layer(Colours.palette.m3surfaceContainer, 2)
        border.color: Qt.alpha(Colours.palette.m3primary, 0.45)
        border.width: 2
        opacity: visible ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: Tokens.anim.durations.normal
                easing.type: Easing.OutCubic
            }
        }

        ColumnLayout {
            id: confirmLayout

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: Tokens.padding.large
            spacing: Tokens.spacing.large

            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spacing.normal

                // Countdown circle
                Item {
                    Layout.preferredWidth: 48
                    Layout.preferredHeight: 48

                    Rectangle {
                        anchors.fill: parent
                        radius: width / 2
                        color: "transparent"
                        border.color: Qt.alpha(Colours.palette.m3outline, 0.25)
                        border.width: 3
                    }

                    // Progress arc background
                    Rectangle {
                        anchors.fill: parent
                        radius: width / 2
                        color: "transparent"
                        border.color: Colours.palette.m3primary
                        border.width: 3
                        opacity: MonitorConfig.confirmCountdown / MonitorConfig.confirmTimeout

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 900
                                easing.type: Easing.Linear
                            }
                        }
                    }

                    StyledText {
                        anchors.centerIn: parent
                        text: MonitorConfig.confirmCountdown.toString()
                        font.pointSize: Tokens.font.size.large
                        font.weight: 700
                        color: MonitorConfig.confirmCountdown <= 5 ? Colours.palette.m3error : Colours.palette.m3primary

                        Behavior on color {
                            CAnim {}
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    StyledText {
                        Layout.fillWidth: true
                        text: qsTr("Confirmar configuração?")
                        font.pointSize: Tokens.font.size.normal
                        font.weight: 600
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: qsTr("A tela voltará ao normal em %1 segundos se não confirmar.").arg(MonitorConfig.confirmCountdown)
                        color: MonitorConfig.confirmCountdown <= 5 ? Colours.palette.m3error : Colours.palette.m3outline
                        font.pointSize: Tokens.font.size.small
                        wrapMode: Text.WordWrap

                        Behavior on color {
                            CAnim {}
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignRight
                spacing: Tokens.spacing.normal

                IconTextButton {
                    icon: "undo"
                    text: qsTr("Reverter agora")
                    type: IconTextButton.Text
                    onClicked: MonitorConfig.revertChanges()
                }

                IconTextButton {
                    icon: "check_circle"
                    text: qsTr("Confirmar")
                    type: IconTextButton.Filled
                    onClicked: MonitorConfig.confirmChanges()
                }
            }
        }
    }

    Component {
        id: bindsComponent

        BindsPage {}
    }
}
