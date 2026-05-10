pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Caelestia.Config
import Caelestia.Services
import qs.components
import qs.components.controls
import qs.services
import qs.utils

Item {
    id: root

    required property bool expanded
    required property bool compact
    required property bool tucked

    property bool trackAnnouncement
    property bool expandedContentReady
    property bool lastWasTucked: true
    property real trackPulseProgress
    property string currentTrackKey

    readonly property real playerProgress: {
        const active = Players.active;
        return active?.length ? (active.position % active.length) / active.length : 0;
    }
    readonly property string titleText: (Players.active?.trackTitle ?? qsTr("Sem mídia")) || qsTr("Título desconhecido")
    readonly property string artistText: (Players.active?.trackArtist ?? qsTr("Artista desconhecido")) || qsTr("Artista desconhecido")
    readonly property string playerName: Players.active ? Players.getIdentity(Players.active) : qsTr("Player")
    readonly property bool announcingTrack: tucked && trackAnnouncement
    readonly property real announcementWidth: Math.min(420, Math.max(224, Math.max(titleText.length * 8.5, artistText.length * 7.2) + Tokens.padding.large * 2 + 58))
    readonly property real audioEnergy: (cavaValue(0) + cavaValue(2) + cavaValue(4) + cavaValue(6)) / 4
    readonly property real tuckedAudioLift: tucked && !announcingTrack && (Players.active?.isPlaying ?? false) ? Math.min(5, audioEnergy * 7) : 0

    function cavaValue(index: int): real {
        return Math.max(0, Math.min(1, Audio.cava.values[index] ?? 0));
    }

    function lengthStr(length: real): string {
        if (length <= 0 || isNaN(length))
            return "-:--";

        const hours = Math.floor(length / 3600);
        const mins = Math.floor((length % 3600) / 60);
        const secs = Math.floor(length % 60).toString().padStart(2, "0");
        return hours > 0 ? `${hours}:${mins.toString().padStart(2, "0")}:${secs}` : `${mins}:${secs}`;
    }

    function positionStr(): string {
        const active = Players.active;
        return active?.length ? lengthStr(active.position % active.length) : "-:--";
    }

    function maybeAnnounceTrackChange(): void {
        const nextTrackKey = `${Players.active?.trackTitle ?? ""}\n${Players.active?.trackArtist ?? ""}`;

        if (nextTrackKey === currentTrackKey)
            return;

        const hadTrack = currentTrackKey.length > 1;
        currentTrackKey = nextTrackKey;

        if (!hadTrack || !root.tucked || root.expanded)
            return;

        root.trackAnnouncement = true;
        trackPulseAnimation.restart();
        announcementTimer.restart();
    }

    implicitWidth: expanded ? 520 : compact ? 360 : announcingTrack ? announcementWidth : 178
    implicitHeight: expanded ? 258 : compact ? 108 : announcingTrack ? 72 : 42 + tuckedAudioLift
    clip: true

    onTitleTextChanged: maybeAnnounceTrackChange()
    onArtistTextChanged: maybeAnnounceTrackChange()
    onExpandedChanged: {
        if (expanded) {
            expandedContentReady = false;
            expandedRevealTimer.restart();
        } else {
            expandedRevealTimer.stop();
            expandedContentReady = false;
        }
    }
    onCompactChanged: {
        if (compact)
            lastWasTucked = false;
    }
    onTuckedChanged: {
        if (tucked)
            lastWasTucked = true;
        else {
            trackAnnouncement = false;
            trackPulseAnimation.stop();
            trackPulseProgress = 0;
        }
    }

    Behavior on implicitWidth {
        Anim {
            type: Anim.FastSpatial
        }
    }

    Behavior on implicitHeight {
        Anim {
            type: Anim.FastSpatial
        }
    }

    Timer {
        id: expandedRevealTimer

        interval: Tokens.anim.durations.expressiveFastSpatial / 2
        onTriggered: root.expandedContentReady = root.expanded
    }

    Timer {
        id: announcementTimer

        interval: 3400
        onTriggered: root.trackAnnouncement = false
    }

    SequentialAnimation {
        id: trackPulseAnimation

        NumberAnimation {
            target: root
            property: "trackPulseProgress"
            from: 0
            to: 1
            duration: Tokens.anim.durations.small / 2
            easing: Tokens.anim.expressiveFastSpatial
        }

        NumberAnimation {
            target: root
            property: "trackPulseProgress"
            to: 0
            duration: Tokens.anim.durations.small
            easing: Tokens.anim.standardDecel
        }
    }

    Timer {
        running: Players.active?.isPlaying ?? false
        interval: GlobalConfig.dashboard.mediaUpdateInterval
        triggeredOnStart: true
        repeat: true
        onTriggered: Players.active?.positionChanged()
    }

    ServiceRef {
        service: Audio.cava
    }

    Loader {
        anchors.fill: parent
        active: root.tucked || (root.expanded && !root.expandedContentReady && root.lastWasTucked)
        opacity: active ? 1 : 0
        sourceComponent: tuckedView

        Behavior on opacity {
            Anim {
                type: Anim.StandardSmall
            }
        }
    }

    Loader {
        anchors.fill: parent
        active: root.compact || (root.expanded && !root.expandedContentReady && !root.lastWasTucked)
        opacity: active ? 1 : 0
        sourceComponent: compactView

        Behavior on opacity {
            Anim {
                type: Anim.StandardSmall
            }
        }
    }

    Loader {
        anchors.fill: parent
        active: root.expanded
        opacity: root.expanded && root.expandedContentReady ? 1 : 0
        sourceComponent: expandedView

        Behavior on opacity {
            Anim {
                type: Anim.StandardSmall
            }
        }
    }

    Component {
        id: tuckedView

        Item {
            anchors.fill: parent

            Row {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.leftMargin: Tokens.padding.normal
                anchors.rightMargin: Tokens.padding.normal
                anchors.bottomMargin: 5
                height: 10
                spacing: 3
                opacity: (Players.active?.isPlaying ?? false) ? 0.16 : 0

                Repeater {
                    model: 18

                    StyledRect {
                        required property int modelData

                        anchors.bottom: parent.bottom
                        width: Math.max(2, (parent.width - 17 * parent.spacing) / 18)
                        height: Math.max(2, 2 + root.cavaValue(modelData % 8) * 8)
                        radius: Tokens.rounding.full
                        color: Colours.palette.m3primary

                        Behavior on height {
                            Anim {
                                type: Anim.StandardSmall
                            }
                        }
                    }
                }

                Behavior on opacity {
                    Anim {
                        type: Anim.StandardSmall
                    }
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Tokens.padding.normal
                anchors.rightMargin: Tokens.padding.normal
                anchors.topMargin: Tokens.padding.smaller
                anchors.bottomMargin: Tokens.padding.smaller
                spacing: Tokens.spacing.small

                CoverArt {
                    Layout.alignment: Qt.AlignVCenter
                    implicitWidth: 28 + root.trackPulseProgress * 2
                    implicitHeight: 28 + root.trackPulseProgress * 2
                    radius: Tokens.rounding.full
                }

                MiniEqualizer {
                    Layout.alignment: Qt.AlignVCenter
                    implicitWidth: 16
                    implicitHeight: 18
                    pulse: root.trackPulseProgress
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: root.announcingTrack ? 1 : 0

                    StyledText {
                        Layout.fillWidth: true
                        text: root.titleText
                        color: root.announcingTrack ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
                        font.pointSize: root.announcingTrack ? Tokens.font.size.normal : Tokens.font.size.small
                        font.weight: root.announcingTrack ? 600 : 400
                        elide: Text.ElideRight
                    }

                    StyledText {
                        Layout.fillWidth: true
                        visible: root.announcingTrack
                        text: root.artistText
                        color: Colours.palette.m3onSurfaceVariant
                        font.pointSize: Tokens.font.size.small
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }

    Component {
        id: compactView

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Tokens.padding.large
            anchors.rightMargin: Tokens.padding.normal
            anchors.topMargin: Tokens.padding.normal
            anchors.bottomMargin: Tokens.padding.normal
            spacing: Tokens.spacing.normal

            CoverArt {
                Layout.alignment: Qt.AlignVCenter
                implicitWidth: 64
                implicitHeight: 64
                radius: Tokens.rounding.small
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: Tokens.spacing.smaller

                StyledText {
                    Layout.fillWidth: true
                    text: root.titleText
                    color: Colours.palette.m3primary
                    font.pointSize: Tokens.font.size.normal
                    font.weight: 500
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    text: root.artistText
                    color: Colours.palette.m3onSurfaceVariant
                    font.pointSize: Tokens.font.size.small
                    elide: Text.ElideRight
                }

                ProgressBar {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 5
                    value: root.playerProgress
                }
            }

            PlayerButton {
                Layout.alignment: Qt.AlignVCenter
                icon: Players.active?.isPlaying ? "pause" : "play_arrow"
                filled: true
                disabled: !Players.active?.canTogglePlaying
                onClicked: Players.active?.togglePlaying()
            }
        }
    }

    Component {
        id: expandedView

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Tokens.padding.large
            anchors.rightMargin: Tokens.padding.large
            anchors.topMargin: Tokens.padding.large
            anchors.bottomMargin: Tokens.padding.large
            spacing: Tokens.spacing.large

            CoverArt {
                Layout.alignment: Qt.AlignVCenter
                implicitWidth: 176
                implicitHeight: 176
                radius: Tokens.rounding.normal
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: Tokens.spacing.small

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spacing.small

                    StyledRect {
                        Layout.alignment: Qt.AlignVCenter
                        implicitWidth: playerName.implicitWidth + Tokens.padding.normal
                        implicitHeight: playerName.implicitHeight + Tokens.padding.smaller
                        radius: Tokens.rounding.full
                        color: Colours.layer(Colours.palette.m3surfaceContainerHighest, 2)

                        StyledText {
                            id: playerName

                            anchors.centerIn: parent
                            text: root.playerName
                            color: Colours.palette.m3onSurfaceVariant
                            font.pointSize: Tokens.font.size.small
                            font.family: Tokens.font.family.mono
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    PlayerButton {
                        icon: "open_in_new"
                        disabled: !Players.active?.canRaise
                        onClicked: Players.active?.raise()
                    }

                    PlayerButton {
                        icon: "close"
                        disabled: !Players.active?.canQuit
                        destructive: true
                        onClicked: Players.active?.quit()
                    }
                }

                StyledText {
                    Layout.fillWidth: true
                    text: root.titleText
                    color: Colours.palette.m3primary
                    font.pointSize: Tokens.font.size.large
                    font.weight: 600
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    text: root.artistText
                    color: Colours.palette.m3onSurfaceVariant
                    font.pointSize: Tokens.font.size.normal
                    elide: Text.ElideRight
                }

                StyledSlider {
                    id: slider

                    Layout.fillWidth: true
                    implicitHeight: 30
                    enabled: !!Players.active?.canSeek && !!Players.active?.positionSupported && Players.active.length > 0
                    onMoved: {
                        const active = Players.active;
                        if (active?.canSeek && active?.positionSupported && active.length > 0)
                            active.position = value * active.length;
                    }

                    Binding {
                        target: slider
                        property: "value"
                        value: root.playerProgress
                        when: !slider.pressed
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spacing.small

                    StyledText {
                        text: root.positionStr()
                        color: Colours.palette.m3outline
                        font.pointSize: Tokens.font.size.small
                        font.family: Tokens.font.family.mono
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    StyledText {
                        text: root.lengthStr(Players.active?.length ?? -1)
                        color: Colours.palette.m3outline
                        font.pointSize: Tokens.font.size.small
                        font.family: Tokens.font.family.mono
                    }
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: Tokens.spacing.normal

                    PlayerButton {
                        icon: "skip_previous"
                        disabled: !Players.active?.canGoPrevious
                        onClicked: Players.active?.previous()
                    }

                    PlayerButton {
                        icon: Players.active?.isPlaying ? "pause" : "play_arrow"
                        filled: true
                        prominent: true
                        disabled: !Players.active?.canTogglePlaying
                        onClicked: Players.active?.togglePlaying()
                    }

                    PlayerButton {
                        icon: "skip_next"
                        disabled: !Players.active?.canGoNext
                        onClicked: Players.active?.next()
                    }
                }
            }
        }
    }

    component CoverArt: StyledClippingRect {
        id: art

        radius: Tokens.rounding.small
        color: Colours.layer(Colours.palette.m3surfaceContainerHighest, 2)

        MaterialIcon {
            anchors.centerIn: parent
            text: "art_track"
            color: Colours.palette.m3outline
            font.pointSize: Math.max(1, art.width * 0.36)
        }

        Image {
            anchors.fill: parent
            source: Players.getArtUrl(Players.active)
            asynchronous: true
            fillMode: Image.PreserveAspectCrop
            sourceSize: {
                const dpr = (QsWindow.window as QsWindow)?.devicePixelRatio ?? 1;
                return Qt.size(width * dpr, height * dpr);
            }
        }
    }

    component ProgressBar: StyledRect {
        id: bar

        required property real value

        radius: Tokens.rounding.full
        color: Colours.layer(Colours.palette.m3surfaceContainerHighest, 2)

        StyledRect {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            implicitWidth: Math.max(parent.height, parent.width * bar.value)
            radius: parent.radius
            color: Colours.palette.m3primary

            Behavior on implicitWidth {
                Anim {
                    type: Anim.StandardLarge
                }
            }
        }
    }

    component MiniEqualizer: Item {
        id: eq

        required property real pulse

        scale: 1 + pulse * 0.08

        Repeater {
            model: 4

            StyledRect {
                id: eqBar

                required property int modelData
                readonly property real value: (Players.active?.isPlaying ?? false) ? root.cavaValue(modelData * 2) : 0.16

                anchors.bottom: parent.bottom
                x: modelData * 4
                width: 3
                height: Math.max(4, parent.height * (0.25 + value * 0.75))
                radius: Tokens.rounding.full
                color: Colours.palette.m3primary

                Behavior on height {
                    Anim {
                        type: Anim.StandardSmall
                    }
                }

                Behavior on color {
                    CAnim {}
                }
            }
        }
    }

    component PlayerButton: IconButton {
        id: button

        property bool filled
        property bool prominent
        property bool destructive

        type: filled ? IconButton.Filled : IconButton.Tonal
        padding: prominent ? Tokens.padding.small : Tokens.padding.smaller
        font.pointSize: prominent ? Math.round(Tokens.font.size.large * 1.45) : Tokens.font.size.large
        inactiveColour: destructive ? Colours.palette.m3errorContainer : filled ? Colours.palette.m3primary : Colours.palette.m3secondaryContainer
        inactiveOnColour: destructive ? Colours.palette.m3onErrorContainer : filled ? Colours.palette.m3onPrimary : Colours.palette.m3onSecondaryContainer
        radius: stateLayer.pressed ? Tokens.rounding.small : implicitHeight / 2
        radiusAnim.duration: Tokens.anim.durations.expressiveFastSpatial
        radiusAnim.easing: Tokens.anim.expressiveFastSpatial
    }
}
