import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/SpotifyAPI.js" as SpotifyAPI
import "../components" 1.0

Page {
    id: page

    property int currentTab: 0  // 0=Tracks, 1=Albums, 2=Artists, 3=Shows
    property bool loading: false

    // Models defined at page level so they can be accessed by functions
    ListModel {
        id: tracksModel
    }

    ListModel {
        id: albumsModel
    }

    ListModel {
        id: artistsModel
    }

    ListModel {
        id: showsModel
    }

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
                onClicked: {
                    if (currentTab === 0) loadSavedTracks()
                    else if (currentTab === 1) loadSavedAlbums()
                    else if (currentTab === 2) loadFollowedArtists()
                    else if (currentTab === 3) loadSavedShows()
                }
            }
        }

        Column {
            id: column
            width: parent.width

            PageHeader {
                title: qsTr("Library")
            }

            // Tab buttons
            Row {
                width: parent.width
                height: Theme.itemSizeSmall

                BackgroundItem {
                    width: parent.width / 4
                    height: parent.height
                    highlighted: currentTab === 0 || down

                    Label {
                        anchors.centerIn: parent
                        text: qsTr("Tracks")
                        color: currentTab === 0 ? Theme.highlightColor : Theme.primaryColor
                        font.pixelSize: Theme.fontSizeExtraSmall
                        font.bold: currentTab === 0
                    }

                    Rectangle {
                        anchors {
                            left: parent.left
                            right: parent.right
                            bottom: parent.bottom
                        }
                        height: 2
                        color: Theme.highlightColor
                        visible: currentTab === 0
                    }

                    onClicked: {
                        currentTab = 0
                        tracksLoader.active = true
                        loadSavedTracks()
                    }
                }

                BackgroundItem {
                    width: parent.width / 4
                    height: parent.height
                    highlighted: currentTab === 1 || down

                    Label {
                        anchors.centerIn: parent
                        text: qsTr("Albums")
                        color: currentTab === 1 ? Theme.highlightColor : Theme.primaryColor
                        font.pixelSize: Theme.fontSizeExtraSmall
                        font.bold: currentTab === 1
                    }

                    Rectangle {
                        anchors {
                            left: parent.left
                            right: parent.right
                            bottom: parent.bottom
                        }
                        height: 2
                        color: Theme.highlightColor
                        visible: currentTab === 1
                    }

                    onClicked: {
                        currentTab = 1
                        albumsLoader.active = true
                        loadSavedAlbums()
                    }
                }

                BackgroundItem {
                    width: parent.width / 4
                    height: parent.height
                    highlighted: currentTab === 2 || down

                    Label {
                        anchors.centerIn: parent
                        text: qsTr("Artists")
                        color: currentTab === 2 ? Theme.highlightColor : Theme.primaryColor
                        font.pixelSize: Theme.fontSizeExtraSmall
                        font.bold: currentTab === 2
                    }

                    Rectangle {
                        anchors {
                            left: parent.left
                            right: parent.right
                            bottom: parent.bottom
                        }
                        height: 2
                        color: Theme.highlightColor
                        visible: currentTab === 2
                    }

                    onClicked: {
                        currentTab = 2
                        artistsLoader.active = true
                        loadFollowedArtists()
                    }
                }

                BackgroundItem {
                    width: parent.width / 4
                    height: parent.height
                    highlighted: currentTab === 3 || down

                    Label {
                        anchors.centerIn: parent
                        text: qsTr("Shows")
                        color: currentTab === 3 ? Theme.highlightColor : Theme.primaryColor
                        font.pixelSize: Theme.fontSizeExtraSmall
                        font.bold: currentTab === 3
                    }

                    Rectangle {
                        anchors {
                            left: parent.left
                            right: parent.right
                            bottom: parent.bottom
                        }
                        height: 2
                        color: Theme.highlightColor
                        visible: currentTab === 3
                    }

                    onClicked: {
                        currentTab = 3
                        showsLoader.active = true
                        loadSavedShows()
                    }
                }
            }

            // Separator
            Rectangle {
                width: parent.width
                height: 1
                color: Theme.rgba(Theme.highlightColor, 0.2)
            }

            BusyIndicator {
                size: BusyIndicatorSize.Large
                anchors.horizontalCenter: parent.horizontalCenter
                running: loading
                visible: loading
            }

            // Tracks tab
            Loader {
                id: tracksLoader
                width: parent.width
                active: currentTab === 0
                visible: currentTab === 0

                sourceComponent: SilicaListView {
                    id: tracksView
                    height: Screen.height - column.y - Theme.itemSizeSmall * 2 - miniPlayer.height
                    clip: true

                    model: tracksModel

                    delegate: ListItem {
                        contentHeight: Theme.itemSizeMedium

                        Row {
                            anchors.fill: parent
                            anchors.margins: Theme.paddingMedium
                            spacing: Theme.paddingMedium

                            Image {
                                id: trackImage
                                width: height
                                height: parent.height
                                source: model.imageUrl || ""
                                fillMode: Image.PreserveAspectCrop
                                smooth: true

                                Rectangle {
                                    anchors.fill: parent
                                    color: Theme.rgba(Theme.highlightBackgroundColor, 0.1)
                                    visible: !trackImage.source || trackImage.status !== Image.Ready

                                    Icon {
                                        anchors.centerIn: parent
                                        source: "image://theme/icon-m-music"
                                        color: Theme.secondaryColor
                                    }
                                }
                            }

                            Column {
                                width: parent.width - trackImage.width - parent.spacing
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: Theme.paddingSmall / 2

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
                    }

                    VerticalScrollDecorator {}
                }
            }

            // Albums tab
            Loader {
                id: albumsLoader
                width: parent.width
                active: currentTab === 1
                visible: currentTab === 1

                sourceComponent: SilicaListView {
                    id: albumsView
                    height: Screen.height - column.y - Theme.itemSizeSmall * 2 - miniPlayer.height
                    clip: true

                    model: albumsModel

                    delegate: ListItem {
                        contentHeight: Theme.itemSizeLarge

                        Row {
                            anchors.fill: parent
                            anchors.margins: Theme.paddingMedium
                            spacing: Theme.paddingMedium

                            Image {
                                id: albumImage
                                width: height
                                height: parent.height
                                source: model.imageUrl || ""
                                fillMode: Image.PreserveAspectCrop
                                smooth: true

                                Rectangle {
                                    anchors.fill: parent
                                    color: Theme.rgba(Theme.highlightBackgroundColor, 0.1)
                                    visible: !albumImage.source || albumImage.status !== Image.Ready

                                    Icon {
                                        anchors.centerIn: parent
                                        source: "image://theme/icon-l-music"
                                        color: Theme.secondaryColor
                                    }
                                }
                            }

                            Column {
                                width: parent.width - albumImage.width - parent.spacing
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
                                    text: model.artist
                                    color: Theme.secondaryColor
                                    font.pixelSize: Theme.fontSizeSmall
                                    truncationMode: TruncationMode.Fade
                                    maximumLineCount: 1
                                }

                                Label {
                                    width: parent.width
                                    text: qsTr("%n track(s)", "", model.totalTracks)
                                    color: Theme.secondaryColor
                                    font.pixelSize: Theme.fontSizeExtraSmall
                                }
                            }
                        }

                        onClicked: {
                            pageStack.push(Qt.resolvedUrl("AlbumDetailsPage.qml"), {
                                albumId: model.id,
                                albumName: model.name,
                                albumArtist: model.artist,
                                albumImageUrl: model.imageUrl,
                                albumUri: model.uri
                            })
                        }
                    }

                    VerticalScrollDecorator {}
                }
            }

            // Artists tab
            Loader {
                id: artistsLoader
                width: parent.width
                active: currentTab === 2
                visible: currentTab === 2

                sourceComponent: SilicaListView {
                    id: artistsView
                    height: Screen.height - column.y - Theme.itemSizeSmall * 2 - miniPlayer.height
                    clip: true

                    model: artistsModel

                    delegate: ListItem {
                        contentHeight: Theme.itemSizeLarge

                        Row {
                            anchors.fill: parent
                            anchors.margins: Theme.paddingMedium
                            spacing: Theme.paddingMedium

                            Image {
                                id: artistImage
                                width: height
                                height: parent.height
                                source: model.imageUrl || ""
                                fillMode: Image.PreserveAspectCrop
                                smooth: true

                                Rectangle {
                                    anchors.fill: parent
                                    color: Theme.rgba(Theme.highlightBackgroundColor, 0.1)
                                    visible: !artistImage.source || artistImage.status !== Image.Ready
                                    radius: width / 2

                                    Icon {
                                        anchors.centerIn: parent
                                        source: "image://theme/icon-l-people"
                                        color: Theme.secondaryColor
                                    }
                                }

                                layer.enabled: true
                                layer.effect: ShaderEffect {
                                    property variant source: artistImage
                                    fragmentShader: "
                                        varying highp vec2 qt_TexCoord0;
                                        uniform sampler2D source;
                                        uniform lowp float qt_Opacity;
                                        void main() {
                                            highp vec2 center = vec2(0.5, 0.5);
                                            highp float dist = distance(qt_TexCoord0, center);
                                            if (dist > 0.5) {
                                                gl_FragColor = vec4(0.0);
                                            } else {
                                                lowp vec4 color = texture2D(source, qt_TexCoord0);
                                                gl_FragColor = color * qt_Opacity;
                                            }
                                        }
                                    "
                                }
                            }

                            Column {
                                width: parent.width - artistImage.width - parent.spacing
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
                                    text: model.genres
                                    color: Theme.secondaryColor
                                    font.pixelSize: Theme.fontSizeSmall
                                    truncationMode: TruncationMode.Fade
                                    maximumLineCount: 1
                                    visible: text.length > 0
                                }
                            }
                        }

                        onClicked: {
                            pageStack.push(Qt.resolvedUrl("ArtistPage.qml"), {
                                artistId: model.id,
                                artistName: model.name,
                                artistImageUrl: model.imageUrl
                            })
                        }
                    }

                    VerticalScrollDecorator {}
                }
            }

            // Shows tab
            Loader {
                id: showsLoader
                width: parent.width
                active: currentTab === 3
                visible: currentTab === 3

                sourceComponent: SilicaListView {
                    id: showsView
                    height: Screen.height - column.y - Theme.itemSizeSmall * 2 - miniPlayer.height
                    clip: true

                    model: showsModel

                    delegate: ListItem {
                        contentHeight: Theme.itemSizeLarge

                        Row {
                            anchors.fill: parent
                            anchors.margins: Theme.paddingMedium
                            spacing: Theme.paddingMedium

                            Image {
                                id: showImage
                                width: height
                                height: parent.height
                                source: model.imageUrl || ""
                                fillMode: Image.PreserveAspectCrop
                                smooth: true

                                Rectangle {
                                    anchors.fill: parent
                                    color: Theme.rgba(Theme.highlightBackgroundColor, 0.1)
                                    visible: !showImage.source || showImage.status !== Image.Ready

                                    Icon {
                                        anchors.centerIn: parent
                                        source: "image://theme/icon-l-music"
                                        color: Theme.secondaryColor
                                    }
                                }
                            }

                            Column {
                                width: parent.width - showImage.width - parent.spacing
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
                                    text: model.publisher
                                    color: Theme.secondaryColor
                                    font.pixelSize: Theme.fontSizeSmall
                                    truncationMode: TruncationMode.Fade
                                    maximumLineCount: 1
                                }

                                Label {
                                    width: parent.width
                                    text: qsTr("%n episode(s)", "", model.totalEpisodes)
                                    color: Theme.secondaryColor
                                    font.pixelSize: Theme.fontSizeExtraSmall
                                }
                            }
                        }

                        onClicked: {
                            // Open show details - could be implemented later
                            console.log("Show clicked:", model.id)
                        }
                    }

                    VerticalScrollDecorator {}
                }
            }
        }

        VerticalScrollDecorator {}
    }

    function loadSavedTracks() {
        loading = true
        tracksModel.clear()

        SpotifyAPI.getSavedTracks(function(data) {
            loading = false

            if (data && data.items) {
                for (var i = 0; i < data.items.length; i++) {
                    var track = data.items[i].track
                    var imageUrl = track.album && track.album.images && track.album.images.length > 0 ?
                                   track.album.images[track.album.images.length - 1].url : ""
                    var artist = track.artists && track.artists.length > 0 ? track.artists[0].name : ""

                    tracksModel.append({
                        id: track.id,
                        name: track.name,
                        artist: artist,
                        uri: track.uri,
                        imageUrl: imageUrl
                    })
                }
            }
        }, function(error) {
            loading = false
            console.error("Failed to load saved tracks:", error)
        }, 50, 0)
    }

    function loadSavedAlbums() {
        loading = true
        albumsModel.clear()

        SpotifyAPI.getSavedAlbums(function(data) {
            loading = false

            if (data && data.items) {
                for (var i = 0; i < data.items.length; i++) {
                    var album = data.items[i].album
                    var imageUrl = album.images && album.images.length > 0 ? album.images[0].url : ""
                    var artist = album.artists && album.artists.length > 0 ? album.artists[0].name : ""

                    albumsModel.append({
                        id: album.id,
                        name: album.name,
                        artist: artist,
                        uri: album.uri,
                        imageUrl: imageUrl,
                        totalTracks: album.total_tracks || 0
                    })
                }
            }
        }, function(error) {
            loading = false
            console.error("Failed to load saved albums:", error)
        }, 50, 0)
    }

    function loadFollowedArtists() {
        loading = true
        artistsModel.clear()

        SpotifyAPI.getFollowedArtists(function(data) {
            loading = false

            if (data && data.artists && data.artists.items) {
                for (var i = 0; i < data.artists.items.length; i++) {
                    var artist = data.artists.items[i]
                    var imageUrl = artist.images && artist.images.length > 0 ? artist.images[0].url : ""
                    var genres = artist.genres && artist.genres.length > 0 ? artist.genres.slice(0, 2).join(", ") : ""

                    artistsModel.append({
                        id: artist.id,
                        name: artist.name,
                        imageUrl: imageUrl,
                        genres: genres
                    })
                }
            }
        }, function(error) {
            loading = false
            console.error("Failed to load followed artists:", error)
        }, 50)
    }

    function loadSavedShows() {
        loading = true
        showsModel.clear()

        SpotifyAPI.getSavedShows(function(data) {
            loading = false

            if (data && data.items) {
                for (var i = 0; i < data.items.length; i++) {
                    var show = data.items[i].show
                    var imageUrl = show.images && show.images.length > 0 ? show.images[0].url : ""

                    showsModel.append({
                        id: show.id,
                        name: show.name,
                        publisher: show.publisher || "",
                        uri: show.uri,
                        imageUrl: imageUrl,
                        totalEpisodes: show.total_episodes || 0
                    })
                }
            }
        }, function(error) {
            loading = false
            console.error("Failed to load saved shows:", error)
        }, 50, 0)
    }

    Component.onCompleted: {
        loadSavedTracks()
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
