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

// Create a new playlist
function createPlaylist(userId, name, description, isPublic, callback, errorCallback) {
    var data = {
        "name": name,
        "description": description || "",
        "public": isPublic !== undefined ? isPublic : true
    }
    request("/users/" + userId + "/playlists", callback, errorCallback, "POST", data)
}

// Add tracks to playlist
function addTracksToPlaylist(playlistId, uris, callback, errorCallback) {
    var data = {
        "uris": uris
    }
    request("/playlists/" + playlistId + "/tracks", callback, errorCallback, "POST", data)
}

// Remove tracks from playlist
function removeTracksFromPlaylist(playlistId, uris, callback, errorCallback) {
    var data = {
        "tracks": uris.map(function(uri) { return {"uri": uri} })
    }
    request("/playlists/" + playlistId + "/tracks", callback, errorCallback, "DELETE", data)
}

// Get artist's top tracks
function getArtistTopTracks(artistId, market, callback, errorCallback) {
    market = market || "US"
    request("/artists/" + artistId + "/top-tracks?market=" + market, callback, errorCallback)
}

// Get artist's albums
function getArtistAlbums(artistId, callback, errorCallback, limit, offset) {
    limit = limit || 20
    offset = offset || 0
    request("/artists/" + artistId + "/albums?limit=" + limit + "&offset=" + offset, callback, errorCallback)
}

// Get artist details
function getArtist(artistId, callback, errorCallback) {
    request("/artists/" + artistId, callback, errorCallback)
}

// Get album tracks
function getAlbumTracks(albumId, callback, errorCallback, limit, offset) {
    limit = limit || 50
    offset = offset || 0
    request("/albums/" + albumId + "/tracks?limit=" + limit + "&offset=" + offset, callback, errorCallback)
}

// Get album details
function getAlbum(albumId, callback, errorCallback) {
    request("/albums/" + albumId, callback, errorCallback)
}

// Get recently played tracks
function getRecentlyPlayed(callback, errorCallback, limit) {
    limit = limit || 20
    request("/me/player/recently-played?limit=" + limit, callback, errorCallback)
}

// Get recommendations based on seed tracks/artists/genres
function getRecommendations(seedTracks, seedArtists, seedGenres, callback, errorCallback, limit) {
    limit = limit || 20
    var params = []
    if (seedTracks && seedTracks.length > 0) params.push("seed_tracks=" + seedTracks.join(","))
    if (seedArtists && seedArtists.length > 0) params.push("seed_artists=" + seedArtists.join(","))
    if (seedGenres && seedGenres.length > 0) params.push("seed_genres=" + seedGenres.join(","))
    params.push("limit=" + limit)
    request("/recommendations?" + params.join("&"), callback, errorCallback)
}

// Get user's top tracks
function getUserTopTracks(callback, errorCallback, limit, offset, timeRange) {
    limit = limit || 20
    offset = offset || 0
    timeRange = timeRange || "medium_term" // short_term, medium_term, long_term
    request("/me/top/tracks?limit=" + limit + "&offset=" + offset + "&time_range=" + timeRange, callback, errorCallback)
}

// Get user's top artists
function getUserTopArtists(callback, errorCallback, limit, offset, timeRange) {
    limit = limit || 20
    offset = offset || 0
    timeRange = timeRange || "medium_term"
    request("/me/top/artists?limit=" + limit + "&offset=" + offset + "&time_range=" + timeRange, callback, errorCallback)
}

// Check if tracks are saved
function checkSavedTracks(trackIds, callback, errorCallback) {
    request("/me/tracks/contains?ids=" + trackIds.join(","), callback, errorCallback)
}

// Get queue
function getQueue(callback, errorCallback) {
    request("/me/player/queue", callback, errorCallback)
}

// Add to queue
function addToQueue(uri, callback, errorCallback) {
    request("/me/player/queue?uri=" + encodeURIComponent(uri), callback, errorCallback, "POST")
}

// Follow/Unfollow
function followArtist(artistId, callback, errorCallback) {
    request("/me/following?type=artist&ids=" + artistId, callback, errorCallback, "PUT")
}

function unfollowArtist(artistId, callback, errorCallback) {
    request("/me/following?type=artist&ids=" + artistId, callback, errorCallback, "DELETE")
}

function followPlaylist(playlistId, callback, errorCallback) {
    request("/playlists/" + playlistId + "/followers", callback, errorCallback, "PUT")
}

