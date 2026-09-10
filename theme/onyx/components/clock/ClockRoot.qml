import QtQuick
import "../.."
import "../effects" as Effects

Item {
    id: clockRoot

    required property real s
    required property ThemeState themeState

    property alias timeProvider: _time

    property real windupDegMin: 0
    property real windupDegSec: 0

    property real tickFlash: 0
    property real tickHaloR: 0
    property real tickHaloOpacity: 0

    property bool clockAwake: true

    property real sparkWindup: 0
    property int sparkBurst: 0
    property real sparkImpulse: 0

    property string lastSec: ""
    property string lastMin: ""
    property string lastHour: ""

    property real secBurstScale: 1.0
    property real secBurstOpacity: 0.0
    property string secBurstText: "00"
    property real secBurstX: 0
    property real secBurstY: 0

    property real minBurstScale: 1.0
    property real minBurstOpacity: 0.0
    property string minBurstText: "00"
    property real minBurstX: 0
    property real minBurstY: 0

    property real hourBurstScale: 1.0
    property real hourBurstOpacity: 0.0
    property string hourBurstText: "00"
    property real hourBurstX: 0
    property real hourBurstY: 0

    readonly property real minuteAngleDeg: ringMin.positionDeg
    readonly property real secondAngleDeg: ringSec.positionDeg

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

    NumberAnimation {
        id: tickFlashAnim
        target: clockRoot
        property: "tickFlash"
        from: 1.0
        to: 0.0
        duration: 140
        easing.type: Easing.OutQuad
    }

    SequentialAnimation {
        id: tickHaloAnim
        running: false
        NumberAnimation {
            target: clockRoot
            property: "tickHaloR"
            from: 16 * clockRoot.s
            to: 110 * clockRoot.s
            duration: 480
            easing.type: Easing.OutCubic
        }
    }

    NumberAnimation {
        id: tickHaloOpacityAnim
        target: clockRoot
        property: "tickHaloOpacity"
        from: 0.50
        to: 0.0
        duration: 480
        easing.type: Easing.OutQuad
    }

    SequentialAnimation {
        id: sparkImpulseAnim
        NumberAnimation { target: clockRoot; property: "sparkImpulse"; to: 0.8; duration: 200; easing.type: Easing.OutCubic }
        NumberAnimation { target: clockRoot; property: "sparkImpulse"; to: 0.0; duration: 500; easing.type: Easing.OutCubic }
    }

    ParallelAnimation {
        id: secBurstAnim
        NumberAnimation { target: clockRoot; property: "secBurstScale"; from: 1.0; to: 2.2; duration: 450; easing.type: Easing.OutCubic }
        NumberAnimation { target: clockRoot; property: "secBurstOpacity"; from: 0.9; to: 0.0; duration: 450; easing.type: Easing.OutQuad }
    }

    ParallelAnimation {
        id: minBurstAnim
        NumberAnimation { target: clockRoot; property: "minBurstScale"; from: 1.0; to: 2.2; duration: 450; easing.type: Easing.OutCubic }
        NumberAnimation { target: clockRoot; property: "minBurstOpacity"; from: 0.9; to: 0.0; duration: 450; easing.type: Easing.OutQuad }
    }

    ParallelAnimation {
        id: hourBurstAnim
        NumberAnimation { target: clockRoot; property: "hourBurstScale"; from: 1.0; to: 2.2; duration: 450; easing.type: Easing.OutCubic }
        NumberAnimation { target: clockRoot; property: "hourBurstOpacity"; from: 0.9; to: 0.0; duration: 450; easing.type: Easing.OutQuad }
    }

    onClockAwakeChanged: {
        if (!clockRoot.clockAwake) {
            secBurstAnim.stop(); clockRoot.secBurstOpacity = 0
            minBurstAnim.stop(); clockRoot.minBurstOpacity = 0
            hourBurstAnim.stop(); clockRoot.hourBurstOpacity = 0
            sparkImpulseAnim.stop(); clockRoot.sparkImpulse = 0
        }
    }

    function triggerTickFeedback() {
        if (!themeState.clockAwake)
            return
        tickFlashAnim.restart()
        tickHaloAnim.restart()
        tickHaloOpacityAnim.restart()
    }

    function maybeSecBurst() {
        if (!clockRoot.clockAwake)
            return
        if (_time.curS === lastSec)
            return
        lastSec = _time.curS
        secBurstText = _time.curS
        var p = pill.mapToItem(clockRoot, pill.secCenterX, pill.secCenterY)
        secBurstX = p.x
        secBurstY = p.y
        secBurstAnim.restart()
        sparkBurst++
        sparkImpulseAnim.restart()
    }

    function maybeMinBurst() {
        if (!clockRoot.clockAwake)
            return
        if (_time.curM === lastMin)
            return
        lastMin = _time.curM
        minBurstText = _time.curM
        var p = pill.mapToItem(clockRoot, pill.minCenterX, pill.minCenterY)
        minBurstX = p.x
        minBurstY = p.y
        minBurstAnim.restart()
        sparkBurst++
        sparkImpulseAnim.restart()
    }

    function maybeHourBurst() {
        if (!clockRoot.clockAwake)
            return
        if (_time.curH === lastHour)
            return
        lastHour = _time.curH
        hourBurstText = _time.curH
        var p = hourText.mapToItem(clockRoot, hourText.width / 2, hourText.height / 2)
        hourBurstX = p.x
        hourBurstY = p.y
        hourBurstAnim.restart()
        sparkBurst++
        sparkImpulseAnim.restart()
    }

    Connections {
        target: _time
        function onCurSChanged() { clockRoot.maybeSecBurst() }
        function onCurMChanged() { clockRoot.triggerTickFeedback(); clockRoot.maybeMinBurst() }
        function onCurHChanged() { clockRoot.maybeHourBurst() }
    }

    OrbitalRing {
        id: ringMin
        z: 10
        x: clockRoot.cx - width / 2
        y: clockRoot.cy - height / 2

        s: clockRoot.s
        themeState: clockRoot.themeState
        tickFlash: clockRoot.tickFlash
        // one full rotation per hour, counter-clockwise, minus windup kick
        positionDeg: -(_time.curMinuteFloat / 60.0) * 360.0 - clockRoot.windupDegMin

        radiusS: 400
        numberRadiusOffset: 30
        spotlightPeakSize: 58
        scaleBehavior: true
        pillWindowHiding: true
        pillWinX: clockRoot.pillWinX - (clockRoot.cx - width / 2)
        pillWinY: clockRoot.pillWinY - (clockRoot.cy - height / 2)
        pillWinW: clockRoot.pillWinW
        pillWinH: clockRoot.pillWinH
    }

    OrbitalRing {
        id: ringSec
        z: 10
        x: clockRoot.cx - width / 2
        y: clockRoot.cy - height / 2

        s: clockRoot.s
        themeState: clockRoot.themeState
        // one full rotation per minute, smooth (16ms), counter-clockwise minus windup kick
        positionDeg: -(_time.curSecondFloat / 60.0) * 360.0 - clockRoot.windupDegSec

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
        pillWindowHiding: true
    }

    Rectangle {
        z: 5
        visible: clockRoot.tickHaloOpacity > 0.01
        x: clockRoot.cx - clockRoot.tickHaloR
        y: clockRoot.cy - clockRoot.tickHaloR
        width: clockRoot.tickHaloR * 2
        height: clockRoot.tickHaloR * 2
        radius: clockRoot.tickHaloR
        color: "transparent"
        border.color: clockRoot.themeState.mainTextColor
        border.width: 1.5 * clockRoot.s
        opacity: clockRoot.tickHaloOpacity
    }

    Effects.Sparks {
        z: 50
        centerX: clockRoot.cx
        centerY: clockRoot.cy
        sparkIntensity: Math.max(clockRoot.sparkWindup, clockRoot.sparkImpulse)
        burstTick: clockRoot.sparkBurst

        s: clockRoot.s
        themeState: clockRoot.themeState
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

    Effects.Burst {
        text: clockRoot.secBurstText
        s: clockRoot.s
        themeState: clockRoot.themeState
        x: clockRoot.secBurstX
        y: clockRoot.secBurstY
        scale: clockRoot.secBurstScale
        opacity: clockRoot.secBurstOpacity
    }

    Effects.Burst {
        text: clockRoot.minBurstText
        s: clockRoot.s
        themeState: clockRoot.themeState
        x: clockRoot.minBurstX
        y: clockRoot.minBurstY
        scale: clockRoot.minBurstScale
        opacity: clockRoot.minBurstOpacity
    }

    Effects.Burst {
        text: clockRoot.hourBurstText
        s: clockRoot.s
        themeState: clockRoot.themeState
        x: clockRoot.hourBurstX
        y: clockRoot.hourBurstY
        scale: clockRoot.hourBurstScale
        opacity: clockRoot.hourBurstOpacity
    }
}
