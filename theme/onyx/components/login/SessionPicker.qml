import QtQuick
import "../.."

Item {
    id: picker

    required property real s
    required property ThemeState themeState

    property bool open: false
    property int _selectedIndex: (typeof sessionModel !== "undefined" && sessionModel.lastIndex !== undefined) ? sessionModel.lastIndex : 0

    readonly property int selectedIndex: picker._selectedIndex

    readonly property string currentName: {
        if (sessionHelper.currentItem && sessionHelper.currentItem.sName)
            return sessionHelper.currentItem.sName
        return "SESSION"
    }

    signal selected(var index)

    width: sLabel.implicitWidth + 30 * picker.s
    height: 15 * picker.s

    ListView {
        id: sessionHelper
        width: 1
        height: 1
        opacity: 0
        currentIndex: picker.selectedIndex
        model: typeof sessionModel !== "undefined" ? sessionModel : null
        delegate: Item {
            property string sName: model.name || ""
        }
    }

    function select(index) {
        picker._selectedIndex = index
        picker.open = false
        picker.selected(index)
    }

    Item {
        id: trigger
        anchors.fill: parent
        z: 100
        property bool active: triggerMa.containsMouse || picker.open

        Text {
            id: sLabel
            anchors.right: parent.right
            anchors.rightMargin: trigger.active ? 15 * picker.s : 0
            anchors.verticalCenter: parent.verticalCenter
            text: picker.currentName.toUpperCase()
            font.family: picker.themeState.fontFamily
            font.pixelSize: 10 * picker.s
            font.letterSpacing: 3 * picker.s
            color: trigger.active ? picker.themeState.mainTextColor : picker.themeState.dimTextColor
            Behavior on color { ColorAnimation { duration: 200 } }
            Behavior on anchors.rightMargin { NumberAnimation { duration: 200 } }
        }

        Text {
            anchors.left: sLabel.right
            anchors.leftMargin: 4 * picker.s
            anchors.verticalCenter: sLabel.verticalCenter
            text: "\u2726"
            color: picker.themeState.mainTextColor
            opacity: trigger.active ? 1 : 0
            font.family: picker.themeState.fontFamily
            font.pixelSize: 8 * picker.s
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
        width: 300 * picker.s
        z: 900
        clip: true
        x: picker.width - width
        y: picker.height + 8 * picker.s

        readonly property int itemCount: (typeof sessionModel !== "undefined" && sessionModel) ? sessionModel.rowCount() : 0
        height: menuContainer.itemCount > 0 ? (menuContainer.itemCount * 26 * picker.s + (menuContainer.itemCount - 1) * 6 * picker.s + 20 * picker.s) : 0
        Behavior on height { NumberAnimation { duration: 350; easing.type: Easing.OutExpo } }

        Column {
            anchors.right: parent.right
            anchors.top: parent.top
            spacing: 6 * picker.s

            Repeater {
                model: typeof sessionModel !== "undefined" ? sessionModel : null
                delegate: Item {
                    id: item
                    width: 300 * picker.s
                    height: 26 * picker.s
                    property bool itemHover: itemMa.containsMouse
                    property bool itemActive: picker.selectedIndex === index

                    Text {
                        id: itemLabel
                        anchors.right: parent.right
                        anchors.rightMargin: item.itemHover ? 30 * picker.s : 10 * picker.s
                        anchors.verticalCenter: parent.verticalCenter
                        text: (model.name || "").toUpperCase()
                        font.family: picker.themeState.fontFamily
                        font.pixelSize: 12 * picker.s
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