import QtQuick
import "translations.js" as Tr
import "components/clock" as Clock
import "components/effects" as Effects
import "components/hud" as Hud
import "components/login" as Login

Rectangle {
    id: root
    width: Screen.width
    height: Screen.height
    color: state.bgColor

    readonly property real s: Screen.height / 768
    readonly property real marginR: 80 * root.s

    FontLoader {
        id: outfitFont
        source: "font/Outfit-Black.ttf"
    }

    ThemeState {
        id: state
        s: root.s
        fontFamily: outfitFont.status === FontLoader.Ready ? outfitFont.name : "Sans Serif"
    }

    property string language: Tr.detectLanguage(Qt.locale().name)
    readonly property var curT: Tr.translations[language] || Tr.translations["en"]

    Effects.AnimEngine {
        id: engine
        clockAwake: state.clockAwake
        animationEnabled: state.windupEnabled
        onBoomFinished: curtainOut.start()
        onFadeInFinished: clock.startDateReveal()
    }

    Clock.ClockRoot {
        id: clock
        s: root.s
        themeState: state
        clockAwake: state.clockAwake
        windupDegMin: engine.windupDegMin
        windupDegSec: engine.windupDegSec
        sparkWindup: engine.isWindup && engine.windupProgress > 0.2 ? (engine.windupProgress - 0.2) * 2.2 : 0
        timeProvider.clockAwake: state.clockAwake
    }

    Item {
        id: uiLayer
        anchors.fill: parent
        opacity: engine.uiOpacity

        Login.LoginPanel {
            id: loginPanel
            s: root.s
            themeState: state
            sessionIndex: (typeof sessionPicker !== "undefined") ? sessionPicker.selectedIndex : 0
            onSessionIndexChanged: {} // noop для стабильности binding
            anchors.right: parent.right
            anchors.rightMargin: root.marginR
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 80 * root.s
        }

        Login.AuthFeedback {
            id: authFeedback
            s: root.s
            themeState: state
            anchors.right: loginPanel.right
            anchors.bottom: loginPanel.top
            anchors.bottomMargin: 12 * root.s
        }

        Item {
            id: hudContainer
            anchors.right: parent.right
            anchors.rightMargin: root.marginR
            anchors.top: parent.top
            anchors.topMargin: 50 * root.s

            Row {
                id: hudRow
                spacing: 25 * root.s

                Hud.LangPicker {
                    s: root.s
                    themeState: state
                    languageOrder: Tr.languageOrder
                    languageNames: Tr.languageNames
                    currentLang: root.language
                    onSelected: function(langCode) { root.language = langCode }
                }

                Login.SessionPicker {
                    id: sessionPicker
                    s: root.s
                    themeState: state
                    fallbackName: root.curT["session"]
                }

                Hud.HudActions {
                    id: hudActions
                    s: root.s
                    themeState: state
                }
            }
        }
    }

    Rectangle {
        id: boomOverlay
        anchors.fill: parent
        z: 9999
        color: state.blastColor
        opacity: engine.boomOpacity
        visible: opacity > 0
    }

    NumberAnimation {
        id: curtainOut
        target: boomOverlay
        property: "opacity"
        from: 1
        to: 0
        duration: 180
        easing.type: Easing.InQuad
    }

    Connections {
        target: typeof sddm !== "undefined" ? sddm : null
        function onLoginSucceeded() { authFeedback.showSuccess() }
        function onLoginFailed() { authFeedback.showDenied() }
    }

    Component.onCompleted: {
        if (state.windupEnabled)
            engine.startReveal()
        else
            engine.uiOpacity = 1
    }
}
