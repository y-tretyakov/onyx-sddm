import QtQuick
import "../.."

Rectangle {
    id: pill

    required property string curM
    required property string curS
    required property real s
    required property ThemeState themeState

    width: 330 * s
    height: 90 * s
    radius: 45 * s
    color: themeState.pillColor
    border.color: themeState.pillBorderColor
    border.width: 1 * s

    readonly property real minCenterX: minText.x + minText.width / 2
    readonly property real minCenterY: minText.y + minText.height / 2
    readonly property real secCenterX: secText.x + secText.width / 2
    readonly property real secCenterY: secText.y + secText.height / 2

    Text {
        id: minText
        x: 85 * pill.s - width / 2
        anchors.verticalCenter: parent.verticalCenter

        text: pill.curM
        font.family: pill.themeState.fontFamily
        font.pixelSize: 54 * pill.s
        font.weight: Font.Black
        color: pill.themeState.mainTextColor
    }

    Rectangle {
        id: divider
        x: 170 * pill.s
        y: (pill.height - 35 * pill.s) / 2
        width: 1 * pill.s
        height: 35 * pill.s
        color: pill.themeState.pillDividerColor
    }

    Text {
        id: secText
        x: 255 * pill.s - width / 2
        anchors.verticalCenter: parent.verticalCenter

        text: pill.curS
        font.family: pill.themeState.fontFamily
        font.pixelSize: 30 * pill.s
        font.weight: Font.Bold
        color: pill.themeState.mainTextColor
    }
}
