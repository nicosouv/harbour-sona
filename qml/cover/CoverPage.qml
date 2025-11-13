import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components" 1.0

CoverBackground {
    Image {
        id: coverArt
        anchors.fill: parent
        source: PlaybackManager.albumImageUrl || ""
        fillMode: Image.PreserveAspectCrop
        opacity: 0.3
        visible: source != ""
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: 0.4
        visible: coverArt.visible
    }

    Column {
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            margins: Theme.paddingMedium
        }
        spacing: Theme.paddingSmall

        Label {
            width: parent.width
            text: PlaybackManager.trackName || qsTr("Sona")
            font.pixelSize: Theme.fontSizeMedium
            font.bold: true
            truncationMode: TruncationMode.Fade
            horizontalAlignment: Text.AlignHCenter
        }

        Label {
            width: parent.width
            text: PlaybackManager.artistName || qsTr("Spotify Client")
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.secondaryColor
            truncationMode: TruncationMode.Fade
            horizontalAlignment: Text.AlignHCenter
            visible: PlaybackManager.artistName !== ""
        }
    }

    CoverActionList {
        enabled: PlaybackManager.trackName !== ""

        CoverAction {
            iconSource: "image://theme/icon-cover-previous"
            onTriggered: PlaybackManager.previous()
        }

        CoverAction {
            iconSource: PlaybackManager.isPlaying ?
                       "image://theme/icon-cover-pause" :
                       "image://theme/icon-cover-play"
            onTriggered: PlaybackManager.togglePlayback()
        }
    }
}
