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
            clockAwake: true
        }
    }

    function fail(reason) {
        console.log("SPARKS-BURST-PROBE: FAIL: " + reason)
        Qt.exit(1)
    }

    function pass() {
        console.log("SPARKS-BURST-PROBE: OK")
        Qt.exit(0)
    }

    property int pollStartN: 0
    property int pollFadeN: 0

    Timer { id: tSecBurst; interval: 60; repeat: false; onTriggered: checkSecBurst() }

    // The offscreen render loop throttles NumberAnimation progress, so wall-clock
    // boundaries do not match animation completion. Poll instead of fixed delays.
    Timer {
        id: pollStartTimer
        interval: 25
        repeat: true
        onTriggered: {
            var started = clockRoot.secBurstOpacity > 0.0
                       && clockRoot.sparkImpulse > 0.0
            if (started) {
                pollStartTimer.stop()
                pollFadeN = 0
                pollFadeTimer.start()
                return
            }
            probe.pollStartN++
            if (probe.pollStartN > 12)
                probe.fail("sec burst never animated within 300ms")
        }
    }

    Timer {
        id: pollFadeTimer
        interval: 50
        repeat: true
        onTriggered: {
            var done = clockRoot.secBurstOpacity < 0.1
                     && clockRoot.secBurstScale >= 2.1
                     && clockRoot.sparkImpulse < 0.05
            if (done) {
                pollFadeTimer.stop()
                checkManual()
                return
            }
            probe.pollFadeN++
            if (probe.pollFadeN > 30)
                probe.fail("sec burst did not fade to ~0 within 1.5s")
        }
    }

    function checkSecBurst() {
        if (!(clockRoot.sparkBurst >= 1))
            return fail("sparkBurst not >= 1 after sec burst")
        pollStartN = 0
        pollStartTimer.start()
    }

    function checkManual() {
        clockRoot.timeProvider.curM = "42"
        clockRoot.timeProvider.curH = "07"
        if (!(clockRoot.minBurstOpacity > 0))
            return fail("minBurstOpacity not > 0 after curM change")
        if (!(clockRoot.hourBurstOpacity > 0))
            return fail("hourBurstOpacity not > 0 after curH change")
        if (!(clockRoot.sparkBurst >= 3))
            return fail("sparkBurst not >= 3 (sec+min+hour)")
        checkGate()
    }

    function checkGate() {
        clockRoot.clockAwake = false
        clockRoot.timeProvider.curS = "03"
        clockRoot.maybeSecBurst()
        if (!(clockRoot.secBurstOpacity < 0.01))
            return fail("sec burst started while clockAwake=false")
        if (!(clockRoot.sparkImpulse < 0.01))
            return fail("spark impulse started while clockAwake=false")
        pass()
    }

    Component.onCompleted: {
        // Deterministic probe: freeze the live tickers, drive time manually.
        clockRoot.timeProvider.clockAwake = false
        clockRoot.timeProvider.tickTimer.stop()
        clockRoot.timeProvider.curS = "01"
        clockRoot.timeProvider.curS = "02"
        tSecBurst.start()
    }
}