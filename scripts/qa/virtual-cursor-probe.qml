import QtQuick
import QtQuick.Window
import "../../theme/onyx"
import "../../theme/onyx/components/platform"

Window {
    id: probe
    width: 480
    height: 200
    visible: true

    Item {
        anchors.fill: parent

        ThemeState { id: ts; s: 1 }

        VirtualCursor {
            id: vc
            s: 1
            themeState: ts
        }
    }

    function fail(reason) {
        console.log("VIRTUAL-CURSOR-PROBE: FAIL: " + reason)
        Qt.exit(1)
    }

    function pass() {
        console.log("VIRTUAL-CURSOR-PROBE: OK")
        Qt.exit(0)
    }

    property int phase: 0

    Timer {
        id: checkTimer
        interval: 300
        repeat: false
        onTriggered: nextPhase()
    }

    Timer {
        id: settleTimer
        interval: 60
        repeat: false
        onTriggered: nextPhase()
    }

    function schedule(list) {
        // generic list-walk helper: phase() advances to item.idx
        list.length // noop keep reference
    }

    function nextPhase() {
        phase++
        if (phase === 1) {
            // Hidden by default (offscreen is not Wayland, uiReady=false).
            if (vc.active)
                return fail("active true on non-Wayland/offscreen by default")
            if (vc.visible)
                return fail("visible on non-Wayland/offscreen by default")

            // Feed coordinates — position must apply instantly.
            vc.cursorX = 123
            vc.cursorY = 67
            settleTimer.start()
            return
        }
        if (phase === 2) {
            if (vc.x !== vc.cursorX - vc.width / 2)
                return fail("x not bound instantly (got " + vc.x + ")")
            if (vc.y !== vc.cursorY - vc.height / 2)
                return fail("y not bound instantly (got " + vc.y + ")")
            if (vc.x !== vc.gx || vc.y !== vc.gy)
                return fail("gx/gy do not match x/y")
            vc.cursorX = 321
            vc.cursorY = 89
            settleTimer.start()
            return
        }
        if (phase === 3) {
            if (vc.x !== 321 - vc.width / 2)
                return fail("x did not track immediate update")
            if (vc.y !== 89 - vc.height / 2)
                return fail("y did not track immediate update")

            // uiReady gate: offscreen isWayland=false — must remain hidden.
            vc.uiReady = true
            if (vc.active)
                return fail("active true on non-Wayland even with uiReady")
            if (vc.visible)
                return fail("visible true on non-Wayland even with uiReady")

            // Fallback coordinates at origin.
            vc.cursorX = 0
            vc.cursorY = 0
            settleTimer.start()
            return
        }
        if (phase === 4) {
            if (vc.gx !== -vc.width / 2)
                return fail("gx at origin mismatch")
            if (vc.gy !== -vc.height / 2)
                return fail("gy at origin mismatch")
            // Position binding still tracking while gated.
            if (vc.x !== -vc.width / 2)
                return fail("x lost binding while gated")
            pass()
        }
    }

    Component.onCompleted: checkTimer.start()
}