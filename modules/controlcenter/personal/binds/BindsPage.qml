import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.utils
import qs.components.misc
import Caelestia
import Caelestia.Config

Item {
    id: root
    
    anchors.fill: parent

    property string selectedKey: ""
    property var currentBinds: Services.HyprBinds ? Services.HyprBinds.getBindsForKey(selectedKey) : []

    // Capturing mode
    property bool isCapturing: false

    // Invisible item to grab focus and capture keys
    Item {
        id: keyGrabber
        anchors.fill: parent
        focus: root.isCapturing
        
        Keys.onPressed: event => {
            if (!root.isCapturing) return;
            
            // Map Qt keys to Hyprland key names (basic mapping)
            let keyName = event.text.toUpperCase();
            if (event.key === Qt.Key_Escape) { root.isCapturing = false; return; }
            if (event.key === Qt.Key_Space) keyName = "space";
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) keyName = "Return";
            if (event.key === Qt.Key_Tab) keyName = "Tab";
            if (event.key === Qt.Key_Backspace) keyName = "BackSpace";
            if (event.key === Qt.Key_Shift) keyName = "Shift_L"; // simplified
            if (event.key === Qt.Key_Control) keyName = "Control_L";
            if (event.key === Qt.Key_Alt) keyName = "Alt_L";
            if (event.key === Qt.Key_Meta || event.key === Qt.Key_Super_L) keyName = "SUPER";

            if (keyName) {
                root.selectedKey = keyName;
            }
            event.accepted = true;
        }
    }

    StyledFlickable {
        id: flickable
        anchors.fill: parent
        flickableDirection: Flickable.VerticalFlick
        contentHeight: mainLayout.height + 48

        StyledScrollBar.vertical: StyledScrollBar { flickable: flickable }

        ColumnLayout {
            id: mainLayout
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: Tokens.spacing.normal
            spacing: Tokens.spacing.large

            // Header
            RowLayout {
                Layout.fillWidth: true
                
                PageHeader {
                    Layout.fillWidth: true
                    title: qsTr("Atalhos do Sistema")
                    description: qsTr("Pressione uma tecla ou selecione no teclado para gerenciar binds.")
                }

                StyledButton {
                    text: root.isCapturing ? qsTr("Parar Captura") : qsTr("Capturar Tecla")
                    icon: root.isCapturing ? "stop_circle" : "keyboard"
                    type: root.isCapturing ? "primary" : "tonal"
                    onClicked: root.isCapturing = !root.isCapturing
                }
            }

            // Keyboard UI
            StyledRect {
                Layout.fillWidth: true
                Layout.preferredHeight: keyboardContent.height + Tokens.spacing.normal * 2
                radius: Tokens.radius.normal
                color: Colours.palette.m3surfaceContainerLow
                border.color: root.isCapturing ? Colours.palette.m3primary : "transparent"
                border.width: root.isCapturing ? 2 : 0

                ColumnLayout {
                    id: keyboardContent
                    anchors.centerIn: parent
                    spacing: Tokens.spacing.normal
                    
                    VirtualKeyboard {
                        activeKey: root.selectedKey
                        onKeySelected: keyName => {
                            root.selectedKey = keyName;
                            root.isCapturing = false; // Stop capture if clicked manually
                        }
                    }
                }
                
                // Overlay pulse if capturing
                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: "transparent"
                    border.color: Colours.palette.m3primary
                    border.width: 2
                    opacity: root.isCapturing ? 0.5 : 0
                    visible: root.isCapturing
                    
                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        running: root.isCapturing
                        NumberAnimation { to: 0.1; duration: 800 }
                        NumberAnimation { to: 0.5; duration: 800 }
                    }
                }
            }

            // Detail View (Binds for selected key)
            StyledRect {
                Layout.fillWidth: true
                Layout.preferredHeight: bindsList.implicitHeight > 100 ? bindsList.implicitHeight + 48 : 150
                radius: Tokens.radius.normal
                color: Colours.palette.m3surfaceContainer
                visible: root.selectedKey !== ""

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Tokens.spacing.normal
                    spacing: Tokens.spacing.normal

                    RowLayout {
                        Layout.fillWidth: true
                        
                        StyledText {
                            text: qsTr("Atalhos com a tecla '%1'").arg(root.selectedKey)
                            font.pointSize: Tokens.font.size.large
                            font.weight: 500
                            Layout.fillWidth: true
                        }
                        
                        StyledButton {
                            text: qsTr("Novo Atalho")
                            icon: "add"
                            type: "tonal"
                        }
                    }

                    ListView {
                        id: bindsList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: 8
                        model: root.currentBinds
                        
                        delegate: StyledRect {
                            width: ListView.view.width
                            height: 60
                            radius: Tokens.radius.small
                            color: Colours.palette.m3surfaceContainerHigh

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: Tokens.spacing.small
                                spacing: Tokens.spacing.normal

                                // Modifiers badge
                                Rectangle {
                                    Layout.preferredHeight: 32
                                    Layout.preferredWidth: modText.width + 16
                                    radius: 16
                                    color: Colours.palette.m3secondaryContainer

                                    StyledText {
                                        id: modText
                                        anchors.centerIn: parent
                                        text: modelData.modmask === 0 ? "Nenhum" : modelData.modmask // Replace with parser later
                                        color: Colours.palette.m3onSecondaryContainer
                                        font.pointSize: Tokens.font.size.small
                                        font.weight: 600
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2
                                    
                                    StyledText {
                                        text: modelData.dispatcher
                                        font.pointSize: Tokens.font.size.normal
                                        font.weight: 500
                                    }
                                    
                                    StyledText {
                                        text: modelData.arg
                                        font.pointSize: Tokens.font.size.small
                                        color: Colours.palette.m3outline
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                }
                                
                                StyledButton {
                                    icon: "edit"
                                    type: "flat"
                                }
                                StyledButton {
                                    icon: "delete"
                                    type: "flat"
                                }
                            }
                        }

                        StyledText {
                            anchors.centerIn: parent
                            text: qsTr("Nenhum atalho configurado para esta tecla.")
                            color: Colours.palette.m3outline
                            visible: root.currentBinds.length === 0
                        }
                    }
                }
            }
        }
    }
}
