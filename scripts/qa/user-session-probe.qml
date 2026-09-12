import QtQuick
import QtQuick.Window
import "../../theme/onyx"
import "../../theme/onyx/components/login"

Window {
    id: probe
    width: 480
    height: 200
    visible: true

    property var userModel: ListModel {
        ListElement { name: "alice"; realName: "Alice Example" }
        ListElement { name: "bob"; realName: "Bob Builder" }
        ListElement { name: "carol"; realName: "Carol Crunch" }
    }
    property var sessionModel: ListModel {
        ListElement { name: "plasma" }
        ListElement { name: "hyprland" }
        ListElement { name: "niri" }
    }

    ThemeState {
        id: ts
        s: 1
    }

    LoginPanel {
        id: panel
        s: 1
        themeState: ts
        width: 350
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 80
        sessionIndex: 0
    }

    SessionPicker {
        id: sessionPicker
        s: 1
        themeState: ts
        anchors.right: parent.right
        anchors.rightMargin: 80
        anchors.top: parent.top
        anchors.topMargin: 50
    }

    function fail(reason) {
        console.log("USER-SESSION-PROBE: FAIL: " + reason)
        Qt.exit(1)
    }
    function ok() {
        console.log("USER-SESSION-PROBE: OK")
        Qt.exit(0)
    }

    property int stage: 0
    property int stall: 0

    // Offscreen throttles frame-driven updates, so poll instead of fixed
    // delays (same pattern as sparks-burst-probe).
    Timer {
        interval: 40
        repeat: true
        running: true
        onTriggered: {
            if (probe.stage === 0) {
                var uName = (panel.userPicker ? panel.userPicker.currentName : "")
                if (uName === "") {
                    if (++probe.stall > 25)
                        probe.fail("currentName empty (expected non-empty from userModel)")
                    return
                }
                probe.stall = 0
                panel.userPicker.select(1)
                probe.stage = 1
            } else if (probe.stage === 1) {
                var login = (panel.userPicker ? panel.userPicker.currentLogin : "")
                if (login === "bob" && panel.userPicker.selectedIndex === 1) {
                    probe.stall = 0
                    sessionPicker.select(2)
                    probe.stage = 2
                } else if (++probe.stall > 25) {
                    probe.fail("currentLogin after select(1) != bob: " + login)
                }
            } else if (probe.stage === 2) {
                if (sessionPicker.selectedIndex === 2 && sessionPicker.currentName.toUpperCase() === "NIRI") {
                    probe.stall = 0
                    if (panel.sessionIndex !== 0)
                        probe.fail("panel.sessionIndex != 0 (default)")
                    panel.sessionIndex = sessionPicker.selectedIndex
                    probe.stage = 3
                } else if (++probe.stall > 25) {
                    probe.fail("session selectedIndex/currentName mismatch: " + sessionPicker.selectedIndex + " / " + sessionPicker.currentName)
                }
            } else if (probe.stage === 3) {
                if (panel.sessionIndex === 2) {
                    probe.stall = 0
                    sessionPicker.open = true
                    probe.stage = 4
                } else if (++probe.stall > 25) {
                    probe.fail("panel.sessionIndex != 2 after assign")
                }
            } else if (probe.stage === 4) {
                if (sessionPicker.open) {
                    probe.ok()
                } else if (++probe.stall > 25) {
                    probe.fail("sessionPicker.open not settable")
                }
            }
        }
    }
}