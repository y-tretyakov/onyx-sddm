import QtQuick

Rectangle {
    id: root
    width: Screen.width
    height: Screen.height
    color: state.bgColor

    readonly property real s: Screen.height / 768

    ThemeState {
        id: state
        s: root.s
    }
}
