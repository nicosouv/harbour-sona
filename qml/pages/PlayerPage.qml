import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/SpotifyAPI.js" as SpotifyAPI

Page {
    id: page

    property bool isPlaying: false
    property bool loading: false
    property string trackName: ""
    property string artistName: ""
    property string albumName: ""
    property string albumImageUrl: ""
    property int progressMs: 0
    property int durationMs: 0
    property bool shuffle: false
    property string repeatMode: "off"

    Timer {
        id: refreshTimer
        interval: 2000
        repeat: true
        running: page.status === PageStatus.Active
        onTriggered: loadCurrentPlayback()
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        PullDownMenu {
            MenuItem {
                text: qsTr("Refresh")
                onClicked: loadCurrentPlayback()
            }
        }

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingLarge * 2

            PageHeader {
                title: qsTr("Now Playing")
            }

            // Album artwork
            Item {
                width: parent.width
                height: albumImage.height + Theme.paddingLarge * 2

                Image {
                    id: albumImage
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Math.min(parent.width - Theme.horizontalPageMargin * 4, Screen.width * 0.7)
                    height: width
                    source: albumImageUrl || ""
                    fillMode: Image.PreserveAspectFit
                    smooth: true

                    Rectangle {
                        anchors.fill: parent
                        color: Theme.rgba(Theme.highlightBackgroundColor, 0.1)
                        visible: !albumImage.source || albumImage.status !== Image.Ready
                        radius: Theme.paddingSmall

                        Icon {
                            anchors.centerIn: parent
                            source: "image://theme/icon-l-music"
                            color: Theme.secondaryColor
                            width: Theme.iconSizeExtraLarge
                            height: Theme.iconSizeExtraLarge
                        }
                    }

                    layer.enabled: true
                    layer.effect: ShaderEffect {
                        property variant source: albumImage
                        fragmentShader: "
                            varying highp vec2 qt_TexCoord0;
                            uniform sampler2D source;
                            uniform lowp float qt_Opacity;
                            void main() {
                                lowp vec4 color = texture2D(source, qt_TexCoord0);
                                gl_FragColor = color * qt_Opacity;
                            }
                        "
                    }
                }

                BusyIndicator {
                    size: BusyIndicatorSize.Large
                    anchors.centerIn: albumImage
                    running: loading
                }
            }

            // Track info
            Column {
                width: parent.width
                spacing: Theme.paddingSmall

                Label {
                    x: Theme.horizontalPageMargin
                    width: parent.width - 2 * Theme.horizontalPageMargin
                    text: trackName || qsTr("No track playing")
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeLarge
                    font.bold: true
                    wrapMode: Text.WordWrap
                    maximumLineCount: 2
                    horizontalAlignment: Text.AlignHCenter
                }

                Label {
                    x: Theme.horizontalPageMargin
                    width: parent.width - 2 * Theme.horizontalPageMargin
                    text: artistName || ""
                    color: Theme.primaryColor
                    font.pixelSize: Theme.fontSizeMedium
                    wrapMode: Text.WordWrap
                    maximumLineCount: 1
                    horizontalAlignment: Text.AlignHCenter
                    visible: artistName !== ""
                }

                Label {
                    x: Theme.horizontalPageMargin
                    width: parent.width - 2 * Theme.horizontalPageMargin
                    text: albumName || ""
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeSmall
                    wrapMode: Text.WordWrap
                    maximumLineCount: 1
                    horizontalAlignment: Text.AlignHCenter
                    visible: albumName !== ""
                }
            }

            // Progress bar
            Column {
                width: parent.width
                spacing: Theme.paddingSmall

                Slider {
                    id: progressSlider
                    width: parent.width
                    minimumValue: 0
                    maximumValue: durationMs
                    value: progressMs
                    enabled: durationMs > 0
                    handleVisible: false

                    background: Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        x: progressSlider.leftMargin
                        width: progressSlider.width - progressSlider.leftMargin - progressSlider.rightMargin
                        height: Theme.paddingSmall / 2
                        radius: height / 2
                        color: Theme.rgba(Theme.highlightColor, 0.2)

                        Rectangle {
                            width: parent.width * (progressMs / Math.max(durationMs, 1))
                            height: parent.height
                            radius: height / 2
                            color: Theme.highlightColor
                        }
                    }
                }

                Row {
                    width: parent.width - Theme.horizontalPageMargin * 2
                    x: Theme.horizontalPageMargin

                    Label {
                        text: formatTime(progressMs)
                        font.pixelSize: Theme.fontSizeExtraSmall
                        color: Theme.secondaryColor
                    }

                    Item { width: parent.width - Theme.fontSizeExtraSmall * 10 }

                    Label {
                        text: formatTime(durationMs)
                        font.pixelSize: Theme.fontSizeExtraSmall
                        color: Theme.secondaryColor
                    }
                }
            }

            // Control buttons
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.paddingLarge

                IconButton {
                    icon.source: "image://theme/icon-m-shuffle"
                    icon.color: shuffle ? Theme.highlightColor : Theme.primaryColor
                    onClicked: {
                        SpotifyAPI.setShuffle(!shuffle, null, function() {
                            console.log("Shuffle toggled")
                            shuffle = !shuffle
                        }, function(error) {
                            console.error("Failed to toggle shuffle:", error)
                        })
                    }
                }

                IconButton {
                    icon.source: "image://theme/icon-m-previous"
                    onClicked: {
                        SpotifyAPI.previous(null, function() {
                            console.log("Previous track")
                            Qt.callLater(loadCurrentPlayback)
                        }, function(error) {
                            console.error("Failed to skip to previous:", error)
                        })
                    }
                }

                IconButton {
                    icon.source: isPlaying ? "image://theme/icon-l-pause" : "image://theme/icon-l-play"
                    icon.width: Theme.iconSizeExtraLarge
                    icon.height: Theme.iconSizeExtraLarge

                    Rectangle {
                        anchors.centerIn: parent
                        width: Theme.iconSizeExtraLarge * 1.5
                        height: width
                        radius: width / 2
                        color: Theme.rgba(Theme.highlightColor, 0.2)
                        z: -1
                    }

                    onClicked: {
                        if (isPlaying) {
                            SpotifyAPI.pause(null, function() {
                                console.log("Paused")
                                isPlaying = false
                            }, function(error) {
                                console.error("Failed to pause:", error)
                            })
                        } else {
                            SpotifyAPI.play(null, null, null, function() {
                                console.log("Playing")
                                isPlaying = true
                            }, function(error) {
                                console.error("Failed to play:", error)
                            })
                        }
                    }
                }

                IconButton {
                    icon.source: "image://theme/icon-m-next"
                    onClicked: {
                        SpotifyAPI.next(null, function() {
                            console.log("Next track")
                            Qt.callLater(loadCurrentPlayback)
                        }, function(error) {
                            console.error("Failed to skip to next:", error)
                        })
                    }
                }

                IconButton {
                    icon.source: "image://theme/icon-m-repeat"
                    icon.color: repeatMode !== "off" ? Theme.highlightColor : Theme.primaryColor

                    Label {
                        anchors.centerIn: parent
                        text: repeatMode === "track" ? "1" : ""
                        font.pixelSize: Theme.fontSizeExtraSmall
                        font.bold: true
                        color: Theme.highlightColor
                        visible: repeatMode === "track"
                    }

                    onClicked: {
                        var newMode = repeatMode === "off" ? "context" :
                                      repeatMode === "context" ? "track" : "off"
                        SpotifyAPI.setRepeat(newMode, null, function() {
                            console.log("Repeat mode:", newMode)
                            repeatMode = newMode
                        }, function(error) {
                            console.error("Failed to set repeat mode:", error)
                        })
                    }
                }
            }

            Item { height: Theme.paddingMedium }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                text: qsTr("Note: Playback requires Spotify Premium and an active device")
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
        }

        VerticalScrollDecorator {}
    }

    function formatTime(ms) {
        var seconds = Math.floor(ms / 1000)
        var minutes = Math.floor(seconds / 60)
        seconds = seconds % 60
        return minutes + ":" + (seconds < 10 ? "0" : "") + seconds
    }

    function loadCurrentPlayback() {
        loading = true

        SpotifyAPI.getCurrentPlayback(function(data) {
            loading = false

            if (data && data.item) {
                trackName = data.item.name
                artistName = data.item.artists && data.item.artists.length > 0 ?
                             data.item.artists[0].name : ""
                albumName = data.item.album ? data.item.album.name : ""
                albumImageUrl = data.item.album && data.item.album.images &&
                                data.item.album.images.length > 0 ?
                                data.item.album.images[0].url : ""
                isPlaying = data.is_playing
                progressMs = data.progress_ms || 0
                durationMs = data.item.duration_ms || 0
                shuffle = data.shuffle_state || false
                repeatMode = data.repeat_state || "off"
            } else {
                console.log("No active playback")
                trackName = ""
                artistName = ""
                albumName = ""
                albumImageUrl = ""
                isPlaying = false
                progressMs = 0
                durationMs = 0
            }
        }, function(error) {
            loading = false
            console.error("Failed to get current playback:", error)
        })
    }

    Component.onCompleted: {
        loadCurrentPlayback()
    }
}
