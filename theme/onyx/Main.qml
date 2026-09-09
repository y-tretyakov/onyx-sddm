import QtQuick
import "components/clock" as Clock
import "components/login" as Login

Rectangle {
    id: root
    width: Screen.width
    height: Screen.height
    color: state.bgColor

    readonly property real s: Screen.height / 768

    ThemeState {
        id: state
        s: root.s
    }

    Clock.OrbitalRing {
        s: root.s
        themeState: state
        currentIndex: clock.timeProvider.curMinute
        anchors.centerIn: parent
    }

    Clock.OrbitalRing {
        id: secondRing
        s: root.s
        themeState: state
        radiusS: 270
        currentIndex: Math.floor(clock.timeProvider.curSecondFloat % 60)
        smoothPosition: clock.timeProvider.curSecondFloat
        anchors.centerIn: parent
    }

    Clock.DigitalClock {
        id: clock
        s: root.s
        themeState: state
        anchors.centerIn: parent
    }

    Login.LoginPanel {
        id: loginPanel
        s: root.s
        themeState: state
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 120 * root.s
    }

    Login.AuthFeedback {
        id: authFeedback
        s: root.s
        themeState: state
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: loginPanel.top
        anchors.bottomMargin: 12 * root.s
    }

    Connections {
        target: typeof sddm !== "undefined" ? sddm : null
        onLoginSucceeded: authFeedback.showSuccess()
        onLoginFailed: authFeedback.showDenied()
    }
}
