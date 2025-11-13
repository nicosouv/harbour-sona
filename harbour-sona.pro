TARGET = harbour-sona

CONFIG += sailfishapp

SOURCES += src/harbour-sona.cpp

DISTFILES += qml/harbour-sona.qml \
    qml/cover/CoverPage.qml \
    qml/pages/MainPage.qml \
    qml/pages/AboutPage.qml \
    qml/pages/PlaylistsPage.qml \
    qml/pages/PlaylistDetailsPage.qml \
    qml/pages/SearchPage.qml \
    qml/pages/PlayerPage.qml \
    qml/js/SpotifyAPI.js \
    qml/config.js \
    rpm/harbour-sona.changes \
    rpm/harbour-sona.spec \
    harbour-sona.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

# Amber Web Authorization for OAuth2
CONFIG += link_pkgconfig
PKGCONFIG += amberwebauthorization
