import QtQuick
import QtQuick.Window
import "../.."

Item {
    id: panel

    required property real s
    required property ThemeState themeState

    width: 350 * s
    height: 100 * s

    // Hidden helper matching the original: usernames come from ListView
    // delegate roles (model.realName / model.name), never the old data() call.
    ListView {
        id: userHelper
        width: 1
        height: 1
        opacity: 0
        currentIndex: {
            if (typeof userModel !== "undefined" && userModel.lastIndex >= 0)
                return userModel.lastIndex
            return 0
        }
        model: typeof userModel !== "undefined" ? userModel : null
        delegate: Item {
            property string uName: model.realName || model.name || ""
            property string uLogin: model.name || ""
        }
    }

    readonly property string currentUserName: {
        if (themeState.isPreview)
            return "preview"
        var h = userHelper.currentItem
        if (h && h.uName)
            return h.uName
        if (typeof userModel !== "undefined" && userModel.lastUser)
            return userModel.lastUser
        return "user"
    }

    readonly property string currentLoginName: {
        var h = userHelper.currentItem
        if (h && h.uLogin)
            return h.uLogin
        if (typeof userModel !== "undefined" && userModel.lastUser)
            return userModel.lastUser
        return ""
    }

    function _submit() {
        if (themeState.isPreview)
            return
        // PAM never answers an empty key (original guard).
        if (textField.text.length === 0) {
            textField.forceActiveFocus()
            return
        }
        var user = currentLoginName
        var session = (typeof sessionModel !== "undefined") ? sessionModel.lastIndex : 0
        if (user !== "" && typeof sddm !== "undefined")
            sddm.login(user, textField.text, session)
    }

    Text {
        id: userLabel

        anchors.right: parent.right
        anchors.top: parent.top

        text: panel.currentUserName.toUpperCase()
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
                event.accepted = true
                panel._submit()
            }
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

    // Re-claim focus after grab, mirroring the original.
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
