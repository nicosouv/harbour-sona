import QtQuick 2.0
import harbour.sona.SpotifyAndroid 1.0

Item {
    id: wrapper

    property var _pendingInstalledCallback: null
    property var _pendingRunningCallback: null
    property var _pendingLaunchCallback: null

    SpotifyAndroidHelper {
        id: backend

        onInstalledResult: {
            console.log("SpotifyAndroidHelper QML: Installed result:", installed)
            if (_pendingInstalledCallback) {
                _pendingInstalledCallback(installed)
                _pendingInstalledCallback = null
            }
        }

        onRunningResult: {
            console.log("SpotifyAndroidHelper QML: Running result:", running)
            if (_pendingRunningCallback) {
                _pendingRunningCallback(running)
                _pendingRunningCallback = null
            }
        }

        onLaunchResult: {
            console.log("SpotifyAndroidHelper QML: Launch result:", success)
            if (_pendingLaunchCallback) {
                _pendingLaunchCallback(success)
                _pendingLaunchCallback = null
            }
        }
    }

    function checkInstalled(callback) {
        _pendingInstalledCallback = callback
        backend.checkInstalled()
    }

    function checkRunning(callback) {
        _pendingRunningCallback = callback
        backend.checkRunning()
    }

    function launch(callback) {
        _pendingLaunchCallback = callback
        backend.launch()
    }
}
