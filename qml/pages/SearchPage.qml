import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/SpotifyAPI.js" as SpotifyAPI
import "../components" 1.0

Page {
    id: page

    property bool searching: false

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
                text: qsTr("Clear Results")
                onClicked: resultsModel.clear()
            }
        }

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
                visible: searching
            }
        }
    }

    SilicaListView {
        id: resultsView
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            topMargin: column.height
        }

        model: ListModel {
            id: resultsModel
        }

        delegate: ListItem {
            id: listItem
            contentHeight: Theme.itemSizeLarge
            width: parent.width

            Row {
                anchors {
                    fill: parent
                    leftMargin: Theme.horizontalPageMargin
                    rightMargin: Theme.horizontalPageMargin
                    topMargin: Theme.paddingMedium
                    bottomMargin: Theme.paddingMedium
                }
                spacing: Theme.paddingMedium

                Image {
                    id: resultImage
                    width: Theme.itemSizeMedium
                    height: Theme.itemSizeMedium
                    source: model.imageUrl || ""
                    fillMode: Image.PreserveAspectCrop
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        anchors.fill: parent
                        color: Theme.rgba(Theme.highlightBackgroundColor, 0.1)
                        visible: !resultImage.source || resultImage.status !== Image.Ready

                        Icon {
                            anchors.centerIn: parent
                            source: model.type === "artist" ? "image://theme/icon-m-contact" :
                                   model.type === "album" ? "image://theme/icon-m-media-artists" :
                                   model.type === "playlist" ? "image://theme/icon-m-media-playlists" :
                                   "image://theme/icon-m-music"
                            color: Theme.secondaryColor
                        }
                    }
                }

                Column {
                    width: parent.width - resultImage.width - parent.spacing - Theme.horizontalPageMargin
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.paddingSmall

                    Label {
                        text: model.name
                        color: listItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                        font.pixelSize: Theme.fontSizeMedium
                        truncationMode: TruncationMode.Fade
                        width: parent.width
                        maximumLineCount: 1
                    }

                    Label {
                        text: model.subtitle
                        color: listItem.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                        font.pixelSize: Theme.fontSizeSmall
                        truncationMode: TruncationMode.Fade
                        width: parent.width
                        maximumLineCount: 1
                        visible: text.length > 0
                    }

                    Label {
                        text: model.type.charAt(0).toUpperCase() + model.type.slice(1)
                        color: Theme.rgba(Theme.highlightColor, 0.6)
                        font.pixelSize: Theme.fontSizeExtraSmall
                        font.bold: true
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
                } else if (model.type === "artist") {
                    pageStack.push(Qt.resolvedUrl("ArtistPage.qml"), {
                        artistId: model.id,
                        artistName: model.name,
                        artistImageUrl: model.imageUrl
                    })
                } else if (model.type === "album") {
                    SpotifyAPI.play(null, model.uri, null, function() {
                        console.log("Playing album:", model.name)
                    }, function(error) {
                        console.error("Failed to play album:", error)
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
                        subtitle: artistName + " • " + track.album.name,
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
                        subtitle: "",
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

    MiniPlayer {
        id: miniPlayer
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
    }
}
