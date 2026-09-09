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

    // Color API — единый хост для тем (ARCHITECTURE §4.3, §5.6).
    // Полная конфигурируемость через theme.conf — stage 3.7 (light theme).
    readonly property color mainTextColor: "#FFFFFF"
    readonly property color pillBgColor: "#1A1A1A"
    readonly property color pillBorderColor: "#333333"
    readonly property color pillDividerColor: "#444444"
    readonly property color pillMinutesColor: "#CCCCCC"
    readonly property color pillSecondsColor: "#888888"
    readonly property color orbitalTickColor: "#FFFFFF"
    readonly property color orbitalTextColor: "#CCCCCC"
    readonly property color denyColor: "#FF5252"
    readonly property string fontFamily: "Sans Serif"
}
