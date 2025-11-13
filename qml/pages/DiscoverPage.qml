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
                onClicked: loadAll()
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

            // Featured Playlists
            Column {
                width: parent.width
                spacing: Theme.paddingSmall

                Label {
                    x: Theme.horizontalPageMargin
                    text: qsTr("Featured Playlists")
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeLarge
                    font.bold: true
                }

                SilicaListView {
                    id: featuredView
                    width: parent.width
                    height: Theme.itemSizeHuge + Theme.paddingLarge
                    orientation: ListView.Horizontal
                    clip: true

                    model: ListModel {
                        id: featuredModel
                    }

                    delegate: BackgroundItem {
                        width: Theme.itemSizeHuge * 1.5
                        height: Theme.itemSizeHuge

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

                                    Icon {
                                        anchors.centerIn: parent
                                        source: "image://theme/icon-l-music"
                                        color: Theme.secondaryColor
                                    }
                                }
                            }

                            Label {
                                width: parent.width
                                text: model.name
                                color: Theme.primaryColor
                                font.pixelSize: Theme.fontSizeSmall
                                truncationMode: TruncationMode.Fade
                                maximumLineCount: 2
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
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

                    HorizontalScrollDecorator {}
                }
            }

            // New Releases
            Column {
                width: parent.width
                spacing: Theme.paddingSmall

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
                    height: Theme.itemSizeHuge + Theme.paddingLarge
                    orientation: ListView.Horizontal
                    clip: true

                    model: ListModel {
                        id: newReleasesModel
                    }

                    delegate: BackgroundItem {
                        width: Theme.itemSizeHuge * 1.5
                        height: Theme.itemSizeHuge

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

                                    Icon {
                                        anchors.centerIn: parent
                                        source: "image://theme/icon-l-music"
                                        color: Theme.secondaryColor
                                    }
                                }
                            }

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

                        onClicked: {
                            PlaybackManager.play(null, model.uri, null)
                        }
                    }

                    HorizontalScrollDecorator {}
                }
            }

            // Categories
            Column {
                width: parent.width
                spacing: Theme.paddingSmall

                Label {
                    x: Theme.horizontalPageMargin
                    text: qsTr("Browse Categories")
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeLarge
                    font.bold: true
                }

                Grid {
                    width: parent.width - Theme.horizontalPageMargin * 2
                    x: Theme.horizontalPageMargin
                    columns: 2
                    spacing: Theme.paddingMedium

                    Repeater {
                        model: ListModel {
                            id: categoriesModel
                        }

                        BackgroundItem {
                            width: (parent.width - Theme.paddingMedium) / 2
                            height: Theme.itemSizeHuge

                            Rectangle {
                                anchors.fill: parent
                                color: Theme.rgba(Theme.highlightBackgroundColor, 0.1)
                                radius: Theme.paddingSmall

                                Image {
                                    anchors.fill: parent
                                    source: model.imageUrl || ""
                                    fillMode: Image.PreserveAspectCrop
                                    smooth: true
                                    opacity: 0.6

                                    Rectangle {
                                        anchors.fill: parent
                                        color: Theme.rgba(Theme.highlightBackgroundColor, 0.2)
                                        visible: !parent.source || parent.status !== Image.Ready
                                    }
                                }

                                Label {
                                    anchors.centerIn: parent
                                    text: model.name
                                    color: Theme.primaryColor
                                    font.pixelSize: Theme.fontSizeMedium
                                    font.bold: true
                                }
                            }

                            onClicked: {
                                console.log("Category clicked:", model.id)
                                // Could load category playlists here
                            }
                        }
                    }
                }
            }
        }

        VerticalScrollDecorator {}
    }

    function loadAll() {
        loadFeaturedPlaylists()
        loadNewReleases()
        loadCategories()
    }

    function loadFeaturedPlaylists() {
        loading = true
        featuredModel.clear()

        SpotifyAPI.getFeaturedPlaylists(function(data) {
            loading = false

            if (data && data.playlists && data.playlists.items) {
                for (var i = 0; i < Math.min(data.playlists.items.length, 10); i++) {
                    var playlist = data.playlists.items[i]
                    var imageUrl = playlist.images && playlist.images.length > 0 ?
                                   playlist.images[0].url : ""

                    featuredModel.append({
                        id: playlist.id,
                        name: playlist.name,
                        imageUrl: imageUrl,
                        uri: playlist.uri
                    })
                }
            }
        }, function(error) {
            loading = false
            console.error("Failed to load featured playlists:", error)
        }, 20, 0)
    }

    function loadNewReleases() {
        loading = true
        newReleasesModel.clear()

        SpotifyAPI.getNewReleases(function(data) {
            loading = false

            if (data && data.albums && data.albums.items) {
                for (var i = 0; i < Math.min(data.albums.items.length, 10); i++) {
                    var album = data.albums.items[i]
                    var imageUrl = album.images && album.images.length > 0 ?
                                   album.images[0].url : ""
                    var artist = album.artists && album.artists.length > 0 ?
                                 album.artists[0].name : ""

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

    function loadCategories() {
        loading = true
        categoriesModel.clear()

        SpotifyAPI.getCategories(function(data) {
            loading = false

            if (data && data.categories && data.categories.items) {
                for (var i = 0; i < Math.min(data.categories.items.length, 10); i++) {
                    var category = data.categories.items[i]
                    var imageUrl = category.icons && category.icons.length > 0 ?
                                   category.icons[0].url : ""

                    categoriesModel.append({
                        id: category.id,
                        name: category.name,
                        imageUrl: imageUrl
                    })
                }
            }
        }, function(error) {
            loading = false
            console.error("Failed to load categories:", error)
        }, 20, 0)
    }

    Component.onCompleted: {
        loadAll()
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
