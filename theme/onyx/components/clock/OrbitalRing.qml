import QtQuick
import "../.."

// Reusable ring reproducing the original Ryoku orbital behaviour.
// positionDeg is a continuous angle offset (e.g. -360..0). Tick i sits at
// (i*6 + positionDeg); a decreasing positionDeg rotates the whole ring
// counter-clockwise. The spotlight anchors at angle 0: the tick crossing
// it is the current second/minute value (mirrors original Main.qml:452-520).
Item {
    id: ring

    required property real s
    required property ThemeState themeState
    required property real positionDeg

    property int tickCount: 60
    property real radiusS: 400

    property real tickFlash: 0

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

            readonly property real deg: index * 6 + ring.positionDeg
            readonly property real disp: deg * Math.PI / 180
            readonly property real relDeg: {
                var a = (deg % 360)
                if (a > 180) a -= 360
                if (a < -180) a += 360
                return Math.abs(a)
            }
            readonly property real spotlight: Math.max(0, Math.pow(1.0 - relDeg / 5.5, 1.6))
            readonly property bool isMajor: index % 5 === 0

            readonly property real tickW: (isMajor ? ring.tickMajorW : ring.tickMinorW) * ring.s
            readonly property real tickLen: (isMajor ? ring.tickMajorLen : ring.tickMinorLen) * ring.s

            readonly property real nx: ring.width / 2 + ring.numberRadius * Math.cos(disp)
            readonly property real ny: ring.height / 2 + ring.numberRadius * Math.sin(disp)
            readonly property bool inPillWindow: ring.pillWindowHiding &&
                nx >= ring.pillWinX && nx <= ring.pillWinX + ring.pillWinW &&
                ny >= ring.pillWinY && ny <= ring.pillWinY + ring.pillWinH
            readonly property bool showNumber: !inPillWindow && (isMajor || spotlight > 0)

            Rectangle {
                x: ring.width / 2 + ring.radius * Math.cos(tick.disp) - width / 2
                y: ring.height / 2 + ring.radius * Math.sin(tick.disp) - height / 2
                width: tick.tickW
                height: tick.tickLen
                radius: 1 * ring.s
                color: tick.spotlight > 0 ? ring.themeState.mainTextColor
                                          : ring.themeState.orbitalTickColor
                opacity: tick.spotlight > 0 ? 1.0
                                            : Math.min(1.0, (tick.isMajor ? 0.40 : 0.22) + (tick.isMajor ? ring.tickFlash * 0.55 : 0))
                scale: tick.isMajor ? 1.0 + ring.tickFlash * 0.04 : 1.0
                rotation: tick.disp * 180 / Math.PI + 90
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
                rotation: ring.rotateNumbers ? tick.disp * 180 / Math.PI : 0
                transformOrigin: Item.Center
                color: tick.spotlight > 0 ? ring.themeState.mainTextColor
                                          : ring.themeState.orbitalTextColor
                opacity: tick.spotlight > 0 ? (0.4 + tick.spotlight * 0.6) : 0.25
            }
        }
    }
}
