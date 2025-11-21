import QtQuick 2.0
import io.thp.pyotherside 1.5

Python {
    id: python

    Component.onCompleted: {
        addImportPath(Qt.resolvedUrl('../py'))
        importModule('spotify_android', function() {
            console.log('Spotify Android helper module loaded')
        })
    }

    function checkInstalled(callback) {
        call('spotify_android.check_installed', [], function(result) {
            if (callback) callback(result)
        })
    }

    function checkRunning(callback) {
        call('spotify_android.check_running', [], function(result) {
            if (callback) callback(result)
        })
    }

    function launch(callback) {
        call('spotify_android.launch', [], function(result) {
            if (callback) callback(result)
        })
    }
}
