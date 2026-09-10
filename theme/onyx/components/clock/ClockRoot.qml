import QtQuick
import "../.."

Item {
    id: clockRoot

    required property real s
    required property ThemeState themeState

    property alias timeProvider: _time

    readonly property real cx: 40 * s
    readonly property real cy: height * 0.5
    readonly property real minR: 400 * s
    readonly property real secR: 520 * s
    readonly property real pillPad: 16 * s
    readonly property real pillWinX: cx + 230 * s - pillPad
    readonly property real pillWinY: cy - 45 * s - pillPad
    readonly property real pillWinW: 330 * s + pillPad * 2
    readonly property real pillWinH: 90 * s + pillPad * 2

    width: 800 * s
    height: parent.height

    anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter

    TimeProvider { id: _time }

    OrbitalRing {
        id: ringMin
        z: 10
        x: clockRoot.cx - width / 2
        y: clockRoot.cy - height / 2

        s: clockRoot.s
        themeState: clockRoot.themeState
        currentIndex: _time.curMinute

        radiusS: 400
        numberRadiusOffset: 30
        spotlightPeakSize: 58
        scaleBehavior: true
        pillWindowHiding: true
        pillWinX: 0
        pillWinY: 0
        pillWinW: 0
        pillWinH: 0
    }

    OrbitalRing {
        id: ringSec
        z: 10
        x: clockRoot.cx - width / 2
        y: clockRoot.cy - height / 2

        s: clockRoot.s
        themeState: clockRoot.themeState
        currentIndex: _time.curSecond
        smoothAngle: (_time.curSecondFloat / 60.0) * 360.0

        radiusS: 520
        numberRadiusOffset: -30
        numMajorSize: 16
        numMinorSize: 13
        spotlightPeakSize: 0
        tickMajorW: 1.5
        tickMajorLen: 13
        tickMinorW: 1
        tickMinorLen: 8
        weightBlackSoft: false
        majorBoldAlways: false
        scaleBehavior: false
    }

    Text {
        id: hourText
        z: 30
        anchors.right: pill.left
        anchors.rightMargin: 40 * clockRoot.s
        anchors.verticalCenter: parent.verticalCenter

        text: _time.curH
        font.family: clockRoot.themeState.fontFamily
        font.pixelSize: 110 * clockRoot.s
        font.weight: Font.Black
        font.letterSpacing: -2 * clockRoot.s
        color: clockRoot.themeState.mainTextColor
    }

    IndicatorPill {
        id: pill
        z: 1

        x: clockRoot.cx + 230 * clockRoot.s
        anchors.verticalCenter: parent.verticalCenter

        s: clockRoot.s
        themeState: clockRoot.themeState
        curM: _time.curM
        curS: _time.curS
    }

    DateBlock {
        id: dateBlk
        z: 30
        anchors.left: pill.right
        anchors.leftMargin: 110 * clockRoot.s
        anchors.verticalCenter: parent.verticalCenter

        s: clockRoot.s
        themeState: clockRoot.themeState
    }

    Connections {
        target: ringMin
        function onWidthChanged() { applyPillWin() }
        function onHeightChanged() { applyPillWin() }
        Component.onCompleted: applyPillWin()
    }
    function applyPillWin() {
        if (ringMin.width === 0) return
        ringMin.pillWinX = clockRoot.pillWinX - ringMin.x
        ringMin.pillWinY = clockRoot.pillWinY - ringMin.y
        ringMin.pillWinW = clockRoot.pillWinW
        ringMin.pillWinH = clockRoot.pillWinH
    }
}
