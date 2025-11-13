import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/SpotifyAPI.js" as SpotifyAPI
import "../components" 1.0

Page {
    id: page

    property string categoryId: ""
    property string categoryName: ""
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
                text: qsTr("Refresh")
                onClicked: loadPlaylists()
            }
        }

        header: PageHeader {
            title: categoryName
        }

        model: ListModel {
            id: playlistsModel
        }

        delegate: ListItem {
            id: listItem
            contentHeight: Theme.itemSizeLarge

            Row {
                anchors.fill: parent
                anchors.margins: Theme.paddingMedium
                spacing: Theme.paddingMedium

                Image {
                    id: playlistImage
                    width: height
                    height: parent.height
                    source: model.imageUrl || ""
                    fillMode: Image.PreserveAspectCrop
                    smooth: true

                    Rectangle {
                        anchors.fill: parent
                        color: Theme.rgba(Theme.highlightBackgroundColor, 0.1)
                        visible: !playlistImage.source || playlistImage.status !== Image.Ready
                    }
                }

                Column {
                    width: parent.width - playlistImage.width - parent.spacing
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.paddingSmall / 2

                    Label {
                        width: parent.width
                        text: model.name
                        color: Theme.primaryColor
                        font.pixelSize: Theme.fontSizeMedium
                        truncationMode: TruncationMode.Fade
                        maximumLineCount: 1
                    }

                    Label {
                        width: parent.width
                        text: model.description
                        color: Theme.secondaryColor
                        font.pixelSize: Theme.fontSizeExtraSmall
                        truncationMode: TruncationMode.Fade
                        maximumLineCount: 2
                        wrapMode: Text.WordWrap
                        visible: model.description !== ""
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

        SpotifyAPI.getCategoryPlaylists(categoryId, function(data) {
            loading = false

            if (data && data.playlists && data.playlists.items) {
                console.log("Category playlists loaded:", data.playlists.items.length)

                for (var i = 0; i < data.playlists.items.length; i++) {
                    var playlist = data.playlists.items[i]
                    var imageUrl = playlist.images && playlist.images.length > 0 ? playlist.images[0].url : ""

                    playlistsModel.append({
                        id: playlist.id,
                        name: playlist.name,
                        description: playlist.description || "",
                        imageUrl: imageUrl
                    })
                }
            }
        }, function(error) {
            loading = false
            console.error("Failed to load category playlists:", error)
        }, 50, 0)
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
