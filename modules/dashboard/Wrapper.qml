pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Caelestia
import Caelestia.Config
import qs.components
import qs.components.filedialog
import qs.utils

Item {
    id: root

    required property DrawerVisibilities visibilities
    readonly property bool needsKeyboard: (content.item as Content)?.needsKeyboard ?? false
    readonly property DashboardState dashState: DashboardState {
        reloadableId: "dashboardState"
    }
    readonly property string defaultProfileGif: "root:/assets/bongocat.gif"
    readonly property FileDialog facePicker: FileDialog {
        title: qsTr("Selecionar imagem de perfil")
        filterLabel: qsTr("Imagens e GIFs")
        filters: ["jpg", "jpeg", "png", "webp", "tif", "tiff", "svg", "gif"]
        onAccepted: path => {
            const lowerPath = path.toLowerCase();
            if (lowerPath.endsWith(".gif") || lowerPath.endsWith(".webp")) {
                GlobalConfig.paths.mediaGif = path;
                Quickshell.execDetached(["notify-send", "-a", "caelestia-shell", "-u", "low", "-h", `STRING:image-path:${path}`, "GIF de perfil alterado", `GIF de perfil alterado para ${Paths.shortenHome(path)}`]);
                return;
            }

            GlobalConfig.paths.mediaGif = root.defaultProfileGif;
            if (CUtils.copyFile(Qt.resolvedUrl(path), Qt.resolvedUrl(`${Paths.home}/.face`)))
                Quickshell.execDetached(["notify-send", "-a", "caelestia-shell", "-u", "low", "-h", `STRING:image-path:${path}`, "Imagem de perfil alterada", `Imagem de perfil alterada para ${Paths.shortenHome(path)}`]);
            else
                Quickshell.execDetached(["notify-send", "-a", "caelestia-shell", "-u", "critical", "Falha ao alterar perfil", `Nao foi possivel alterar a imagem para ${Paths.shortenHome(path)}`]);
        }
    }

    readonly property real nonAnimHeight: state === "visible" ? ((content.item as Content)?.nonAnimHeight ?? 0) : 0
    readonly property bool shouldBeActive: visibilities.dashboard && Config.dashboard.enabled
    property real offsetScale: shouldBeActive ? 0 : 1

    visible: offsetScale < 1
    anchors.topMargin: (-implicitHeight - 5) * offsetScale
    implicitHeight: content.implicitHeight
    implicitWidth: content.implicitWidth || 854 // Hard coded fallback for first open
    opacity: 1 - offsetScale

    Behavior on offsetScale {
        Anim {
            type: Anim.DefaultSpatial
        }
    }

    Loader {
        id: content

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom

        active: root.shouldBeActive || root.visible

        sourceComponent: Content {
            visibilities: root.visibilities
            dashState: root.dashState
            facePicker: root.facePicker
        }
    }
}
