import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/SpotifyAPI.js" as SpotifyAPI
import "../components" 1.0

Page {
    id: page

    property string albumId: ""
    property string albumName: ""
    property string albumArtist: ""
    property string albumImageUrl: ""
    property string albumUri: ""
    property bool loading: false

    SilicaListView {
        id: listView
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: miniPlayer.top
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Play album")
                onClicked: PlaybackManager.play(null, albumUri, null)
            }
        }

        header: Column {
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: albumName
            }

            // Album artwork and info
            Item {
                width: parent.width
                height: albumArt.height + Theme.paddingLarge * 2

                Image {
                    id: albumArt
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Screen.width / 2
                    height: width
                    source: albumImageUrl || ""
                    fillMode: Image.PreserveAspectCrop
                    smooth: true

                    Rectangle {
                        anchors.fill: parent
                        color: Theme.rgba(Theme.highlightBackgroundColor, 0.1)
                        visible: !albumArt.source || albumArt.status !== Image.Ready

                        Icon {
                            anchors.centerIn: parent
                            source: "image://theme/icon-l-music"
                            color: Theme.secondaryColor
                            width: Theme.iconSizeExtraLarge
                            height: Theme.iconSizeExtraLarge
                        }
                    }
                }
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: albumName
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeLarge
                font.bold: true
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                width: parent.width - Theme.horizontalPageMargin * 2
                horizontalAlignment: Text.AlignHCenter
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: albumArtist
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeMedium
                wrapMode: Text.WordWrap
                maximumLineCount: 1
                width: parent.width - Theme.horizontalPageMargin * 2
                horizontalAlignment: Text.AlignHCenter
            }

            Item { height: Theme.paddingMedium }
        }

        model: ListModel {
            id: tracksModel
        }

        delegate: ListItem {
            id: listItem
            contentHeight: Theme.itemSizeSmall

            Row {
                anchors {
                    fill: parent
                    leftMargin: Theme.horizontalPageMargin
                    rightMargin: Theme.horizontalPageMargin
                }
                spacing: Theme.paddingMedium

                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: model.trackNumber
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeSmall
                    width: Theme.fontSizeMedium * 2
                }

                Column {
                    width: parent.width - Theme.fontSizeMedium * 2 - parent.spacing
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.paddingSmall / 4

                    Label {
                        width: parent.width
                        text: model.name
                        color: Theme.primaryColor
                        font.pixelSize: Theme.fontSizeSmall
                        truncationMode: TruncationMode.Fade
                        maximumLineCount: 1
                    }

                    Label {
                        width: parent.width
                        text: model.artist
                        color: Theme.secondaryColor
                        font.pixelSize: Theme.fontSizeExtraSmall
                        truncationMode: TruncationMode.Fade
                        maximumLineCount: 1
                    }
                }
            }

            onClicked: {
                PlaybackManager.play(null, null, [model.uri])
            }

            TrackContextMenu {
                trackId: model.id
                trackName: model.name
                trackUri: model.uri
                trackArtist: model.artist
            }
        }

        ViewPlaceholder {
            enabled: listView.count === 0 && !loading
            text: qsTr("No tracks")
            hintText: qsTr("Pull down to refresh")
        }

        BusyIndicator {
            size: BusyIndicatorSize.Large
            anchors.centerIn: parent
            running: loading
        }

        VerticalScrollDecorator {}
    }

    function loadTracks() {
        loading = true
        tracksModel.clear()

        SpotifyAPI.getAlbumTracks(albumId, function(data) {
            loading = false

            if (data && data.items) {
                console.log("Album tracks loaded:", data.items.length)

                for (var i = 0; i < data.items.length; i++) {
                    var track = data.items[i]
                    var artist = track.artists && track.artists.length > 0 ? track.artists[0].name : ""

                    tracksModel.append({
                        id: track.id,
                        name: track.name,
                        artist: artist,
                        uri: track.uri,
                        trackNumber: track.track_number
                    })
                }
            }
        }, function(error) {
            loading = false
            console.error("Failed to load album tracks:", error)
        }, 50, 0)
    }

    Component.onCompleted: {
        loadTracks()
    }

    MiniPlayer {
        id: miniPlayer
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
    }
}
