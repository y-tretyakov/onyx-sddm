import QtQuick
import "../.."

Item {
    id: clock

    required property real s
    required property ThemeState themeState
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
            font.family: clock.themeState.fontFamily
            font.pixelSize: 110 * clock.s
            font.weight: Font.Black
            color: clock.themeState.mainTextColor
        }

        IndicatorPill {
            id: pillItem

            s: clock.s
            themeState: clock.themeState
            curM: _time.curM
            curS: _time.curS
        }
    }
}
