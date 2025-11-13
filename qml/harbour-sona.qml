import QtQuick 2.0
import Sailfish.Silica 1.0

ApplicationWindow
{
    id: appWindow
    initialPage: Component {
        Qt.createComponent(Qt.resolvedUrl("pages/MainPage.qml")).createObject()
    }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations
}
