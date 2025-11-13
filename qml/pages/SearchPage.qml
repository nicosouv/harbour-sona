import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/SpotifyAPI.js" as SpotifyAPI

Page {
    id: page

    property bool searching: false

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: parent.width

            PageHeader {
                title: qsTr("Search")
            }

            SearchField {
                id: searchField
                width: parent.width
                placeholderText: qsTr("Search for tracks, artists, albums...")

                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked: performSearch()
            }

            ComboBox {
                id: searchTypeCombo
                label: qsTr("Search type")
                currentIndex: 0

                menu: ContextMenu {
                    MenuItem { text: qsTr("All") }
                    MenuItem { text: qsTr("Tracks") }
                    MenuItem { text: qsTr("Artists") }
                    MenuItem { text: qsTr("Albums") }
                    MenuItem { text: qsTr("Playlists") }
                }
            }

            BusyIndicator {
                size: BusyIndicatorSize.Large
                anchors.horizontalCenter: parent.horizontalCenter
                running: searching
            }

            SilicaListView {
                id: resultsView
                width: parent.width
                height: page.height - column.y - searchField.height - searchTypeCombo.height

                model: ListModel {
                    id: resultsModel
                }

                delegate: ListItem {
                    id: listItem
                    contentHeight: Theme.itemSizeMedium

                    Row {
                        anchors.fill: parent
                        anchors.margins: Theme.paddingMedium
                        spacing: Theme.paddingMedium

                        Image {
                            id: resultImage
                            width: Theme.itemSizeSmall
                            height: Theme.itemSizeSmall
                            source: model.imageUrl || ""
                            fillMode: Image.PreserveAspectCrop

                            Rectangle {
                                anchors.fill: parent
                                color: Theme.rgba(Theme.highlightBackgroundColor, 0.1)
                                visible: !resultImage.source || resultImage.status !== Image.Ready
                            }
                        }

                        Column {
                            width: parent.width - resultImage.width - Theme.paddingMedium * 2
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
                                text: model.subtitle
                                color: listItem.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                                font.pixelSize: Theme.fontSizeSmall
                                truncationMode: TruncationMode.Fade
                                width: parent.width
                            }

                            Label {
                                text: model.type
                                color: Theme.secondaryColor
                                font.pixelSize: Theme.fontSizeExtraSmall
                            }
                        }
                    }

                    onClicked: {
                        if (model.type === "track") {
                            SpotifyAPI.play(null, null, [model.uri], function() {
                                console.log("Playing track:", model.name)
                            }, function(error) {
                                console.error("Failed to play track:", error)
                            })
                        } else if (model.type === "playlist") {
                            pageStack.push(Qt.resolvedUrl("PlaylistDetailsPage.qml"), {
                                playlistId: model.id,
                                playlistName: model.name,
                                playlistImageUrl: model.imageUrl
                            })
                        }
                    }
                }

                ViewPlaceholder {
                    enabled: resultsView.count === 0 && !searching && searchField.text.length > 0
                    text: qsTr("No results")
                    hintText: qsTr("Try a different search")
                }

                ViewPlaceholder {
                    enabled: resultsView.count === 0 && !searching && searchField.text.length === 0
                    text: qsTr("Search Spotify")
                    hintText: qsTr("Enter a search term above")
                }

                VerticalScrollDecorator {}
            }
        }
    }

    function performSearch() {
        if (searchField.text.length === 0) return

        searching = true
        resultsModel.clear()

        var types = []
        switch(searchTypeCombo.currentIndex) {
            case 0: types = ["track", "artist", "album", "playlist"]; break
            case 1: types = ["track"]; break
            case 2: types = ["artist"]; break
            case 3: types = ["album"]; break
            case 4: types = ["playlist"]; break
        }

        SpotifyAPI.search(searchField.text, types, function(data) {
            searching = false
            console.log("Search results received")

            // Process tracks
            if (data.tracks) {
                for (var i = 0; i < data.tracks.items.length; i++) {
                    var track = data.tracks.items[i]
                    var artistName = track.artists && track.artists.length > 0 ? track.artists[0].name : ""
                    var imageUrl = track.album && track.album.images && track.album.images.length > 0 ? track.album.images[0].url : ""

                    resultsModel.append({
                        id: track.id,
                        name: track.name,
                        subtitle: artistName + " - " + track.album.name,
                        type: "track",
                        uri: track.uri,
                        imageUrl: imageUrl
                    })
                }
            }

            // Process artists
            if (data.artists) {
                for (var j = 0; j < data.artists.items.length; j++) {
                    var artist = data.artists.items[j]
                    var artistImageUrl = artist.images && artist.images.length > 0 ? artist.images[0].url : ""

                    resultsModel.append({
                        id: artist.id,
                        name: artist.name,
                        subtitle: qsTr("Artist"),
                        type: "artist",
                        uri: artist.uri,
                        imageUrl: artistImageUrl
                    })
                }
            }

            // Process albums
            if (data.albums) {
                for (var k = 0; k < data.albums.items.length; k++) {
                    var album = data.albums.items[k]
                    var albumArtist = album.artists && album.artists.length > 0 ? album.artists[0].name : ""
                    var albumImageUrl = album.images && album.images.length > 0 ? album.images[0].url : ""

                    resultsModel.append({
                        id: album.id,
                        name: album.name,
                        subtitle: albumArtist,
                        type: "album",
                        uri: album.uri,
                        imageUrl: albumImageUrl
                    })
                }
            }

            // Process playlists
            if (data.playlists) {
                for (var l = 0; l < data.playlists.items.length; l++) {
                    var playlist = data.playlists.items[l]
                    var playlistImageUrl = playlist.images && playlist.images.length > 0 ? playlist.images[0].url : ""

                    resultsModel.append({
                        id: playlist.id,
                        name: playlist.name,
                        subtitle: qsTr("%n track(s)", "", playlist.tracks.total),
                        type: "playlist",
                        uri: playlist.uri,
                        imageUrl: playlistImageUrl
                    })
                }
            }
        }, function(error) {
            searching = false
            console.error("Search failed:", error)
        })
    }
}
