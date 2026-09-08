import QtQuick

Rectangle {
    id: pill

    required property string curM
    required property string curS
    required property real s

    width: 330 * s
    height: 90 * s
    radius: 12 * s
    color: "#1A1A1A"
    border.color: "#333333"
    border.width: 1 * s

    // Minutes — left half
    Text {
        id: minText

        anchors.left: parent.left
        anchors.leftMargin: 20 * pill.s
        anchors.verticalCenter: parent.verticalCenter

        text: pill.curM
        font.family: "Sans Serif"
        font.pixelSize: 36 * pill.s
        font.weight: Font.DemiBold
        color: "#CCCCCC"
    }

    // Vertical divider
    Rectangle {
        width: 1 * pill.s
        height: 40 * pill.s
        anchors.centerIn: parent
        color: "#444444"
    }

    // Seconds — right half
    Text {
        id: secText

        anchors.right: parent.right
        anchors.rightMargin: 20 * pill.s
        anchors.verticalCenter: parent.verticalCenter

        text: pill.curS
        font.family: "Sans Serif"
        font.pixelSize: 36 * pill.s
        font.weight: Font.DemiBold
        color: "#888888"
    }
}
