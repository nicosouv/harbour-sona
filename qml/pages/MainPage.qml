import QtQuick 2.0
import Sailfish.Silica 1.0
import Amber.Web.Authorization 1.0
import QtQuick.LocalStorage 2.0
import "../config.js" as Config
import "../js/SpotifyAPI.js" as SpotifyAPI
import "../components" 1.0

Page {
    id: page

    property string accessToken: ""
    property string refreshToken: ""
    property bool isAuthenticated: false
    property string userName: ""
    property string userEmail: ""
    property bool hasCheckedDevices: false

    // Helper to get/set persistent data using LocalStorage
    function getStoredValue(key) {
        var db = LocalStorage.openDatabaseSync("SonaOAuth", "1.0", "OAuth state storage", 1000000)
        var value = ""
        db.transaction(function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS oauth(key TEXT PRIMARY KEY, value TEXT)')
            var rs = tx.executeSql('SELECT value FROM oauth WHERE key=?', [key])
            if (rs.rows.length > 0) {
                value = rs.rows.item(0).value
            }
        })
        return value
    }

    function setStoredValue(key, value) {
        var db = LocalStorage.openDatabaseSync("SonaOAuth", "1.0", "OAuth state storage", 1000000)
        db.transaction(function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS oauth(key TEXT PRIMARY KEY, value TEXT)')
            tx.executeSql('INSERT OR REPLACE INTO oauth(key, value) VALUES(?, ?)', [key, value])
        })
    }

    function clearStoredValue(key) {
        var db = LocalStorage.openDatabaseSync("SonaOAuth", "1.0", "OAuth state storage", 1000000)
        db.transaction(function(tx) {
            tx.executeSql('DELETE FROM oauth WHERE key=?', [key])
        })
    }

    function getCodeVerifier() { return getStoredValue('codeVerifier') }
    function setCodeVerifier(value) { setStoredValue('codeVerifier', value) }
    function clearCodeVerifier() { clearStoredValue('codeVerifier') }

    // Check for available Spotify devices
    function checkDevicesAndShowSelector() {
        if (hasCheckedDevices) return
        hasCheckedDevices = true

        console.log("Checking for available Spotify devices...")
        SpotifyAPI.getAvailableDevices(function(data) {
            if (!data || !data.devices || data.devices.length === 0) {
                console.log("No devices found, showing device selector")
                // No devices found, show the DevicesPage immediately
                pageStack.push(Qt.resolvedUrl("DevicesPage.qml"))
            } else {
                console.log("Found", data.devices.length, "device(s)")
            }
        }, function(error) {
            console.error("Failed to check devices:", error)
        })
    }

    // Refresh the access token using the refresh token
    function refreshAccessToken(onSuccess, onError) {
        var savedRefreshToken = getStoredValue('refreshToken')
        if (!savedRefreshToken) {
            console.error("No refresh token available")
            if (onError) onError("No refresh token")
            return
        }

        console.log("Refreshing access token...")
        SpotifyAPI.refreshAccessToken(
            savedRefreshToken,
            Config.SPOTIFY_CLIENT_ID,
            Config.SPOTIFY_CLIENT_SECRET,
            function(tokenResponse) {
                console.log("Token refreshed successfully!")
                page.accessToken = tokenResponse.access_token
                page.isAuthenticated = true

                // Update stored access token
                setStoredValue('accessToken', tokenResponse.access_token)

                // Update refresh token if provided (Spotify may rotate it)
                if (tokenResponse.refresh_token) {
                    page.refreshToken = tokenResponse.refresh_token
                    setStoredValue('refreshToken', tokenResponse.refresh_token)
                }

                // Update expiration time
                var expiresAt = Date.now() + (tokenResponse.expires_in * 1000)
                setStoredValue('tokenExpiresAt', expiresAt.toString())

                // Set token in API client
                SpotifyAPI.setAccessToken(tokenResponse.access_token)

                if (onSuccess) onSuccess()
            },
            function(error) {
                console.error("Failed to refresh token:", error)
                // Token refresh failed, clear stored credentials
                clearStoredValue('accessToken')
                clearStoredValue('refreshToken')
                clearStoredValue('tokenExpiresAt')
                page.accessToken = ""
                page.refreshToken = ""
                page.isAuthenticated = false
                if (onError) onError(error)
            }
        )
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
        // Try to load saved token first
        var savedToken = getStoredValue('accessToken')
        var savedRefreshToken = getStoredValue('refreshToken')
        var expiresAtStr = getStoredValue('tokenExpiresAt')

        if (savedToken) {
            var expiresAt = expiresAtStr ? parseInt(expiresAtStr) : 0
            var now = Date.now()
            var timeUntilExpiry = expiresAt - now

            // Check if token is expired or will expire in less than 5 minutes
            if (expiresAt > 0 && timeUntilExpiry < 5 * 60 * 1000) {
                console.log("Token expired or expiring soon, attempting refresh...")
                if (savedRefreshToken) {
                    refreshAccessToken(function() {
                        // Success - load user profile
                        SpotifyAPI.getUserProfile(function(profile) {
                            console.log("User profile loaded:", profile.display_name)
                            page.userName = profile.display_name || profile.id
                            page.userEmail = profile.email || ""
                            // Check for available devices
                            checkDevicesAndShowSelector()
                        })
                    }, function(error) {
                        console.error("Token refresh failed:", error)
                    })
                } else {
                    console.log("No refresh token available, clearing credentials")
                    clearStoredValue('accessToken')
                    clearStoredValue('tokenExpiresAt')
                    page.accessToken = ""
                    page.isAuthenticated = false
                }
            } else {
                console.log("Found valid saved token")
                page.accessToken = savedToken
                page.refreshToken = savedRefreshToken || ""
                page.isAuthenticated = true
                SpotifyAPI.setAccessToken(savedToken)

                // Load user profile
                SpotifyAPI.getUserProfile(function(profile) {
                    console.log("User profile loaded:", profile.display_name)
                    page.userName = profile.display_name || profile.id
                    page.userEmail = profile.email || ""
                    // Check for available devices
                    checkDevicesAndShowSelector()
                }, function(error) {
                    console.error("Saved token invalid, attempting refresh:", error)
                    // Token invalid, try to refresh
                    if (savedRefreshToken) {
                        refreshAccessToken(function() {
                            // Success - reload user profile
                            SpotifyAPI.getUserProfile(function(profile) {
                                console.log("User profile loaded after refresh:", profile.display_name)
                                page.userName = profile.display_name || profile.id
                                page.userEmail = profile.email || ""
                                // Check for available devices
                                checkDevicesAndShowSelector()
                            })
                        })
                    } else {
                        clearStoredValue('accessToken')
                        clearStoredValue('tokenExpiresAt')
                        page.accessToken = ""
                        page.isAuthenticated = false
                    }
                })
            }
        }

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
                            page.refreshToken = tokenResponse.refresh_token || ""
                            page.isAuthenticated = true

                            // Save token and refresh token for next time
                            setStoredValue('accessToken', tokenResponse.access_token)
                            if (tokenResponse.refresh_token) {
                                setStoredValue('refreshToken', tokenResponse.refresh_token)
                            }

                            // Save expiration time (current time + expires_in seconds)
                            var expiresAt = Date.now() + (tokenResponse.expires_in * 1000)
                            setStoredValue('tokenExpiresAt', expiresAt.toString())

                            // Clear the stored code verifier (security best practice)
                            clearCodeVerifier()

                            // Set token in API client
                            SpotifyAPI.setAccessToken(tokenResponse.access_token)

                            // Get user profile
                            SpotifyAPI.getUserProfile(function(profile) {
                                console.log("User profile:", profile.display_name)
                                page.userName = profile.display_name || profile.id
                                page.userEmail = profile.email || ""
                                // Save user info
                                setStoredValue('userName', page.userName)
                                setStoredValue('userEmail', page.userEmail)
                                // Check for available devices
                                checkDevicesAndShowSelector()
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
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: miniPlayer.top
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
            MenuItem {
                text: qsTr("Disconnect")
                visible: isAuthenticated
                onClicked: {
                    page.accessToken = ""
                    page.isAuthenticated = false
                    page.userName = ""
                    page.userEmail = ""
                    clearStoredValue('accessToken')
                }
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

            // Welcome message
            Item {
                width: parent.width
                height: welcomeColumn.height + Theme.paddingLarge * 2

                Column {
                    id: welcomeColumn
                    width: parent.width - Theme.horizontalPageMargin * 2
                    x: Theme.horizontalPageMargin
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.paddingSmall

                    Label {
                        width: parent.width
                        text: {
                            var hour = new Date().getHours()
                            if (hour < 12) return qsTr("Good morning")
                            else if (hour < 18) return qsTr("Good afternoon")
                            else return qsTr("Good evening")
                        }
                        color: Theme.highlightColor
                        font.pixelSize: Theme.fontSizeHuge
                        font.bold: true
                        visible: isAuthenticated
                    }

                    Label {
                        width: parent.width
                        text: userName || qsTr("User")
                        color: Theme.primaryColor
                        font.pixelSize: Theme.fontSizeLarge
                        visible: isAuthenticated && userName !== ""
                    }

                    Label {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        text: qsTr("Welcome to Sona - Your Spotify remote control")
                        color: Theme.secondaryColor
                        font.pixelSize: Theme.fontSizeMedium
                        visible: !isAuthenticated
                    }
                }
            }

            // Login button for non-authenticated users
            BackgroundItem {
                width: parent.width - Theme.horizontalPageMargin * 2
                height: Theme.itemSizeHuge
                anchors.horizontalCenter: parent.horizontalCenter
                visible: !isAuthenticated

                Rectangle {
                    anchors.fill: parent
                    radius: Theme.paddingSmall
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#1DB954" }
                        GradientStop { position: 1.0; color: "#1AA34A" }
                    }
                    opacity: parent.down ? 0.8 : 1.0

                    Behavior on opacity {
                        NumberAnimation { duration: 100 }
                    }
                }

                Column {
                    anchors.centerIn: parent
                    spacing: Theme.paddingSmall

                    Icon {
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: "image://theme/icon-l-developer-mode"
                        color: "white"
                        width: Theme.iconSizeLarge
                        height: Theme.iconSizeLarge
                    }

                    Label {
                        text: qsTr("Connect to Spotify")
                        color: "white"
                        font.pixelSize: Theme.fontSizeLarge
                        font.bold: true
                    }
                }

                onClicked: {
                    setCodeVerifier(oauth2.codeVerifier)
                    console.log("Stored code verifier for later use:", oauth2.codeVerifier.substring(0, 10) + "...")
                    oauth2.authorizeInBrowser()
                }
            }

            // Navigation grid
            Grid {
                width: parent.width - Theme.horizontalPageMargin * 2
                x: Theme.horizontalPageMargin
                columns: 2
                spacing: Theme.paddingMedium
                visible: isAuthenticated
                rowSpacing: Theme.paddingMedium

                // Discover card
                BackgroundItem {
                    width: parent.width / 2 - Theme.paddingMedium / 2
                    height: width * 1.2

                    Rectangle {
                        anchors.fill: parent
                        radius: Theme.paddingMedium
                        color: Theme.rgba(Theme.highlightBackgroundColor, 0.15)
                        opacity: parent.down ? 0.6 : 1.0

                        Behavior on opacity {
                            NumberAnimation { duration: 100 }
                        }

                        Column {
                            anchors {
                                left: parent.left
                                right: parent.right
                                bottom: parent.bottom
                                margins: Theme.paddingMedium
                            }
                            spacing: Theme.paddingSmall

                            Icon {
                                source: "image://theme/icon-l-favorite"
                                color: Theme.highlightColor
                                width: Theme.iconSizeLarge
                                height: Theme.iconSizeLarge
                            }

                            Label {
                                text: qsTr("Discover")
                                color: Theme.primaryColor
                                font.pixelSize: Theme.fontSizeLarge
                                font.bold: true
                            }

                            Label {
                                width: parent.width
                                text: qsTr("Featured music")
                                color: Theme.secondaryColor
                                font.pixelSize: Theme.fontSizeExtraSmall
                                wrapMode: Text.WordWrap
                            }
                        }
                    }

                    onClicked: pageStack.push(Qt.resolvedUrl("DiscoverPage.qml"))
                }

                // Search card
                BackgroundItem {
                    width: parent.width / 2 - Theme.paddingMedium / 2
                    height: width * 1.2

                    Rectangle {
                        anchors.fill: parent
                        radius: Theme.paddingMedium
                        color: Theme.rgba(Theme.highlightBackgroundColor, 0.15)
                        opacity: parent.down ? 0.6 : 1.0

                        Behavior on opacity {
                            NumberAnimation { duration: 100 }
                        }

                        Column {
                            anchors {
                                left: parent.left
                                right: parent.right
                                bottom: parent.bottom
                                margins: Theme.paddingMedium
                            }
                            spacing: Theme.paddingSmall

                            Icon {
                                source: "image://theme/icon-m-search"
                                color: Theme.highlightColor
                                width: Theme.iconSizeLarge
                                height: Theme.iconSizeLarge
                            }

                            Label {
                                text: qsTr("Search")
                                color: Theme.primaryColor
                                font.pixelSize: Theme.fontSizeLarge
                                font.bold: true
                            }

                            Label {
                                width: parent.width
                                text: qsTr("Find anything")
                                color: Theme.secondaryColor
                                font.pixelSize: Theme.fontSizeExtraSmall
                                wrapMode: Text.WordWrap
                            }
                        }
                    }

                    onClicked: pageStack.push(Qt.resolvedUrl("SearchPage.qml"))
                }

                // Library card
                BackgroundItem {
                    width: parent.width / 2 - Theme.paddingMedium / 2
                    height: width * 1.2

                    Rectangle {
                        anchors.fill: parent
                        radius: Theme.paddingMedium
                        color: Theme.rgba(Theme.highlightBackgroundColor, 0.15)
                        opacity: parent.down ? 0.6 : 1.0

                        Behavior on opacity {
                            NumberAnimation { duration: 100 }
                        }

                        Column {
                            anchors {
                                left: parent.left
                                right: parent.right
                                bottom: parent.bottom
                                margins: Theme.paddingMedium
                            }
                            spacing: Theme.paddingSmall

                            Icon {
                                source: "image://theme/icon-l-music"
                                color: Theme.highlightColor
                                width: Theme.iconSizeLarge
                                height: Theme.iconSizeLarge
                            }

                            Label {
                                text: qsTr("Library")
                                color: Theme.primaryColor
                                font.pixelSize: Theme.fontSizeLarge
                                font.bold: true
                            }

                            Label {
                                width: parent.width
                                text: qsTr("Your collection")
                                color: Theme.secondaryColor
                                font.pixelSize: Theme.fontSizeExtraSmall
                                wrapMode: Text.WordWrap
                            }
                        }
                    }

                    onClicked: pageStack.push(Qt.resolvedUrl("LibraryPage.qml"))
                }

                // Playlists card
                BackgroundItem {
                    width: parent.width / 2 - Theme.paddingMedium / 2
                    height: width * 1.2

                    Rectangle {
                        anchors.fill: parent
                        radius: Theme.paddingMedium
                        color: Theme.rgba(Theme.highlightBackgroundColor, 0.15)
                        opacity: parent.down ? 0.6 : 1.0

                        Behavior on opacity {
                            NumberAnimation { duration: 100 }
                        }

                        Column {
                            anchors {
                                left: parent.left
                                right: parent.right
                                bottom: parent.bottom
                                margins: Theme.paddingMedium
                            }
                            spacing: Theme.paddingSmall

                            Icon {
                                source: "image://theme/icon-m-file-folder-playlist"
                                color: Theme.highlightColor
                                width: Theme.iconSizeLarge
                                height: Theme.iconSizeLarge
                            }

                            Label {
                                text: qsTr("Playlists")
                                color: Theme.primaryColor
                                font.pixelSize: Theme.fontSizeLarge
                                font.bold: true
                            }

                            Label {
                                width: parent.width
                                text: qsTr("Your playlists")
                                color: Theme.secondaryColor
                                font.pixelSize: Theme.fontSizeExtraSmall
                                wrapMode: Text.WordWrap
                            }
                        }
                    }

                    onClicked: pageStack.push(Qt.resolvedUrl("PlaylistsPage.qml"))
                }

                // Stats card
                BackgroundItem {
                    width: parent.width / 2 - Theme.paddingMedium / 2
                    height: width * 1.2

                    Rectangle {
                        anchors.fill: parent
                        radius: Theme.paddingMedium
                        color: Theme.rgba(Theme.highlightBackgroundColor, 0.15)
                        opacity: parent.down ? 0.6 : 1.0

                        Behavior on opacity {
                            NumberAnimation { duration: 100 }
                        }

                        Column {
                            anchors {
                                left: parent.left
                                right: parent.right
                                bottom: parent.bottom
                                margins: Theme.paddingMedium
                            }
                            spacing: Theme.paddingSmall

                            Icon {
                                source: "image://theme/icon-m-health"
                                color: Theme.highlightColor
                                width: Theme.iconSizeLarge
                                height: Theme.iconSizeLarge
                            }

                            Label {
                                text: qsTr("Stats")
                                color: Theme.primaryColor
                                font.pixelSize: Theme.fontSizeLarge
                                font.bold: true
                            }

                            Label {
                                width: parent.width
                                text: qsTr("Your listening stats")
                                color: Theme.secondaryColor
                                font.pixelSize: Theme.fontSizeExtraSmall
                                wrapMode: Text.WordWrap
                            }
                        }
                    }

                    onClicked: pageStack.push(Qt.resolvedUrl("StatsPage.qml"))
                }

                // Now Playing card
                BackgroundItem {
                    width: parent.width / 2 - Theme.paddingMedium / 2
                    height: width * 1.2

                    Rectangle {
                        anchors.fill: parent
                        radius: Theme.paddingMedium
                        color: Theme.rgba(Theme.highlightBackgroundColor, 0.15)
                        opacity: parent.down ? 0.6 : 1.0

                        Behavior on opacity {
                            NumberAnimation { duration: 100 }
                        }

                        Column {
                            anchors {
                                left: parent.left
                                right: parent.right
                                bottom: parent.bottom
                                margins: Theme.paddingMedium
                            }
                            spacing: Theme.paddingSmall

                            Icon {
                                source: "image://theme/icon-m-play"
                                color: Theme.highlightColor
                                width: Theme.iconSizeLarge
                                height: Theme.iconSizeLarge
                            }

                            Label {
                                text: qsTr("Player")
                                color: Theme.primaryColor
                                font.pixelSize: Theme.fontSizeLarge
                                font.bold: true
                            }

                            Label {
                                width: parent.width
                                text: qsTr("Now playing")
                                color: Theme.secondaryColor
                                font.pixelSize: Theme.fontSizeExtraSmall
                                wrapMode: Text.WordWrap
                            }
                        }
                    }

                    onClicked: pageStack.push(Qt.resolvedUrl("PlayerPage.qml"))
                }
            }

            // Now Playing quick access
            BackgroundItem {
                width: parent.width - Theme.horizontalPageMargin * 2
                height: Theme.itemSizeLarge
                anchors.horizontalCenter: parent.horizontalCenter
                visible: isAuthenticated && PlaybackManager.trackName !== ""

                Rectangle {
                    anchors.fill: parent
                    radius: Theme.paddingMedium
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Theme.rgba(Theme.highlightColor, 0.3) }
                        GradientStop { position: 1.0; color: Theme.rgba(Theme.highlightColor, 0.15) }
                    }
                    opacity: parent.down ? 0.6 : 1.0

                    Behavior on opacity {
                        NumberAnimation { duration: 100 }
                    }
                }

                Row {
                    anchors {
                        fill: parent
                        margins: Theme.paddingMedium
                    }
                    spacing: Theme.paddingMedium

                    Image {
                        width: height
                        height: parent.height
                        source: PlaybackManager.albumImageUrl || ""
                        fillMode: Image.PreserveAspectCrop
                        smooth: true

                        Rectangle {
                            anchors.fill: parent
                            color: Theme.rgba(Theme.highlightBackgroundColor, 0.2)
                            visible: !parent.source || parent.status !== Image.Ready
                            radius: Theme.paddingSmall / 2

                            Icon {
                                anchors.centerIn: parent
                                source: "image://theme/icon-l-music"
                                color: Theme.secondaryColor
                            }
                        }
                    }

                    Column {
                        width: parent.width - parent.height - parent.spacing
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.paddingSmall / 2

                        Label {
                            width: parent.width
                            text: qsTr("Now Playing")
                            color: Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }

                        Label {
                            width: parent.width
                            text: PlaybackManager.trackName
                            color: Theme.primaryColor
                            font.pixelSize: Theme.fontSizeMedium
                            font.bold: true
                            truncationMode: TruncationMode.Fade
                            maximumLineCount: 1
                        }

                        Label {
                            width: parent.width
                            text: PlaybackManager.artistName
                            color: Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeSmall
                            truncationMode: TruncationMode.Fade
                            maximumLineCount: 1
                        }
                    }
                }

                onClicked: pageStack.push(Qt.resolvedUrl("PlayerPage.qml"))
            }

            Item { height: Theme.paddingLarge }
        }
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
