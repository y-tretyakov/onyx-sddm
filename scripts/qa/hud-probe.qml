import QtQuick
import QtQuick.Window
import "../../theme/onyx"
import "../../theme/onyx/components/hud" as Hud

Window {
    id: probe
    width: 480
    height: 200
    visible: true

    // Greeter context stub: sddm injected as unqualified access, mirroring SDDM.
    property var sddm: ({
        reboot: function() { probe.rebootCalls++ },
        powerOff: function() { probe.powerOffCalls++ }
    })

    property int rebootCalls: 0
    property int powerOffCalls: 0

    Item {
        anchors.fill: parent

        ThemeState { id: ts; s: 1 }

        Hud.HudActions {
            id: hudActions
            s: 1
            themeState: ts
            anchors.right: parent.right
            anchors.rightMargin: 80
            anchors.top: parent.top
            anchors.topMargin: 50
        }
    }

    function fail(reason) {
        console.log("HUD-PROBE: FAIL: " + reason)
        Qt.exit(1)
    }

    function pass() {
        console.log("HUD-PROBE: OK")
        Qt.exit(0)
    }

    property int stage: 0
    property int stall: 0

    Timer {
        id: checkTimer
        interval: 250
        repeat: false
        onTriggered: run()
    }

    Timer {
        id: pollTimer
        interval: 40
        repeat: true
        onTriggered: poll()
    }

    // Offscreen throttles the animation clock, so scale is polled until it
    // reaches the hover target (same pattern as user-session-probe).
    function poll() {
        if (probe.stage !== 1) {
            pollTimer.stop()
            return
        }
        if (hudActions.rebootAction.scale > 1.1) {
            probe.stage = 2
            pollTimer.stop()
            hudActions.powerAction.active = true
            var ovColor = hudActions.powerAction.hoverColor
            var expColor = Qt.rgba(1.0, 92 / 255, 92 / 255, 1.0)
            if (Math.abs(ovColor.r - expColor.r) > 0.001
                    || Math.abs(ovColor.g - expColor.g) > 0.001
                    || Math.abs(ovColor.b - expColor.b) > 0.001)
                return fail("power hoverColor not wired (got " + ovColor.toString() + ")")
            pass()
            return
        }
        if (++probe.stall > 60)
            fail("active=true did not raise scale (stuck at " + hudActions.rebootAction.scale + ")")
    }

    function run() {
        // Wiring: clicks must reach the sddm stub.
        hudActions.rebootAction.clicked()
        if (probe.rebootCalls !== 1)
            return fail("rebootAction.clicked() did not call sddm.reboot()")

        hudActions.powerAction.clicked()
        if (probe.powerOffCalls !== 1)
            return fail("powerAction.clicked() did not call sddm.powerOff()")

        // Hover surface: active -> scale grows + hover tint applied.
        if (hudActions.rebootAction.active)
            return fail("active should be false without hover")

        hudActions.rebootAction.active = true
        probe.stage = 1
        probe.stall = 0
        pollTimer.start()
    }

    Component.onCompleted: checkTimer.start()
}