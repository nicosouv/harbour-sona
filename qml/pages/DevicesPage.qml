import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/SpotifyAPI.js" as SpotifyAPI
import "../components" 1.0

Page {
    id: page

    property bool loading: false
    property bool spotifyAndroidInstalled: false
    property bool spotifyAndroidRunning: false
    property bool checkingSpotifyAndroid: false

    ListModel {
        id: devicesModel
    }

    SpotifyAndroidHelper {
        id: spotifyAndroidHelper
    }

    Timer {
        id: reloadTimer
        interval: 500
        repeat: false
        onTriggered: loadDevices()
    }

    Timer {
        id: checkSpotifyTimer
        interval: 1000
        repeat: false
        onTriggered: checkSpotifyAndroid()
    }

    // Check if Spotify Android is installed and running
    function checkSpotifyAndroid() {
        if (checkingSpotifyAndroid) return
        checkingSpotifyAndroid = true

        spotifyAndroidHelper.checkInstalled(function(installed) {
            spotifyAndroidInstalled = installed
            console.log("Spotify Android installed:", spotifyAndroidInstalled)

            if (spotifyAndroidInstalled) {
                spotifyAndroidHelper.checkRunning(function(running) {
                    spotifyAndroidRunning = running
                    console.log("Spotify Android running:", spotifyAndroidRunning)
                    checkingSpotifyAndroid = false
                })
            } else {
                checkingSpotifyAndroid = false
            }
        })
    }

    // Launch Spotify Android app
    function launchSpotifyAndroid() {
        console.log("Launching Spotify Android...")
        spotifyAndroidHelper.launch(function(success) {
            console.log("Spotify Android launch result:", success)
            if (success) {
                spotifyAndroidRunning = true
                // Wait a bit for Spotify to start, then reload devices
                reloadTimer.interval = 3000
                reloadTimer.restart()
            }
        })
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
                onClicked: loadDevices()
            }
        }

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr("Devices")
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                text: qsTr("Available Spotify devices")
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeMedium
                wrapMode: Text.WordWrap
            }

            BusyIndicator {
                size: BusyIndicatorSize.Large
                anchors.horizontalCenter: parent.horizontalCenter
                running: loading
                visible: loading
            }

            SilicaListView {
                id: devicesView
                width: parent.width
                height: contentHeight
                interactive: false
                visible: !loading

                model: devicesModel

                delegate: BackgroundItem {
                    id: deviceItem
                    height: Theme.itemSizeExtraLarge

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: Theme.paddingMedium
                        radius: Theme.paddingMedium
                        color: model.isActive ?
                               Theme.rgba(Theme.highlightColor, 0.2) :
                               Theme.rgba(Theme.highlightBackgroundColor, 0.1)
                        opacity: deviceItem.down ? 0.6 : 1.0

                        Behavior on opacity {
                            NumberAnimation { duration: 100 }
                        }

                        Behavior on color {
                            ColorAnimation { duration: 200 }
                        }
                    }

                    Row {
                        anchors {
                            fill: parent
                            margins: Theme.paddingLarge
                        }
                        spacing: Theme.paddingMedium

                        Icon {
                            anchors.verticalCenter: parent.verticalCenter
                            source: {
                                switch(model.type.toLowerCase()) {
                                    case "computer": return "image://theme/icon-m-computer"
                                    case "smartphone": return "image://theme/icon-m-phone"
                                    case "speaker": return "image://theme/icon-m-speaker"
                                    case "tv": return "image://theme/icon-m-display"
                                    default: return "image://theme/icon-m-music"
                                }
                            }
                            color: model.isActive ? Theme.highlightColor : Theme.primaryColor
                            width: Theme.iconSizeMedium
                            height: Theme.iconSizeMedium
                        }

                        Column {
                            width: parent.width - Theme.iconSizeMedium - volumeIcon.width - parent.spacing * 2
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Theme.paddingSmall / 2

                            Label {
                                width: parent.width
                                text: model.name
                                color: model.isActive ? Theme.highlightColor : Theme.primaryColor
                                font.pixelSize: Theme.fontSizeMedium
                                font.bold: model.isActive
                                truncationMode: TruncationMode.Fade
                                maximumLineCount: 1
                            }

                            Label {
                                width: parent.width
                                text: model.type + (model.isActive ? " • " + qsTr("Active") : "")
                                color: model.isActive ? Theme.secondaryHighlightColor : Theme.secondaryColor
                                font.pixelSize: Theme.fontSizeExtraSmall
                                truncationMode: TruncationMode.Fade
                                maximumLineCount: 1
                            }

                            Row {
                                spacing: Theme.paddingSmall
                                visible: model.volumePercent >= 0

                                Icon {
                                    id: volumeIcon
                                    source: model.volumePercent === 0 ?
                                           "image://theme/icon-s-alarm" :
                                           "image://theme/icon-m-speaker"
                                    color: Theme.secondaryColor
                                    width: Theme.iconSizeExtraSmall
                                    height: Theme.iconSizeExtraSmall
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Label {
                                    text: model.volumePercent + "%"
                                    color: Theme.secondaryColor
                                    font.pixelSize: Theme.fontSizeExtraSmall
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }

                        Icon {
                            anchors.verticalCenter: parent.verticalCenter
                            source: "image://theme/icon-m-right"
                            color: model.isActive ? Theme.highlightColor : Theme.secondaryColor
                            width: Theme.iconSizeSmall
                            height: Theme.iconSizeSmall
                            visible: !model.isActive
                        }

                        Icon {
                            anchors.verticalCenter: parent.verticalCenter
                            source: "image://theme/icon-m-acknowledge"
                            color: Theme.highlightColor
                            width: Theme.iconSizeSmall
                            height: Theme.iconSizeSmall
                            visible: model.isActive
                        }
                    }

                    onClicked: {
                        if (!model.isActive) {
                            loading = true
                            SpotifyAPI.transferPlayback(model.id, true, function() {
                                console.log("Transferred playback to:", model.name)
                                // Reload devices to update active status
                                reloadTimer.restart()
                            }, function(error) {
                                loading = false
                                console.error("Failed to transfer playback:", error)
                            })
                        }
                    }
                }
            }

            // No devices found - show message with optional launch button
            Column {
                width: parent.width
                spacing: Theme.paddingLarge
                visible: !loading && devicesModel.count === 0

                Item { height: Theme.paddingLarge * 2 }

                Icon {
                    source: "image://theme/icon-l-music"
                    color: spotifyAndroidInstalled && !spotifyAndroidRunning ? Theme.highlightColor : Theme.secondaryColor
                    width: Theme.iconSizeExtraLarge
                    height: Theme.iconSizeExtraLarge
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Label {
                    x: Theme.horizontalPageMargin
                    width: parent.width - 2 * Theme.horizontalPageMargin
                    text: spotifyAndroidInstalled && !spotifyAndroidRunning ?
                          qsTr("Spotify detected on this device") :
                          qsTr("No Spotify app detected")
                    color: spotifyAndroidInstalled && !spotifyAndroidRunning ? Theme.highlightColor : Theme.primaryColor
                    font.pixelSize: Theme.fontSizeLarge
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }

                Label {
                    x: Theme.horizontalPageMargin
                    width: parent.width - 2 * Theme.horizontalPageMargin
                    text: spotifyAndroidInstalled && !spotifyAndroidRunning ?
                          qsTr("Launch Spotify on this device to use it as a playback device") :
                          qsTr("Launch the official Spotify app on a device (phone, computer, speaker) and start playing music, then refresh")
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeSmall
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }

                Button {
                    text: qsTr("Launch Spotify")
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: launchSpotifyAndroid()
                    preferredWidth: Theme.buttonWidthMedium
                    visible: spotifyAndroidInstalled && !spotifyAndroidRunning
                }

                Item { height: Theme.paddingLarge }
            }

            // Info section
            Item {
                width: parent.width
                height: infoColumn.height
                visible: !loading

                Column {
                    id: infoColumn
                    width: parent.width - Theme.horizontalPageMargin * 2
                    x: Theme.horizontalPageMargin
                    spacing: Theme.paddingMedium

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Theme.rgba(Theme.highlightColor, 0.2)
                    }

                    Label {
                        width: parent.width
                        text: qsTr("About playback")
                        color: Theme.highlightColor
                        font.pixelSize: Theme.fontSizeMedium
                        font.bold: true
                    }

                    Label {
                        width: parent.width
                        text: qsTr("Sona is a remote control for Spotify. To play music, you need:")
                        color: Theme.primaryColor
                        font.pixelSize: Theme.fontSizeSmall
                        wrapMode: Text.WordWrap
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.paddingSmall

                        Row {
                            width: parent.width
                            spacing: Theme.paddingMedium

                            Label {
                                text: "•"
                                color: Theme.highlightColor
                                font.pixelSize: Theme.fontSizeSmall
                            }

                            Label {
                                width: parent.width - Theme.paddingMedium * 2
                                text: qsTr("A Spotify Premium account")
                                color: Theme.secondaryColor
                                font.pixelSize: Theme.fontSizeSmall
                                wrapMode: Text.WordWrap
                            }
                        }

                        Row {
                            width: parent.width
                            spacing: Theme.paddingMedium

                            Label {
                                text: "•"
                                color: Theme.highlightColor
                                font.pixelSize: Theme.fontSizeSmall
                            }

                            Label {
                                width: parent.width - Theme.paddingMedium * 2
                                text: qsTr("An active Spotify device (computer, phone, speaker, etc.)")
                                color: Theme.secondaryColor
                                font.pixelSize: Theme.fontSizeSmall
                                wrapMode: Text.WordWrap
                            }
                        }
                    }

                    Label {
                        width: parent.width
                        text: qsTr("Tap a device above to transfer playback to it.")
                        color: Theme.secondaryColor
                        font.pixelSize: Theme.fontSizeExtraSmall
                        wrapMode: Text.WordWrap
                    }
                }
            }

            Item { height: Theme.paddingLarge }
        }

        VerticalScrollDecorator {}
    }

    function loadDevices() {
        loading = true
        devicesModel.clear()

        SpotifyAPI.getAvailableDevices(function(data) {
            loading = false

            if (data && data.devices) {
                console.log("Devices found:", data.devices.length)

                for (var i = 0; i < data.devices.length; i++) {
                    var device = data.devices[i]

                    devicesModel.append({
                        id: device.id,
                        name: device.name,
                        type: device.type || "Unknown",
                        isActive: device.is_active || false,
                        volumePercent: device.volume_percent !== null ? device.volume_percent : -1
                    })
                }

                // If no devices found, check for Spotify Android
                if (data.devices.length === 0) {
                    checkSpotifyTimer.start()
                }
            } else {
                // No data, check for Spotify Android
                checkSpotifyTimer.start()
            }
        }, function(error) {
            loading = false
            console.error("Failed to load devices:", error)
            // On error, also check for Spotify Android
            checkSpotifyTimer.start()
        })
    }

    Component.onCompleted: {
        loadDevices()
        // Check for Spotify Android in background
        checkSpotifyTimer.start()
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
