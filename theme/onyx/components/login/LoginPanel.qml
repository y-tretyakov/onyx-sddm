import QtQuick
import "../.."

Item {
    id: panel

    required property real s
    required property ThemeState themeState

    width: 330 * s
    height: 90 * s

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

        anchors.left: parent.left
        anchors.top: parent.top

        text: {
            if (panel.themeState.isPreview)
                return "preview"
            if (typeof userModel !== "undefined" && userModel.lastIndex >= 0)
                return userModel.data(userModel.lastIndex, "name")
            return "user"
        }
        font.family: panel.themeState.fontFamily
        font.pixelSize: 14 * panel.s
        font.weight: Font.DemiBold
        color: panel.themeState.pillMinutesColor
    }

    TextInput {
        id: textField

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: userLabel.bottom
        anchors.topMargin: 8 * panel.s

        text: ""
        font.family: panel.themeState.fontFamily
        font.pixelSize: 22 * panel.s
        font.weight: Font.DemiBold
        color: panel.themeState.mainTextColor
        echoMode: TextInput.Password
        clip: true

        placeholderText: "Password"
        placeholderTextColor: panel.themeState.pillSecondsColor

        selectByMouse: true
        focus: true

        Keys.onReturnPressed: panel._submit()
        Keys.onEnterPressed: panel._submit()
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

    Component.onCompleted: textField.forceActiveFocus()
}
