import QtQuick
import "../.."

Item {
    id: cursor

    required property real s
    required property ThemeState themeState

    property real cursorX: 0
    property real cursorY: 0
    property bool uiReady: false

    readonly property bool active: cursor.themeState.isWayland && cursor.uiReady

    readonly property real gx: cursor.cursorX - cursor.width / 2
    readonly property real gy: cursor.cursorY - cursor.height / 2

    width: 16 * cursor.s
    height: 16 * cursor.s
    visible: cursor.active
    x: cursor.gx
    y: cursor.gy

    Text {
        anchors.centerIn: parent
        text: "\u2726"
        font.pixelSize: 18 * cursor.s
        font.family: cursor.themeState.fontFamily
        color: cursor.themeState.mainTextColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}