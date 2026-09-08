import QtQuick

Item {
    id: ring

    required property real s
    required property QtObject themeState
    required property int currentIndex

    width: 640 * s
    height: 640 * s

    Repeater {
        model: 60

        Item {
            id: tick

            readonly property bool isMajor: index % 5 === 0
            readonly property bool isCurrent: index === ring.currentIndex

            x: ring.width * 0.5
            y: ring.height * 0.5
            width: 1
            height: 1

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: (parent.isMajor ? 2 : 1) * ring.s
                height: (parent.isMajor ? 22 : 12) * ring.s
                radius: 1 * ring.s
                color: parent.isCurrent
                       ? ring.themeState.mainTextColor
                       : ring.themeState.orbitalTickColor
                opacity: parent.isCurrent ? 1.0 : 0.6
            }

            Text {
                visible: parent.isMajor || parent.isCurrent

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.bottom
                anchors.topMargin: 6 * ring.s

                text: parent.isMajor || parent.isCurrent ? index : ""
                font.family: ring.themeState.fontFamily
                font.pixelSize: 14 * ring.s
                font.weight: Font.DemiBold
                font.bold: parent.isCurrent
                color: parent.isCurrent
                        ? ring.themeState.mainTextColor
                        : ring.themeState.orbitalTextColor
            }

            transform: Rotation {
                angle: index * 6 - 90
                origin.x: 0
                origin.y: 0
            }

            transformOrigin: Item.TopLeft
        }
    }
}
