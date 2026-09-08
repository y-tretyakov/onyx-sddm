import QtQuick

Item {
    id: clock

    required property real s
    property alias timeProvider: _time

    width: row.width
    height: row.height

    TimeProvider { id: _time }

    Row {
        id: row

        anchors.centerIn: parent
        spacing: 24 * clock.s

        Text {
            id: hourText

            anchors.verticalCenter: parent.verticalCenter

            text: _time.curH
            font.family: "Sans Serif"
            font.pixelSize: 110 * clock.s
            font.weight: Font.Black
            color: "#FFFFFF"
        }

        IndicatorPill {
            id: pillItem

            s: clock.s
            curM: _time.curM
            curS: _time.curS
        }
    }
}
