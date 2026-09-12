import QtQuick
import "../.."

Item {
    id: burst

    required property string text
    required property real s
    required property ThemeState themeState

    property real pixelSize: 30 * burst.s

    width: 1
    height: 1
    z: 20
    visible: opacity > 0.01

    Text {
        anchors.centerIn: parent
        text: burst.text
        color: burst.themeState.mainTextColor
        font.family: burst.themeState.fontFamily
        font.pixelSize: burst.pixelSize
        font.weight: Font.Bold
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    Text {
        anchors.centerIn: parent
        text: burst.text
        color: burst.themeState.tickAccentColor
        opacity: 0.65
        font.family: burst.themeState.fontFamily
        font.pixelSize: burst.pixelSize
        font.weight: Font.Bold
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}