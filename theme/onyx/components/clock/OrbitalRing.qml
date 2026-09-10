import QtQuick
import "../.."

// Reusable ring reproducing the original Ryoku orbital behaviour.
// Index 0 sits at 12 o'clock; angle = index*6 - 90 (deg, clockwise).
// Spotlight = smooth falloff around currentIndex (pow(1-|rel|/5.5, 1.6));
// numbers rotate radially; optional smooth hand (single Rectangle) at smoothAngle.
Item {
    id: ring

    required property real s
    required property ThemeState themeState
    required property int currentIndex

    property int tickCount: 60
    property real radiusS: 400
    property real smoothAngle: -1

    property real numberRadiusOffset: 30
    property bool  showNumbers: true
    property bool  rotateNumbers: true

    property real tickMajorW: 2
    property real tickMajorLen: 18
    property real tickMinorW: 1
    property real tickMinorLen: 10
    property real numMajorSize: 26
    property real numMinorSize: 15
    property real spotlightPeakSize: 58

    property bool weightBlackSoft: true
    property bool majorBoldAlways: true
    property bool scaleBehavior: true

    property bool  pillWindowHiding: false
    property real  pillWinX: 0
    property real  pillWinY: 0
    property real  pillWinW: 0
    property real  pillWinH: 0

    readonly property real radius: radiusS * s
    readonly property real numberRadius: (radiusS + numberRadiusOffset) * s

    width: 2 * radiusS * s
    height: 2 * radiusS * s

    Repeater {
        model: ring.tickCount

        Item {
            id: tick

            readonly property real angleDeg: index * 6 - 90
            readonly property real angleRad: angleDeg * Math.PI / 180
            readonly property bool isMajor: index % 5 === 0

            readonly property real relAngle: {
                var a = Math.abs(index * 6 - ring.currentIndex * 6)
                a = ((a + 180) % 360) - 180
                return a
            }
            readonly property real spotlight: Math.max(0, Math.pow(1.0 - Math.abs(relAngle) / 5.5, 1.6))

            readonly property real tickW: (isMajor ? ring.tickMajorW : ring.tickMinorW) * ring.s
            readonly property real tickLen: (isMajor ? ring.tickMajorLen : ring.tickMinorLen) * ring.s

            readonly property real nx: ring.width / 2 + ring.numberRadius * Math.cos(angleRad)
            readonly property real ny: ring.height / 2 + ring.numberRadius * Math.sin(angleRad)
            readonly property bool inPillWindow: ring.pillWindowHiding &&
                nx >= ring.pillWinX && nx <= ring.pillWinX + ring.pillWinW &&
                ny >= ring.pillWinY && ny <= ring.pillWinY + ring.pillWinH
            readonly property bool showNumber: !inPillWindow && (isMajor || spotlight > 0)

            // Tick rectangle — centered on the radius circle, pointing inward.
            Rectangle {
                id: tickRect
                x: ring.width / 2 + ring.radius * Math.cos(angleRad) - width / 2
                y: ring.height / 2 + ring.radius * Math.sin(angleRad) - height / 2
                width: tick.tickW
                height: tick.tickLen
                radius: 1 * ring.s
                color: tick.spotlight > 0 ? ring.themeState.mainTextColor
                                          : ring.themeState.orbitalTickColor
                opacity: tick.spotlight > 0 ? 1.0 : (tick.isMajor ? 0.40 : 0.22)
                rotation: tick.angleDeg + 90
                antialiasing: true
            }

            Text {
                visible: tick.showNumber
                x: tick.nx - width / 2
                y: tick.ny - height / 2

                text: (index < 10 ? "0" : "") + index
                font.family: ring.themeState.fontFamily
                font.pixelSize: (tick.spotlight > 0.70 && ring.spotlightPeakSize > 0)
                                ? ring.spotlightPeakSize * ring.s
                                : (tick.isMajor ? ring.numMajorSize : ring.numMinorSize) * ring.s
                font.weight: {
                    if (ring.weightBlackSoft && tick.spotlight > 0.50) return Font.Black
                    if (tick.isMajor && ring.majorBoldAlways) return Font.Bold
                    if (tick.spotlight > 0.50) return Font.Bold
                    return Font.Normal
                }
                scale: ring.scaleBehavior && tick.spotlight > 0.60 ? 1.15 : 1.0
                Behavior on scale {
                    enabled: ring.scaleBehavior
                    NumberAnimation { duration: 280; easing.type: Easing.OutCubic }
                }
                rotation: ring.rotateNumbers ? tick.angleDeg : 0
                transformOrigin: Item.Center
                color: tick.spotlight > 0 ? ring.themeState.mainTextColor
                                          : ring.themeState.orbitalTextColor
                opacity: tick.spotlight > 0 ? (0.4 + tick.spotlight * 0.6) : 0.25
            }
        }
    }

    // Smooth hand — OUTSIDE the Repeater, single instance.
    Rectangle {
        id: smoothHand
        visible: ring.smoothAngle >= 0

        x: ring.width / 2 - width / 2
        y: ring.height / 2 - height

        width: 3 * ring.s
        height: ring.radiusS * ring.s * 0.75
        radius: 1.5 * ring.s
        color: ring.themeState.mainTextColor
        opacity: 1.0
        transformOrigin: Item.Bottom
        rotation: ring.smoothAngle
        antialiasing: true
    }
}
