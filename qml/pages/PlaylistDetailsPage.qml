import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/SpotifyAPI.js" as SpotifyAPI
import "../components" 1.0

Page {
    id: page

    property string playlistId: ""
    property string playlistName: ""
    property string playlistImageUrl: ""
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
                text: qsTr("Edit Playlist")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("../components/PlaylistDialog.qml"), {
                        isEditMode: true,
                        playlistId: playlistId,
                        initialName: playlistName
                    })
                }
            }
            MenuItem {
                text: qsTr("Refresh")
                onClicked: loadTracks()
            }
        }

        header: Column {
            width: parent.width

            PageHeader {
                title: playlistName
            }

            Item {
                width: parent.width
                height: playlistImage.height + Theme.paddingLarge * 2

                Image {
                    id: playlistImage
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Theme.itemSizeHuge
                    height: Theme.itemSizeHuge
                    source: playlistImageUrl || ""
                    fillMode: Image.PreserveAspectCrop

                    Rectangle {
                        anchors.fill: parent
                        color: Theme.rgba(Theme.highlightBackgroundColor, 0.1)
                        visible: !playlistImage.source || playlistImage.status !== Image.Ready
                    }
                }
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Play")
                onClicked: {
                    SpotifyAPI.play(null, "spotify:playlist:" + playlistId, null, function() {
                        console.log("Playing playlist")
                    }, function(error) {
                        console.error("Failed to play playlist:", error)
                    })
                }
            }
        }

        model: ListModel {
            id: tracksModel
        }

        delegate: ListItem {
            id: listItem
            contentHeight: Theme.itemSizeMedium

            Row {
                anchors.fill: parent
                anchors.margins: Theme.paddingMedium
                spacing: Theme.paddingMedium

                Image {
                    id: trackImage
                    width: Theme.itemSizeSmall
                    height: Theme.itemSizeSmall
                    source: model.imageUrl || ""
                    fillMode: Image.PreserveAspectCrop

                    Rectangle {
                        anchors.fill: parent
                        color: Theme.rgba(Theme.highlightBackgroundColor, 0.1)
                        visible: !trackImage.source || trackImage.status !== Image.Ready
                    }
                }

                Column {
                    width: parent.width - trackImage.width - Theme.paddingMedium * 2
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.paddingSmall

                    Label {
                        text: model.name
                        color: listItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                        font.pixelSize: Theme.fontSizeMedium
                        truncationMode: TruncationMode.Fade
                        width: parent.width
                    }

                    Label {
                        text: model.artist
                        color: listItem.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                        font.pixelSize: Theme.fontSizeSmall
                        truncationMode: TruncationMode.Fade
                        width: parent.width
                    }
                }
            }

            onClicked: {
                SpotifyAPI.play(null, null, [model.uri], function() {
                    console.log("Playing track:", model.name)
                }, function(error) {
                    console.error("Failed to play track:", error)
                })
            }
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Refresh")
                onClicked: loadTracks()
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

        SpotifyAPI.getPlaylistTracks(playlistId, function(data) {
            loading = false
            console.log("Tracks loaded:", data.items.length)

            for (var i = 0; i < data.items.length; i++) {
                var item = data.items[i]
                if (!item.track) continue

                var track = item.track
                var artistName = ""
                if (track.artists && track.artists.length > 0) {
                    artistName = track.artists[0].name
                }

                var imageUrl = ""
                if (track.album && track.album.images && track.album.images.length > 0) {
                    imageUrl = track.album.images[0].url
                }

                tracksModel.append({
                    id: track.id,
                    name: track.name,
                    artist: artistName,
                    uri: track.uri,
                    imageUrl: imageUrl
                })
            }
        }, function(error) {
            loading = false
            console.error("Failed to load tracks:", error)
        })
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
