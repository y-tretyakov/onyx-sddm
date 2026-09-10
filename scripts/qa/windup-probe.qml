import QtQuick
import QtQuick.Window
import "../../theme/onyx"
import "../../theme/onyx/components/clock"
import "../../theme/onyx/components/effects"

Window {
    id: probe
    width: 480
    height: 200
    visible: true

    property bool mockAwake: true

    Item {
        anchors.fill: parent

        AnimEngine {
            id: engine
            clockAwake: true
            animationEnabled: true
        }

        ThemeState {
            id: state
            s: 1
        }

        ClockRoot {
            id: clockRoot
            s: 1
            themeState: state
            windupDegMin: engine.windupDegMin
            windupDegSec: engine.windupDegSec
            timeProvider.clockAwake: probe.mockAwake
        }
    }

    function fail(reason) {
        console.log("WINDUP-PROBE: FAIL: " + reason)
        Qt.exit(1)
    }

    function _ringBaseMin() {
        return -(clockRoot.timeProvider.curMinuteFloat / 60.0) * 360.0
    }

    function _ringBaseSec() {
        return -(clockRoot.timeProvider.curSecondFloat / 60.0) * 360.0
    }

    function _livePass(label, got, want) {
        if (Math.abs(got - want) > 1.0)
            return fail(label + ": got " + got.toFixed(2) + " want " + want.toFixed(2))
        return true
    }

    Timer { id: tStart;  interval: 60  ; repeat: false; onTriggered: checkStart() }
    Timer { id: tWind;   interval: 560 ; repeat: false; onTriggered: checkWindup() }
    Timer { id: tReach;  interval: 1300; repeat: false; onTriggered: checkWindupReach() }
    Timer { id: tBoom;   interval: 1780; repeat: false; onTriggered: checkBoom() }
    Timer { id: tEnd;    interval: 2500; repeat: false; onTriggered: checkEnd() }
    Timer { id: tGateA;  interval: 120 ; repeat: false; onTriggered: checkAwakeOff() }
    Timer { id: tGateB;  interval: 120 ; repeat: false; onTriggered: checkAwakeResume() }

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
        tReach.start()
    }

    function checkWindupReach() {
        if (!engine.isWindup)
            return fail("windup ended before reach-check at 1300ms")
        var secOk = _livePass("live sec ring",
            clockRoot.secondAngleDeg - _ringBaseSec(),
            -engine.windupDegSec)
        if (secOk !== true) return secOk
        var minOk = _livePass("live min ring",
            clockRoot.minuteAngleDeg - _ringBaseMin(),
            -engine.windupDegMin)
        if (minOk !== true) return minOk
        tBoom.start()
    }

    function checkBoom() {
        if (!(engine.boomOpacity > 0))
            return fail("boomOpacity still 0 at boom phase")
        if (!(engine.boomScale > 1.0))
            return fail("boomScale did not grow during boom")
        var secOk = _livePass("post-windup sec ring",
            clockRoot.secondAngleDeg - _ringBaseSec(),
            -engine.windupDegSec)
        if (secOk !== true) return secOk
        tEnd.start()
    }

    function checkEnd() {
        if (!(engine.uiOpacity === 1.0))
            return fail("uiOpacity !== 1 after fadeIn completed")
        checkAwakeOn()
    }

    function checkAwakeOn() {
        if (!clockRoot.timeProvider.smoothTimer.running)
            return fail("smoothTimer not running while mockAwake=true")
        probe.mockAwake = false
        tGateA.start()
    }

    function checkAwakeOff() {
        if (clockRoot.timeProvider.smoothTimer.running)
            return fail("smoothTimer still running while mockAwake=false")
        probe.mockAwake = true
        tGateB.start()
    }

    function checkAwakeResume() {
        if (!clockRoot.timeProvider.smoothTimer.running)
            return fail("smoothTimer did not resume after mockAwake=true restored")
        console.log("WINDUP-PROBE: OK")
        Qt.exit(0)
    }

    Component.onCompleted: {
        engine.startReveal()
        tStart.start()
    }
}
