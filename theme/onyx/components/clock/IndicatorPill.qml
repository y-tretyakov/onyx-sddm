import QtQuick

Rectangle {
    id: pill

    required property string curM
    required property string curS
    required property real s
    required property QtObject themeState

    width: 330 * s
    height: 90 * s
    radius: 12 * s
    color: themeState.pillBgColor
    border.color: themeState.pillBorderColor
    border.width: 1 * s

    // Minutes — left half
    Text {
        id: minText

        anchors.left: parent.left
        anchors.leftMargin: 20 * pill.s
        anchors.verticalCenter: parent.verticalCenter

        text: pill.curM
        font.family: pill.themeState.fontFamily
        font.pixelSize: 36 * pill.s
        font.weight: Font.DemiBold
        color: pill.themeState.pillMinutesColor
    }

    // Vertical divider
    Rectangle {
        width: 1 * pill.s
        height: 40 * pill.s
        anchors.centerIn: parent
        color: pill.themeState.pillDividerColor
    }

    // Seconds — right half
    Text {
        id: secText

        anchors.right: parent.right
        anchors.rightMargin: 20 * pill.s
        anchors.verticalCenter: parent.verticalCenter

        text: pill.curS
        font.family: pill.themeState.fontFamily
        font.pixelSize: 36 * pill.s
        font.weight: Font.DemiBold
        color: pill.themeState.pillSecondsColor
    }
}
