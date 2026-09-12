import QtQuick
import "../.."

Item {
    id: st

    required property string text
    required property real s
    required property ThemeState themeState

    property real stPixelSize: 13 * s
    property real stLetterSpacing: 0
    property color stColor
    property int stWeight: Font.Normal
    property bool staggerActive: false
    property real progress: 0

    readonly property real charW: stPixelSize * 0.72
    readonly property int stDuration: 320 + text.length * 28

    width: charW * text.length + stLetterSpacing * Math.max(0, text.length - 1)
    height: stPixelSize

    onStaggerActiveChanged: {
        if (st.staggerActive) {
            st.progress = 0
            staggerMaster.duration = st.stDuration
            staggerMaster.restart()
        }
    }

    NumberAnimation {
        id: staggerMaster
        target: st
        property: "progress"
        to: 1
    }

    function easedFor(i) {
        if (!st.staggerActive) return 0
        var N = Math.max(1, text.length)
        var t = progress * (N + 1)
        var raw = t - i
        if (raw <= 0) return 0
        if (raw >= 1) return 1
        var c1 = 1.70158, c3 = c1 + 1
        return 1 + c3 * Math.pow(raw - 1, 3) + c1 * Math.pow(raw - 1, 2)
    }

    Row {
        spacing: st.stLetterSpacing
        Repeater {
            model: st.text.length
            delegate: Item {
                width: st.charW
                height: st.stPixelSize
                property real e: st.easedFor(index)
                opacity: e
                scale: 1 - (1 - e) * 0.08
                transform: Translate { y: (1 - e) * st.stPixelSize * 0.8 }

                Text {
                    anchors.centerIn: parent
                    text: st.text.charAt(index)
                    color: st.stColor
                    font.family: st.themeState.fontFamily
                    font.pixelSize: st.stPixelSize
                    font.weight: st.stWeight
                }
            }
        }
    }
}