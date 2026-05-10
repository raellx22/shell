pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.containers
import qs.components.controls
import qs.components.effects
import qs.services

Item {
    id: root

    property string activeKind: "window"
    property string searchText: ""
    property bool editing
    property int editingIndex: -1
    property string draftMatcherKey: "class"
    property string draftMatcherValue: ""
    property string draftMatchersText: ""
    property string draftNamespace: ""
    property string draftEffectName: "float"
    property string draftEffectArgs: ""

    readonly property bool editingWindow: editing && activeKind === "window"
    readonly property bool editingLayer: editing && activeKind === "layer"
    readonly property string previewLine: HyprRules.previewLine(activeKind, activeKind === "layer" ? draftNamespace : draftMatchersText, draftEffectName, draftEffectArgs)

    function activeEntries(): var {
        HyprRules.revision;
        return activeKind === "layer" ? HyprRules.layerRules : HyprRules.windowRules;
    }

    function filteredEntries(): var {
        const query = searchText.trim().toLowerCase();
        const result = [];
        const source = activeEntries();
        for (let idx = 0; idx < source.length; idx++) {
            const entry = source[idx];
            const haystack = [entry.title, entry.subtitle, entry.line].join(" ").toLowerCase();
            if (query.length === 0 || haystack.indexOf(query) !== -1) {
                result.push({
                    entry,
                    sourceIndex: idx
                });
            }
        }
        return result;
    }

    function filteredExternal(): var {
        HyprRules.revision;
        const query = searchText.trim().toLowerCase();
        const result = [];
        for (const entry of HyprRules.externalRules) {
            if (entry.kind !== activeKind)
                continue;
            const haystack = [entry.title, entry.subtitle, entry.line, entry.source].join(" ").toLowerCase();
            if (query.length === 0 || haystack.indexOf(query) !== -1)
                result.push(entry);
        }
        return result;
    }

    function matcherPlaceholder(): string {
        for (const matcher of HyprRules.matcherKinds) {
            if (matcher.key === draftMatcherKey)
                return matcher.placeholder;
        }
        return "^(kitty)$";
    }

    function syncMatchersText(): void {
        if (draftMatcherKey.length === 0 || draftMatcherValue.trim().length === 0)
            draftMatchersText = "";
        else
            draftMatchersText = `match:${draftMatcherKey} ${draftMatcherValue.trim()}`;
    }

    function beginNew(kind: string): void {
        activeKind = kind;
        editing = true;
        editingIndex = -1;
        if (kind === "layer") {
            draftNamespace = "^(rofi|wofi)$";
            draftEffectName = "blur";
            draftEffectArgs = "";
        } else {
            draftMatcherKey = "class";
            draftMatcherValue = "";
            draftMatchersText = "";
            draftEffectName = "float";
            draftEffectArgs = "";
        }
    }

    function beginEdit(index: int, entry: var): void {
        editing = true;
        editingIndex = index;
        activeKind = entry.kind;
        draftEffectName = entry.effectName;
        draftEffectArgs = entry.effectArgs;
        if (entry.kind === "layer") {
            draftNamespace = entry.namespace;
        } else {
            const matcher = entry.matchers.length > 0 ? entry.matchers[0] : {
                key: "class",
                value: ""
            };
            draftMatcherKey = matcher.key;
            draftMatcherValue = matcher.value;
            draftMatchersText = entry.matchersText;
        }
    }

    function closeEditor(): void {
        editing = false;
        editingIndex = -1;
    }

    function applyEditor(): void {
        if (activeKind === "layer") {
            if (draftNamespace.trim().length === 0 || draftEffectName.trim().length === 0)
                return;
            if (editingIndex >= 0)
                HyprRules.updateLayerRule(editingIndex, draftNamespace, draftEffectName, draftEffectArgs);
            else
                HyprRules.addLayerRule(draftNamespace, draftEffectName, draftEffectArgs);
        } else {
            const matchers = draftMatchersText.trim();
            if (matchers.length === 0 || draftEffectName.trim().length === 0)
                return;
            if (editingIndex >= 0)
                HyprRules.updateWindowRule(editingIndex, matchers, draftEffectName, draftEffectArgs);
            else
                HyprRules.addWindowRule(matchers, draftEffectName, draftEffectArgs);
        }
        closeEditor();
    }

    anchors.fill: parent

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
                            text: "rule"
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
                            text: qsTr("Regras")
                            font.pointSize: Tokens.font.size.large
                            font.weight: 700
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: qsTr("Window rules e layer rules em bloco gerenciado, com preview da linha final.")
                            color: Colours.palette.m3outline
                            font.pointSize: Tokens.font.size.small
                            elide: Text.ElideRight
                        }
                    }

                    MetricPill {
                        icon: "select_window"
                        value: HyprRules.windowRules.length.toString()
                        label: qsTr("janelas")
                    }

                    MetricPill {
                        icon: "layers"
                        value: HyprRules.layerRules.length.toString()
                        label: qsTr("layers")
                    }

                    MetricPill {
                        icon: "lock"
                        value: HyprRules.externalRules.length.toString()
                        label: qsTr("externas")
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spacing.normal

                SegmentChip {
                    Layout.fillWidth: true
                    active: root.activeKind === "window"
                    icon: "select_window"
                    label: qsTr("Janelas")
                    subtitle: qsTr("windowrule")
                    onPicked: {
                        root.activeKind = "window";
                        root.closeEditor();
                    }
                }

                SegmentChip {
                    Layout.fillWidth: true
                    active: root.activeKind === "layer"
                    icon: "layers"
                    label: qsTr("Layers")
                    subtitle: qsTr("layerrule")
                    onPicked: {
                        root.activeKind = "layer";
                        root.closeEditor();
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spacing.normal

                SearchBox {
                    Layout.fillWidth: true
                }

                IconTextButton {
                    icon: "add"
                    text: qsTr("Nova")
                    type: IconTextButton.Tonal
                    onClicked: root.beginNew(root.activeKind)
                }
            }

            NoticeCard {
                Layout.fillWidth: true
                icon: "info"
                title: qsTr("Aplicacao ao vivo parcial")
                subtitle: qsTr("Regras novas ou editadas sao enviadas ao Hyprland. Remover ou reordenar fica correto apos reload, pois nao existe unwindowrule/unlayerrule via IPC.")
            }

            RuleEditor {
                Layout.fillWidth: true
                visible: root.editing
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Tokens.spacing.small
                visible: root.filteredEntries().length > 0

                Repeater {
                    model: root.filteredEntries()

                    RuleRow {
                        required property var modelData

                        entry: modelData.entry
                        sourceIndex: modelData.sourceIndex
                        active: root.editing && root.editingIndex === modelData.sourceIndex && root.activeKind === modelData.entry.kind
                        managed: true
                        onEditRequested: (index, entry) => root.beginEdit(index, entry)
                        onRemoveRequested: (index, kind) => kind === "layer" ? HyprRules.removeLayerRule(index) : HyprRules.removeWindowRule(index)
                        onMoveRequested: (index, kind, delta) => HyprRules.moveRule(kind, index, delta)
                    }
                }
            }

            EmptyHint {
                visible: root.filteredEntries().length === 0 && !root.editing
                icon: root.activeKind === "layer" ? "layers" : "select_window"
                title: root.activeKind === "layer" ? qsTr("Nenhuma layer rule gerenciada") : qsTr("Nenhuma window rule gerenciada")
                subtitle: root.searchText.trim().length > 0 ? qsTr("A busca nao encontrou regras gerenciadas.") : qsTr("Crie uma regra para controlar janelas, barras, launchers ou superficies do shell.")
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Tokens.spacing.small
                visible: root.filteredExternal().length > 0

                SectionTitle {
                    title: qsTr("Externas somente leitura")
                    subtitle: qsTr("Encontradas fora do bloco gerenciado em hypr-user.conf.")
                }

                Repeater {
                    model: root.filteredExternal()

                    RuleRow {
                        required property var modelData

                        entry: modelData
                        sourceIndex: -1
                        managed: false
                    }
                }
            }
        }
    }

    component MetricPill: StyledRect {
        id: metric

        required property string icon
        required property string value
        required property string label

        Layout.preferredWidth: Math.max(94, metricRow.implicitWidth + Tokens.padding.normal * 2)
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

    component SegmentChip: StyledRect {
        id: chip

        required property string icon
        required property string label
        required property string subtitle
        property bool active

        signal picked

        implicitHeight: segmentRow.implicitHeight + Tokens.padding.normal * 2
        radius: Tokens.rounding.normal
        color: active ? Colours.palette.m3secondaryContainer : Colours.layer(Colours.palette.m3surfaceContainer, 1)
        border.color: active ? Colours.palette.m3secondary : Qt.alpha(Colours.palette.m3outline, 0.16)
        border.width: 1

        StateLayer {
            color: chip.active ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurface
            onClicked: chip.picked()
        }

        RowLayout {
            id: segmentRow

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: Tokens.padding.normal
            spacing: Tokens.spacing.normal

            MaterialIcon {
                text: chip.icon
                color: chip.active ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3primary
                font.pointSize: Tokens.font.size.large
                fill: chip.active ? 1 : 0
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                StyledText {
                    Layout.fillWidth: true
                    text: chip.label
                    color: chip.active ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurface
                    font.weight: 700
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    text: chip.subtitle
                    color: chip.active ? Qt.alpha(Colours.palette.m3onSecondaryContainer, 0.72) : Colours.palette.m3outline
                    font.pointSize: Tokens.font.size.small
                    elide: Text.ElideRight
                }
            }
        }

        Behavior on color {
            CAnim {}
        }
    }

    component SearchBox: StyledRect {
        implicitHeight: 44
        radius: Tokens.rounding.normal
        color: Colours.layer(Colours.palette.m3surfaceContainer, 1)
        border.color: Qt.alpha(Colours.palette.m3outline, 0.18)
        border.width: 1

        RowLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: Tokens.padding.small
            spacing: Tokens.spacing.small

            MaterialIcon {
                text: "search"
                color: Colours.palette.m3outline
                font.pointSize: Tokens.font.size.normal
            }

            StyledInputField {
                Layout.fillWidth: true
                text: root.searchText
                horizontalAlignment: TextInput.AlignLeft
                onTextEdited: text => root.searchText = text
            }
        }
    }

    component NoticeCard: StyledRect {
        id: notice

        required property string icon
        required property string title
        required property string subtitle

        implicitHeight: noticeRow.implicitHeight + Tokens.padding.normal * 2
        radius: Tokens.rounding.normal
        color: Qt.alpha(Colours.palette.m3tertiaryContainer, 0.38)
        border.color: Qt.alpha(Colours.palette.m3tertiary, 0.28)
        border.width: 1

        RowLayout {
            id: noticeRow

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: Tokens.padding.normal
            spacing: Tokens.spacing.normal

            MaterialIcon {
                text: notice.icon
                color: Colours.palette.m3tertiary
                font.pointSize: Tokens.font.size.normal
                fill: 1
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                StyledText {
                    Layout.fillWidth: true
                    text: notice.title
                    font.weight: 700
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    text: notice.subtitle
                    color: Colours.palette.m3outline
                    font.pointSize: Tokens.font.size.small
                    wrapMode: Text.WordWrap
                }
            }
        }
    }

    component SectionTitle: RowLayout {
        required property string title
        required property string subtitle

        spacing: Tokens.spacing.normal

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1

            StyledText {
                Layout.fillWidth: true
                text: title
                font.pointSize: Tokens.font.size.normal
                font.weight: 700
            }

            StyledText {
                Layout.fillWidth: true
                text: subtitle
                color: Colours.palette.m3outline
                font.pointSize: Tokens.font.size.small
                elide: Text.ElideRight
            }
        }
    }

    component RuleRow: StyledRect {
        id: rowRoot

        required property var entry
        property int sourceIndex: -1
        property bool active
        property bool managed

        signal editRequested(int sourceIndex, var entry)
        signal removeRequested(int sourceIndex, string kind)
        signal moveRequested(int sourceIndex, string kind, int delta)

        Layout.fillWidth: true
        implicitHeight: row.implicitHeight + Tokens.padding.normal * 2
        radius: Tokens.rounding.normal
        color: active ? Qt.alpha(Colours.palette.m3primaryContainer, 0.72) : Colours.layer(Colours.palette.m3surfaceContainer, managed ? 1 : 0)
        border.color: active ? Colours.palette.m3primary : Qt.alpha(Colours.palette.m3outline, managed ? 0.14 : 0.22)
        border.width: 1
        opacity: managed ? 1 : 0.72

        StateLayer {
            enabled: rowRoot.managed
            color: rowRoot.active ? Colours.palette.m3onPrimaryContainer : Colours.palette.m3onSurface
            onClicked: rowRoot.editRequested(rowRoot.sourceIndex, rowRoot.entry)
        }

        RowLayout {
            id: row

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: Tokens.padding.normal
            spacing: Tokens.spacing.normal

            StyledRect {
                Layout.preferredWidth: 44
                Layout.preferredHeight: 44
                radius: Tokens.rounding.normal
                color: rowRoot.entry.kind === "layer" ? Colours.palette.m3tertiaryContainer : Colours.palette.m3secondaryContainer

                MaterialIcon {
                    anchors.centerIn: parent
                    text: rowRoot.entry.kind === "layer" ? "layers" : "select_window"
                    color: rowRoot.entry.kind === "layer" ? Colours.palette.m3onTertiaryContainer : Colours.palette.m3onSecondaryContainer
                    font.pointSize: Tokens.font.size.normal
                    fill: 1
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spacing.small

                    StyledText {
                        Layout.fillWidth: true
                        text: rowRoot.entry.title
                        font.pointSize: Tokens.font.size.normal
                        font.weight: 700
                        elide: Text.ElideRight
                    }

                    SourceBadge {
                        managed: rowRoot.managed
                        source: rowRoot.entry.source
                    }
                }

                StyledText {
                    Layout.fillWidth: true
                    text: rowRoot.entry.subtitle
                    color: Colours.palette.m3outline
                    font.pointSize: Tokens.font.size.small
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    text: rowRoot.entry.line
                    color: Qt.alpha(Colours.palette.m3outline, 0.86)
                    font.family: "monospace"
                    font.pointSize: Tokens.font.size.smaller
                    elide: Text.ElideMiddle
                }
            }

            IconTextButton {
                visible: rowRoot.managed
                icon: "keyboard_arrow_up"
                text: qsTr("Subir")
                type: IconTextButton.Text
                onClicked: rowRoot.moveRequested(rowRoot.sourceIndex, rowRoot.entry.kind, -1)
            }

            IconTextButton {
                visible: rowRoot.managed
                icon: "keyboard_arrow_down"
                text: qsTr("Descer")
                type: IconTextButton.Text
                onClicked: rowRoot.moveRequested(rowRoot.sourceIndex, rowRoot.entry.kind, 1)
            }

            IconTextButton {
                visible: rowRoot.managed
                icon: "edit"
                text: qsTr("Editar")
                type: IconTextButton.Text
                onClicked: rowRoot.editRequested(rowRoot.sourceIndex, rowRoot.entry)
            }

            IconTextButton {
                visible: rowRoot.managed
                icon: "delete"
                text: qsTr("Remover")
                type: IconTextButton.Text
                onClicked: rowRoot.removeRequested(rowRoot.sourceIndex, rowRoot.entry.kind)
            }
        }
    }

    component SourceBadge: StyledRect {
        id: badge

        property bool managed
        property string source

        Layout.preferredWidth: Math.max(78, badgeRow.implicitWidth + Tokens.padding.small * 2)
        Layout.preferredHeight: 24
        radius: Tokens.rounding.full
        color: managed ? Qt.alpha(Colours.palette.m3primaryContainer, 0.76) : Qt.alpha(Colours.palette.m3errorContainer, 0.44)

        RowLayout {
            id: badgeRow

            anchors.centerIn: parent
            spacing: 4

            MaterialIcon {
                text: badge.managed ? "edit" : "lock"
                color: badge.managed ? Colours.palette.m3onPrimaryContainer : Colours.palette.m3onErrorContainer
                font.pointSize: Tokens.font.size.smaller
                fill: 1
            }

            StyledText {
                text: badge.managed ? qsTr("gerenciada") : qsTr("externa")
                color: badge.managed ? Colours.palette.m3onPrimaryContainer : Colours.palette.m3onErrorContainer
                font.pointSize: Tokens.font.size.smaller
                font.weight: 700
            }
        }
    }

    component RuleEditor: StyledRect {
        implicitHeight: editorLayout.implicitHeight + Tokens.padding.normal * 2
        radius: Tokens.rounding.normal
        color: Colours.layer(Colours.palette.m3surfaceContainer, 3)
        border.color: Qt.alpha(Colours.palette.m3primary, 0.28)
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

                StyledText {
                    Layout.fillWidth: true
                    text: root.editingIndex >= 0 ? qsTr("Editar regra") : qsTr("Nova regra")
                    font.pointSize: Tokens.font.size.normal
                    font.weight: 700
                }

                IconTextButton {
                    icon: "close"
                    text: qsTr("Fechar")
                    type: IconTextButton.Text
                    onClicked: root.closeEditor()
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Tokens.spacing.normal
                visible: root.activeKind === "window"

                Flow {
                    Layout.fillWidth: true
                    Layout.preferredHeight: childrenRect.height
                    spacing: Tokens.spacing.small

                    Repeater {
                        model: HyprRules.matcherKinds

                        TextButton {
                            required property var modelData

                            text: modelData.label
                            checked: root.draftMatcherKey === modelData.key
                            toggle: false
                            type: checked ? TextButton.Filled : TextButton.Tonal
                            onClicked: {
                                root.draftMatcherKey = modelData.key;
                                root.syncMatchersText();
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spacing.normal

                    FieldBlock {
                        Layout.fillWidth: true
                        label: qsTr("Valor do matcher")
                        value: root.draftMatcherValue
                        hint: root.matcherPlaceholder()
                        onChanged: value => {
                            root.draftMatcherValue = value;
                            root.syncMatchersText();
                        }
                    }

                    FieldBlock {
                        Layout.fillWidth: true
                        label: qsTr("Matchers completos")
                        value: root.draftMatchersText
                        hint: qsTr("match:class ^(kitty)$, match:title foo")
                        onChanged: value => root.draftMatchersText = value
                    }
                }
            }

            FieldBlock {
                Layout.fillWidth: true
                visible: root.activeKind === "layer"
                label: qsTr("Namespace")
                value: root.draftNamespace
                hint: qsTr("^(waybar|rofi|notifications)$")
                onChanged: value => root.draftNamespace = value
            }

            ActionPicker {
                Layout.fillWidth: true
            }

            FieldBlock {
                Layout.fillWidth: true
                label: qsTr("Argumentos")
                value: root.draftEffectArgs
                hint: HyprRules.actionHint(root.activeKind, root.draftEffectName)
                onChanged: value => root.draftEffectArgs = value
            }

            PreviewLine {
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignRight
                spacing: Tokens.spacing.normal

                IconTextButton {
                    icon: "check"
                    text: qsTr("Salvar")
                    type: IconTextButton.Filled
                    onClicked: root.applyEditor()
                }
            }
        }
    }

    component ActionPicker: ColumnLayout {
        spacing: Tokens.spacing.small

        StyledText {
            Layout.fillWidth: true
            text: qsTr("Acao")
            color: Colours.palette.m3outline
            font.pointSize: Tokens.font.size.small
        }

        Flow {
            Layout.fillWidth: true
            Layout.preferredHeight: childrenRect.height
            spacing: Tokens.spacing.small

            Repeater {
                model: HyprRules.actionCatalog(root.activeKind)

                TextButton {
                    required property var modelData

                    text: modelData.label
                    checked: root.draftEffectName === modelData.id
                    toggle: false
                    type: checked ? TextButton.Filled : TextButton.Tonal
                    onClicked: {
                        root.draftEffectName = modelData.id;
                        root.draftEffectArgs = "";
                    }
                }
            }
        }
    }

    component PreviewLine: StyledRect {
        implicitHeight: previewLayout.implicitHeight + Tokens.padding.normal * 2
        radius: Tokens.rounding.small
        color: Colours.layer(Colours.palette.m3surfaceContainer, 1)
        border.color: Qt.alpha(Colours.palette.m3outline, 0.18)
        border.width: 1

        ColumnLayout {
            id: previewLayout

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: Tokens.padding.normal
            spacing: Tokens.spacing.small

            StyledText {
                Layout.fillWidth: true
                text: qsTr("Preview")
                color: Colours.palette.m3outline
                font.pointSize: Tokens.font.size.small
            }

            StyledText {
                Layout.fillWidth: true
                text: root.previewLine
                font.family: "monospace"
                font.pointSize: Tokens.font.size.small
                wrapMode: Text.WrapAnywhere
            }
        }
    }

    component FieldBlock: ColumnLayout {
        id: field

        required property string label
        property string value: ""
        property string hint: ""

        signal changed(string value)

        spacing: Tokens.spacing.small

        RowLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.small

            StyledText {
                text: field.label
                color: Colours.palette.m3outline
                font.pointSize: Tokens.font.size.small
            }

            StyledText {
                Layout.fillWidth: true
                text: field.hint
                color: Qt.alpha(Colours.palette.m3outline, 0.7)
                font.pointSize: Tokens.font.size.smaller
                elide: Text.ElideRight
            }
        }

        StyledInputField {
            Layout.fillWidth: true
            text: field.value
            horizontalAlignment: TextInput.AlignLeft
            onTextEdited: text => field.changed(text)
        }
    }

    component EmptyHint: StyledRect {
        id: empty

        required property string icon
        required property string title
        required property string subtitle

        Layout.fillWidth: true
        implicitHeight: emptyRow.implicitHeight + Tokens.padding.large * 2
        radius: Tokens.rounding.normal
        color: Colours.layer(Colours.palette.m3surfaceContainer, 1)

        RowLayout {
            id: emptyRow

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: Tokens.padding.large
            spacing: Tokens.spacing.normal

            MaterialIcon {
                text: empty.icon
                color: Colours.palette.m3primary
                font.pointSize: Tokens.font.size.large
                fill: 1
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                StyledText {
                    Layout.fillWidth: true
                    text: empty.title
                    font.pointSize: Tokens.font.size.normal
                    font.weight: 700
                }

                StyledText {
                    Layout.fillWidth: true
                    text: empty.subtitle
                    color: Colours.palette.m3outline
                    font.pointSize: Tokens.font.size.small
                    wrapMode: Text.WordWrap
                }
            }
        }
    }
}
