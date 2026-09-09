import QtQuick
import "../.."

Item {
    id: feedback

    required property real s
    required property ThemeState themeState

    width: 340 * s
    height: 34 * s

    readonly property bool active: textLabel.opacity > 0
    readonly property string displayText: textLabel.text

    property bool _granted: false
    readonly property string icon: "\u2726"

    Text {
        id: textLabel

        anchors.centerIn: parent

        text: (feedback._granted ? "ACCESS GRANTED " : "ACCESS DENIED ") + feedback.icon
        font.family: feedback.themeState.fontFamily
        font.pixelSize: 22 * feedback.s
        font.weight: Font.Bold
        font.letterSpacing: 2 * feedback.s
        color: feedback._granted ? feedback.themeState.mainTextColor
                                 : feedback.themeState.denyColor
        opacity: 0
    }

    NumberAnimation {
        id: fadeIn
        target: textLabel
        property: "opacity"
        from: 0
        to: 1
        duration: 250
        easing.type: Easing.OutCubic
    }

    NumberAnimation {
        id: fadeOut
        target: textLabel
        property: "opacity"
        from: 1
        to: 0
        duration: 400
        easing.type: Easing.InCubic
    }

    Timer {
        id: hideTimer
        interval: 2200
        repeat: false
        onTriggered: fadeOut.start()
    }

    function _show(granted) {
        feedback._granted = granted
        hideTimer.stop()
        fadeOut.stop()
        textLabel.opacity = 0
        fadeIn.start()
        hideTimer.interval = granted ? 2200 : 5000
        hideTimer.start()
    }

    function showSuccess() { feedback._show(true) }
    function showDenied()  { feedback._show(false) }
}
