.pragma library

// Spotify Web API client
var accessToken = ""
var baseUrl = "https://api.spotify.com/v1"

function setAccessToken(token) {
    accessToken = token
}

function request(endpoint, callback, errorCallback, method, data) {
    if (!accessToken) {
        console.error("No access token available")
        if (errorCallback) errorCallback("No access token")
        return
    }

    var xhr = new XMLHttpRequest()
    var url = baseUrl + endpoint

    method = method || "GET"

    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status >= 200 && xhr.status < 300) {
                try {
                    var response = JSON.parse(xhr.responseText)
                    if (callback) callback(response)
                } catch (e) {
                    console.error("Failed to parse response:", e)
                    if (errorCallback) errorCallback("Parse error: " + e)
                }
            } else {
                console.error("Request failed:", xhr.status, xhr.statusText)
                if (errorCallback) {
                    try {
                        var error = JSON.parse(xhr.responseText)
                        errorCallback(error.error ? error.error.message : xhr.statusText)
                    } catch (e) {
                        errorCallback(xhr.statusText)
                    }
                }
            }
        }
    }

    xhr.open(method, url, true)
    xhr.setRequestHeader("Authorization", "Bearer " + accessToken)
    xhr.setRequestHeader("Content-Type", "application/json")

    if (data) {
        xhr.send(JSON.stringify(data))
    } else {
        xhr.send()
    }
}

// Get current user's profile
function getUserProfile(callback, errorCallback) {
    request("/me", callback, errorCallback)
}

// Get user's playlists
function getUserPlaylists(callback, errorCallback, limit, offset) {
    limit = limit || 20
    offset = offset || 0
    request("/me/playlists?limit=" + limit + "&offset=" + offset, callback, errorCallback)
}

// Get playlist details
function getPlaylist(playlistId, callback, errorCallback) {
    request("/playlists/" + playlistId, callback, errorCallback)
}

// Get playlist tracks
function getPlaylistTracks(playlistId, callback, errorCallback, limit, offset) {
    limit = limit || 100
    offset = offset || 0
    request("/playlists/" + playlistId + "/tracks?limit=" + limit + "&offset=" + offset, callback, errorCallback)
}

// Search
function search(query, types, callback, errorCallback, limit) {
    types = types || ["track", "artist", "album", "playlist"]
    limit = limit || 20
    var typesStr = types.join(",")
    var encodedQuery = encodeURIComponent(query)
    request("/search?q=" + encodedQuery + "&type=" + typesStr + "&limit=" + limit, callback, errorCallback)
}

// Get current playback state
function getCurrentPlayback(callback, errorCallback) {
    request("/me/player", callback, errorCallback)
}

// Get currently playing track
function getCurrentlyPlaying(callback, errorCallback) {
    request("/me/player/currently-playing", callback, errorCallback)
}

// Get available devices
function getAvailableDevices(callback, errorCallback) {
    request("/me/player/devices", callback, errorCallback)
}

// Transfer playback to device
function transferPlayback(deviceId, play, callback, errorCallback) {
    play = play !== undefined ? play : false
    var data = {
        "device_ids": [deviceId],
        "play": play
    }
    request("/me/player", callback, errorCallback, "PUT", data)
}

// Play
function play(deviceId, contextUri, uris, callback, errorCallback) {
    var endpoint = "/me/player/play"
    if (deviceId) {
        endpoint += "?device_id=" + deviceId
    }

    var data = {}
    if (contextUri) {
        data.context_uri = contextUri
    }
    if (uris) {
        data.uris = uris
    }

    request(endpoint, callback, errorCallback, "PUT", data)
}

// Pause
function pause(deviceId, callback, errorCallback) {
    var endpoint = "/me/player/pause"
    if (deviceId) {
        endpoint += "?device_id=" + deviceId
    }
    request(endpoint, callback, errorCallback, "PUT")
}

// Next track
function next(deviceId, callback, errorCallback) {
    var endpoint = "/me/player/next"
    if (deviceId) {
        endpoint += "?device_id=" + deviceId
    }
    request(endpoint, callback, errorCallback, "POST")
}

// Previous track
function previous(deviceId, callback, errorCallback) {
    var endpoint = "/me/player/previous"
    if (deviceId) {
        endpoint += "?device_id=" + deviceId
    }
    request(endpoint, callback, errorCallback, "POST")
}

// Set volume
function setVolume(volumePercent, deviceId, callback, errorCallback) {
    var endpoint = "/me/player/volume?volume_percent=" + volumePercent
    if (deviceId) {
        endpoint += "&device_id=" + deviceId
    }
    request(endpoint, callback, errorCallback, "PUT")
}

// Seek to position
function seek(positionMs, deviceId, callback, errorCallback) {
    var endpoint = "/me/player/seek?position_ms=" + positionMs
    if (deviceId) {
        endpoint += "&device_id=" + deviceId
    }
    request(endpoint, callback, errorCallback, "PUT")
}

// Set repeat mode
function setRepeat(state, deviceId, callback, errorCallback) {
    // state: "track", "context", "off"
    var endpoint = "/me/player/repeat?state=" + state
    if (deviceId) {
        endpoint += "&device_id=" + deviceId
    }
    request(endpoint, callback, errorCallback, "PUT")
}

// Set shuffle
function setShuffle(state, deviceId, callback, errorCallback) {
    var endpoint = "/me/player/shuffle?state=" + (state ? "true" : "false")
    if (deviceId) {
        endpoint += "&device_id=" + deviceId
    }
    request(endpoint, callback, errorCallback, "PUT")
}

// Get user's saved tracks
function getSavedTracks(callback, errorCallback, limit, offset) {
    limit = limit || 20
    offset = offset || 0
    request("/me/tracks?limit=" + limit + "&offset=" + offset, callback, errorCallback)
}

// Get user's saved albums
function getSavedAlbums(callback, errorCallback, limit, offset) {
    limit = limit || 20
    offset = offset || 0
    request("/me/albums?limit=" + limit + "&offset=" + offset, callback, errorCallback)
}

// Save tracks
function saveTracks(trackIds, callback, errorCallback) {
    var data = {
        "ids": trackIds
    }
    request("/me/tracks", callback, errorCallback, "PUT", data)
}

// Remove saved tracks
function removeSavedTracks(trackIds, callback, errorCallback) {
    var data = {
        "ids": trackIds
    }
    request("/me/tracks", callback, errorCallback, "DELETE", data)
}