function unfollowPlaylist(playlistId, callback, errorCallback) {
    request("/playlists/" + playlistId + "/followers", callback, errorCallback, "DELETE")
}

function checkFollowingArtists(artistIds, callback, errorCallback) {
    request("/me/following/contains?type=artist&ids=" + artistIds.join(","), callback, errorCallback)
}

function getFollowedArtists(callback, errorCallback, limit) {
    limit = limit || 20
    request("/me/following?type=artist&limit=" + limit, callback, errorCallback)
}

// Albums
function saveAlbums(albumIds, callback, errorCallback) {
    var data = { "ids": albumIds }
    request("/me/albums", callback, errorCallback, "PUT", data)
}

function removeAlbums(albumIds, callback, errorCallback) {
    var data = { "ids": albumIds }
    request("/me/albums", callback, errorCallback, "DELETE", data)
}

function checkSavedAlbums(albumIds, callback, errorCallback) {
    request("/me/albums/contains?ids=" + albumIds.join(","), callback, errorCallback)
}

// Shows (Podcasts)
function getSavedShows(callback, errorCallback, limit, offset) {
    limit = limit || 20
    offset = offset || 0
    request("/me/shows?limit=" + limit + "&offset=" + offset, callback, errorCallback)
}

function saveShows(showIds, callback, errorCallback) {
    var data = { "ids": showIds }
    request("/me/shows", callback, errorCallback, "PUT", data)
}

function removeShows(showIds, callback, errorCallback) {
    request("/me/shows?ids=" + showIds.join(","), callback, errorCallback, "DELETE")
}

function getShow(showId, callback, errorCallback) {
    request("/shows/" + showId, callback, errorCallback)
}

function getShowEpisodes(showId, callback, errorCallback, limit, offset) {
    limit = limit || 20
    offset = offset || 0
    request("/shows/" + showId + "/episodes?limit=" + limit + "&offset=" + offset, callback, errorCallback)
}

// Episodes
function getSavedEpisodes(callback, errorCallback, limit, offset) {
    limit = limit || 20
    offset = offset || 0
    request("/me/episodes?limit=" + limit + "&offset=" + offset, callback, errorCallback)
}

function saveEpisodes(episodeIds, callback, errorCallback) {
    var data = { "ids": episodeIds }
    request("/me/episodes", callback, errorCallback, "PUT", data)
}

function removeEpisodes(episodeIds, callback, errorCallback) {
    request("/me/episodes?ids=" + episodeIds.join(","), callback, errorCallback, "DELETE")
}

function getEpisode(episodeId, callback, errorCallback) {
    request("/episodes/" + episodeId, callback, errorCallback)
}

// Audiobooks
function getSavedAudiobooks(callback, errorCallback, limit, offset) {
    limit = limit || 20
    offset = offset || 0
    request("/me/audiobooks?limit=" + limit + "&offset=" + offset, callback, errorCallback)
}

function saveAudiobooks(audiobookIds, callback, errorCallback) {
    var data = { "ids": audiobookIds }
    request("/me/audiobooks", callback, errorCallback, "PUT", data)
}

function removeAudiobooks(audiobookIds, callback, errorCallback) {
    request("/me/audiobooks?ids=" + audiobookIds.join(","), callback, errorCallback, "DELETE")
}

function getAudiobook(audiobookId, callback, errorCallback) {
    request("/audiobooks/" + audiobookId, callback, errorCallback)
}

// Categories & Browse
function getCategories(callback, errorCallback, limit, offset) {
    limit = limit || 20
    offset = offset || 0
    request("/browse/categories?limit=" + limit + "&offset=" + offset, callback, errorCallback)
}

function getCategoryPlaylists(categoryId, callback, errorCallback, limit, offset) {
    limit = limit || 20
    offset = offset || 0
    request("/browse/categories/" + categoryId + "/playlists?limit=" + limit + "&offset=" + offset, callback, errorCallback)
}

function getFeaturedPlaylists(callback, errorCallback, limit, offset) {
    limit = limit || 20
    offset = offset || 0
    request("/browse/featured-playlists?limit=" + limit + "&offset=" + offset, callback, errorCallback)
}

function getNewReleases(callback, errorCallback, limit, offset) {
    limit = limit || 20
    offset = offset || 0
    request("/browse/new-releases?limit=" + limit + "&offset=" + offset, callback, errorCallback)
}

