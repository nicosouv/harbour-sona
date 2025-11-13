import QtQuick 2.0
import Sailfish.Silica 1.0
import "components" 1.0

ApplicationWindow
{
    id: appWindow

    initialPage: Qt.createComponent(Qt.resolvedUrl("pages/MainPage.qml"))

    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations

    ErrorNotification {
        anchors.top: parent.top
        width: parent.width
    }
}
