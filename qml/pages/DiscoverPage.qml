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

            // Browse Categories
            Column {
                width: parent.width
                spacing: Theme.paddingSmall
                visible: !loading

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
                    rowSpacing: Theme.paddingMedium

                    Repeater {
                        model: ListModel {
                            id: categoriesModel
                        }

                        BackgroundItem {
                            width: (parent.width - Theme.paddingMedium) / 2
                            height: Theme.itemSizeHuge

                            Rectangle {
                                anchors.fill: parent
                                radius: Theme.paddingMedium
                                color: Theme.rgba(Theme.highlightBackgroundColor, 0.1)

                                Image {
                                    anchors.fill: parent
                                    source: model.imageUrl || ""
                                    fillMode: Image.PreserveAspectCrop
                                    opacity: 0.3
                                    smooth: true
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    radius: Theme.paddingMedium
                                    gradient: Gradient {
                                        GradientStop { position: 0.0; color: "transparent" }
                                        GradientStop { position: 1.0; color: Theme.rgba("black", 0.7) }
                                    }
                                }

                                Label {
                                    anchors {
                                        left: parent.left
                                        right: parent.right
                                        bottom: parent.bottom
                                        margins: Theme.paddingMedium
                                    }
                                    text: model.name
                                    color: "white"
                                    font.pixelSize: Theme.fontSizeMedium
                                    font.bold: true
                                    truncationMode: TruncationMode.Fade
                                    maximumLineCount: 2
                                    wrapMode: Text.WordWrap
                                }
                            }

                            onClicked: {
                                console.log("Category clicked:", model.id)
                                pageStack.push(Qt.resolvedUrl("CategoryPlaylistsPage.qml"), {
                                    categoryId: model.id,
                                    categoryName: model.name
                                })
                            }
                        }
                    }
                }
            }

            Item { height: Theme.paddingLarge }
        }

        VerticalScrollDecorator {}
    }

    function loadAll() {
        loadNewReleases()
        loadCategories()
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

    function loadCategories() {
        categoriesModel.clear()

        SpotifyAPI.getCategories(function(data) {
            if (data && data.categories && data.categories.items) {
                console.log("Categories loaded:", data.categories.items.length)

                for (var i = 0; i < Math.min(data.categories.items.length, 10); i++) {
                    var category = data.categories.items[i]
                    var imageUrl = category.icons && category.icons.length > 0 ? category.icons[0].url : ""

                    categoriesModel.append({
                        id: category.id,
                        name: category.name,
                        imageUrl: imageUrl
                    })
                }
            }
        }, function(error) {
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
