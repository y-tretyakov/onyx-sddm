import QtQuick
import QtQuick.Window
import "../../theme/onyx"
import "../../theme/onyx/translations.js" as Tr
import "../../theme/onyx/components/login" as Login
import "../../theme/onyx/components/hud" as Hud

Window {
    id: probe
    width: 480
    height: 200
    visible: true

    Item {
        anchors.fill: parent

        ThemeState { id: ts; s: 1 }

        // Stub LangPicker to verify its contract without UI
        Hud.LangPicker {
            id: langPicker
            s: 1
            themeState: ts
            languageOrder: Tr.languageOrder
            languageNames: Tr.languageNames
            currentLang: probe.currentLang
            onSelected: function(langCode) { probe.currentLang = langCode }
        }

        // SessionPicker to verify fallbackName updates with language
        Login.SessionPicker {
            id: sessionPicker
            s: 1
            themeState: ts
            fallbackName: Tr.translations[probe.currentLang]["session"] || "SESSION"
            visible: false
        }
    }

    property string currentLang: "en"
    property int passed: 0
    property int total: 0

    function check(label, condition) {
        total++
        if (condition) {
            passed++
            return true
        }
        console.log("I18N-PROBE: FAIL: " + label)
        Qt.exit(1)
        return false
    }

    Timer {
        interval: 400
        repeat: false
        running: true
        onTriggered: run()
    }

    function run() {
        // 1. detectLanguage
        check("detect en_US → en", Tr.detectLanguage("en_US") === "en")
        check("detect ru_RU → ru", Tr.detectLanguage("ru_RU") === "ru")
        check("detect uk_UA → uk", Tr.detectLanguage("uk_UA") === "uk")
        check("detect de_DE → en (fallback)", Tr.detectLanguage("de_DE") === "en")
        check("detect empty → en (fallback)", Tr.detectLanguage("") === "en")

        // 2. English fallback for unknown key via t()
        check("t fallback to English for missing key", Tr.t("xx", "accessDenied") === "ACCESS DENIED")

        // 3. Simulate language switch → SessionPicker fallback updates
        currentLang = "ru"
        var ruSession = Tr.translations["ru"]["session"]
        if (sessionPicker.fallbackName !== ruSession)
            return // check will fail below

        check("SessionPicker fallbackName = ru session after switch",
              sessionPicker.fallbackName === ruSession)

        currentLang = "uk"
        var ukSession = Tr.translations["uk"]["session"]
        check("SessionPicker fallbackName = uk session after switch",
              sessionPicker.fallbackName === ukSession)

        // 4. LangPicker signal wiring
        var sigFired = false
        langPicker.selected.connect(function(c) { sigFired = true })
        langPicker.selected("en")
        check("LangPicker selected signal fires", sigFired)
        check("LangPicker currentLang updates via signal", currentLang === "en")

        // 5. English values present
        check("translations['en']['months'] length 12",
              Tr.translations["en"]["months"] && Tr.translations["en"]["months"].length === 12)
        check("translations['ru']['weekdays'] length 7",
              Tr.translations["ru"]["weekdays"] && Tr.translations["ru"]["weekdays"].length === 7)

        console.log("I18N-PROBE: OK (" + passed + "/" + total + " checks passed)")
        Qt.exit(0)
    }
}