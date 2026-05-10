pragma ComponentBehavior: Bound

import "../dash"
import ".."
import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.components.filedialog
import qs.services
import qs.modules.sidebar as Sidebar

Item {
    id: root

    required property DrawerVisibilities visibilities
    required property DashboardState dashState
    required property FileDialog facePicker
    property bool performanceDetailOpen
    readonly property int panelHeight: 616
    readonly property int notificationHeight: 318

    implicitWidth: performanceDetailOpen ? performanceDetail.implicitWidth : layout.implicitWidth
    implicitHeight: performanceDetailOpen ? performanceDetail.implicitHeight : layout.implicitHeight

    Sidebar.Props {
        id: notifProps
    }

    RowLayout {
        id: layout

        visible: !root.performanceDetailOpen
        spacing: Tokens.spacing.normal

        ColumnLayout {
            Layout.preferredWidth: 300
            Layout.preferredHeight: root.panelHeight
            spacing: Tokens.spacing.normal

            Card {
                Layout.fillWidth: true
                Layout.preferredHeight: user.implicitHeight + Tokens.padding.large * 2

                User {
                    id: user

                    anchors.centerIn: parent
                    visibilities: root.visibilities
                    facePicker: root.facePicker
                }
            }

            QuickActions {
                Layout.fillWidth: true
                visibilities: root.visibilities
            }

            RecordingCard {
                Layout.fillWidth: true
            }
        }

        ColumnLayout {
            Layout.preferredWidth: 386
            Layout.preferredHeight: root.panelHeight
            spacing: Tokens.spacing.normal

            PerformanceSummary {
                Layout.fillWidth: true
                onOpenDetails: root.performanceDetailOpen = true
            }

            SystemControls {
                Layout.fillWidth: true
            }
        }

        ColumnLayout {
            Layout.preferredWidth: 392
            Layout.preferredHeight: root.panelHeight
            spacing: Tokens.spacing.normal

            NotificationCenter {
                Layout.fillWidth: true
                Layout.preferredHeight: root.notificationHeight
                props: notifProps
            }

            Card {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Calendar {
                    anchors.fill: parent
                    dashState: root.dashState
                }
            }
        }
    }

    ColumnLayout {
        id: performanceDetail

        visible: root.performanceDetailOpen
        spacing: Tokens.spacing.normal

        Card {
            Layout.fillWidth: true
            Layout.preferredHeight: header.implicitHeight + Tokens.padding.normal * 2

            RowLayout {
                id: header

                anchors.fill: parent
                anchors.margins: Tokens.padding.normal
                spacing: Tokens.spacing.normal

                IconTextButton {
                    icon: "arrow_back"
                    text: qsTr("Centro")
                    type: IconTextButton.Text
                    onClicked: root.performanceDetailOpen = false
                }

                StyledText {
                    Layout.fillWidth: true
                    text: qsTr("Performance")
                    color: Colours.palette.m3onSurface
                    font.pointSize: Tokens.font.size.normal
                    font.weight: 500
                    horizontalAlignment: Text.AlignRight
                    elide: Text.ElideRight
                }
            }
        }

        Performance {
            Layout.alignment: Qt.AlignHCenter
        }
    }

    component Card: StyledRect {
        radius: Tokens.rounding.normal
        color: Colours.tPalette.m3surfaceContainer
    }
}
