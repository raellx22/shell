pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.containers
import qs.components.controls
import qs.components.misc
import qs.services

Item {
    id: root

    property string selectedKey: ""
    property bool captureMode
    property var captureKeys: []
    property var captureMods: []
    property var editingBind: null
    property bool editingNew
    property string draftMods: "SUPER"
    property string draftKey: selectedKey
    property string draftType: "bind"
    property string draftDispatcher: "exec"
    property string draftArg: ""

    readonly property var currentBinds: HyprBinds.getBindsForKey(selectedKey)
    readonly property bool hasSelection: selectedKey.length > 0
    readonly property int activeKeyCount: Object.keys(HyprBinds.keyToBinds).length
    readonly property string selectedKeyLabel: hasSelection ? HyprBinds.displayKey(selectedKey) : qsTr("Nenhuma")
    readonly property string captureLabel: captureKeys.length > 0 ? captureKeys.map(key => HyprBinds.displayKey(key)).join(" + ") : qsTr("aguardando")
    readonly property var topKeyItems: topKeys(8)

    function topKeys(limit: int): var {
        HyprBinds.revision;

        const keys = Object.keys(HyprBinds.keyToBinds);
        const items = [];
        for (const key of keys) {
            const binds = HyprBinds.keyToBinds[key] ?? [];
            if (binds.length <= 0)
                continue;
            items.push({
                count: binds.length,
                key,
                label: HyprBinds.displayKey(key)
            });
        }
        items.sort((a, b) => {
            if (b.count !== a.count)
                return b.count - a.count;
            return a.label.localeCompare(b.label);
        });
        return items.slice(0, limit);
    }

    function sourceCount(sourceName: string): int {
        HyprBinds.revision;

        let total = 0;
        for (const bind of HyprBinds.bindsData) {
            if (bind.source === sourceName)
                total++;
        }
        return total;
    }

    function dispatcherIcon(dispatcher: string): string {
        if (dispatcher === "exec")
            return "terminal";
        if (dispatcher === "workspace" || dispatcher === "movetoworkspace")
            return "splitscreen";
        if (dispatcher === "togglefloating" || dispatcher === "fullscreen")
            return "select_window";
        if (dispatcher === "killactive")
            return "close";
        return "bolt";
    }

    function selectKey(keyName: string): void {
        selectedKey = keyName;
        draftKey = keyName;
        captureMode = false;
        captureKeys = [];
        editingBind = null;
        editingNew = false;
    }

    function toggleCapture(): void {
        captureMode = !captureMode;
        captureKeys = [];
        if (captureMode)
            keyGrabber.forceActiveFocus();
    }

    function modsFromEvent(event: var): var {
        const mods = [];
        if ((event.modifiers & Qt.MetaModifier) !== 0)
            mods.push("SUPER");
        if ((event.modifiers & Qt.ControlModifier) !== 0)
            mods.push("CTRL");
        if ((event.modifiers & Qt.AltModifier) !== 0)
            mods.push("ALT");
        if ((event.modifiers & Qt.ShiftModifier) !== 0)
            mods.push("SHIFT");
        return mods;
    }

    function keyFromEvent(event: var): string {
        if (event.key === Qt.Key_Escape)
            return "Escape";
        if (event.key === Qt.Key_Space)
            return "Space";
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
            return "Return";
        if (event.key === Qt.Key_Tab)
            return "Tab";
        if (event.key === Qt.Key_Backspace)
            return "BackSpace";
        if (event.key === Qt.Key_Delete)
            return "Delete";
        if (event.key === Qt.Key_Shift)
            return "Shift_L";
        if (event.key === Qt.Key_Control)
            return "Control_L";
        if (event.key === Qt.Key_Alt)
            return "Alt_L";
        if (event.key === Qt.Key_Meta || event.key === Qt.Key_Super_L)
            return "Super_L";
        if (event.key === Qt.Key_CapsLock)
            return "Caps_Lock";
        if (event.key === Qt.Key_Print)
            return "Print";
        if (event.key >= Qt.Key_F1 && event.key <= Qt.Key_F35)
            return `F${event.key - Qt.Key_F1 + 1}`;
        if (event.text && event.text.length > 0)
            return event.text.toUpperCase();
        return "";
    }

    function handleCapturedKey(event: var): void {
        if (!captureMode)
            return;

        const key = keyFromEvent(event);
        if (key === "Escape") {
            captureMode = false;
            captureKeys = [];
            event.accepted = true;
            return;
        }
        if (!key)
            return;

        const mods = modsFromEvent(event);
        captureMods = mods;
        captureKeys = mods.concat([key]);
        selectedKey = key;
        draftKey = key;
        draftMods = mods.join(" ");
        editingBind = null;
        editingNew = true;
        event.accepted = true;
    }

    function startNewBind(): void {
        editingBind = null;
        editingNew = true;
        draftMods = captureMods.length > 0 ? captureMods.join(" ") : "SUPER";
        draftKey = selectedKey || "R";
        draftType = "bind";
        draftDispatcher = "exec";
        draftArg = "";
    }

    function editBind(bind: var): void {
        editingBind = bind;
        editingNew = false;
        draftMods = bind.modsLabel ?? HyprBinds.modsLabel(bind.mods ?? []);
        draftKey = bind.key ?? selectedKey;
        draftType = bind.bindType ?? "bind";
        draftDispatcher = bind.dispatcher ?? "exec";
        draftArg = bind.arg ?? "";
    }

    function applyEditor(): void {
        HyprBinds.saveBindEdit(editingBind, {
            arg: draftArg,
            bindType: draftType,
            dispatcher: draftDispatcher,
            key: draftKey,
            mods: draftMods
        });
        selectedKey = draftKey;
        editingBind = null;
        editingNew = false;
    }

    function disableCurrentBind(): void {
        if (!editingBind)
            return;

        HyprBinds.disableBind(editingBind);
        editingBind = null;
        editingNew = false;
    }

    anchors.fill: parent

    Item {
        id: keyGrabber

        anchors.fill: parent
        focus: root.captureMode
        Keys.onPressed: event => root.handleCapturedKey(event)
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
                border.color: Qt.alpha(root.captureMode ? Colours.palette.m3tertiary : Colours.palette.m3primary, 0.26)
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
                        color: root.captureMode ? Colours.palette.m3tertiaryContainer : Colours.palette.m3primaryContainer

                        MaterialIcon {
                            anchors.centerIn: parent
                            text: root.captureMode ? "radar" : "keyboard"
                            color: root.captureMode ? Colours.palette.m3onTertiaryContainer : Colours.palette.m3onPrimaryContainer
                            font.pointSize: Tokens.font.size.large
                            fill: 1
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        StyledText {
                            Layout.fillWidth: true
                            text: qsTr("Atalhos")
                            font.pointSize: Tokens.font.size.large
                            font.weight: 700
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: root.captureMode ? qsTr("Modo captura ativo: pressione uma combinacao real ou Esc para sair.") : qsTr("Mapa interativo dos binds do Hyprland, com edicao gerenciada pelo Caelestia.")
                            color: root.captureMode ? Colours.palette.m3tertiary : Colours.palette.m3outline
                            font.pointSize: Tokens.font.size.small
                            elide: Text.ElideRight
                        }
                    }

                    MetricPill {
                        icon: "keyboard_keys"
                        value: HyprBinds.bindsData.length.toString()
                        label: qsTr("binds")
                    }

                    MetricPill {
                        icon: "ads_click"
                        value: root.activeKeyCount.toString()
                        label: qsTr("teclas")
                    }

                    MetricPill {
                        icon: "edit_note"
                        value: root.sourceCount("caelestia").toString()
                        label: qsTr("editados")
                    }
                }
            }

            StyledRect {
                Layout.fillWidth: true
                implicitHeight: keyboardPanel.implicitHeight + Tokens.padding.normal * 2
                radius: Tokens.rounding.normal
                color: Colours.layer(Colours.palette.m3surfaceContainer, 1)
                border.color: root.captureMode ? Colours.palette.m3tertiary : Qt.alpha(Colours.palette.m3outline, 0.18)
                border.width: 1
                clip: false

                ColumnLayout {
                    id: keyboardPanel

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
                                text: qsTr("Mapa do teclado")
                                font.pointSize: Tokens.font.size.normal
                                font.weight: 700
                            }

                            StyledText {
                                Layout.fillWidth: true
                                text: root.captureMode ? qsTr("Capturando: %1").arg(root.captureLabel) : qsTr("Badges discretos indicam quantos atalhos usam cada tecla.")
                                color: root.captureMode ? Colours.palette.m3tertiary : Colours.palette.m3outline
                                font.pointSize: Tokens.font.size.small
                                elide: Text.ElideRight
                            }
                        }

                        IconTextButton {
                            icon: "refresh"
                            text: qsTr("Atualizar")
                            type: IconTextButton.Text
                            onClicked: HyprBinds.refresh()
                        }

                        IconTextButton {
                            icon: root.captureMode ? "stop_circle" : "keyboard"
                            text: root.captureMode ? qsTr("Parar") : qsTr("Capturar")
                            type: root.captureMode ? IconTextButton.Filled : IconTextButton.Tonal
                            onClicked: root.toggleCapture()
                        }
                    }

                    Flow {
                        Layout.fillWidth: true
                        Layout.preferredHeight: childrenRect.height
                        spacing: Tokens.spacing.small
                        visible: root.topKeyItems.length > 0

                        Repeater {
                            model: root.topKeyItems

                            KeyInsightChip {
                                required property var modelData

                                active: HyprBinds.canonicalKey(root.selectedKey) === HyprBinds.canonicalKey(modelData.key)
                                count: modelData.count
                                keyName: modelData.key
                                label: modelData.label
                                onPicked: keyName => root.selectKey(keyName)
                            }
                        }
                    }

                    Flickable {
                        id: keyboardScroller

                        Layout.fillWidth: true
                        Layout.preferredHeight: keyboard.implicitHeight
                        contentWidth: keyboard.width
                        contentHeight: keyboard.height
                        boundsBehavior: Flickable.StopAtBounds
                        clip: true

                        VirtualKeyboard {
                            id: keyboard

                            width: Math.max(keyboardScroller.width, 860)
                            activeKey: root.selectedKey
                            captureKeys: root.captureKeys
                            onKeySelected: keyName => root.selectKey(keyName)
                        }
                    }
                }
            }

            StyledRect {
                Layout.fillWidth: true
                implicitHeight: detailsLayout.implicitHeight + Tokens.padding.large * 2
                radius: Tokens.rounding.normal
                color: Colours.layer(Colours.palette.m3surfaceContainer, 1)

                ColumnLayout {
                    id: detailsLayout

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: Tokens.padding.large
                    spacing: Tokens.spacing.normal

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Tokens.spacing.normal

                        StyledRect {
                            Layout.preferredWidth: 58
                            Layout.preferredHeight: 58
                            radius: Tokens.rounding.normal
                            color: root.hasSelection ? Colours.palette.m3primaryContainer : Colours.layer(Colours.palette.m3surfaceContainer, 3)
                            border.color: root.hasSelection ? Colours.palette.m3primary : Qt.alpha(Colours.palette.m3outline, 0.18)
                            border.width: root.hasSelection ? 1 : 0

                            StyledText {
                                anchors.centerIn: parent
                                width: parent.width - Tokens.padding.small * 2
                                text: root.hasSelection ? root.selectedKeyLabel : "?"
                                color: root.hasSelection ? Colours.palette.m3onPrimaryContainer : Colours.palette.m3outline
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                                font.pointSize: Tokens.font.size.normal
                                font.weight: 800
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            StyledText {
                                Layout.fillWidth: true
                                text: root.hasSelection ? qsTr("Tecla %1").arg(root.selectedKeyLabel) : qsTr("Selecione uma tecla")
                                font.pointSize: Tokens.font.size.normal
                                font.weight: 700
                            }

                            StyledText {
                                Layout.fillWidth: true
                                text: root.hasSelection ? qsTr("%1 atalho(s) usando esta tecla. Clique em uma linha para editar.").arg(root.currentBinds.length) : qsTr("Clique no teclado virtual, use um chip acima ou ative o modo captura.")
                                color: Colours.palette.m3outline
                                font.pointSize: Tokens.font.size.small
                                elide: Text.ElideRight
                            }
                        }

                        IconTextButton {
                            enabled: root.hasSelection
                            icon: "add"
                            text: qsTr("Novo")
                            type: IconTextButton.Tonal
                            visible: root.hasSelection
                            onClicked: root.startNewBind()
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Tokens.spacing.small
                        visible: root.hasSelection && root.currentBinds.length > 0

                        Repeater {
                            model: root.currentBinds

                            BindRow {
                                required property var modelData

                                bindData: modelData
                                active: root.editingBind?.uid === modelData.uid
                                onEditRequested: bind => root.editBind(bind)
                            }
                        }
                    }

                    EmptySelection {
                        Layout.fillWidth: true
                        visible: !root.hasSelection || root.currentBinds.length === 0
                        icon: root.hasSelection ? "add_link" : "keyboard"
                        title: root.hasSelection ? qsTr("Nenhum atalho nesta tecla") : qsTr("Nenhuma tecla selecionada")
                        subtitle: root.hasSelection ? qsTr("Crie um atalho novo ou capture uma combinacao real para começar por esta tecla.") : qsTr("As teclas mais usadas aparecem em chips e o teclado inteiro continua clicavel.")
                    }

                    BindEditor {
                        Layout.fillWidth: true
                        visible: root.editingNew || root.editingBind !== null
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

        Layout.preferredWidth: Math.max(98, metricRow.implicitWidth + Tokens.padding.normal * 2)
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

    component KeyInsightChip: StyledRect {
        id: chip

        required property string keyName
        required property string label
        required property int count
        property bool active

        signal picked(string keyName)

        width: chipRow.implicitWidth + Tokens.padding.normal * 2
        height: 32
        radius: Tokens.rounding.full
        color: active ? Colours.palette.m3primaryContainer : Colours.layer(Colours.palette.m3surfaceContainer, 3)
        border.color: active ? Colours.palette.m3primary : Qt.alpha(Colours.palette.m3outline, 0.14)
        border.width: 1

        StateLayer {
            color: chip.active ? Colours.palette.m3onPrimaryContainer : Colours.palette.m3onSurface
            onClicked: chip.picked(chip.keyName)
        }

        RowLayout {
            id: chipRow

            anchors.centerIn: parent
            spacing: Tokens.spacing.small

            StyledText {
                text: chip.label
                color: chip.active ? Colours.palette.m3onPrimaryContainer : Colours.palette.m3onSurface
                font.pointSize: Tokens.font.size.small
                font.weight: 800
            }

            StyledRect {
                Layout.preferredWidth: Math.max(20, chipCount.implicitWidth + 10)
                Layout.preferredHeight: 20
                radius: Tokens.rounding.full
                color: chip.active ? Colours.palette.m3primary : Colours.palette.m3tertiaryContainer

                StyledText {
                    id: chipCount

                    anchors.centerIn: parent
                    text: chip.count.toString()
                    color: chip.active ? Colours.palette.m3onPrimary : Colours.palette.m3onTertiaryContainer
                    font.pointSize: Tokens.font.size.smaller
                    font.weight: 800
                }
            }
        }
    }

    component BindRow: StyledRect {
        id: bindRow

        required property var bindData
        property bool active

        signal editRequested(var bind)

        Layout.fillWidth: true
        implicitHeight: row.implicitHeight + Tokens.padding.normal * 2
        radius: Tokens.rounding.small
        color: active ? Qt.alpha(Colours.palette.m3primaryContainer, 0.72) : Colours.layer(Colours.palette.m3surfaceContainer, 2)
        border.color: active ? Colours.palette.m3primary : "transparent"
        border.width: active ? 1 : 0

        StateLayer {
            color: bindRow.active ? Colours.palette.m3onPrimaryContainer : Colours.palette.m3onSurface
            onClicked: bindRow.editRequested(bindRow.bindData)
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
                color: bindRow.active ? Colours.palette.m3primary : Colours.palette.m3secondaryContainer

                MaterialIcon {
                    anchors.centerIn: parent
                    text: root.dispatcherIcon(bindRow.bindData.dispatcher)
                    color: bindRow.active ? Colours.palette.m3onPrimary : Colours.palette.m3onSecondaryContainer
                    font.pointSize: Tokens.font.size.normal
                    fill: 1
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Tokens.spacing.small

                StyledText {
                    Layout.fillWidth: true
                    text: bindRow.bindData.actionLabel
                    font.pointSize: Tokens.font.size.normal
                    font.weight: 600
                    elide: Text.ElideRight
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spacing.small

                    StyledRect {
                        Layout.preferredWidth: Math.max(96, comboText.implicitWidth + Tokens.padding.normal * 2)
                        Layout.preferredHeight: 26
                        radius: Tokens.rounding.full
                        color: Colours.palette.m3secondaryContainer

                        StyledText {
                            id: comboText

                            anchors.centerIn: parent
                            width: parent.width - Tokens.padding.small * 2
                            text: bindRow.bindData.comboLabel
                            color: Colours.palette.m3onSecondaryContainer
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                            font.pointSize: Tokens.font.size.small
                            font.weight: 700
                        }
                    }

                    StyledRect {
                        Layout.preferredWidth: typeText.implicitWidth + Tokens.padding.normal * 2
                        Layout.preferredHeight: 26
                        radius: Tokens.rounding.full
                        color: Colours.layer(Colours.palette.m3surfaceContainer, 4)

                        StyledText {
                            id: typeText

                            anchors.centerIn: parent
                            text: bindRow.bindData.flagsLabel.length > 0 ? `${bindRow.bindData.bindType} / ${bindRow.bindData.flagsLabel}` : bindRow.bindData.bindType
                            color: Colours.palette.m3outline
                            font.pointSize: Tokens.font.size.smaller
                            font.weight: 600
                        }
                    }
                }
            }

            StyledRect {
                Layout.preferredWidth: sourceText.implicitWidth + Tokens.padding.normal * 2
                Layout.preferredHeight: 30
                radius: Tokens.rounding.full
                color: bindRow.bindData.source === "caelestia" ? Qt.alpha(Colours.palette.m3tertiaryContainer, 0.75) : Colours.layer(Colours.palette.m3surfaceContainer, 3)

                StyledText {
                    id: sourceText

                    anchors.centerIn: parent
                    text: bindRow.bindData.source === "caelestia" ? qsTr("gerenciado") : qsTr("hyprland")
                    color: bindRow.bindData.source === "caelestia" ? Colours.palette.m3onTertiaryContainer : Colours.palette.m3outline
                    font.pointSize: Tokens.font.size.smaller
                    font.weight: 700
                }
            }

            StyledRect {
                Layout.preferredWidth: 34
                Layout.preferredHeight: 34
                radius: Tokens.rounding.full
                color: Qt.alpha(Colours.palette.m3primary, bindRow.active ? 0.22 : 0.12)

                MaterialIcon {
                    anchors.centerIn: parent
                    text: "edit"
                    color: Colours.palette.m3primary
                    font.pointSize: Tokens.font.size.normal
                }
            }
        }
    }

    component BindEditor: StyledRect {
        id: editor

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
                    text: root.editingNew ? qsTr("Novo atalho") : qsTr("Editar atalho")
                    font.pointSize: Tokens.font.size.normal
                    font.weight: 600
                }

                IconTextButton {
                    icon: "close"
                    text: qsTr("Fechar")
                    type: IconTextButton.Text
                    onClicked: {
                        root.editingBind = null;
                        root.editingNew = false;
                    }
                }
            }

            Flow {
                Layout.fillWidth: true
                Layout.preferredHeight: childrenRect.height
                spacing: Tokens.spacing.small

                Repeater {
                    model: ["bind", "binde", "bindl", "bindr", "bindn"]

                    TextButton {
                        required property string modelData

                        text: modelData
                        checked: root.draftType === modelData
                        toggle: false
                        type: checked ? TextButton.Filled : TextButton.Tonal
                        onClicked: root.draftType = modelData
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spacing.normal

                FieldBlock {
                    Layout.fillWidth: true
                    label: qsTr("Mods")
                    value: root.draftMods
                    placeholder: "SUPER CTRL ALT SHIFT"
                    onChanged: value => root.draftMods = value
                }

                FieldBlock {
                    Layout.preferredWidth: 160
                    label: qsTr("Tecla")
                    value: root.draftKey
                    placeholder: "R"
                    onChanged: value => root.draftKey = value
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spacing.normal

                FieldBlock {
                    Layout.preferredWidth: 190
                    label: qsTr("Dispatcher")
                    value: root.draftDispatcher
                    placeholder: "exec"
                    onChanged: value => root.draftDispatcher = value
                }

                FieldBlock {
                    Layout.fillWidth: true
                    label: qsTr("Argumento")
                    value: root.draftArg
                    placeholder: "app2unit -- foot"
                    onChanged: value => root.draftArg = value
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignRight
                spacing: Tokens.spacing.normal

                IconTextButton {
                    visible: root.editingBind !== null
                    icon: "block"
                    text: qsTr("Desativar")
                    type: IconTextButton.Text
                    onClicked: root.disableCurrentBind()
                }

                IconTextButton {
                    icon: "check"
                    text: qsTr("Aplicar")
                    type: IconTextButton.Filled
                    onClicked: root.applyEditor()
                }
            }
        }
    }

    component FieldBlock: ColumnLayout {
        id: field

        required property string label
        property string value: ""
        property string placeholder: ""

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

    component EmptySelection: StyledRect {
        required property string icon
        required property string title
        required property string subtitle

        implicitHeight: emptyRow.implicitHeight + Tokens.padding.large * 2
        radius: Tokens.rounding.normal
        color: Colours.layer(Colours.palette.m3surfaceContainer, 2)

        RowLayout {
            id: emptyRow

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: Tokens.padding.large
            spacing: Tokens.spacing.normal

            MaterialIcon {
                text: icon
                color: Colours.palette.m3primary
                font.pointSize: Tokens.font.size.large
                fill: 1
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                StyledText {
                    Layout.fillWidth: true
                    text: title
                    font.pointSize: Tokens.font.size.normal
                    font.weight: 600
                }

                StyledText {
                    Layout.fillWidth: true
                    text: subtitle
                    color: Colours.palette.m3outline
                    font.pointSize: Tokens.font.size.small
                    wrapMode: Text.WordWrap
                }
            }
        }
    }
}
