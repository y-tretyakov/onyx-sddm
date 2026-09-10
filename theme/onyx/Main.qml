import QtQuick
import "components/clock" as Clock
import "components/login" as Login

Rectangle {
    id: root
    width: Screen.width
    height: Screen.height
    color: state.bgColor

    readonly property real s: Screen.height / 768
    readonly property real marginR: 80 * root.s

    FontLoader {
        id: outfitFont
        source: "font/Outfit-Black.ttf"
    }

    ThemeState {
        id: state
        s: root.s
        fontFamily: outfitFont.status === FontLoader.Ready ? outfitFont.name : "Sans Serif"
    }

    Clock.ClockRoot {
        id: clock
        s: root.s
        themeState: state
    }

    Login.LoginPanel {
        id: loginPanel
        s: root.s
        themeState: state
        anchors.right: parent.right
        anchors.rightMargin: root.marginR
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 80 * root.s
    }

    Login.AuthFeedback {
        id: authFeedback
        s: root.s
        themeState: state
        anchors.right: loginPanel.right
        anchors.bottom: loginPanel.top
        anchors.bottomMargin: 12 * root.s
    }

    Connections {
        target: typeof sddm !== "undefined" ? sddm : null
        onLoginSucceeded: authFeedback.showSuccess()
        onLoginFailed: authFeedback.showDenied()
    }
}
