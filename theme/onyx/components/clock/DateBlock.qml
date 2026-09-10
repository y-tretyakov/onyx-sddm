import QtQuick
import Qt5Compat.GraphicalEffects
import "../.."
import "../effects" as Effects

Item {
    id: dateBlock

    required property real s
    required property ThemeState themeState

    property bool dateAnimActive: false
    property bool weekdayAnimActive: false
    property real dateBlurR: 0

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

    Timer {
        id: weekdayDelayTimer
        interval: 420
        onTriggered: dateBlock.weekdayAnimActive = true
    }

    NumberAnimation {
        id: dateBlurAnim
        target: dateBlock
        property: "dateBlurR"
        from: 7
        to: 0
        duration: 800
    }

    function startReveal() {
        dateBlurR = 7
        dateAnimActive = true
        dateBlurAnim.restart()
        weekdayDelayTimer.restart()
    }

    Column {
        spacing: 5 * s
        Item {
            width: dW.width
            height: dW.height
            layer.enabled: dateBlock.dateBlurR > 0.01
            layer.effect: GaussianBlur {
                radius: dateBlock.dateBlurR
                samples: 16
            }
            Effects.StaggerText {
                id: dW
                text: dateBlock.dateStr.toUpperCase()
                s: dateBlock.s
                themeState: dateBlock.themeState
                stPixelSize: 13 * dateBlock.s
                stLetterSpacing: 4 * dateBlock.s
                stColor: dateBlock.themeState.subTextColor
                staggerActive: dateBlock.dateAnimActive
            }
        }
        Item {
            width: wW.width
            height: wW.height
            layer.enabled: dateBlock.dateBlurR > 0.01
            layer.effect: GaussianBlur {
                radius: dateBlock.dateBlurR
                samples: 16
            }
            Effects.StaggerText {
                id: wW
                text: dateBlock.weekdayStr.toUpperCase()
                s: dateBlock.s
                themeState: dateBlock.themeState
                stPixelSize: 18 * dateBlock.s
                stLetterSpacing: 8 * dateBlock.s
                stColor: dateBlock.themeState.mainTextColor
                stWeight: Font.Bold
                staggerActive: dateBlock.weekdayAnimActive
            }
        }
    }
}