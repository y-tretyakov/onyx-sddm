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
        console.log("DATE-REVEAL-PROBE: FAIL: " + reason)
        Qt.exit(1)
    }

    function pass() {
        console.log("DATE-REVEAL-PROBE: OK")
        Qt.exit(0)
    }

    property int pollStartN: 0
    property int pollWeekdayN: 0
    property int pollBlurN: 0

    // The offscreen render loop throttles NumberAnimation progress and may lag
    // wall-clock for the 420ms weekday Timer, so poll with budgets instead of
    // fixed delays.
    Timer {
        id: pollStartTimer
        interval: 25
        repeat: true
        onTriggered: {
            var gate = clockRoot.dateBlock.dateAnimActive
                    && clockRoot.dateBlock.dateBlurR > 0
                    && !clockRoot.dateBlock.weekdayAnimActive
            if (gate) {
                pollStartTimer.stop()
                pollWeekdayN = 0
                pollWeekdayTimer.start()
                return
            }
            probe.pollStartN++
            if (probe.pollStartN > 20)
                probe.fail("date reveal never started (blur>0, dateAnimActive, weekday still idle)")
        }
    }

    Timer {
        id: pollWeekdayTimer
        interval: 25
        repeat: true
        onTriggered: {
            if (clockRoot.dateBlock.weekdayAnimActive) {
                pollWeekdayTimer.stop()
                pollBlurN = 0
                pollBlurTimer.start()
                return
            }
            probe.pollWeekdayN++
            if (probe.pollWeekdayN > 80)
                probe.fail("weekdayAnimActive never became true within 2s (420ms delay)")
        }
    }

    Timer {
        id: pollBlurTimer
        interval: 25
        repeat: true
        onTriggered: {
            var done = clockRoot.dateBlock.dateBlurR === 0
                    && clockRoot.dateBlock.dateAnimActive
            if (done) {
                pollBlurTimer.stop()
                probe.pass()
                return
            }
            probe.pollBlurN++
            if (probe.pollBlurN > 120)
                probe.fail("dateBlurR never reached 0 within 3s after weekday start")
        }
    }

    Component.onCompleted: {
        // Freeze live tickers; the reveal itself is driven manually.
        clockRoot.timeProvider.clockAwake = false
        clockRoot.timeProvider.tickTimer.stop()
        clockRoot.startDateReveal()
        pollStartN = 0
        pollStartTimer.start()
    }
}