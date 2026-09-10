import QtQuick
import "../.."

Item {
    id: sparkField

    required property real s
    required property ThemeState themeState
    property real centerX: 0
    property real centerY: 0
    property real sparkIntensity: 0
    property int burstTick: 0

    readonly property real ringRadius: 400 * s

    Repeater {
        model: 60

        Rectangle {
            id: spark

            property real randA: Math.random() * 6.28
            property real randV: 400 * s + Math.random() * 900 * s
            property real life: 1.0

            readonly property real sX: (sparkField.centerX + sparkField.ringRadius)
                                       + Math.cos(randA) * (randV * sparkField.sparkIntensity)
            readonly property real sY: sparkField.centerY
                                       + Math.sin(randA) * (randV * sparkField.sparkIntensity)

            x: sX
            y: sY
            width: (1 + Math.random() * 2) * sparkField.s
            height: (1 + 12 * sparkField.sparkIntensity) * sparkField.s
            rotation: randA * 180 / Math.PI + 90
            radius: width / 2
            color: sparkField.themeState.sparkColor
            opacity: sparkField.sparkIntensity * life * (Math.random() > 0.4 ? 1.0 : 0.2)
            visible: sparkField.sparkIntensity > 0

            NumberAnimation {
                id: sparkFade
                target: spark
                property: "life"
                from: 1.0
                to: 0.0
                duration: 600 + Math.random() * 400
                easing.type: Easing.OutQuad
            }

            Connections {
                target: sparkField
                function onBurstTickChanged() { sparkFade.start() }
            }
        }
    }
}