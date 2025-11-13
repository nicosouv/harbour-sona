import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components" 1.0

Page {
    id: page

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        PullDownMenu {
            MenuItem {
                text: qsTr("Refresh")
                onClicked: PlaybackManager.refreshPlayback()
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
                    source: PlaybackManager.albumImageUrl || ""
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
                    running: PlaybackManager.loading
                }
            }

            // Track info
            Column {
                width: parent.width
                spacing: Theme.paddingSmall

                Label {
                    x: Theme.horizontalPageMargin
                    width: parent.width - 2 * Theme.horizontalPageMargin
                    text: PlaybackManager.trackName || qsTr("No track playing")
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
                    text: PlaybackManager.artistName || ""
                    color: Theme.primaryColor
                    font.pixelSize: Theme.fontSizeMedium
                    wrapMode: Text.WordWrap
                    maximumLineCount: 1
                    horizontalAlignment: Text.AlignHCenter
                    visible: PlaybackManager.artistName !== ""
                }

                Label {
                    x: Theme.horizontalPageMargin
                    width: parent.width - 2 * Theme.horizontalPageMargin
                    text: PlaybackManager.albumName || ""
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeSmall
                    wrapMode: Text.WordWrap
                    maximumLineCount: 1
                    horizontalAlignment: Text.AlignHCenter
                    visible: PlaybackManager.albumName !== ""
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
                    maximumValue: PlaybackManager.durationMs
                    value: PlaybackManager.progressMs
                    enabled: PlaybackManager.durationMs > 0
                    handleVisible: false

                    background: Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        x: progressSlider.leftMargin
                        width: progressSlider.width - progressSlider.leftMargin - progressSlider.rightMargin
                        height: Theme.paddingSmall / 2
                        radius: height / 2
                        color: Theme.rgba(Theme.highlightColor, 0.2)

                        Rectangle {
                            width: parent.width * (PlaybackManager.progressMs / Math.max(PlaybackManager.durationMs, 1))
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
                        text: formatTime(PlaybackManager.progressMs)
                        font.pixelSize: Theme.fontSizeExtraSmall
                        color: Theme.secondaryColor
                    }

                    Item { width: parent.width - Theme.fontSizeExtraSmall * 10 }

                    Label {
                        text: formatTime(PlaybackManager.durationMs)
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
                    icon.color: PlaybackManager.shuffle ? Theme.highlightColor : Theme.primaryColor
                    onClicked: {
                        PlaybackManager.toggleShuffle(null, function() {
                            console.log("Shuffle toggled")
                        })
                    }
                }

                IconButton {
                    icon.source: "image://theme/icon-m-previous"
                    onClicked: {
                        PlaybackManager.previous(null, function() {
                            console.log("Previous track")
                        })
                    }
                }

                IconButton {
                    icon.source: PlaybackManager.isPlaying ? "image://theme/icon-l-pause" : "image://theme/icon-l-play"
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
                        PlaybackManager.togglePlayback(function() {
                            console.log("Playback toggled")
                        })
                    }
                }

                IconButton {
                    icon.source: "image://theme/icon-m-next"
                    onClicked: {
                        PlaybackManager.next(null, function() {
                            console.log("Next track")
                        })
                    }
                }

                IconButton {
                    icon.source: "image://theme/icon-m-repeat"
                    icon.color: PlaybackManager.repeatMode !== "off" ? Theme.highlightColor : Theme.primaryColor

                    Label {
                        anchors.centerIn: parent
                        text: PlaybackManager.repeatMode === "track" ? "1" : ""
                        font.pixelSize: Theme.fontSizeExtraSmall
                        font.bold: true
                        color: Theme.highlightColor
                        visible: PlaybackManager.repeatMode === "track"
                    }

                    onClicked: {
                        PlaybackManager.cycleRepeat(null, function() {
                            console.log("Repeat mode:", PlaybackManager.repeatMode)
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
}
