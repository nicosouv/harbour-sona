import QtQuick 2.0
import Sailfish.Silica 1.0
import Amber.Web.Authorization 1.0
import QtQuick.LocalStorage 2.0
import "../config.js" as Config
import "../js/SpotifyAPI.js" as SpotifyAPI

Page {
    id: page

    property string accessToken: ""
    property bool isAuthenticated: false
    property string userName: ""
    property string userEmail: ""

    // Helper to get/set persistent data using LocalStorage
    function getCodeVerifier() {
        var db = LocalStorage.openDatabaseSync("SonaOAuth", "1.0", "OAuth state storage", 1000000)
        var value = ""
        db.transaction(function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS oauth(key TEXT PRIMARY KEY, value TEXT)')
            var rs = tx.executeSql('SELECT value FROM oauth WHERE key=?', ['codeVerifier'])
            if (rs.rows.length > 0) {
                value = rs.rows.item(0).value
            }
        })
        return value
    }

    function setCodeVerifier(value) {
        var db = LocalStorage.openDatabaseSync("SonaOAuth", "1.0", "OAuth state storage", 1000000)
        db.transaction(function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS oauth(key TEXT PRIMARY KEY, value TEXT)')
            tx.executeSql('INSERT OR REPLACE INTO oauth(key, value) VALUES(?, ?)', ['codeVerifier', value])
        })
    }

    function clearCodeVerifier() {
        var db = LocalStorage.openDatabaseSync("SonaOAuth", "1.0", "OAuth state storage", 1000000)
        db.transaction(function(tx) {
            tx.executeSql('DELETE FROM oauth WHERE key=?', ['codeVerifier'])
        })
    }

    // Helper function to parse URL parameters
    function parseUrlParams(url) {
        var params = {}
        var queryStart = url.indexOf('?')
        if (queryStart === -1) return params

        var queryString = url.substring(queryStart + 1)
        var pairs = queryString.split('&')

        for (var i = 0; i < pairs.length; i++) {
            var pair = pairs[i].split('=')
            if (pair.length === 2) {
                params[decodeURIComponent(pair[0])] = decodeURIComponent(pair[1])
            }
        }
        return params
    }

    Component.onCompleted: {
        // Check if app was launched with a callback URL
        if (typeof commandLineArguments !== 'undefined' && commandLineArguments.length > 1) {
            var callbackUrl = commandLineArguments[1]
            console.log("Received callback URL:", callbackUrl)

            if (callbackUrl.indexOf("harbour-sona://callback") === 0) {
                // Parse the authorization code from the callback URL
                var params = parseUrlParams(callbackUrl)

                if (params.code) {
                    console.log("Authorization code received, exchanging for token...")
                    var storedVerifier = getCodeVerifier()
                    console.log("Using stored code verifier:", storedVerifier.substring(0, 10) + "...")

                    // Exchange the code for an access token
                    SpotifyAPI.exchangeCodeForToken(
                        params.code,
                        storedVerifier,
                        Config.SPOTIFY_CLIENT_ID,
                        Config.SPOTIFY_CLIENT_SECRET,
                        oauth2.redirectUri,
                        function(tokenResponse) {
                            console.log("Access token received!")
                            page.accessToken = tokenResponse.access_token
                            page.isAuthenticated = true

                            // Clear the stored code verifier (security best practice)
                            clearCodeVerifier()

                            // Set token in API client
                            SpotifyAPI.setAccessToken(tokenResponse.access_token)

                            // Get user profile
                            SpotifyAPI.getUserProfile(function(profile) {
                                console.log("User profile:", profile.display_name)
                                page.userName = profile.display_name || profile.id
                                page.userEmail = profile.email || ""
                            }, function(error) {
                                console.error("Failed to get user profile:", error)
                            })
                        },
                        function(error) {
                            console.error("Token exchange failed:", error)
                        }
                    )
                } else if (params.error) {
                    console.error("OAuth error:", params.error, params.error_description || "")
                }
            }
        }
    }

    OAuth2AcPkce {
        id: oauth2

        clientId: Config.SPOTIFY_CLIENT_ID
        clientSecret: Config.SPOTIFY_CLIENT_SECRET

        authorizationEndpoint: "https://accounts.spotify.com/authorize"
        tokenEndpoint: "https://accounts.spotify.com/api/token"

        scopes: [
            // Playback
            "user-read-playback-state",
            "user-modify-playback-state",
            "user-read-currently-playing",
            // Library
            "user-library-read",
            "user-library-modify",
            // Playlists
            "playlist-read-private",
            "playlist-read-collaborative",
            "playlist-modify-public",
            "playlist-modify-private",
            // Listening History
            "user-read-recently-played",
            "user-top-read",
            // Follow
            "user-follow-read",
            "user-follow-modify",
            // User Profile
            "user-read-email",
            "user-read-private",
            // Podcasts
            "user-library-read",
            "user-library-modify",
            // Streaming (for Web Playback SDK - not used but doesn't hurt)
            "streaming",
            "app-remote-control"
        ]

        redirectUri: "harbour-sona://callback"

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

        onErrorOccurred: {
            console.log("OAuth2 error occurred:", error)
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
                        // Store the code verifier before opening browser
                        setCodeVerifier(oauth2.codeVerifier)
                        console.log("Stored code verifier for later use:", oauth2.codeVerifier.substring(0, 10) + "...")
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
