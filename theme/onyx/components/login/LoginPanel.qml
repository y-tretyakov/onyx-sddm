import QtQuick
import QtQuick.Window
import "../.."

Item {
    id: panel

    required property real s
    required property ThemeState themeState

    width: 350 * s
    height: 100 * s

    readonly property bool canLogin: !themeState.isPreview && textField.text.length > 0

    function _submit() {
        if (themeState.isPreview)
            return
        var idx = (typeof userModel !== "undefined" && userModel.lastIndex >= 0)
                  ? userModel.lastIndex
                  : 0
        var user = (typeof userModel !== "undefined")
                   ? userModel.data(idx, "name")
                   : "user"
        var session = (typeof sessionModel !== "undefined")
                      ? sessionModel.lastIndex
                      : 0
        sddm.login(user, textField.text, session)
    }

    Text {
        id: userLabel

        anchors.right: parent.right
        anchors.top: parent.top

        text: {
            if (panel.themeState.isPreview)
                return "preview"
            if (typeof userModel !== "undefined" && userModel.lastIndex >= 0)
                return userModel.data(userModel.lastIndex, "name")
            return "user"
        }
        font.family: panel.themeState.fontFamily
        font.pixelSize: 18 * panel.s
        font.weight: Font.Bold
        font.letterSpacing: 8 * panel.s
        color: panel.themeState.dimTextColor
    }

    TextInput {
        id: textField

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: userLabel.bottom
        anchors.topMargin: 8 * panel.s

        text: ""
        font.family: panel.themeState.fontFamily
        font.pixelSize: 14 * panel.s
        font.letterSpacing: 10 * panel.s
        font.weight: Font.Normal
        color: panel.themeState.mainTextColor
        echoMode: TextInput.Password
        clip: true
        horizontalAlignment: TextInput.AlignRight

        selectByMouse: true
        focus: true

        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                panel._submit();
                event.accepted = true;
            }
        }
    }

    // Fallback: submit even if focus is not on the TextInput.
    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            panel._submit();
            event.accepted = true;
        }
    }

    Rectangle {
        id: underline

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: textField.bottom
        anchors.topMargin: 6 * panel.s

        width: parent.width
        height: 1 * panel.s
        color: panel.themeState.pillDividerColor
    }

    // Original Ryoku re-claims focus via a 300ms startup timer + window active grab.
    Timer {
        id: focusTimer
        interval: 300
        running: true
        onTriggered: textField.forceActiveFocus()
    }

    Connections {
        target: typeof Window !== "undefined" ? Window.window : null
        function onActiveChanged() {
            if (Window.window && Window.window.active)
                textField.forceActiveFocus()
        }
    }
}
