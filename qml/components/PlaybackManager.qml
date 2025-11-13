pragma Singleton
import QtQuick 2.0
import "../js/SpotifyAPI.js" as SpotifyAPI

QtObject {
    id: playbackManager

    // Current playback state
    property bool isPlaying: false
    property bool loading: false
    property string trackName: ""
    property string artistName: ""
    property string albumName: ""
    property string albumImageUrl: ""
    property string trackId: ""
    property string trackUri: ""
    property int progressMs: 0
    property int durationMs: 0
    property bool shuffle: false
    property string repeatMode: "off"

    // Error notification
    property string errorMessage: ""
    property bool hasError: false

    // Signals for state changes
    signal playbackStateChanged()
    signal trackChanged()
    signal progressChanged()
    signal errorOccurred(string message)

    // Auto-refresh timer
    property var _refreshTimer: Timer {
        interval: 2000
        repeat: true
        running: true
        onTriggered: playbackManager.refreshPlayback()
    }

    // Progress simulation timer (for smooth progress bar updates)
    property var _progressTimer: Timer {
        interval: 1000
        repeat: true
        running: playbackManager.isPlaying
        onTriggered: {
            if (playbackManager.isPlaying && playbackManager.durationMs > 0) {
                playbackManager.progressMs = Math.min(
                    playbackManager.progressMs + 1000,
                    playbackManager.durationMs
                )
                playbackManager.progressChanged()
            }
        }
    }

    // Error clear timer
    property var _errorClearTimer: Timer {
        interval: 3000
        repeat: false
        onTriggered: {
            playbackManager.hasError = false
            playbackManager.errorMessage = ""
        }
    }

    // Show error message
    function showError(message) {
        errorMessage = message
        hasError = true
        errorOccurred(message)
        _errorClearTimer.restart()
    }

    // Refresh playback state from Spotify
    function refreshPlayback() {
        if (loading) return

        loading = true
        SpotifyAPI.getCurrentPlayback(function(data) {
            loading = false

            if (data && data.item) {
                var trackChangedFlag = trackId !== data.item.id

                trackName = data.item.name
                artistName = data.item.artists && data.item.artists.length > 0 ?
                             data.item.artists[0].name : ""
                albumName = data.item.album ? data.item.album.name : ""
                albumImageUrl = data.item.album && data.item.album.images &&
                                data.item.album.images.length > 0 ?
                                data.item.album.images[0].url : ""
                trackId = data.item.id
                trackUri = data.item.uri
                isPlaying = data.is_playing
                progressMs = data.progress_ms || 0
                durationMs = data.item.duration_ms || 0
                shuffle = data.shuffle_state || false
                repeatMode = data.repeat_state || "off"

                playbackStateChanged()
                if (trackChangedFlag) {
                    trackChanged()
                }
            } else {
                // No active playback
                var hadTrack = trackName !== ""
                trackName = ""
                artistName = ""
                albumName = ""
                albumImageUrl = ""
                trackId = ""
                trackUri = ""
                isPlaying = false
                progressMs = 0
                durationMs = 0

                if (hadTrack) {
                    playbackStateChanged()
                    trackChanged()
                }
            }
        }, function(error) {
            loading = false
            console.error("PlaybackManager: Failed to refresh playback:", error)
        })
    }

    // Timer for delayed refresh
    property var _delayedRefreshTimer: Timer {
        interval: 500
        repeat: false
        onTriggered: playbackManager.refreshPlayback()
    }

    // Playback control functions
    function play(deviceId, contextUri, uris, callback, errorCallback) {
        SpotifyAPI.play(deviceId, contextUri, uris, function() {
            isPlaying = true
            playbackStateChanged()
            _delayedRefreshTimer.restart()
            if (callback) callback()
        }, function(error) {
            console.error("PlaybackManager: Failed to play:", error)
            if (error && error.toString().indexOf("No active device") !== -1) {
                showError(qsTr("No active device. Please select a device first."))
            }
            if (errorCallback) errorCallback(error)
        })
    }

    function pause(deviceId, callback, errorCallback) {
        SpotifyAPI.pause(deviceId, function() {
            isPlaying = false
            playbackStateChanged()
            if (callback) callback()
        }, function(error) {
            console.error("PlaybackManager: Failed to pause:", error)
            if (error && error.toString().indexOf("No active device") !== -1) {
                showError(qsTr("No active device. Please select a device first."))
            }
            if (errorCallback) errorCallback(error)
        })
    }

    function next(deviceId, callback, errorCallback) {
        SpotifyAPI.next(deviceId, function() {
            _delayedRefreshTimer.restart()
            if (callback) callback()
        }, function(error) {
            console.error("PlaybackManager: Failed to skip to next:", error)
            if (error && error.toString().indexOf("No active device") !== -1) {
                showError(qsTr("No active device. Please select a device first."))
            }
            if (errorCallback) errorCallback(error)
        })
    }

    function previous(deviceId, callback, errorCallback) {
        SpotifyAPI.previous(deviceId, function() {
            _delayedRefreshTimer.restart()
            if (callback) callback()
        }, function(error) {
            console.error("PlaybackManager: Failed to skip to previous:", error)
            if (error && error.toString().indexOf("No active device") !== -1) {
                showError(qsTr("No active device. Please select a device first."))
            }
            if (errorCallback) errorCallback(error)
        })
    }

    function toggleShuffle(deviceId, callback, errorCallback) {
        var newShuffle = !shuffle
        SpotifyAPI.setShuffle(newShuffle, deviceId, function() {
            shuffle = newShuffle
            playbackStateChanged()
            if (callback) callback()
        }, function(error) {
            console.error("PlaybackManager: Failed to toggle shuffle:", error)
            if (errorCallback) errorCallback(error)
        })
    }

    function cycleRepeat(deviceId, callback, errorCallback) {
        var newMode = repeatMode === "off" ? "context" :
                      repeatMode === "context" ? "track" : "off"
        SpotifyAPI.setRepeat(newMode, deviceId, function() {
            repeatMode = newMode
            playbackStateChanged()
            if (callback) callback()
        }, function(error) {
            console.error("PlaybackManager: Failed to set repeat mode:", error)
            if (errorCallback) errorCallback(error)
        })
    }

    function seek(positionMs, deviceId, callback, errorCallback) {
        SpotifyAPI.seek(positionMs, deviceId, function() {
            progressMs = positionMs
            progressChanged()
            if (callback) callback()
        }, function(error) {
            console.error("PlaybackManager: Failed to seek:", error)
            if (errorCallback) errorCallback(error)
        })
    }

    function togglePlayback(callback, errorCallback) {
        if (isPlaying) {
            pause(null, callback, errorCallback)
        } else {
            play(null, null, null, callback, errorCallback)
        }
    }
}
