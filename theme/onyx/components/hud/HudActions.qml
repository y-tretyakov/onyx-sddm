import QtQuick
import "../.."

Row {
    id: hudActions

    required property real s
    required property ThemeState themeState

    property alias rebootAction: rebootBtn
    property alias powerAction: powerBtn

    spacing: 25 * hudActions.s

    HudAction {
        id: rebootBtn
        s: hudActions.s
        themeState: hudActions.themeState
        iconSource: "icons/reboot.svg"
        hoverColor: "#4a9eff"
        onClicked: { if (typeof sddm !== "undefined") sddm.reboot() }
    }

    Rectangle {
        width: 1 * hudActions.s
        height: 10 * hudActions.s
        color: hudActions.themeState.pillDividerColor
        anchors.verticalCenter: parent.verticalCenter
    }

    HudAction {
        id: powerBtn
        s: hudActions.s
        themeState: hudActions.themeState
        iconSource: "icons/power.svg"
        hoverColor: "#ff5c5c"
        onClicked: { if (typeof sddm !== "undefined") sddm.powerOff() }
    }
}