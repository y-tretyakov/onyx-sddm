import QtQuick
import QtQuick.Window
import "../.."

Item {
    id: panel

    required property real s
    required property ThemeState themeState

    property var windowWin: typeof Window !== "undefined" ? Window.window : null

    property alias userPicker: pickerInstance
    property int sessionIndex: (typeof sessionModel !== "undefined" && sessionModel.lastIndex !== undefined) ? sessionModel.lastIndex : 0

    width: 350 * s
    height: 100 * s

    // SDDM exposes the last logged-in user as a plain string (userModel.lastUser).
    // Reading it directly is qmllint-hard clean and avoids the SDDM
    // data()-hazard seen on Nobara 44.
    readonly property string currentUserName: {
        if (themeState.isPreview)
            return "preview"
        if (typeof userModel !== "undefined" && userModel.lastUser)
            return userModel.lastUser
        return "user"
    }

    property string currentLoginName: {
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
        if (user === "" && userPicker && userPicker.currentLogin !== "")
            user = userPicker.currentLogin
        if (user === "" && typeof userModel !== "undefined" && userModel.lastUser)
            user = userModel.lastUser
        var session = (typeof panel.sessionIndex !== "undefined") ? panel.sessionIndex : 0
        if (typeof sessionModel !== "undefined" && ((typeof panel.sessionIndex === "undefined") || panel.sessionIndex < 0))
            session = sessionModel.lastIndex
        if (user !== "" && typeof sddm !== "undefined")
            sddm.login(user, textField.text, session)
    }

    UserPicker {
        id: pickerInstance
        s: panel.s
        themeState: panel.themeState
        width: parent.width
        anchors.right: parent.right
        anchors.top: parent.top
        onSelected: function(index, login, name) {
            if (login !== "")
                panel.currentLoginName = login
        }
    }

    TextInput {
        id: textField

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: pickerInstance.bottom
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
        target: windowWin
        function onActiveChanged() {
            if (windowWin && windowWin.active)
                textField.forceActiveFocus()
        }
    }
}
