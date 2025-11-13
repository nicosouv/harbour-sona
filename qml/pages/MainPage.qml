import QtQuick 2.0
import Sailfish.Silica 1.0
import Amber.Web.Authorization 1.0
import "../config.js" as Config
import "../js/SpotifyAPI.js" as SpotifyAPI

Page {
    id: page

    property string accessToken: ""
    property bool isAuthenticated: false
    property string userName: ""
    property string userEmail: ""

    OAuth2AcPkce {
        id: oauth2

        clientId: Config.SPOTIFY_CLIENT_ID
        clientSecret: Config.SPOTIFY_CLIENT_SECRET

        authorizationEndpoint: "https://accounts.spotify.com/authorize"
        tokenEndpoint: "https://accounts.spotify.com/api/token"

        scopes: [
            "user-read-playback-state",
            "user-modify-playback-state",
            "user-read-currently-playing",
            "user-library-read",
            "user-library-modify",
            "playlist-read-private",
            "playlist-read-collaborative"
        ]

        redirectListener.port: 8080
        redirectUri: "http://127.0.0.1:8080/callback"

        onReceivedAuthorizationCode: {
            console.log("Received authorization code, requesting token...")
        }

        onReceivedAccessToken: {
            console.log("Access token received!")
            page.accessToken = accessToken
            page.isAuthenticated = true

            // Set token in API client
            SpotifyAPI.setAccessToken(accessToken)

            // Get user profile
            SpotifyAPI.getUserProfile(function(profile) {
                console.log("User profile:", profile.display_name)
                page.userName = profile.display_name || profile.id
                page.userEmail = profile.email || ""
            }, function(error) {
                console.error("Failed to get user profile:", error)
            })
        }

        onFailed: {
            console.log("OAuth2 failed: " + errorMessage)
        }
    }

    SilicaFlickable {
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
        }

        contentHeight: column.height

        Column {
            id: column
            width: page.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr("Sona")
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                wrapMode: Text.WordWrap
                text: isAuthenticated ?
                    qsTr("Welcome, %1").arg(userName || "User") :
                    qsTr("Welcome to Sona - Spotify client for Sailfish OS")
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeExtraLarge
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: isAuthenticated ?
                    qsTr("Disconnect") :
                    qsTr("Connect to Spotify")
                visible: !isAuthenticated
                onClicked: {
                    if (!isAuthenticated) {
                        oauth2.authorizeInBrowser()
                    } else {
                        // Handle disconnect
                        page.accessToken = ""
                        page.isAuthenticated = false
                    }
                }
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                wrapMode: Text.WordWrap
                text: qsTr("Tap 'Connect to Spotify' to authenticate with your account.")
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
                visible: !isAuthenticated
            }

            // Navigation buttons
            Column {
                width: parent.width
                spacing: Theme.paddingMedium
                visible: isAuthenticated

                Button {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("My Playlists")
                    onClicked: pageStack.push(Qt.resolvedUrl("PlaylistsPage.qml"))
                }

                Button {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Now Playing")
                    onClicked: pageStack.push(Qt.resolvedUrl("PlayerPage.qml"))
                }

                Button {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Search")
                    onClicked: pageStack.push(Qt.resolvedUrl("SearchPage.qml"))
                }

                Button {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Disconnect")
                    onClicked: {
                        page.accessToken = ""
                        page.isAuthenticated = false
                        page.userName = ""
                        page.userEmail = ""
                    }
                }
            }
        }
    }
}
