import QtQuick

QtObject {
    id: themeState

    property real s: 1

    readonly property bool isPreview: typeof sddm === "undefined" || sddm.hostName === undefined

    readonly property color bgColor: {
        if (!isPreview && typeof config !== "undefined" && config.bgColor)
            return config.bgColor
        return "#000000"
    }
}
