import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/SpotifyAPI.js" as SpotifyAPI
import "../components" 1.0

Page {
    id: page

    property bool loading: false

    SilicaListView {
        id: listView
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: miniPlayer.top
        }

        header: PageHeader {
            title: qsTr("My Playlists")
        }

        model: ListModel {
            id: playlistsModel
        }

        delegate: ListItem {
            id: listItem
            contentHeight: Theme.itemSizeMedium

            Row {
                anchors.fill: parent
                anchors.margins: Theme.paddingMedium
                spacing: Theme.paddingMedium

                Image {
                    id: playlistImage
                    width: Theme.itemSizeSmall
                    height: Theme.itemSizeSmall
                    source: model.imageUrl || ""
                    fillMode: Image.PreserveAspectCrop

                    Rectangle {
                        anchors.fill: parent
                        color: Theme.rgba(Theme.highlightBackgroundColor, 0.1)
                        visible: !playlistImage.source || playlistImage.status !== Image.Ready
                    }
                }

                Column {
                    width: parent.width - playlistImage.width - Theme.paddingMedium * 2
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
                        text: qsTr("%n track(s)", "", model.trackCount)
                        color: listItem.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                        font.pixelSize: Theme.fontSizeSmall
                    }
                }
            }

            onClicked: {
                pageStack.push(Qt.resolvedUrl("PlaylistDetailsPage.qml"), {
                    playlistId: model.id,
                    playlistName: model.name,
                    playlistImageUrl: model.imageUrl
                })
            }
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Refresh")
                onClicked: loadPlaylists()
            }
        }

        ViewPlaceholder {
            enabled: listView.count === 0 && !loading
            text: qsTr("No playlists")
            hintText: qsTr("Pull down to refresh")
        }

        BusyIndicator {
            size: BusyIndicatorSize.Large
            anchors.centerIn: parent
            running: loading
        }

        VerticalScrollDecorator {}
    }

    function loadPlaylists() {
        loading = true
        playlistsModel.clear()

        SpotifyAPI.getUserPlaylists(function(data) {
            loading = false
            console.log("Playlists loaded:", data.items.length)

            for (var i = 0; i < data.items.length; i++) {
                var playlist = data.items[i]
                var imageUrl = ""
                if (playlist.images && playlist.images.length > 0) {
                    imageUrl = playlist.images[0].url
                }

                playlistsModel.append({
                    id: playlist.id,
                    name: playlist.name,
                    trackCount: playlist.tracks.total,
                    imageUrl: imageUrl
                })
            }
        }, function(error) {
            loading = false
            console.error("Failed to load playlists:", error)
        })
    }

    Component.onCompleted: {
        loadPlaylists()
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
