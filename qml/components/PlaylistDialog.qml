import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/SpotifyAPI.js" as SpotifyAPI

Dialog {
    id: dialog

    property bool isEditMode: false
    property string playlistId: ""
    property string initialName: ""
    property string initialDescription: ""
    property bool initialPublic: true

    canAccept: nameField.text.length > 0

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingLarge

            DialogHeader {
                title: isEditMode ? qsTr("Edit Playlist") : qsTr("Create Playlist")
                acceptText: isEditMode ? qsTr("Save") : qsTr("Create")
            }

            TextField {
                id: nameField
                width: parent.width
                label: qsTr("Playlist Name")
                placeholderText: qsTr("Enter playlist name")
                text: initialName

                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: descriptionField.focus = true
            }

            TextArea {
                id: descriptionField
                width: parent.width
                label: qsTr("Description (optional)")
                placeholderText: qsTr("Enter description")
                text: initialDescription
            }

            TextSwitch {
                id: publicSwitch
                text: qsTr("Public Playlist")
                description: qsTr("Anyone can see and follow this playlist")
                checked: initialPublic
            }
        }

        VerticalScrollDecorator {}
    }

    onAccepted: {
        if (isEditMode) {
            // Edit existing playlist
            SpotifyAPI.changePlaylistDetails(
                playlistId,
                nameField.text,
                descriptionField.text,
                publicSwitch.checked,
                function() {
                    console.log("Playlist updated successfully")
                },
                function(error) {
                    console.error("Failed to update playlist:", error)
                }
            )
        } else {
            // Create new playlist
            // We need the user ID - this should be passed or retrieved from stored data
            SpotifyAPI.getUserProfile(function(profile) {
                SpotifyAPI.createPlaylist(
                    profile.id,
                    nameField.text,
                    descriptionField.text,
                    publicSwitch.checked,
                    function(playlist) {
                        console.log("Playlist created:", playlist.id)
                    },
                    function(error) {
                        console.error("Failed to create playlist:", error)
                    }
                )
            }, function(error) {
                console.error("Failed to get user profile:", error)
            })
        }
    }
}
