import QtQuick
import "../.."

Item {
    id: picker

    required property real s
    required property ThemeState themeState

    property var languageOrder: []
    property var languageNames: ({})
    property string currentLang: "en"

    signal selected(var langCode)

    property bool open: false

    width: langLabelTxt.width + 30 * picker.s
    height: 15 * picker.s

    Item {
        id: trigger
        anchors.fill: parent
        z: 100
        property bool active: triggerMa.containsMouse || picker.open

        Text {
            id: langLabelTxt
            anchors.right: parent.right
            anchors.rightMargin: trigger.active ? 15 * picker.s : 0
            anchors.verticalCenter: parent.verticalCenter
            text: (picker.languageNames[picker.currentLang] || picker.currentLang).toUpperCase()
            font.family: picker.themeState.fontFamily
            font.pixelSize: 10 * picker.s
            font.letterSpacing: 3 * picker.s
            color: trigger.active ? picker.themeState.mainTextColor : picker.themeState.dimTextColor
            Behavior on color { ColorAnimation { duration: 200 } }
            Behavior on anchors.rightMargin { NumberAnimation { duration: 200 } }
        }

        Text {
            anchors.left: langLabelTxt.right
            anchors.leftMargin: 4 * picker.s
            anchors.verticalCenter: langLabelTxt.verticalCenter
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
        width: 200 * picker.s
        z: 900
        clip: true
        anchors.right: trigger.right
        anchors.top: trigger.bottom
        anchors.topMargin: 8 * picker.s

        readonly property int itemCount: picker.languageOrder ? picker.languageOrder.length : 0
        height: itemCount > 0 ? (itemCount * 26 * picker.s + (itemCount - 1) * 6 * picker.s + 20 * picker.s) : 0
        Behavior on height { NumberAnimation { duration: 350; easing.type: Easing.OutExpo } }

        Column {
            anchors.right: parent.right
            anchors.top: parent.top
            spacing: 6 * picker.s

            Repeater {
                model: picker.languageOrder
                delegate: Item {
                    id: langItem
                    width: 200 * picker.s
                    height: 26 * picker.s
                    property bool itemHover: langItemMa.containsMouse

                    Text {
                        id: langItemTxt
                        anchors.right: parent.right
                        anchors.rightMargin: langItem.itemHover ? 30 * picker.s : 10 * picker.s
                        anchors.verticalCenter: parent.verticalCenter
                        text: (picker.languageNames[modelData] || modelData).toUpperCase()
                        font.family: picker.themeState.fontFamily
                        font.pixelSize: 12 * picker.s
                        font.letterSpacing: 2 * picker.s
                        color: (picker.currentLang === modelData || langItem.itemHover) ? picker.themeState.mainTextColor
                                                                                     : picker.themeState.userItemInactiveColor
                        Behavior on color { ColorAnimation { duration: 200 } }
                        Behavior on anchors.rightMargin { NumberAnimation { duration: 200 } }
                    }

                    Text {
                        anchors.left: langItemTxt.right
                        anchors.leftMargin: 8 * picker.s
                        anchors.verticalCenter: langItemTxt.verticalCenter
                        text: "\u2726"
                        color: picker.themeState.mainTextColor
                        opacity: (picker.currentLang === modelData || langItem.itemHover) ? 1 : 0
                        font.family: picker.themeState.fontFamily
                        font.pixelSize: 10 * picker.s
                        Behavior on opacity { NumberAnimation { duration: 200 } }
                    }

                    MouseArea {
                        id: langItemMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            picker.selected(modelData)
                            picker.open = false
                        }
                    }
                }
            }
        }
    }
}
