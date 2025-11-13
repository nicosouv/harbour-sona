import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/SpotifyAPI.js" as SpotifyAPI
import "../components" 1.0

Page {
    id: page

    property string artistId: ""
    property string artistName: ""
    property string artistImageUrl: ""
    property bool loading: false
    property bool isFollowing: false

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
                onClicked: loadAllData()
            }
        }

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: artistName
            }

            // Artist header
            Column {
                width: parent.width
                spacing: Theme.paddingMedium

                Image {
                    id: artistImage
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Math.min(parent.width - Theme.horizontalPageMargin * 2, Screen.width * 0.5)
                    height: width
                    source: artistImageUrl || ""
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
                            width: Theme.iconSizeExtraLarge
                            height: Theme.iconSizeExtraLarge
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

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: Theme.paddingMedium

                    Button {
                        text: qsTr("Play Artist")
                        onClicked: {
                            var artistUri = "spotify:artist:" + artistId
                            PlaybackManager.play(null, artistUri, null, function() {
                                console.log("Playing artist radio")
                            })
                        }
                    }

                    Button {
                        text: isFollowing ? qsTr("Unfollow") : qsTr("Follow")
                        onClicked: {
                            if (isFollowing) {
                                SpotifyAPI.unfollowArtist(artistId, function() {
                                    console.log("Unfollowed artist")
                                    isFollowing = false
                                })
                            } else {
                                SpotifyAPI.followArtist(artistId, function() {
                                    console.log("Followed artist")
                                    isFollowing = true
                                })
                            }
                        }
                    }
                }
            }

            BusyIndicator {
                size: BusyIndicatorSize.Large
                anchors.horizontalCenter: parent.horizontalCenter
                running: loading
                visible: loading
            }

            // Top Tracks
            Column {
                width: parent.width
                spacing: Theme.paddingSmall

                Label {
                    x: Theme.horizontalPageMargin
                    text: qsTr("Popular")
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeLarge
                    font.bold: true
                }

                Repeater {
                    model: ListModel {
                        id: topTracksModel
                    }

                    ListItem {
                        contentHeight: Theme.itemSizeMedium

                        Row {
                            anchors.fill: parent
                            anchors.margins: Theme.paddingMedium
                            spacing: Theme.paddingMedium

                            Label {
                                width: Theme.paddingLarge * 2
                                text: (index + 1).toString()
                                color: Theme.secondaryColor
                                font.pixelSize: Theme.fontSizeLarge
                                horizontalAlignment: Text.AlignHCenter
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Image {
                                id: trackImage
                                width: height
                                height: parent.height - Theme.paddingSmall
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
                                width: parent.width - Theme.paddingLarge * 2 - trackImage.width - parent.spacing * 2
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
                                    text: model.album
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
                }
            }

            // Albums
            Column {
                width: parent.width
                spacing: Theme.paddingSmall

                Label {
                    x: Theme.horizontalPageMargin
                    text: qsTr("Albums")
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeLarge
                    font.bold: true
                }

                SilicaListView {
                    width: parent.width
                    height: Math.min(Theme.itemSizeLarge * 3, albumsModel.count * Theme.itemSizeLarge)
                    clip: true

                    model: ListModel {
                        id: albumsModel
                    }

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
                                    text: model.releaseDate
                                    color: Theme.secondaryColor
                                    font.pixelSize: Theme.fontSizeSmall
                                }
                            }
                        }

                        onClicked: {
                            pageStack.push(Qt.resolvedUrl("AlbumDetailsPage.qml"), {
                                albumId: model.id,
                                albumName: model.name,
                                albumArtist: artistName,
                                albumImageUrl: model.imageUrl,
                                albumUri: model.uri
                            })
                        }
                    }
                }
            }

        }

        VerticalScrollDecorator {}
    }

    function loadAllData() {
        loadTopTracks()
        loadAlbums()
    }

    function loadTopTracks() {
        loading = true
        topTracksModel.clear()

        SpotifyAPI.getArtistTopTracks(artistId, "US", function(data) {
            loading = false

            if (data && data.tracks) {
                for (var i = 0; i < Math.min(data.tracks.length, 5); i++) {
                    var track = data.tracks[i]
                    var imageUrl = track.album && track.album.images && track.album.images.length > 0 ?
                                   track.album.images[track.album.images.length - 1].url : ""

                    topTracksModel.append({
                        id: track.id,
                        name: track.name,
                        album: track.album ? track.album.name : "",
                        uri: track.uri,
                        imageUrl: imageUrl
                    })
                }
            }
        }, function(error) {
            loading = false
            console.error("Failed to load top tracks:", error)
        })
    }

    function loadAlbums() {
        loading = true
        albumsModel.clear()

        SpotifyAPI.getArtistAlbums(artistId, function(data) {
            loading = false

            if (data && data.items) {
                for (var i = 0; i < Math.min(data.items.length, 10); i++) {
                    var album = data.items[i]
                    var imageUrl = album.images && album.images.length > 0 ? album.images[0].url : ""

                    albumsModel.append({
                        id: album.id,
                        name: album.name,
                        releaseDate: album.release_date || "",
                        uri: album.uri,
                        imageUrl: imageUrl
                    })
                }
            }
        }, function(error) {
            loading = false
            console.error("Failed to load albums:", error)
        }, 20, 0)
    }


    Component.onCompleted: {
        loadAllData()
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
