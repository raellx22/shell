pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.containers
import qs.components.controls
import qs.services

Item {
    id: root

    property string activeSection: "autostart"
    property string editingKind: ""
    property int editingIndex: -1
    property string draftKeyword: "exec-once"
    property string draftCommand: ""
    property string draftName: ""
    property string draftValue: ""

    readonly property bool editingAutostart: editingKind === "autostart"
    readonly property bool editingEnv: editingKind === "env"

    function autostartByKeyword(keyword: string): var {
        HyprStartup.revision;

        const result = [];
        for (let idx = 0; idx < HyprStartup.autostartEntries.length; idx++) {
            const entry = HyprStartup.autostartEntries[idx];
            if (entry.keyword === keyword) {
                result.push({
                    entry,
                    sourceIndex: idx
                });
            }
        }
        return result;
    }

    function beginAutostart(index: int): void {
        editingKind = "autostart";
        editingIndex = index;
        if (index >= 0) {
            const entry = HyprStartup.autostartEntries[index];
            draftKeyword = entry.keyword;
            draftCommand = entry.command;
        } else {
            draftKeyword = "exec-once";
            draftCommand = "";
        }
    }

    function beginEnv(index: int): void {
        editingKind = "env";
        editingIndex = index;
        if (index >= 0) {
            const entry = HyprStartup.envEntries[index];
            draftName = entry.name;
            draftValue = entry.value;
        } else {
            draftName = "";
            draftValue = "";
        }
    }

    function closeEditor(): void {
        editingKind = "";
        editingIndex = -1;
    }

    function applyAutostart(): void {
        if (draftCommand.trim().length === 0)
            return;

        if (editingIndex >= 0)
            HyprStartup.updateAutostart(editingIndex, draftKeyword, draftCommand);
        else
            HyprStartup.addAutostart(draftKeyword, draftCommand);
        closeEditor();
    }

    function applyEnv(): void {
        if (draftName.trim().length === 0 || draftValue.trim().length === 0 || HyprStartup.reservedEnv(draftName))
            return;

        if (editingIndex >= 0)
            HyprStartup.updateEnv(editingIndex, draftName, draftValue);
        else
            HyprStartup.addEnv(draftName, draftValue);
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
                            text: "rocket_launch"
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
                            text: qsTr("Inicializacao")
                            font.pointSize: Tokens.font.size.large
                            font.weight: 700
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: qsTr("Autostart e variaveis de ambiente salvos em bloco gerenciado, sem disparar acoes inesperadas.")
                            color: Colours.palette.m3outline
                            font.pointSize: Tokens.font.size.small
                            elide: Text.ElideRight
                        }
                    }

                    MetricPill {
                        icon: "rocket_launch"
                        value: HyprStartup.countAutostart("exec-once").toString()
                        label: qsTr("inicio")
                    }

                    MetricPill {
                        icon: "sync"
                        value: HyprStartup.countAutostart("exec").toString()
                        label: qsTr("reload")
                    }

                    MetricPill {
                        icon: "terminal"
                        value: HyprStartup.envEntries.length.toString()
                        label: qsTr("env")
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spacing.normal

                SegmentChip {
                    Layout.fillWidth: true
                    active: root.activeSection === "autostart"
                    icon: "play_circle"
                    label: qsTr("Autostart")
                    subtitle: qsTr("Comandos da sessao")
                    onPicked: {
                        root.activeSection = "autostart";
                        root.closeEditor();
                    }
                }

                SegmentChip {
                    Layout.fillWidth: true
                    active: root.activeSection === "env"
                    icon: "terminal"
                    label: qsTr("Variaveis")
                    subtitle: qsTr("Ambiente do Hyprland")
                    onPicked: {
                        root.activeSection = "env";
                        root.closeEditor();
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Tokens.spacing.normal
                visible: root.activeSection === "autostart"

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spacing.normal

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        StyledText {
                            Layout.fillWidth: true
                            text: qsTr("Autostart")
                            font.pointSize: Tokens.font.size.normal
                            font.weight: 700
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: qsTr("Edicoes entram no arquivo gerenciado. Use Rodar para testar um comando isolado.")
                            color: Colours.palette.m3outline
                            font.pointSize: Tokens.font.size.small
                            elide: Text.ElideRight
                        }
                    }

                    IconTextButton {
                        icon: "add"
                        text: qsTr("Novo")
                        type: IconTextButton.Tonal
                        onClicked: root.beginAutostart(-1)
                    }
                }

                AutostartGroup {
                    title: HyprStartup.keywordLabel("exec-once")
                    subtitle: qsTr("Executa uma vez quando a sessao Hyprland inicia.")
                    entries: root.autostartByKeyword("exec-once")
                }

                AutostartGroup {
                    title: HyprStartup.keywordLabel("exec")
                    subtitle: qsTr("Executa sempre que o Hyprland recarrega a configuracao.")
                    entries: root.autostartByKeyword("exec")
                }

                EmptyHint {
                    visible: HyprStartup.autostartEntries.length === 0 && !root.editingAutostart
                    icon: "rocket_launch"
                    title: qsTr("Nenhum autostart gerenciado")
                    subtitle: qsTr("Adicione apps ou comandos que devem ser controlados pela nova dotfile.")
                }

                AutostartEditor {
                    Layout.fillWidth: true
                    visible: root.editingAutostart
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Tokens.spacing.normal
                visible: root.activeSection === "env"

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spacing.normal

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        StyledText {
                            Layout.fillWidth: true
                            text: qsTr("Variaveis de ambiente")
                            font.pointSize: Tokens.font.size.normal
                            font.weight: 700
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: qsTr("Linhas env entram na proxima sessao do Hyprland; variaveis de cursor ficam reservadas para a aba Cursor.")
                            color: Colours.palette.m3outline
                            font.pointSize: Tokens.font.size.small
                            elide: Text.ElideRight
                        }
                    }

                    IconTextButton {
                        icon: "add"
                        text: qsTr("Nova")
                        type: IconTextButton.Tonal
                        onClicked: root.beginEnv(-1)
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spacing.small
                    visible: HyprStartup.envEntries.length > 0

                    Repeater {
                        model: HyprStartup.envEntries

                        EnvRow {
                            required property int index
                            required property var modelData

                            entry: modelData
                            sourceIndex: index
                            active: root.editingEnv && root.editingIndex === index
                            onEditRequested: sourceIndex => root.beginEnv(sourceIndex)
                            onRemoveRequested: sourceIndex => HyprStartup.removeEnv(sourceIndex)
                        }
                    }
                }

                EmptyHint {
                    visible: HyprStartup.envEntries.length === 0 && !root.editingEnv
                    icon: "terminal"
                    title: qsTr("Nenhuma variavel gerenciada")
                    subtitle: qsTr("Adicione variaveis como QT_QPA_PLATFORMTHEME, GDK_BACKEND ou PATH customizado.")
                }

                EnvEditor {
                    Layout.fillWidth: true
                    visible: root.editingEnv
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

    component AutostartGroup: StyledRect {
        id: group

        required property string title
        required property string subtitle
        property var entries: []

        Layout.fillWidth: true
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

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1

                    StyledText {
                        Layout.fillWidth: true
                        text: group.title
                        font.pointSize: Tokens.font.size.normal
                        font.weight: 700
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: group.subtitle
                        color: Colours.palette.m3outline
                        font.pointSize: Tokens.font.size.small
                        elide: Text.ElideRight
                    }
                }

                StyledRect {
                    Layout.preferredWidth: Math.max(30, countText.implicitWidth + Tokens.padding.normal * 2)
                    Layout.preferredHeight: 28
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

                AutostartRow {
                    required property var modelData

                    itemData: modelData
                    active: root.editingAutostart && root.editingIndex === modelData.sourceIndex
                    onEditRequested: sourceIndex => root.beginAutostart(sourceIndex)
                    onRemoveRequested: sourceIndex => HyprStartup.removeAutostart(sourceIndex)
                    onRunRequested: sourceIndex => HyprStartup.runAutostart(sourceIndex)
                }
            }
        }
    }

    component AutostartRow: StyledRect {
        id: rowRoot

        required property var itemData
        property bool active
        readonly property var entry: itemData.entry
        readonly property int sourceIndex: itemData.sourceIndex

        signal editRequested(int sourceIndex)
        signal removeRequested(int sourceIndex)
        signal runRequested(int sourceIndex)

        Layout.fillWidth: true
        implicitHeight: row.implicitHeight + Tokens.padding.normal * 2
        radius: Tokens.rounding.small
        color: active ? Qt.alpha(Colours.palette.m3primaryContainer, 0.72) : Colours.layer(Colours.palette.m3surfaceContainer, 2)
        border.color: active ? Colours.palette.m3primary : "transparent"
        border.width: active ? 1 : 0

        StateLayer {
            color: rowRoot.active ? Colours.palette.m3onPrimaryContainer : Colours.palette.m3onSurface
            onClicked: rowRoot.editRequested(rowRoot.sourceIndex)
        }

        RowLayout {
            id: row

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: Tokens.padding.normal
            spacing: Tokens.spacing.normal

            StyledRect {
                Layout.preferredWidth: 42
                Layout.preferredHeight: 42
                radius: Tokens.rounding.normal
                color: rowRoot.active ? Colours.palette.m3primary : Colours.palette.m3secondaryContainer

                MaterialIcon {
                    anchors.centerIn: parent
                    text: HyprStartup.keywordIcon(rowRoot.entry.keyword)
                    color: rowRoot.active ? Colours.palette.m3onPrimary : Colours.palette.m3onSecondaryContainer
                    font.pointSize: Tokens.font.size.normal
                    fill: 1
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                StyledText {
                    Layout.fillWidth: true
                    text: rowRoot.entry.command
                    font.pointSize: Tokens.font.size.normal
                    font.weight: 650
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    text: HyprStartup.keywordLabel(rowRoot.entry.keyword)
                    color: Colours.palette.m3outline
                    font.pointSize: Tokens.font.size.small
                    elide: Text.ElideRight
                }
            }

            IconTextButton {
                icon: "play_arrow"
                text: qsTr("Rodar")
                type: IconTextButton.Text
                onClicked: rowRoot.runRequested(rowRoot.sourceIndex)
            }

            IconTextButton {
                icon: "edit"
                text: qsTr("Editar")
                type: IconTextButton.Text
                onClicked: rowRoot.editRequested(rowRoot.sourceIndex)
            }

            IconTextButton {
                icon: "delete"
                text: qsTr("Remover")
                type: IconTextButton.Text
                onClicked: rowRoot.removeRequested(rowRoot.sourceIndex)
            }
        }
    }

    component EnvRow: StyledRect {
        id: rowRoot

        required property var entry
        required property int sourceIndex
        property bool active

        signal editRequested(int sourceIndex)
        signal removeRequested(int sourceIndex)

        Layout.fillWidth: true
        implicitHeight: row.implicitHeight + Tokens.padding.normal * 2
        radius: Tokens.rounding.small
        color: active ? Qt.alpha(Colours.palette.m3primaryContainer, 0.72) : Colours.layer(Colours.palette.m3surfaceContainer, 1)
        border.color: active ? Colours.palette.m3primary : Qt.alpha(Colours.palette.m3outline, 0.12)
        border.width: 1

        StateLayer {
            color: rowRoot.active ? Colours.palette.m3onPrimaryContainer : Colours.palette.m3onSurface
            onClicked: rowRoot.editRequested(rowRoot.sourceIndex)
        }

        RowLayout {
            id: row

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: Tokens.padding.normal
            spacing: Tokens.spacing.normal

            StyledRect {
                Layout.preferredWidth: 42
                Layout.preferredHeight: 42
                radius: Tokens.rounding.normal
                color: Colours.palette.m3secondaryContainer

                MaterialIcon {
                    anchors.centerIn: parent
                    text: "terminal"
                    color: Colours.palette.m3onSecondaryContainer
                    font.pointSize: Tokens.font.size.normal
                    fill: 1
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                StyledText {
                    Layout.fillWidth: true
                    text: rowRoot.entry.name
                    font.pointSize: Tokens.font.size.normal
                    font.weight: 700
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    text: rowRoot.entry.value
                    color: Colours.palette.m3outline
                    font.pointSize: Tokens.font.size.small
                    elide: Text.ElideMiddle
                }
            }

            IconTextButton {
                icon: "edit"
                text: qsTr("Editar")
                type: IconTextButton.Text
                onClicked: rowRoot.editRequested(rowRoot.sourceIndex)
            }

            IconTextButton {
                icon: "delete"
                text: qsTr("Remover")
                type: IconTextButton.Text
                onClicked: rowRoot.removeRequested(rowRoot.sourceIndex)
            }
        }
    }

    component AutostartEditor: StyledRect {
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
                    text: root.editingIndex >= 0 ? qsTr("Editar autostart") : qsTr("Novo autostart")
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

            Flow {
                Layout.fillWidth: true
                Layout.preferredHeight: childrenRect.height
                spacing: Tokens.spacing.small

                Repeater {
                    model: HyprStartup.execKeywords

                    TextButton {
                        required property string modelData

                        text: HyprStartup.keywordLabel(modelData)
                        checked: root.draftKeyword === modelData
                        toggle: false
                        type: checked ? TextButton.Filled : TextButton.Tonal
                        onClicked: root.draftKeyword = modelData
                    }
                }
            }

            FieldBlock {
                Layout.fillWidth: true
                label: qsTr("Comando")
                value: root.draftCommand
                onChanged: value => root.draftCommand = value
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignRight
                spacing: Tokens.spacing.normal

                IconTextButton {
                    icon: "check"
                    text: qsTr("Salvar")
                    type: IconTextButton.Filled
                    onClicked: root.applyAutostart()
                }
            }
        }
    }

    component EnvEditor: StyledRect {
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
                    text: root.editingIndex >= 0 ? qsTr("Editar variavel") : qsTr("Nova variavel")
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

            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spacing.normal

                FieldBlock {
                    Layout.preferredWidth: 220
                    label: qsTr("Nome")
                    value: root.draftName
                    onChanged: value => root.draftName = value
                }

                FieldBlock {
                    Layout.fillWidth: true
                    label: qsTr("Valor")
                    value: root.draftValue
                    onChanged: value => root.draftValue = value
                }
            }

            StyledText {
                Layout.fillWidth: true
                visible: HyprStartup.reservedEnv(root.draftName)
                text: qsTr("Esta variavel e reservada para a futura aba Cursor.")
                color: Colours.palette.m3error
                font.pointSize: Tokens.font.size.small
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignRight
                spacing: Tokens.spacing.normal

                IconTextButton {
                    icon: "check"
                    text: qsTr("Salvar")
                    type: IconTextButton.Filled
                    onClicked: root.applyEnv()
                }
            }
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
