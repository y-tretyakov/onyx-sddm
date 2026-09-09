import QtQuick
import QtQuick.Window
import "../../theme/onyx"
import "../../theme/onyx/components/login"

Window {
    width: 480
    height: 200
    visible: true

    ThemeState {
        id: ts
        s: 1
    }

    AuthFeedback {
        id: fb
        anchors.centerIn: parent
        s: 1
        themeState: ts
    }

    Timer {
        id: denyTimer
        interval: 800
        repeat: false
        onTriggered: {
            var visible = fb.active
            var isDenied = !fb._granted
            var ok = visible && isDenied
            console.log("PROBE slide1 denied active=" + fb.active + " granted=" + fb._granted + (ok ? " OK" : " FAIL"))
            fb.showSuccess()
            successTimer.start()
        }
    }

    Timer {
        id: successTimer
        interval: 800
        repeat: false
        onTriggered: {
            var visible = fb.active
            var isGranted = fb._granted
            var ok = visible && isGranted
            console.log("PROBE slide2 success active=" + fb.active + " granted=" + fb._granted + (ok ? " OK" : " FAIL"))
            Qt.exit(ok ? 0 : 1)
        }
    }

    Component.onCompleted: {
        fb.showDenied()
        denyTimer.start()
    }
}