// Playlist details/management
function updatePlaylistDetails(playlistId, name, description, isPublic, callback, errorCallback) {
    var data = {}
    if (name !== undefined) data.name = name
    if (description !== undefined) data.description = description
    if (isPublic !== undefined) data.public = isPublic
    request("/playlists/" + playlistId, callback, errorCallback, "PUT", data)
}

function reorderPlaylistTracks(playlistId, rangeStart, insertBefore, rangeLength, callback, errorCallback) {
    var data = {
        "range_start": rangeStart,
        "insert_before": insertBefore,
        "range_length": rangeLength || 1
    }
    request("/playlists/" + playlistId + "/tracks", callback, errorCallback, "PUT", data)
}

function replacePlaylistTracks(playlistId, uris, callback, errorCallback) {
    var data = { "uris": uris }
    request("/playlists/" + playlistId + "/tracks", callback, errorCallback, "PUT", data)
}

// Related artists
function getRelatedArtists(artistId, callback, errorCallback) {
    request("/artists/" + artistId + "/related-artists", callback, errorCallback)
}

// Multiple artists/albums/tracks at once
function getMultipleArtists(artistIds, callback, errorCallback) {
    request("/artists?ids=" + artistIds.join(","), callback, errorCallback)
}

function getMultipleAlbums(albumIds, callback, errorCallback) {
    request("/albums?ids=" + albumIds.join(","), callback, errorCallback)
}

function getMultipleTracks(trackIds, callback, errorCallback) {
    request("/tracks?ids=" + trackIds.join(","), callback, errorCallback)
}

// Available genre seeds for recommendations
function getAvailableGenreSeeds(callback, errorCallback) {
    request("/recommendations/available-genre-seeds", callback, errorCallback)
}

// Markets
function getAvailableMarkets(callback, errorCallback) {
    request("/markets", callback, errorCallback)
}

// Track audio features/analysis
function getTrackAudioFeatures(trackId, callback, errorCallback) {
    request("/audio-features/" + trackId, callback, errorCallback)
}

function getTracksAudioFeatures(trackIds, callback, errorCallback) {
    request("/audio-features?ids=" + trackIds.join(","), callback, errorCallback)
}

function getTrackAudioAnalysis(trackId, callback, errorCallback) {
    request("/audio-analysis/" + trackId, callback, errorCallback)
}

// Playback with more options
function startPlayback(deviceId, contextUri, uris, offset, positionMs, callback, errorCallback) {
    var endpoint = "/me/player/play"
    if (deviceId) endpoint += "?device_id=" + deviceId

    var data = {}
    if (contextUri) data.context_uri = contextUri
    if (uris) data.uris = uris
    if (offset !== undefined) data.offset = offset
    if (positionMs !== undefined) data.position_ms = positionMs

    request(endpoint, callback, errorCallback, "PUT", data)
}

// Exchange authorization code for access token (PKCE)
function exchangeCodeForToken(code, codeVerifier, clientId, clientSecret, redirectUri, callback, errorCallback) {
    var xhr = new XMLHttpRequest()
    var url = "https://accounts.spotify.com/api/token"

    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status >= 200 && xhr.status < 300) {
                try {
                    var response = JSON.parse(xhr.responseText)
                    if (callback) callback(response)
                } catch (e) {
                    console.error("Failed to parse token response:", e)
                    if (errorCallback) errorCallback("Parse error: " + e)
                }
            } else {
                console.error("Token exchange failed:", xhr.status, xhr.statusText, xhr.responseText)
                if (errorCallback) {
                    try {
                        var error = JSON.parse(xhr.responseText)
                        errorCallback(error.error_description || error.error || xhr.statusText)
                    } catch (e) {
                        errorCallback(xhr.statusText)
                    }
                }
            }
        }
    }

    xhr.open("POST", url, true)
    xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")

    var params = "grant_type=authorization_code"
    params += "&code=" + encodeURIComponent(code)
    params += "&redirect_uri=" + encodeURIComponent(redirectUri)
    params += "&client_id=" + encodeURIComponent(clientId)
    params += "&code_verifier=" + encodeURIComponent(codeVerifier)

    if (clientSecret) {
        params += "&client_secret=" + encodeURIComponent(clientSecret)
    }

    xhr.send(params)
}
