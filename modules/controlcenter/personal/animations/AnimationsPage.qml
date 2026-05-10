pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Caelestia.Config
import qs.components
import qs.components.containers
import qs.components.controls
import qs.components.effects
import qs.services

Item {
    id: root

    property string curveNameDraft: ""
    property bool animationsEnabled
    property var curveNameList: []
    property var editorPoints: [0.25, 0.10, 0.25, 1.00]
    property string overrideCountText: "0"
    property string customCurveCountText: "0"

    property var selectedItem: HyprAnimations.animationCatalog[1]
    property var selectedState: ({
        curve: "default",
        enabled: true,
        name: "windows",
        overridden: false,
        speed: 3,
        style: ""
    })
    property bool selectedOverridden
    property string selectedCurve: "default"
    property string selectedPreviewLine: "animation = windows, 1, 3, default"

    function refreshSelection(syncEditor: bool): void {
        const item = HyprAnimations.selectedItem();
        const state = Object.assign({}, HyprAnimations.effectiveState(item.name));
        selectedItem = item;
        selectedState = state;
        selectedOverridden = Boolean(HyprAnimations.stateFor(item.name).overridden);
        selectedCurve = state.curve ?? "default";
        selectedPreviewLine = HyprAnimations.previewLine(item.name);
        curveNameList = HyprAnimations.curveNames();
        overrideCountText = HyprAnimations.overriddenCount().toString();
        customCurveCountText = HyprAnimations.customCurveCount().toString();
        if (syncEditor)
            refreshEditorPoints();
    }

    function refreshEditorPoints(): void {
        const points = HyprAnimations.curvePoints(selectedCurve);
        editorPoints = [points[0], points[1], points[2], points[3]];
        curveNameDraft = HyprAnimations.nativeCurves.includes(selectedCurve) || HyprAnimations.curves[selectedCurve]?.builtin ? `caelestia_${selectedItem.name}` : selectedCurve;
    }

    function setEditorPoint(index: int, value: real): void {
        const next = editorPoints.slice();
        next[index] = Number(value);
        editorPoints = next;
    }

    function selectAnimation(name: string): void {
        HyprAnimations.selectedName = name;
        refreshSelection(true);
    }

    function applySelectedField(field: string, value: var): void {
        HyprAnimations.setAnimationField(selectedItem.name, field, value);
        refreshSelection(false);
        if (field === "curve")
            refreshEditorPoints();
    }

    function saveCurrentCurve(): void {
        const savedName = HyprAnimations.saveCurveAs(selectedItem.name, curveNameDraft, editorPoints);
        curveNameDraft = savedName;
        refreshEditorPoints();
    }

    anchors.fill: parent
    Component.onCompleted: {
        animationsEnabled = Boolean(HyprConfig.valueFor("animations:enabled"));
        refreshSelection(true);
    }

    Connections {
        function onRevisionChanged(): void {
            root.refreshSelection(true);
        }

        target: HyprAnimations
    }

    StyledFlickable {
        id: flickable

        anchors.fill: parent
        flickableDirection: Flickable.VerticalFlick
        contentHeight: mainLayout.height

        StyledScrollBar.vertical: StyledScrollBar {
            flickable: flickable
        }

        ColumnLayout {
            id: mainLayout

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            spacing: Tokens.spacing.normal

            StyledRect {
                Layout.fillWidth: true
                implicitHeight: heroLayout.implicitHeight + Tokens.padding.large * 2
                radius: Tokens.rounding.normal
                color: Colours.layer(Colours.palette.m3surfaceContainer, 1)
                border.color: Qt.alpha(Colours.palette.m3primary, 0.24)
                border.width: 1

                RowLayout {
                    id: heroLayout

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: Tokens.padding.large
                    spacing: Tokens.spacing.normal

                    StyledRect {
                        Layout.preferredWidth: 54
                        Layout.preferredHeight: 54
                        radius: Tokens.rounding.normal
                        color: Colours.palette.m3primaryContainer

                        MaterialIcon {
                            anchors.centerIn: parent
                            text: "animation"
                            color: Colours.palette.m3onPrimaryContainer
                            font.pointSize: Tokens.font.size.large
                            fill: 1
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        StyledText {
                            Layout.fillWidth: true
                            text: qsTr("Animações")
                            font.pointSize: Tokens.font.size.large
                            font.weight: 700
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: qsTr("Curvas Bezier, velocidade e overrides por animação com preview visual.")
                            color: Colours.palette.m3outline
                            font.pointSize: Tokens.font.size.small
                            elide: Text.ElideRight
                        }
                    }

                    MetricPill {
                        icon: "tune"
                        value: root.overrideCountText
                        label: qsTr("overrides")
                    }

                    MetricPill {
                        icon: "draw"
                        value: root.customCurveCountText
                        label: qsTr("curvas")
                    }

                    StyledSwitch {
                        checked: root.animationsEnabled
                        onToggled: {
                            root.animationsEnabled = checked;
                            HyprConfig.setOption("animations:enabled", checked);
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spacing.normal

                BezierStage {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 300
                    points: root.editorPoints
                    editable: true
                    onPointsEdited: points => root.editorPoints = points
                }

                MotionPanel {
                    Layout.preferredWidth: 220
                    Layout.fillHeight: true
                }
            }

            EditorPanel {
                Layout.fillWidth: true
            }

            Repeater {
                model: HyprAnimations.groupOrder

                AnimationGroup {
                    required property string modelData

                    Layout.fillWidth: true
                    groupName: modelData
                }
            }
        }
    }

    QtObject {
        id: bezierMath

        function cubic(t: real, p1: real, p2: real): real {
            return 3 * Math.pow(1 - t, 2) * t * p1 + 3 * (1 - t) * Math.pow(t, 2) * p2 + Math.pow(t, 3);
        }

        function solveTForX(x: real, x1: real, x2: real): real {
            let t = x;
            for (let idx = 0; idx < 20; idx++) {
                const xAtT = cubic(t, x1, x2);
                const dx = 3 * Math.pow(1 - t, 2) * x1 + 6 * (1 - t) * t * (x2 - x1) + 3 * Math.pow(t, 2) * (1 - x2);
                if (Math.abs(dx) < 0.000001)
                    break;
                t -= (xAtT - x) / dx;
                t = Math.max(0, Math.min(1, t));
            }
            return t;
        }

        function ease(progress: real, x1: real, y1: real, x2: real, y2: real): real {
            const t = solveTForX(progress, x1, x2);
            return cubic(t, y1, y2);
        }
    }

    component MetricPill: StyledRect {
        id: metric

        required property string icon
        required property string value
        required property string label

        Layout.preferredWidth: Math.max(100, metricRow.implicitWidth + Tokens.padding.normal * 2)
        Layout.preferredHeight: 40
        radius: Tokens.rounding.full
        color: Colours.layer(Colours.palette.m3surfaceContainer, 3)

        RowLayout {
            id: metricRow

            anchors.centerIn: parent
            spacing: Tokens.spacing.small

            MaterialIcon {
                text: metric.icon
                color: Colours.palette.m3primary
                font.pointSize: Tokens.font.size.small
                fill: 1
            }

            StyledText {
                text: metric.value
                font.pointSize: Tokens.font.size.normal
                font.weight: 800
            }

            StyledText {
                text: metric.label
                color: Colours.palette.m3outline
                font.pointSize: Tokens.font.size.smaller
                font.weight: 600
            }
        }
    }

    component MotionPanel: StyledRect {
        id: panel

        property real progress

        radius: Tokens.rounding.normal
        color: Colours.layer(Colours.palette.m3surfaceContainer, 1)
        border.color: Qt.alpha(Colours.palette.m3outline, 0.16)
        border.width: 1

        Timer {
            interval: 16
            running: panel.visible
            repeat: true
            onTriggered: panel.progress = panel.progress >= 1 ? 0 : panel.progress + 0.008
        }

        ColumnLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: Tokens.padding.normal
            spacing: Tokens.spacing.normal

            StyledText {
                Layout.fillWidth: true
                text: qsTr("Preview")
                font.weight: 700
            }

            StyledRect {
                Layout.fillWidth: true
                Layout.preferredHeight: 118
                radius: Tokens.rounding.normal
                color: Colours.layer(Colours.palette.m3surfaceContainer, 2)
                clip: true

                StyledRect {
                    id: movingCard

                    readonly property real eased: bezierMath.ease(panel.progress, root.editorPoints[0], root.editorPoints[1], root.editorPoints[2], root.editorPoints[3])

                    width: 56
                    height: 44
                    x: Tokens.padding.normal + Math.max(0, Math.min(1, eased)) * (parent.width - width - Tokens.padding.normal * 2)
                    y: (parent.height - height) / 2
                    radius: Tokens.rounding.normal
                    color: Colours.palette.m3primaryContainer
                    border.color: Colours.palette.m3primary
                    border.width: 1

                    MaterialIcon {
                        anchors.centerIn: parent
                        text: "open_in_new"
                        color: Colours.palette.m3onPrimaryContainer
                        fill: 1
                    }
                }
            }

            StyledText {
                Layout.fillWidth: true
                text: root.selectedPreviewLine
                color: Colours.palette.m3outline
                font.family: "monospace"
                font.pointSize: Tokens.font.size.smaller
                wrapMode: Text.WrapAnywhere
            }
        }
    }

    component EditorPanel: StyledRect {
        id: editor

        implicitHeight: editorLayout.implicitHeight + Tokens.padding.normal * 2
        radius: Tokens.rounding.normal
        color: Colours.layer(Colours.palette.m3surfaceContainer, 2)
        border.color: Qt.alpha(Colours.palette.m3primary, 0.20)
        border.width: 1

        ColumnLayout {
            id: editorLayout

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: Tokens.padding.normal
            spacing: Tokens.spacing.normal

            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spacing.normal

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    StyledText {
                        Layout.fillWidth: true
                        text: root.selectedItem.label
                        font.pointSize: Tokens.font.size.normal
                        font.weight: 800
                        elide: Text.ElideRight
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: root.selectedOverridden ? qsTr("Override gerenciado") : qsTr("Herdando da animação pai")
                        color: Colours.palette.m3outline
                        font.pointSize: Tokens.font.size.small
                        elide: Text.ElideRight
                    }
                }

                StyledSwitch {
                    checked: root.selectedState.enabled
                    onToggled: root.applySelectedField("enabled", checked)
                }

                IconTextButton {
                    visible: root.selectedOverridden && root.selectedItem.name !== "global"
                    icon: "undo"
                    text: qsTr("Herdar")
                    type: IconTextButton.Text
                    onClicked: HyprAnimations.removeOverride(root.selectedItem.name)
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spacing.normal

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spacing.small

                    StyledText {
                        Layout.fillWidth: true
                        text: qsTr("Velocidade: %1 ds").arg(Number(root.selectedState.speed).toFixed(1))
                        color: Colours.palette.m3outline
                        font.pointSize: Tokens.font.size.small
                    }

                    StyledSlider {
                        Layout.fillWidth: true
                        from: 0.5
                        to: 12
                        stepSize: 0.1
                        value: Number(root.selectedState.speed)
                        onMoved: root.applySelectedField("speed", Number(value.toFixed(1)))
                    }
                }

                FieldBlock {
                    Layout.preferredWidth: 180
                    label: qsTr("Nome da curva")
                    value: root.curveNameDraft
                    onChanged: value => root.curveNameDraft = value
                }

                IconTextButton {
                    icon: "save"
                    text: qsTr("Salvar curva")
                    type: IconTextButton.Tonal
                    onClicked: root.saveCurrentCurve()
                }
            }

            Flow {
                Layout.fillWidth: true
                Layout.preferredHeight: childrenRect.height
                spacing: Tokens.spacing.small

                Repeater {
                    model: root.curveNameList

                    TextButton {
                        required property string modelData

                        text: modelData
                        checked: root.selectedCurve === modelData
                        toggle: false
                        type: checked ? TextButton.Filled : TextButton.Tonal
                        onClicked: root.applySelectedField("curve", modelData)
                    }
                }
            }

            Flow {
                Layout.fillWidth: true
                Layout.preferredHeight: childrenRect.height
                visible: root.selectedItem.styles.length > 0
                spacing: Tokens.spacing.small

                TextButton {
                    text: qsTr("default")
                    checked: String(root.selectedState.style ?? "").length === 0
                    toggle: false
                    type: checked ? TextButton.Filled : TextButton.Tonal
                    onClicked: root.applySelectedField("style", "")
                }

                Repeater {
                    model: root.selectedItem.styles

                    TextButton {
                        required property string modelData

                        text: modelData
                        checked: root.selectedState.style === modelData
                        toggle: false
                        type: checked ? TextButton.Filled : TextButton.Tonal
                        onClicked: root.applySelectedField("style", modelData)
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spacing.normal

                PointField {
                    label: "x1"
                    value: root.editorPoints[0]
                    from: 0
                    to: 1
                    onChanged: value => root.setEditorPoint(0, value)
                }

                PointField {
                    label: "y1"
                    value: root.editorPoints[1]
                    from: -2
                    to: 3
                    onChanged: value => root.setEditorPoint(1, value)
                }

                PointField {
                    label: "x2"
                    value: root.editorPoints[2]
                    from: 0
                    to: 1
                    onChanged: value => root.setEditorPoint(2, value)
                }

                PointField {
                    label: "y2"
                    value: root.editorPoints[3]
                    from: -2
                    to: 3
                    onChanged: value => root.setEditorPoint(3, value)
                }
            }
        }
    }

    component AnimationGroup: StyledRect {
        id: group

        required property string groupName
        readonly property var entries: HyprAnimations.groupItems(groupName)

        implicitHeight: groupLayout.implicitHeight + Tokens.padding.normal * 2
        radius: Tokens.rounding.normal
        color: Colours.layer(Colours.palette.m3surfaceContainer, 1)
        visible: entries.length > 0

        ColumnLayout {
            id: groupLayout

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: Tokens.padding.normal
            spacing: Tokens.spacing.small

            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spacing.normal

                StyledText {
                    Layout.fillWidth: true
                    text: group.groupName
                    font.pointSize: Tokens.font.size.normal
                    font.weight: 800
                }

                StyledRect {
                    Layout.preferredWidth: Math.max(30, countText.implicitWidth + Tokens.padding.normal)
                    Layout.preferredHeight: 26
                    radius: Tokens.rounding.full
                    color: Colours.palette.m3tertiaryContainer

                    StyledText {
                        id: countText

                        anchors.centerIn: parent
                        text: group.entries.length.toString()
                        color: Colours.palette.m3onTertiaryContainer
                        font.pointSize: Tokens.font.size.small
                        font.weight: 800
                    }
                }
            }

            Repeater {
                model: group.entries

                AnimationRow {
                    required property var modelData

                    itemData: modelData
                }
            }
        }
    }

    component AnimationRow: StyledRect {
        id: rowRoot

        required property var itemData

        property var rowState: ({
            curve: "default",
            enabled: true,
            name: itemData.name,
            overridden: false,
            speed: 3,
            style: ""
        })
        property bool overridden

        readonly property bool selected: HyprAnimations.selectedName === itemData.name

        function refreshRow(): void {
            rowState = Object.assign({}, HyprAnimations.effectiveState(itemData.name));
            overridden = Boolean(HyprAnimations.stateFor(itemData.name).overridden);
        }

        Layout.fillWidth: true
        implicitHeight: row.implicitHeight + Tokens.padding.normal * 2
        radius: Tokens.rounding.small
        color: selected ? Qt.alpha(Colours.palette.m3primaryContainer, 0.72) : Colours.layer(Colours.palette.m3surfaceContainer, 2)
        border.color: selected ? Colours.palette.m3primary : Qt.alpha(Colours.palette.m3outline, 0.10)
        border.width: 1
        opacity: rowState.enabled ? 1 : 0.58

        Component.onCompleted: refreshRow()

        Connections {
            function onRevisionChanged(): void {
                rowRoot.refreshRow();
            }

            target: HyprAnimations
        }

        StateLayer {
            color: rowRoot.selected ? Colours.palette.m3onPrimaryContainer : Colours.palette.m3onSurface
            onClicked: root.selectAnimation(rowRoot.itemData.name)
        }

        RowLayout {
            id: row

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: Tokens.padding.normal
            spacing: Tokens.spacing.normal

            Item {
                Layout.preferredWidth: 12 + rowRoot.itemData.depth * 14
                Layout.preferredHeight: 1
            }

            StyledRect {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                radius: Tokens.rounding.normal
                color: rowRoot.overridden ? Colours.palette.m3primaryContainer : Colours.palette.m3secondaryContainer

                MaterialIcon {
                    anchors.centerIn: parent
                    text: rowRoot.overridden ? "tune" : "account_tree"
                    color: rowRoot.overridden ? Colours.palette.m3onPrimaryContainer : Colours.palette.m3onSecondaryContainer
                    font.pointSize: Tokens.font.size.normal
                    fill: rowRoot.overridden ? 1 : 0
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spacing.small

                    StyledText {
                        Layout.fillWidth: true
                        text: rowRoot.itemData.label
                        font.weight: 700
                        elide: Text.ElideRight
                    }

                    StyledText {
                        text: rowRoot.overridden ? qsTr("gerenciada") : qsTr("herdada")
                        color: rowRoot.overridden ? Colours.palette.m3primary : Colours.palette.m3outline
                        font.pointSize: Tokens.font.size.smaller
                        font.weight: 700
                    }
                }

                StyledText {
                    Layout.fillWidth: true
                    text: `${Number(rowRoot.rowState.speed).toFixed(1)} ds · ${rowRoot.rowState.curve}${rowRoot.rowState.style ? ` · ${rowRoot.rowState.style}` : ""}`
                    color: Colours.palette.m3outline
                    font.pointSize: Tokens.font.size.small
                    elide: Text.ElideRight
                }
            }

            StyledSwitch {
                checked: rowRoot.rowState.enabled
                onToggled: HyprAnimations.setAnimationField(rowRoot.itemData.name, "enabled", checked)
            }
        }
    }

    component BezierStage: StyledRect {
        id: stage

        property var points: [0.25, 0.10, 0.25, 1.00]
        property bool editable
        property string draggingPoint: ""

        signal pointsEdited(var points)

        function yMin(): real {
            return Math.min(-0.1, points[1], points[3]) - 0.12;
        }

        function yMax(): real {
            return Math.max(1.1, points[1], points[3]) + 0.12;
        }

        function toCanvas(xValue: real, yValue: real): point {
            const pad = 24;
            const widthScale = Math.max(1, canvas.width - pad * 2);
            const heightScale = Math.max(1, canvas.height - pad * 2);
            const yLo = yMin();
            const yHi = yMax();
            return Qt.point(pad + xValue * widthScale, pad + (yHi - yValue) / (yHi - yLo) * heightScale);
        }

        function fromCanvas(xValue: real, yValue: real): point {
            const pad = 24;
            const widthScale = Math.max(1, canvas.width - pad * 2);
            const heightScale = Math.max(1, canvas.height - pad * 2);
            const yLo = yMin();
            const yHi = yMax();
            const x = Math.max(0, Math.min(1, (xValue - pad) / widthScale));
            const y = yHi - (yValue - pad) / heightScale * (yHi - yLo);
            return Qt.point(Number(x.toFixed(3)), Number(y.toFixed(3)));
        }

        function hitTest(xValue: real, yValue: real): string {
            const p1 = toCanvas(points[0], points[1]);
            const p2 = toCanvas(points[2], points[3]);
            const r = 16;
            if (Math.pow(xValue - p1.x, 2) + Math.pow(yValue - p1.y, 2) <= r * r)
                return "p1";
            if (Math.pow(xValue - p2.x, 2) + Math.pow(yValue - p2.y, 2) <= r * r)
                return "p2";
            return "";
        }

        radius: Tokens.rounding.normal
        color: Colours.layer(Colours.palette.m3surfaceContainer, 1)
        border.color: Qt.alpha(Colours.palette.m3outline, 0.18)
        border.width: 1
        clip: true

        Canvas {
            id: canvas

            anchors.fill: parent
            antialiasing: true
            onPaint: {
                const ctx = getContext("2d");
                ctx.reset();

                const widthValue = width;
                const heightValue = height;
                const pad = 24;
                const p0 = stage.toCanvas(0, 0);
                const p1 = stage.toCanvas(stage.points[0], stage.points[1]);
                const p2 = stage.toCanvas(stage.points[2], stage.points[3]);
                const p3 = stage.toCanvas(1, 1);

                ctx.clearRect(0, 0, widthValue, heightValue);
                ctx.strokeStyle = Qt.alpha(Colours.palette.m3outline, 0.14);
                ctx.lineWidth = 1;
                for (let idx = 0; idx <= 10; idx++) {
                    const x = pad + (widthValue - pad * 2) * idx / 10;
                    const y = pad + (heightValue - pad * 2) * idx / 10;
                    ctx.beginPath();
                    ctx.moveTo(x, pad);
                    ctx.lineTo(x, heightValue - pad);
                    ctx.moveTo(pad, y);
                    ctx.lineTo(widthValue - pad, y);
                    ctx.stroke();
                }

                ctx.strokeStyle = Qt.alpha(Colours.palette.m3outline, 0.30);
                ctx.beginPath();
                ctx.rect(pad, pad, widthValue - pad * 2, heightValue - pad * 2);
                ctx.stroke();

                ctx.setLineDash([5, 5]);
                ctx.strokeStyle = Qt.alpha(Colours.palette.m3outline, 0.34);
                ctx.beginPath();
                ctx.moveTo(p0.x, p0.y);
                ctx.lineTo(p3.x, p3.y);
                ctx.stroke();
                ctx.setLineDash([]);

                ctx.strokeStyle = Qt.alpha(Colours.palette.m3primary, 0.45);
                ctx.lineWidth = 2;
                ctx.beginPath();
                ctx.moveTo(p0.x, p0.y);
                ctx.lineTo(p1.x, p1.y);
                ctx.moveTo(p3.x, p3.y);
                ctx.lineTo(p2.x, p2.y);
                ctx.stroke();

                ctx.strokeStyle = Colours.palette.m3primary;
                ctx.lineWidth = 3;
                ctx.beginPath();
                ctx.moveTo(p0.x, p0.y);
                for (let step = 1; step <= 90; step++) {
                    const t = step / 90;
                    const bx = bezierMath.cubic(t, stage.points[0], stage.points[2]);
                    const by = bezierMath.cubic(t, stage.points[1], stage.points[3]);
                    const point = stage.toCanvas(bx, by);
                    ctx.lineTo(point.x, point.y);
                }
                ctx.stroke();

                for (const handle of [p1, p2]) {
                    ctx.fillStyle = Colours.palette.m3primaryContainer;
                    ctx.strokeStyle = Colours.palette.m3primary;
                    ctx.lineWidth = 2;
                    ctx.beginPath();
                    ctx.arc(handle.x, handle.y, 9, 0, Math.PI * 2);
                    ctx.fill();
                    ctx.stroke();
                }
            }

            Connections {
                function onPointsChanged(): void {
                    canvas.requestPaint();
                }

                target: stage
            }
        }

        MouseArea {
            anchors.fill: parent
            enabled: stage.editable
            hoverEnabled: true
            cursorShape: stage.draggingPoint || stage.hitTest(mouseX, mouseY) ? Qt.PointingHandCursor : Qt.ArrowCursor
            onPressed: mouse => stage.draggingPoint = stage.hitTest(mouse.x, mouse.y)
            onPositionChanged: mouse => {
                if (!stage.draggingPoint)
                    return;
                const point = stage.fromCanvas(mouse.x, mouse.y);
                const next = stage.points.slice();
                if (stage.draggingPoint === "p1") {
                    next[0] = point.x;
                    next[1] = point.y;
                } else {
                    next[2] = point.x;
                    next[3] = point.y;
                }
                stage.pointsEdited(next);
            }
            onReleased: stage.draggingPoint = ""
        }
    }

    component PointField: ColumnLayout {
        id: pointField

        required property string label
        property real value
        property real from
        property real to

        signal changed(real value)

        spacing: Tokens.spacing.small

        StyledText {
            Layout.fillWidth: true
            text: `${pointField.label}: ${Number(pointField.value).toFixed(3)}`
            color: Colours.palette.m3outline
            font.pointSize: Tokens.font.size.small
        }

        StyledSlider {
            Layout.fillWidth: true
            from: pointField.from
            to: pointField.to
            stepSize: 0.01
            value: pointField.value
            onMoved: pointField.changed(Number(value.toFixed(3)))
        }
    }

    component FieldBlock: ColumnLayout {
        id: field

        required property string label
        property string value: ""

        signal changed(string value)

        spacing: Tokens.spacing.small

        StyledText {
            Layout.fillWidth: true
            text: field.label
            color: Colours.palette.m3outline
            font.pointSize: Tokens.font.size.small
        }

        StyledInputField {
            Layout.fillWidth: true
            text: field.value
            horizontalAlignment: TextInput.AlignLeft
            onTextEdited: text => field.changed(text)
        }
    }
}
