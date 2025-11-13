import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/SpotifyAPI.js" as SpotifyAPI
import "../components" 1.0

Page {
    id: page

    property bool loading: false

    SilicaFlickable {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: miniPlayer.top
        }
        contentHeight: column.height

        PullDownMenu {
            MenuItem {
                text: qsTr("Refresh")
                onClicked: loadNewReleases()
            }
        }

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr("Discover")
            }

            BusyIndicator {
                size: BusyIndicatorSize.Large
                anchors.horizontalCenter: parent.horizontalCenter
                running: loading
                visible: loading
            }

            // New Releases
            Column {
                width: parent.width
                spacing: Theme.paddingSmall
                visible: !loading

                Label {
                    x: Theme.horizontalPageMargin
                    text: qsTr("New Releases")
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeLarge
                    font.bold: true
                }

                SilicaListView {
                    id: newReleasesView
                    width: parent.width
                    height: Theme.itemSizeHuge * 1.8
                    orientation: ListView.Horizontal
                    clip: true

                    model: ListModel {
                        id: newReleasesModel
                    }

                    delegate: BackgroundItem {
                        width: Theme.itemSizeHuge * 1.5
                        height: parent.height

                        Column {
                            anchors.fill: parent
                            anchors.margins: Theme.paddingSmall
                            spacing: Theme.paddingSmall

                            Image {
                                width: parent.width
                                height: parent.width
                                source: model.imageUrl || ""
                                fillMode: Image.PreserveAspectCrop
                                smooth: true

                                Rectangle {
                                    anchors.fill: parent
                                    color: Theme.rgba(Theme.highlightBackgroundColor, 0.1)
                                    visible: !parent.source || parent.status !== Image.Ready
                                }
                            }

                            Label {
                                width: parent.width
                                text: model.name
                                color: Theme.primaryColor
                                font.pixelSize: Theme.fontSizeSmall
                                font.bold: true
                                truncationMode: TruncationMode.Fade
                                maximumLineCount: 2
                                wrapMode: Text.WordWrap
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

                        onClicked: {
                            PlaybackManager.play(null, model.uri, null)
                        }
                    }

                    HorizontalScrollDecorator {}
                }
            }


            Item { height: Theme.paddingLarge }
        }

        VerticalScrollDecorator {}
    }

    function loadNewReleases() {
        loading = true
        newReleasesModel.clear()

        SpotifyAPI.getNewReleases(function(data) {
            loading = false

            if (data && data.albums && data.albums.items) {
                console.log("New releases loaded:", data.albums.items.length)

                for (var i = 0; i < Math.min(data.albums.items.length, 20); i++) {
                    var album = data.albums.items[i]
                    var imageUrl = album.images && album.images.length > 0 ? album.images[0].url : ""
                    var artist = album.artists && album.artists.length > 0 ? album.artists[0].name : ""

                    newReleasesModel.append({
                        id: album.id,
                        name: album.name,
                        artist: artist,
                        imageUrl: imageUrl,
                        uri: album.uri
                    })
                }
            }
        }, function(error) {
            loading = false
            console.error("Failed to load new releases:", error)
        }, 20, 0)
    }

    Component.onCompleted: {
        loadNewReleases()
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
