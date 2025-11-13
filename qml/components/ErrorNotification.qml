import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components" 1.0

Rectangle {
    id: errorNotification
    width: parent.width
    height: visible ? Theme.itemSizeSmall : 0
    color: Theme.rgba("#FF5252", 0.95)
    visible: PlaybackManager.hasError
    z: 999

    Behavior on height {
        NumberAnimation {
            duration: 200
            easing.type: Easing.InOutQuad
        }
    }

    Row {
        anchors {
            fill: parent
            leftMargin: Theme.horizontalPageMargin
            rightMargin: Theme.horizontalPageMargin
        }
        spacing: Theme.paddingMedium

        Icon {
            anchors.verticalCenter: parent.verticalCenter
            source: "image://theme/icon-s-warning"
            color: "white"
            width: Theme.iconSizeSmall
            height: Theme.iconSizeSmall
        }

        Label {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - Theme.iconSizeSmall - parent.spacing
            text: PlaybackManager.errorMessage
            color: "white"
            font.pixelSize: Theme.fontSizeSmall
            wrapMode: Text.WordWrap
        }
    }
}
