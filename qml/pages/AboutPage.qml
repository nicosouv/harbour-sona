import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: page.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr("About")
            }

            // App icon and name
            Item {
                width: parent.width
                height: appIcon.height + Theme.paddingLarge * 2

                Icon {
                    id: appIcon
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: "image://theme/icon-l-music"
                    color: Theme.highlightColor
                    width: Theme.iconSizeExtraLarge * 1.5
                    height: Theme.iconSizeExtraLarge * 1.5
                }
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Sona"
                font.pixelSize: Theme.fontSizeHuge
                font.bold: true
                color: Theme.highlightColor
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Version 1.2.1")
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                text: qsTr("Your Spotify Companion")
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeLarge
            }

            Rectangle {
                width: parent.width - Theme.horizontalPageMargin * 2
                height: 1
                x: Theme.horizontalPageMargin
                color: Theme.rgba(Theme.highlightColor, 0.2)
            }

            SectionHeader {
                text: qsTr("What is Sona?")
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                wrapMode: Text.WordWrap
                text: qsTr("Sona is a remote control companion for Spotify. It allows you to browse your music library, discover new content, and control playback on your Spotify Connect devices.")
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeSmall
            }

            Rectangle {
                width: parent.width - Theme.horizontalPageMargin * 4
                height: noticeColumn.height + Theme.paddingLarge
                x: Theme.horizontalPageMargin * 2
                radius: Theme.paddingSmall
                color: Theme.rgba(Theme.highlightColor, 0.1)

                Column {
                    id: noticeColumn
                    anchors.centerIn: parent
                    width: parent.width - Theme.paddingLarge * 2
                    spacing: Theme.paddingSmall

                    Icon {
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: "image://theme/icon-m-info"
                        color: Theme.highlightColor
                        width: Theme.iconSizeMedium
                        height: Theme.iconSizeMedium
                    }

                    Label {
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        text: qsTr("Important: Sona does not play music directly. You need an active Spotify device (computer, phone, speaker) to stream audio.")
                        color: Theme.primaryColor
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }
                }
            }

            SectionHeader {
                text: qsTr("Features")
            }

            Column {
                width: parent.width
                spacing: Theme.paddingSmall

                Row {
                    x: Theme.horizontalPageMargin
                    width: parent.width - 2 * Theme.horizontalPageMargin
                    spacing: Theme.paddingMedium

                    Icon {
                        source: "image://theme/icon-s-checkmark"
                        color: Theme.highlightColor
                        width: Theme.iconSizeSmall
                        height: Theme.iconSizeSmall
                        anchors.top: parent.top
                        anchors.topMargin: Theme.paddingSmall / 2
                    }

                    Label {
                        width: parent.width - Theme.iconSizeSmall - Theme.paddingMedium
                        wrapMode: Text.WordWrap
                        text: qsTr("Secure OAuth2 authentication")
                        color: Theme.primaryColor
                        font.pixelSize: Theme.fontSizeSmall
                    }
                }

                Row {
                    x: Theme.horizontalPageMargin
                    width: parent.width - 2 * Theme.horizontalPageMargin
                    spacing: Theme.paddingMedium

                    Icon {
                        source: "image://theme/icon-s-checkmark"
                        color: Theme.highlightColor
                        width: Theme.iconSizeSmall
                        height: Theme.iconSizeSmall
                        anchors.top: parent.top
                        anchors.topMargin: Theme.paddingSmall / 2
                    }

                    Label {
                        width: parent.width - Theme.iconSizeSmall - Theme.paddingMedium
                        wrapMode: Text.WordWrap
                        text: qsTr("Browse your library, playlists, and saved content")
                        color: Theme.primaryColor
                        font.pixelSize: Theme.fontSizeSmall
                    }
                }

                Row {
                    x: Theme.horizontalPageMargin
                    width: parent.width - 2 * Theme.horizontalPageMargin
                    spacing: Theme.paddingMedium

                    Icon {
                        source: "image://theme/icon-s-checkmark"
                        color: Theme.highlightColor
                        width: Theme.iconSizeSmall
                        height: Theme.iconSizeSmall
                        anchors.top: parent.top
                        anchors.topMargin: Theme.paddingSmall / 2
                    }

                    Label {
                        width: parent.width - Theme.iconSizeSmall - Theme.paddingMedium
                        wrapMode: Text.WordWrap
                        text: qsTr("Discover new music and browse categories")
                        color: Theme.primaryColor
                        font.pixelSize: Theme.fontSizeSmall
                    }
                }

                Row {
                    x: Theme.horizontalPageMargin
                    width: parent.width - 2 * Theme.horizontalPageMargin
                    spacing: Theme.paddingMedium

                    Icon {
                        source: "image://theme/icon-s-checkmark"
                        color: Theme.highlightColor
                        width: Theme.iconSizeSmall
                        height: Theme.iconSizeSmall
                        anchors.top: parent.top
                        anchors.topMargin: Theme.paddingSmall / 2
                    }

                    Label {
                        width: parent.width - Theme.iconSizeSmall - Theme.paddingMedium
                        wrapMode: Text.WordWrap
                        text: qsTr("Search for tracks, artists, albums, and playlists")
                        color: Theme.primaryColor
                        font.pixelSize: Theme.fontSizeSmall
                    }
                }

                Row {
                    x: Theme.horizontalPageMargin
                    width: parent.width - 2 * Theme.horizontalPageMargin
                    spacing: Theme.paddingMedium

                    Icon {
                        source: "image://theme/icon-s-checkmark"
                        color: Theme.highlightColor
                        width: Theme.iconSizeSmall
                        height: Theme.iconSizeSmall
                        anchors.top: parent.top
                        anchors.topMargin: Theme.paddingSmall / 2
                    }

                    Label {
                        width: parent.width - Theme.iconSizeSmall - Theme.paddingMedium
                        wrapMode: Text.WordWrap
                        text: qsTr("Full playback control via Spotify Connect")
                        color: Theme.primaryColor
                        font.pixelSize: Theme.fontSizeSmall
                    }
                }

                Row {
                    x: Theme.horizontalPageMargin
                    width: parent.width - 2 * Theme.horizontalPageMargin
                    spacing: Theme.paddingMedium

                    Icon {
                        source: "image://theme/icon-s-checkmark"
                        color: Theme.highlightColor
                        width: Theme.iconSizeSmall
                        height: Theme.iconSizeSmall
                        anchors.top: parent.top
                        anchors.topMargin: Theme.paddingSmall / 2
                    }

                    Label {
                        width: parent.width - Theme.iconSizeSmall - Theme.paddingMedium
                        wrapMode: Text.WordWrap
                        text: qsTr("View your listening statistics and top content")
                        color: Theme.primaryColor
                        font.pixelSize: Theme.fontSizeSmall
                    }
                }

                Row {
                    x: Theme.horizontalPageMargin
                    width: parent.width - 2 * Theme.horizontalPageMargin
                    spacing: Theme.paddingMedium

                    Icon {
                        source: "image://theme/icon-s-checkmark"
                        color: Theme.highlightColor
                        width: Theme.iconSizeSmall
                        height: Theme.iconSizeSmall
                        anchors.top: parent.top
                        anchors.topMargin: Theme.paddingSmall / 2
                    }

                    Label {
                        width: parent.width - Theme.iconSizeSmall - Theme.paddingMedium
                        wrapMode: Text.WordWrap
                        text: qsTr("Create and manage playlists")
                        color: Theme.primaryColor
                        font.pixelSize: Theme.fontSizeSmall
                    }
                }

                Row {
                    x: Theme.horizontalPageMargin
                    width: parent.width - 2 * Theme.horizontalPageMargin
                    spacing: Theme.paddingMedium

                    Icon {
                        source: "image://theme/icon-s-checkmark"
                        color: Theme.highlightColor
                        width: Theme.iconSizeSmall
                        height: Theme.iconSizeSmall
                        anchors.top: parent.top
                        anchors.topMargin: Theme.paddingSmall / 2
                    }

                    Label {
                        width: parent.width - Theme.iconSizeSmall - Theme.paddingMedium
                        wrapMode: Text.WordWrap
                        text: qsTr("Device management and playback transfer")
                        color: Theme.primaryColor
                        font.pixelSize: Theme.fontSizeSmall
                    }
                }
            }

            Rectangle {
                width: parent.width - Theme.horizontalPageMargin * 2
                height: 1
                x: Theme.horizontalPageMargin
                color: Theme.rgba(Theme.highlightColor, 0.2)
            }

            SectionHeader {
                text: qsTr("Requirements")
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                wrapMode: Text.WordWrap
                text: qsTr("• A Spotify Premium account\n• An active Spotify device (computer, phone, speaker, etc.)\n• Internet connection")
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeSmall
            }

            Rectangle {
                width: parent.width - Theme.horizontalPageMargin * 2
                height: 1
                x: Theme.horizontalPageMargin
                color: Theme.rgba(Theme.highlightColor, 0.2)
            }

            SectionHeader {
                text: qsTr("License")
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                wrapMode: Text.WordWrap
                text: qsTr("MIT License\n\nCopyright (c) 2024")
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeSmall
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                wrapMode: Text.WordWrap
                text: qsTr("This app is not affiliated with or endorsed by Spotify AB.")
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                font.italic: true
            }

            Rectangle {
                width: parent.width - Theme.horizontalPageMargin * 2
                height: 1
                x: Theme.horizontalPageMargin
                color: Theme.rgba(Theme.highlightColor, 0.2)
            }

            Item { height: Theme.paddingLarge }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Made with ❤️ for Sailfish OS"
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeMedium
                font.bold: true
            }

            Item { height: Theme.paddingLarge }
        }

        VerticalScrollDecorator {}
    }
}
