pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components

Item {
    id: root

    required property DashboardState dashState
    required property var pages

    readonly property int pageCount: pages.length
    readonly property int currentIndex: Math.max(0, Math.min(dashState.currentTab, pageCount - 1))
    readonly property Item currentLoader: {
        pageRepeater.count;
        return pageRepeater.itemAt(currentIndex);
    }
    readonly property Item currentItem: currentLoader?.item ?? null

    property bool wheelLocked

    function setPage(index: int): void {
        if (pageCount <= 0)
            return;

        dashState.currentTab = Math.max(0, Math.min(index, pageCount - 1));
    }

    function previousPage(): void {
        setPage(currentIndex - 1);
    }

    function nextPage(): void {
        setPage(currentIndex + 1);
    }

    function handleWheel(delta: real): void {
        if (wheelLocked || pageCount <= 1 || delta === 0)
            return;

        wheelLocked = true;
        wheelLockTimer.restart();

        if (delta < 0)
            nextPage();
        else
            previousPage();
    }

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    RowLayout {
        id: layout

        spacing: Tokens.spacing.normal

        Item {
            id: pageHost

            Layout.alignment: Qt.AlignVCenter

            implicitWidth: root.currentItem?.implicitWidth ?? 0
            implicitHeight: root.currentItem?.implicitHeight ?? 0
            clip: true

            Repeater {
                id: pageRepeater

                model: root.pages

                delegate: Loader {
                    id: pageLoader

                    required property int index
                    required property var modelData

                    readonly property bool current: index === root.currentIndex
                    readonly property real pageOffset: index - root.currentIndex

                    active: true
                    enabled: current
                    visible: opacity > 0.01
                    sourceComponent: modelData.component
                    width: item?.implicitWidth ?? pageHost.width
                    height: item?.implicitHeight ?? pageHost.height
                    x: pageOffset * 46
                    y: pageOffset * 10
                    opacity: current ? 1 : 0
                    scale: current ? 1 : 0.982
                    z: current ? 1 : 0

                    Behavior on x {
                        Anim {
                            type: Anim.DefaultSpatial
                        }
                    }

                    Behavior on y {
                        Anim {
                            type: Anim.DefaultSpatial
                        }
                    }

                    Behavior on opacity {
                        Anim {
                            type: Anim.FastSpatial
                        }
                    }

                    Behavior on scale {
                        Anim {
                            type: Anim.DefaultSpatial
                        }
                    }
                }
            }

            WheelHandler {
                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                onWheel: event => {
                    if (event.modifiers !== Qt.NoModifier)
                        return;

                    const y = event.angleDelta.y !== 0 ? event.angleDelta.y : event.pixelDelta.y;
                    const x = event.angleDelta.x !== 0 ? event.angleDelta.x : event.pixelDelta.x;
                    if (Math.abs(y) < Math.abs(x))
                        return;

                    root.handleWheel(y);
                    event.accepted = true;
                }
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

        PageIndicator {
            Layout.alignment: Qt.AlignVCenter
            currentIndex: root.currentIndex
            pages: root.pages
            onPageRequested: index => root.setPage(index)
            onPreviousRequested: root.previousPage()
            onNextRequested: root.nextPage()
        }
    }

    Timer {
        id: wheelLockTimer

        interval: 420
        onTriggered: root.wheelLocked = false
    }
}
