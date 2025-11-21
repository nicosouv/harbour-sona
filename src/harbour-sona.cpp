#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <sailfishapp.h>
#include <QGuiApplication>
#include <QQuickView>
#include <QQmlContext>
#include <QtQml>

#include "spotifyandroidhelper.h"

int main(int argc, char *argv[])
{
    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    QScopedPointer<QQuickView> view(SailfishApp::createView());

    // Register C++ types for QML
    qmlRegisterType<SpotifyAndroidHelper>("harbour.sona.SpotifyAndroid", 1, 0, "SpotifyAndroidHelper");

    // Expose command line arguments to QML
    QStringList args;
    for (int i = 0; i < argc; i++) {
        args << QString::fromUtf8(argv[i]);
    }
    view->rootContext()->setContextProperty("commandLineArguments", args);

    view->setSource(SailfishApp::pathTo("qml/harbour-sona.qml"));
    view->show();

    return app->exec();
}
