import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/SpotifyAPI.js" as SpotifyAPI
import "../components" 1.0

Page {
    id: page

    property string artistId: ""
    property string artistName: ""
    property string artistImageUrl: ""

    SilicaFlickable {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: miniPlayer.top
        }
        contentHeight: column.height

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: artistName
            }

            Image {
                id: artistImage
                anchors.horizontalCenter: parent.horizontalCenter
                width: Math.min(parent.width - Theme.horizontalPageMargin * 2, Screen.width * 0.6)
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
                        source: "image://theme/icon-l-contact"
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

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Play Artist Radio")
                onClicked: {
                    // Play artist radio by using their URI
                    var artistUri = "spotify:artist:" + artistId
                    SpotifyAPI.play(null, artistUri, null, function() {
                        console.log("Playing artist radio")
                        pageStack.pop()
                    }, function(error) {
                        console.error("Failed to play artist radio:", error)
                    })
                }
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                text: qsTr("Artist page - more features coming soon!")
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
        }

        VerticalScrollDecorator {}
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
