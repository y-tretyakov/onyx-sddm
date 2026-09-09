import QtQuick
import "../.."

// Reusable ring: `tickCount` radial ticks placed on a circle of radius R = width / 2.
// Index 0 sits at 12 o'clock; angle = index * 6 - 90 (degrees, clockwise).
// Major ticks (index % 5 === 0) carry a two-digit number; the tick at `currentIndex`
// gets the spotlight (larger font, full opacity). Numbers stay horizontal (no radial
// rotation) — ADR for MVP readability.
// optional smoothPosition in [0,60) renders a smooth hand marker at angle smoothPosition*6; spotlight stays on currentIndex
Item {
    id: ring

    required property real s
    required property ThemeState themeState
    required property int currentIndex

    property real radiusS: 320
    property real smoothPosition: -1

    property int tickCount: 60
    property real majorFontSize: 13
    property real spotlightFontSize: 18
    property real majorTickLen: 20
    property real minorTickLen: 12
    property real spotlightTickLen: 26
    property real tickOpacity: 0.6
    property real numberOpacity: 0.6
    property real numberOffset: 18

    readonly property real radius: radiusS * s

    width: 2 * radiusS * s
    height: 2 * radiusS * s

    Repeater {
        model: ring.tickCount

        Item {
            id: tick

            readonly property real angleDeg: index * 6 - 90
            readonly property real angleRad: angleDeg * Math.PI / 180
            readonly property bool isMajor: index % 5 === 0
            readonly property bool isCurrent: index === ring.currentIndex
            readonly property real tickLen: (isCurrent ? ring.spotlightTickLen
                                              : (isMajor ? ring.majorTickLen : ring.minorTickLen)) * ring.s

            x: ring.width / 2 + ring.radius * Math.cos(angleRad) - width / 2
            y: ring.height / 2 + ring.radius * Math.sin(angleRad) - height / 2
            width: 0
            height: 0

            Rectangle {
                anchors.centerIn: parent

                width: (isCurrent ? 3 : (isMajor ? 2 : 1)) * ring.s
                height: tick.tickLen
                radius: (isCurrent ? 1.5 : 1) * ring.s
                color: tick.isCurrent ? ring.themeState.mainTextColor
                                      : ring.themeState.orbitalTickColor
                opacity: tick.isCurrent ? 1.0 : ring.tickOpacity
                rotation: tick.angleDeg + 90
                antialiasing: true
            }

            Rectangle {
                visible: ring.smoothPosition >= 0

                anchors.centerIn: parent

                width: 3 * ring.s
                height: 26 * ring.s
                radius: 1.5 * ring.s
                color: ring.themeState.mainTextColor
                opacity: 1.0
                rotation: ring.smoothPosition * 6
                antialiasing: true
            }

            Text {
                visible: tick.isMajor || tick.isCurrent

                x: Math.cos(tick.angleRad) * ring.numberOffset * ring.s - width / 2
                y: Math.sin(tick.angleRad) * ring.numberOffset * ring.s - height / 2

                text: (index < 10 ? "0" : "") + index
                font.family: ring.themeState.fontFamily
                font.pixelSize: (tick.isCurrent ? ring.spotlightFontSize
                                                : ring.majorFontSize) * ring.s
                font.weight: tick.isCurrent ? Font.Bold : Font.DemiBold
                color: tick.isCurrent ? ring.themeState.mainTextColor
                                      : ring.themeState.orbitalTextColor
                opacity: tick.isCurrent ? 1.0 : ring.numberOpacity
            }
        }
    }
}
