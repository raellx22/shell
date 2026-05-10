pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Caelestia.Config
import qs.components
import qs.components.filedialog
import "unified"

Item {
    id: root

    required property DrawerVisibilities visibilities
    readonly property bool needsKeyboard: false
    required property DashboardState dashState
    required property FileDialog facePicker

    readonly property var dashboardPages: {
        const allPages = [
            {
                component: unifiedComponent,
                iconName: "dashboard",
                text: qsTr("Centro"),
                enabled: Config.dashboard.showDashboard
            },
            {
                component: weatherComponent,
                iconName: "cloud",
                text: qsTr("Clima"),
                enabled: Config.dashboard.showWeather
            }
        ];
        return allPages.filter(page => page.enabled);
    }

    readonly property real nonAnimWidth: pager.implicitWidth + Tokens.padding.large * 2
    readonly property real nonAnimHeight: pager.implicitHeight + Tokens.padding.large * 2

    implicitWidth: nonAnimWidth
    implicitHeight: nonAnimHeight

    DashboardPager {
        id: pager

        anchors.centerIn: parent
        dashState: root.dashState
        pages: root.dashboardPages
    }

    Component {
        id: unifiedComponent

        UnifiedDashboard {
            visibilities: root.visibilities
            dashState: root.dashState
            facePicker: root.facePicker
        }
    }

    Component {
        id: weatherComponent

        WeatherDashboard {}
    }

    Behavior on implicitWidth {
        Anim {
            type: Anim.EmphasizedLarge
        }
    }

    Behavior on implicitHeight {
        Anim {
            type: Anim.EmphasizedLarge
        }
    }
}
