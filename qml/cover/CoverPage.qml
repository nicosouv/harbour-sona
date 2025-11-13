import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    Label {
        id: label
        anchors.centerIn: parent
        text: qsTr("Sona")
        font.pixelSize: Theme.fontSizeLarge
    }

    CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: "image://theme/icon-cover-play"
        }

        CoverAction {
            iconSource: "image://theme/icon-cover-pause"
        }
    }
}
