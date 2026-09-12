import QtQuick
import "../.."

Item {
    id: picker

    required property real s
    required property ThemeState themeState

    property bool open: false
    property int _selectedIndex: (typeof userModel !== "undefined" && userModel.lastIndex !== undefined) ? userModel.lastIndex : 0

    readonly property int selectedIndex: picker._selectedIndex

    property string _selectedName: ""
    property string _selectedLogin: ""

    readonly property string currentName: {
        if (picker._selectedName !== "")
            return picker._selectedName
        if (typeof userModel !== "undefined" && userModel.lastUser)
            return userModel.lastUser
        return themeState.isPreview ? "preview" : "user"
    }

    readonly property string currentLogin: {
        if (picker._selectedLogin !== "")
            return picker._selectedLogin
        if (typeof userModel !== "undefined" && userModel.lastUser)
            return userModel.lastUser
        return ""
    }

    function holdRoles(inName, inLogin) {
        picker._selectedName = inName
        picker._selectedLogin = inLogin
    }

    signal selected(var index, var login, var name)

    width: parent.width
    height: 32 * s

    ListView {
        id: userHelper
        width: 1
        height: 1
        opacity: 0
        currentIndex: picker.selectedIndex
        model: typeof userModel !== "undefined" ? userModel : null
        delegate: Item {
            required property var model
            required property int index
            readonly property string uName: model.realName || model.name || ""
            readonly property string uLogin: model.name || ""
            readonly property bool active: picker.selectedIndex === index
            onActiveChanged: if (active) picker.holdRoles(uName, uLogin)
        }
    }

    function select(index) {
        picker._selectedIndex = index
        picker.open = false
        picker.selected(index, picker.currentLogin, picker.currentName)
    }

    Item {
        id: trigger
        anchors.fill: parent
        z: 5000

        Text {
            id: userNameLabel
            anchors.right: parent.right
            anchors.rightMargin: (triggerMa.containsMouse || picker.open) ? 25 * picker.s : 0
            anchors.verticalCenter: parent.verticalCenter
            text: picker.currentName.toUpperCase()
            font.family: picker.themeState.fontFamily
            font.pixelSize: 18 * picker.s
            font.weight: Font.Bold
            font.letterSpacing: 8 * picker.s
            color: (triggerMa.containsMouse || picker.open) ? picker.themeState.mainTextColor
                                                            : picker.themeState.dimTextColor
            Behavior on color { ColorAnimation { duration: 200 } }
            Behavior on anchors.rightMargin { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
        }

        Text {
            anchors.left: userNameLabel.right
            anchors.leftMargin: 8 * picker.s
            anchors.verticalCenter: userNameLabel.verticalCenter
            text: "\u2726"
            color: picker.themeState.mainTextColor
            opacity: (triggerMa.containsMouse || picker.open) ? 1 : 0
            font.family: picker.themeState.fontFamily
            font.pixelSize: 12 * picker.s
            Behavior on opacity { NumberAnimation { duration: 200 } }
        }

        MouseArea {
            id: triggerMa
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: picker.open = !picker.open
        }
    }

    Item {
        id: menuContainer
        visible: picker.open
        width: 280 * picker.s
        z: 5100
        clip: true
        anchors.right: trigger.right
        anchors.bottom: trigger.top
        anchors.bottomMargin: 15 * picker.s

        readonly property int itemCount: (typeof userModel !== "undefined" && userModel) ? userModel.rowCount() : 0
        height: menuContainer.itemCount > 0 ? (menuContainer.itemCount * 26 * picker.s + (menuContainer.itemCount - 1) * 6 * picker.s + 20 * picker.s) : 0
        Behavior on height { NumberAnimation { duration: 400; easing.type: Easing.OutExpo } }

        Column {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            spacing: 6 * picker.s

            Repeater {
                model: typeof userModel !== "undefined" ? userModel : null
                delegate: Item {
                    id: item
                    width: 260 * picker.s
                    height: 26 * picker.s
                    property bool itemHover: itemMa.containsMouse
                    property bool itemActive: picker.selectedIndex === index

                    Text {
                        id: itemLabel
                        anchors.right: parent.right
                        anchors.rightMargin: item.itemHover ? 30 * picker.s : 10 * picker.s
                        anchors.verticalCenter: parent.verticalCenter
                        text: (model.realName || model.name || "").toUpperCase()
                        font.family: picker.themeState.fontFamily
                        font.pixelSize: 13 * picker.s
                        font.letterSpacing: 2 * picker.s
                        color: (item.itemActive || item.itemHover) ? picker.themeState.mainTextColor
                                                                   : picker.themeState.userItemInactiveColor
                        Behavior on color { ColorAnimation { duration: 200 } }
                        Behavior on anchors.rightMargin { NumberAnimation { duration: 200 } }
                    }

                    Text {
                        anchors.left: itemLabel.right
                        anchors.leftMargin: 8 * picker.s
                        anchors.verticalCenter: itemLabel.verticalCenter
                        text: "\u2726"
                        color: picker.themeState.mainTextColor
                        opacity: (item.itemActive || item.itemHover) ? 1 : 0
                        font.family: picker.themeState.fontFamily
                        font.pixelSize: 10 * picker.s
                        Behavior on opacity { NumberAnimation { duration: 200 } }
                    }

                    MouseArea {
                        id: itemMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: picker.select(index)
                    }
                }
            }
        }
    }
}