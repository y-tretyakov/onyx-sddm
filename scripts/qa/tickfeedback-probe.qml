import QtQuick
import QtQuick.Window
import "../../theme/onyx"
import "../../theme/onyx/components/clock"

Window {
    id: probe
    width: 480
    height: 200
    visible: true

    Item {
        anchors.fill: parent

        ThemeState {
            id: ts
            s: 1
        }

        ClockRoot {
            id: clockRoot
            s: 1
            themeState: ts
        }
    }

    function fail(reason) {
        console.log("TICKFEEDBACK-PROBE: FAIL: " + reason)
        Qt.exit(1)
    }

    function pass() {
        console.log("TICKFEEDBACK-PROBE: OK")
        Qt.exit(0)
    }

    Timer { id: tEarly; interval: 80 ; repeat: false; onTriggered: checkEarly() }
    Timer { id: tMid;   interval: 550; repeat: false; onTriggered: checkMid() }
    Timer { id: tLate;  interval: 700; repeat: false; onTriggered: checkLate() }

    function checkEarly() {
        if (!(clockRoot.tickFlash > 0))
            return fail("tickFlash not > 0 at 80ms")
        if (!(clockRoot.tickHaloOpacity > 0))
            return fail("tickHaloOpacity not > 0 at 80ms")
        if (!(clockRoot.tickHaloR > 16))
            return fail("tickHaloR not > 16*s at 80ms")
        tMid.start()
    }

    function checkMid() {
        if (!(clockRoot.tickHaloR >= 105))
            return fail("tickHaloR not >= 105*s at 550ms")
        if (!(clockRoot.tickHaloOpacity < 0.1))
            return fail("tickHaloOpacity not < 0.1 at 550ms")
        if (!(clockRoot.tickFlash < 0.05))
            return fail("tickFlash not < 0.05 at 550ms")
        tLate.start()
    }

    function checkLate() {
        if (!(clockRoot.tickFlash < 0.01))
            return fail("tickFlash not ~0 at 700ms")
        if (!(clockRoot.tickHaloR >= 109))
            return fail("tickHaloR not near max at 700ms")
        if (!(clockRoot.tickHaloOpacity < 0.01))
            return fail("tickHaloOpacity not ~0 at 700ms")
        pass()
    }

    Component.onCompleted: {
        clockRoot.triggerTickFeedback()
        tEarly.start()
    }
}