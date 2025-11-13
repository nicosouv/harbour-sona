import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/SpotifyAPI.js" as SpotifyAPI
import "../components" 1.0

Page {
    id: page

    property int currentTab: 0  // 0=Top Tracks, 1=Top Artists, 2=Recently Played
    property string timeRange: "medium_term"  // short_term, medium_term, long_term
    property bool loading: false

    ListModel {
        id: topTracksModel
    }

    ListModel {
        id: topArtistsModel
    }

    ListModel {
        id: recentlyPlayedModel
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
                    if (currentTab === 0) loadTopTracks()
                    else if (currentTab === 1) loadTopArtists()
                    else if (currentTab === 2) loadRecentlyPlayed()
                }
            }
        }

        Column {
            id: column
            width: parent.width

            PageHeader {
                title: qsTr("Your Stats")
            }

            // Time range selector
            Row {
                width: parent.width
                height: Theme.itemSizeSmall
                visible: currentTab !== 2

                BackgroundItem {
                    width: parent.width / 3
                    height: parent.height
                    highlighted: timeRange === "short_term" || down

                    Label {
                        anchors.centerIn: parent
                        text: qsTr("4 Weeks")
                        color: timeRange === "short_term" ? Theme.highlightColor : Theme.primaryColor
                        font.pixelSize: Theme.fontSizeSmall
                        font.bold: timeRange === "short_term"
                    }

                    Rectangle {
                        anchors {
                            left: parent.left
                            right: parent.right
                            bottom: parent.bottom
                        }
                        height: 2
                        color: Theme.highlightColor
                        visible: timeRange === "short_term"
                    }

                    onClicked: {
                        timeRange = "short_term"
                        if (currentTab === 0) loadTopTracks()
                        else if (currentTab === 1) loadTopArtists()
                    }
                }

                BackgroundItem {
                    width: parent.width / 3
                    height: parent.height
                    highlighted: timeRange === "medium_term" || down

                    Label {
                        anchors.centerIn: parent
                        text: qsTr("6 Months")
                        color: timeRange === "medium_term" ? Theme.highlightColor : Theme.primaryColor
                        font.pixelSize: Theme.fontSizeSmall
                        font.bold: timeRange === "medium_term"
                    }

                    Rectangle {
                        anchors {
                            left: parent.left
                            right: parent.right
                            bottom: parent.bottom
                        }
                        height: 2
                        color: Theme.highlightColor
                        visible: timeRange === "medium_term"
                    }

                    onClicked: {
                        timeRange = "medium_term"
                        if (currentTab === 0) loadTopTracks()
                        else if (currentTab === 1) loadTopArtists()
                    }
                }

                BackgroundItem {
                    width: parent.width / 3
                    height: parent.height
                    highlighted: timeRange === "long_term" || down

                    Label {
                        anchors.centerIn: parent
                        text: qsTr("All Time")
                        color: timeRange === "long_term" ? Theme.highlightColor : Theme.primaryColor
                        font.pixelSize: Theme.fontSizeSmall
                        font.bold: timeRange === "long_term"
                    }

                    Rectangle {
                        anchors {
                            left: parent.left
                            right: parent.right
                            bottom: parent.bottom
                        }
                        height: 2
                        color: Theme.highlightColor
                        visible: timeRange === "long_term"
                    }

                    onClicked: {
                        timeRange = "long_term"
                        if (currentTab === 0) loadTopTracks()
                        else if (currentTab === 1) loadTopArtists()
                    }
                }
            }

            // Tab buttons
            Row {
                width: parent.width
                height: Theme.itemSizeSmall

                BackgroundItem {
                    width: parent.width / 3
                    height: parent.height
                    highlighted: currentTab === 0 || down

                    Label {
                        anchors.centerIn: parent
                        text: qsTr("Tracks")
                        color: currentTab === 0 ? Theme.highlightColor : Theme.primaryColor
                        font.pixelSize: Theme.fontSizeSmall
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
                        loadTopTracks()
                    }
                }

                BackgroundItem {
                    width: parent.width / 3
                    height: parent.height
                    highlighted: currentTab === 1 || down

                    Label {
                        anchors.centerIn: parent
                        text: qsTr("Artists")
                        color: currentTab === 1 ? Theme.highlightColor : Theme.primaryColor
                        font.pixelSize: Theme.fontSizeSmall
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
                        loadTopArtists()
                    }
                }

                BackgroundItem {
                    width: parent.width / 3
                    height: parent.height
                    highlighted: currentTab === 2 || down

                    Label {
                        anchors.centerIn: parent
                        text: qsTr("Recent")
                        color: currentTab === 2 ? Theme.highlightColor : Theme.primaryColor
                        font.pixelSize: Theme.fontSizeSmall
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
                        loadRecentlyPlayed()
                    }
                }
            }

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

            // Top Tracks List
            SilicaListView {
                id: topTracksView
                width: parent.width
                height: Screen.height - column.y - Theme.itemSizeSmall * 2 - miniPlayer.height
                clip: true
                visible: currentTab === 0 && !loading

                model: topTracksModel

                delegate: ListItem {
                    contentHeight: Theme.itemSizeMedium

                    Row {
                        anchors.fill: parent
                        anchors.margins: Theme.paddingMedium
                        spacing: Theme.paddingMedium

                        Label {
                            width: Theme.paddingLarge * 2
                            anchors.verticalCenter: parent.verticalCenter
                            text: "#" + (model.index + 1)
                            color: model.index < 3 ? Theme.highlightColor : Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeLarge
                            font.bold: model.index < 3
                            horizontalAlignment: Text.AlignRight
                        }

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
                            }
                        }

                        Column {
                            width: parent.width - trackImage.width - Theme.paddingLarge * 2 - parent.spacing * 2
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

            // Top Artists List
            SilicaListView {
                id: topArtistsView
                width: parent.width
                height: Screen.height - column.y - Theme.itemSizeSmall * 2 - miniPlayer.height
                clip: true
                visible: currentTab === 1 && !loading

                model: topArtistsModel

                delegate: ListItem {
                    contentHeight: Theme.itemSizeLarge

                    Row {
                        anchors.fill: parent
                        anchors.margins: Theme.paddingMedium
                        spacing: Theme.paddingMedium

                        Label {
                            width: Theme.paddingLarge * 2
                            anchors.verticalCenter: parent.verticalCenter
                            text: "#" + (model.index + 1)
                            color: model.index < 3 ? Theme.highlightColor : Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeLarge
                            font.bold: model.index < 3
                            horizontalAlignment: Text.AlignRight
                        }

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
                            }

                            layer.enabled: true
                            layer.effect: ShaderEffect {
                                property variant source: artistImage
                                fragmentShader: "
                                    varying highp vec2 qt_TexCoord0;
                                    uniform sampler2D source;
                                    uniform lowp float qt_Opacity;
                                    void main() {
                                        highp vec2 pos = qt_TexCoord0 - vec2(0.5);
                                        if (length(pos) > 0.5) discard;
                                        lowp vec4 color = texture2D(source, qt_TexCoord0);
                                        gl_FragColor = color * qt_Opacity;
                                    }
                                "
                            }
                        }

                        Column {
                            width: parent.width - artistImage.width - Theme.paddingLarge * 2 - parent.spacing * 2
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
                                text: qsTr("%n follower(s)", "", model.followers)
                                color: Theme.secondaryColor
                                font.pixelSize: Theme.fontSizeExtraSmall
                            }

                            Label {
                                width: parent.width
                                text: model.genres
                                color: Theme.secondaryColor
                                font.pixelSize: Theme.fontSizeExtraSmall
                                truncationMode: TruncationMode.Fade
                                maximumLineCount: 1
                                visible: model.genres !== ""
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

            // Recently Played List
            SilicaListView {
                id: recentlyPlayedView
                width: parent.width
                height: Screen.height - column.y - Theme.itemSizeSmall * 2 - miniPlayer.height
                clip: true
                visible: currentTab === 2 && !loading

                model: recentlyPlayedModel

                delegate: ListItem {
                    contentHeight: Theme.itemSizeMedium

                    Row {
                        anchors.fill: parent
                        anchors.margins: Theme.paddingMedium
                        spacing: Theme.paddingMedium

                        Image {
                            id: recentImage
                            width: height
                            height: parent.height
                            source: model.imageUrl || ""
                            fillMode: Image.PreserveAspectCrop
                            smooth: true

                            Rectangle {
                                anchors.fill: parent
                                color: Theme.rgba(Theme.highlightBackgroundColor, 0.1)
                                visible: !recentImage.source || recentImage.status !== Image.Ready
                            }
                        }

                        Column {
                            width: parent.width - recentImage.width - parent.spacing
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

                            Label {
                                width: parent.width
                                text: model.playedAt
                                color: Theme.secondaryColor
                                font.pixelSize: Theme.fontSizeExtraSmall
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

        VerticalScrollDecorator {}
    }

    function loadTopTracks() {
        loading = true
        topTracksModel.clear()

        SpotifyAPI.getUserTopTracks(function(data) {
            loading = false

            if (data && data.items) {
                for (var i = 0; i < data.items.length; i++) {
                    var track = data.items[i]
                    var imageUrl = track.album && track.album.images && track.album.images.length > 0 ?
                                   track.album.images[track.album.images.length - 1].url : ""
                    var artist = track.artists && track.artists.length > 0 ? track.artists[0].name : ""

                    topTracksModel.append({
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
            console.error("Failed to load top tracks:", error)
        }, 50, 0, timeRange)
    }

    function loadTopArtists() {
        loading = true
        topArtistsModel.clear()

        SpotifyAPI.getUserTopArtists(function(data) {
            loading = false

            if (data && data.items) {
                for (var i = 0; i < data.items.length; i++) {
                    var artist = data.items[i]
                    var imageUrl = artist.images && artist.images.length > 0 ? artist.images[0].url : ""
                    var genres = artist.genres && artist.genres.length > 0 ?
                                 artist.genres.slice(0, 2).join(", ") : ""

                    topArtistsModel.append({
                        id: artist.id,
                        name: artist.name,
                        imageUrl: imageUrl,
                        followers: artist.followers ? artist.followers.total : 0,
                        genres: genres
                    })
                }
            }
        }, function(error) {
            loading = false
            console.error("Failed to load top artists:", error)
        }, 50, 0, timeRange)
    }

    function loadRecentlyPlayed() {
        loading = true
        recentlyPlayedModel.clear()

        SpotifyAPI.getRecentlyPlayed(function(data) {
            loading = false

            if (data && data.items) {
                for (var i = 0; i < data.items.length; i++) {
                    var item = data.items[i]
                    var track = item.track
                    var imageUrl = track.album && track.album.images && track.album.images.length > 0 ?
                                   track.album.images[track.album.images.length - 1].url : ""
                    var artist = track.artists && track.artists.length > 0 ? track.artists[0].name : ""

                    var playedAt = new Date(item.played_at)
                    var now = new Date()
                    var diff = Math.floor((now - playedAt) / 1000 / 60)  // minutes
                    var timeStr = ""
                    if (diff < 1) timeStr = qsTr("Just now")
                    else if (diff < 60) timeStr = qsTr("%n minute(s) ago", "", diff)
                    else if (diff < 1440) timeStr = qsTr("%n hour(s) ago", "", Math.floor(diff / 60))
                    else timeStr = qsTr("%n day(s) ago", "", Math.floor(diff / 1440))

                    recentlyPlayedModel.append({
                        id: track.id,
                        name: track.name,
                        artist: artist,
                        uri: track.uri,
                        imageUrl: imageUrl,
                        playedAt: timeStr
                    })
                }
            }
        }, function(error) {
            loading = false
            console.error("Failed to load recently played:", error)
        }, 50)
    }

    Component.onCompleted: {
        loadTopTracks()
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
