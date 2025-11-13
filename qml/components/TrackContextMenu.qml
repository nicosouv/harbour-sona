import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/SpotifyAPI.js" as SpotifyAPI

ContextMenu {
    id: contextMenu

    property string trackId: ""
    property string trackUri: ""
    property string trackName: ""
    property string artistName: ""
    property bool isSaved: false

    MenuItem {
        text: qsTr("Play Now")
        onClicked: {
            PlaybackManager.play(null, null, [trackUri])
        }
    }

    MenuItem {
        text: qsTr("Add to Queue")
        onClicked: {
            SpotifyAPI.addToQueue(trackUri, function() {
                console.log("Added to queue:", trackName)
            }, function(error) {
                console.error("Failed to add to queue:", error)
            })
        }
    }

    MenuItem {
        text: isSaved ? qsTr("Remove from Library") : qsTr("Save to Library")
        onClicked: {
            if (isSaved) {
                SpotifyAPI.removeSavedTracks([trackId], function() {
                    console.log("Removed from library:", trackName)
                    isSaved = false
                }, function(error) {
                    console.error("Failed to remove from library:", error)
                })
            } else {
                SpotifyAPI.saveTracks([trackId], function() {
                    console.log("Saved to library:", trackName)
                    isSaved = true
                }, function(error) {
                    console.error("Failed to save to library:", error)
                })
            }
        }
    }

    MenuItem {
        text: qsTr("Go to Artist")
        visible: artistName !== ""
        onClicked: {
            // This would need the artist ID - could be passed as property
            console.log("Go to artist:", artistName)
        }
    }

    MenuItem {
        text: qsTr("Share Track")
        onClicked: {
            // Share the Spotify URI or web link
            console.log("Share:", trackUri)
        }
    }
}
