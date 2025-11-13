import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components" 1.0

BackgroundItem {
    id: miniPlayer
    height: visible ? Theme.itemSizeMedium : 0
    width: parent.width
    visible: PlaybackManager.trackName !== ""

    Behavior on height {
        NumberAnimation {
            duration: 200
            easing.type: Easing.InOutQuad
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.rgba(Theme.highlightBackgroundColor, 0.1)
        opacity: miniPlayer.highlighted ? 0.3 : 0.2

        Behavior on opacity {
            NumberAnimation { duration: 100 }
        }
    }

    Row {
        anchors {
            fill: parent
            leftMargin: Theme.horizontalPageMargin
            rightMargin: Theme.horizontalPageMargin
        }
        spacing: Theme.paddingMedium

        // Album artwork
        Image {
            id: albumArt
            width: height
            height: parent.height - Theme.paddingSmall * 2
            anchors.verticalCenter: parent.verticalCenter
            source: PlaybackManager.albumImageUrl || ""
            fillMode: Image.PreserveAspectCrop
            smooth: true
            opacity: status === Image.Ready ? 1.0 : 0.0

            Behavior on opacity {
                FadeAnimation { duration: 300 }
            }

            Rectangle {
                anchors.fill: parent
                color: Theme.rgba(Theme.highlightBackgroundColor, 0.1)
                visible: !albumArt.source || albumArt.status !== Image.Ready
                radius: Theme.paddingSmall / 2

                Icon {
                    anchors.centerIn: parent
                    source: "image://theme/icon-m-music"
                    color: Theme.secondaryColor
                }
            }

            layer.enabled: true
            layer.effect: ShaderEffect {
                property variant source: albumArt
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

        // Track info
        Column {
            width: parent.width - albumArt.width - playPauseButton.width - parent.spacing * 2
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.paddingSmall / 2

            Label {
                width: parent.width
                text: PlaybackManager.trackName
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeSmall
                truncationMode: TruncationMode.Fade
                maximumLineCount: 1
            }

            Label {
                width: parent.width
                text: PlaybackManager.artistName
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                truncationMode: TruncationMode.Fade
                maximumLineCount: 1
            }

            // Progress bar
            Rectangle {
                width: parent.width
                height: 2
                color: Theme.rgba(Theme.highlightColor, 0.2)
                radius: 1

                Rectangle {
                    width: parent.width * (PlaybackManager.progressMs / Math.max(PlaybackManager.durationMs, 1))
                    height: parent.height
                    color: Theme.highlightColor
                    radius: 1
                }
            }
        }

        // Play/Pause button
        IconButton {
            id: playPauseButton
            anchors.verticalCenter: parent.verticalCenter
            icon.source: PlaybackManager.isPlaying ? "image://theme/icon-m-pause" : "image://theme/icon-m-play"
            onClicked: {
                PlaybackManager.togglePlayback()
            }
        }
    }

    onClicked: {
        pageStack.push(Qt.resolvedUrl("../pages/PlayerPage.qml"))
    }
}
