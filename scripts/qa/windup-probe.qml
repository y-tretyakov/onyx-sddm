import QtQuick
import QtQuick.Window
import "../../theme/onyx/components/effects"

Window {
    width: 480
    height: 200
    visible: true

    AnimEngine {
        id: engine
        clockAwake: true
    }

    function fail(reason) {
        console.log("WINDUP-PROBE: FAIL: " + reason)
        Qt.exit(1)
    }

    Timer { id: tStart; interval: 60  ; repeat: false; onTriggered: checkStart() }
    Timer { id: tWind ; interval: 560 ; repeat: false; onTriggered: checkWindup() }
    Timer { id: tBoom ; interval: 1780; repeat: false; onTriggered: checkBoom() }
    Timer { id: tEnd  ; interval: 2500; repeat: false; onTriggered: checkEnd() }

    function checkStart() {
        if (!engine.isWindup)
            return fail("isWindup false right after startReveal")
        tWind.start()
    }

    function checkWindup() {
        if (!engine.isWindup)
            return fail("windup ended before 560ms")
        if (!(engine.windupOffset > 0))
            return fail("windupOffset not >0 during windup")
        tBoom.start()
    }

    function checkBoom() {
        if (!(engine.boomOpacity > 0))
            return fail("boomOpacity still 0 at boom phase")
        if (!(engine.boomScale > 1.0))
            return fail("boomScale did not grow during boom")
        tEnd.start()
    }

    function checkEnd() {
        if (!(engine.uiOpacity === 1.0))
            return fail("uiOpacity !== 1 after fadeIn completed")
        console.log("WINDUP-PROBE: OK")
        Qt.exit(0)
    }

    Component.onCompleted: {
        engine.startReveal()
        tStart.start()
    }
}