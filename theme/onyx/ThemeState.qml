import QtQuick
import QtQuick.Window

QtObject {
    id: themeState

    property real s: 1
    property string fontFamily: "Sans Serif"

    readonly property bool isPreview: typeof sddm === "undefined" || sddm.hostName === undefined

    readonly property bool clockAwake: {
        if (isPreview) return true
        return typeof Window !== "undefined" ? Window.active : true
    }

    readonly property bool windupEnabled: {
        if (typeof config !== "undefined" && config.enableWindup !== undefined)
            return config.enableWindup !== "false" && config.enableWindup !== false
        return true
    }

    readonly property color blastColor: "#FFFFFF"
    readonly property color sparkColor: "#FFFFFF"

    readonly property color bgColor: {
        if (!isPreview && typeof config !== "undefined" && config.bgColor)
            return config.bgColor
        return "#000000"
    }

    readonly property color mainTextColor: "#FFFFFF"
    readonly property color dimTextColor: "#666666"
    readonly property color subTextColor: "#555555"
    readonly property color pillColor: "#080808"
    readonly property color pillBorderColor: "#1a1a1a"
    readonly property color pillDividerColor: "#222222"
    readonly property color tickAccentColor: "#FF7A18"
    readonly property color inputWaitColor: "#333333"
    readonly property color orbitalTickColor: "#FFFFFF"
    readonly property color orbitalTextColor: "#CCCCCC"
    readonly property color errorColor: "#FF4444"

}
