import QtQuick
import Qt5Compat.GraphicalEffects
import "../.."

Item {
    id: hudAction

    required property real s
    required property ThemeState themeState

    property string iconSource: ""
    property color idleColor: hudAction.themeState.dimTextColor
    property color hoverColor: hudAction.themeState.mainTextColor
    property bool active: hudMa.containsMouse

    signal clicked()

    width: 24 * hudAction.s
    height: 24 * hudAction.s
    scale: hudAction.active ? 1.12 : 1.0
    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

    Image {
        id: icon
        anchors.centerIn: parent
        width: 17 * hudAction.s
        height: 17 * hudAction.s
        source: hudAction.iconSource
        sourceSize.width: 34 * hudAction.s
        sourceSize.height: 34 * hudAction.s
        smooth: true
    }

    ColorOverlay {
        anchors.fill: icon
        source: icon
        color: hudAction.active ? hudAction.hoverColor : hudAction.idleColor
        Behavior on color { ColorAnimation { duration: 150 } }
    }

    MouseArea {
        id: hudMa
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: hudAction.clicked()
    }
}