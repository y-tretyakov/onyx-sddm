import QtQuick

QtObject {
    id: themeState

    FontLoader {
        id: outfitFont
        source: "font/Outfit-Black.ttf"
    }

    property real s: 1

    readonly property bool isPreview: typeof sddm === "undefined" || sddm.hostName === undefined

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
    readonly property string fontFamily: outfitFont.status === FontLoader.Ready
                                          ? outfitFont.name
                                          : "Sans Serif"
}
