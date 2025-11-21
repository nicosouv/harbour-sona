TARGET = harbour-sona

CONFIG += sailfishapp

PKGCONFIG += amberwebauthorization

SOURCES += src/harbour-sona.cpp

DISTFILES += qml/harbour-sona.qml \
    qml/cover/CoverPage.qml \
    qml/pages/MainPage.qml \
    qml/pages/AboutPage.qml \
    qml/pages/PlaylistsPage.qml \
    qml/pages/PlaylistDetailsPage.qml \
    qml/pages/SearchPage.qml \
    qml/pages/PlayerPage.qml \
    qml/pages/ArtistPage.qml \
    qml/pages/LibraryPage.qml \
    qml/pages/DiscoverPage.qml \
    qml/pages/AlbumDetailsPage.qml \
    qml/pages/DevicesPage.qml \
    qml/pages/StatsPage.qml \
    qml/components/PlaybackManager.qml \
    qml/components/MiniPlayer.qml \
    qml/components/TrackContextMenu.qml \
    qml/components/PlaylistDialog.qml \
    qml/components/ErrorNotification.qml \
    qml/components/SpotifyAndroidHelper.qml \
    qml/components/qmldir \
    qml/js/SpotifyAPI.js \
    qml/py/spotify_android.py \
    qml/config.js \
    qml/config.js.example \
    rpm/harbour-sona.changes \
    rpm/harbour-sona.spec \
    harbour-sona.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172
