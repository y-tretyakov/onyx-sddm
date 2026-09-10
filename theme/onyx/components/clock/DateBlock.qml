import QtQuick
import "../.."

Item {
    id: dateBlock

    required property real s
    required property ThemeState themeState

    property var _months: ["January","February","March","April","May","June",
                           "July","August","September","October","November","December"]
    property var _weekdays: ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]

    readonly property string dateStr: {
        var d = new Date()
        return Qt.formatDate(d, "dd") + " " + _months[d.getMonth()] + " " + d.getFullYear()
    }
    readonly property string weekdayStr: _weekdays[new Date().getDay()]

    width: Math.max(dW.implicitWidth, wW.implicitWidth)
    height: dW.height + wW.height + 5 * s

    Column {
        spacing: 5 * s

        Text {
            id: dW
            text: dateBlock.dateStr.toUpperCase()
            font.family: dateBlock.themeState.fontFamily
            font.pixelSize: 13 * dateBlock.s
            font.letterSpacing: 4 * dateBlock.s
            color: dateBlock.themeState.subTextColor
        }

        Text {
            id: wW
            text: dateBlock.weekdayStr.toUpperCase()
            font.family: dateBlock.themeState.fontFamily
            font.pixelSize: 18 * dateBlock.s
            font.letterSpacing: 8 * dateBlock.s
            font.weight: Font.Bold
            color: dateBlock.themeState.mainTextColor
        }
    }
}