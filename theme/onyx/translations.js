.pragma library

var languageOrder = ["en", "ru", "uk"]

var languageNames = {
    "en": "English",
    "ru": "Русский",
    "uk": "Українська"
}

var translations = {
    "en": {
        "accessGranted": "ACCESS GRANTED ✦",
        "accessDeniedPw": "ACCESS DENIED ✦ ENTER PASSWORD",
        "sensorActive": "SENSOR ACTIVE ✦ TOUCH OR ENTER",
        "touchSensor": "TOUCH SENSOR TO ENTER",
        "passwordHint": "PASSWORD OR FIDO PIN",
        "session": "SESSION",
        "reboot": "REBOOT",
        "powerOff": "POWER OFF",
        "user": "USER",
        "login": "LOGIN",
        "accessDenied": "ACCESS DENIED",
        "months": ["JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE",
                   "JULY", "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER"],
        "weekdays": ["SUNDAY", "MONDAY", "TUESDAY", "WEDNESDAY",
                     "THURSDAY", "FRIDAY", "SATURDAY"]
    },
    "ru": {
        "accessGranted": "ДОСТУП РАЗРЕШЁН ✦",
        "accessDeniedPw": "ДОСТУП ЗАПРЕЩЁН ✦ ВВЕДИТЕ ПАРОЛЬ",
        "sensorActive": "СЕНСОР АКТИВЕН ✦ КОСНИТЕСЬ ИЛИ ВВЕДИТЕ",
        "touchSensor": "КОСНИТЕСЬ СЕНСОРА ✦ ДЛЯ ВХОДА",
        "passwordHint": "ПАРОЛЬ ИЛИ FIDO PIN",
        "session": "СЕАНС",
        "reboot": "ПЕРЕЗАГРУЗКА",
        "powerOff": "ВЫКЛЮЧЕНИЕ",
        "user": "ПОЛЬЗОВАТЕЛЬ",
        "login": "ВОЙТИ",
        "accessDenied": "ДОСТУП ЗАПРЕЩЁН",
        "months": ["ЯНВАРЬ", "ФЕВРАЛЬ", "МАРТ", "АПРЕЛЬ", "МАЙ", "ИЮНЬ",
                   "ИЮЛЬ", "АВГУСТ", "СЕНТЯБРЬ", "ОКТЯБРЬ", "НОЯБРЬ", "ДЕКАБРЬ"],
        "weekdays": ["ВОСКРЕСЕНЬЕ", "ПОНЕДЕЛЬНИК", "ВТОРНИК", "СРЕДА",
                     "ЧЕТВЕРГ", "ПЯТНИЦА", "СУББОТА"]
    },
    "uk": {
        "accessGranted": "ДОСТУП НАДАНО ✦",
        "accessDeniedPw": "ДОСТУП ЗАБОРОНЕНО ✦ ВВЕДІТЬ ПАРОЛЬ",
        "sensorActive": "СЕНСОР АКТИВНИЙ ✦ ТОРКНІТЬСЯ АБО ВВЕДІТЬ",
        "touchSensor": "ТОРКНІТЬСЯ СЕНСОРА ✦ ДЛЯ ВХОДУ",
        "passwordHint": "ПАРОЛЬ АБО FIDO PIN",
        "session": "СЕАНС",
        "reboot": "ПЕРЕЗАВАНТАЖЕННЯ",
        "powerOff": "ВИМКНЕННЯ",
        "user": "КОРИСТУВАЧ",
        "login": "УВІЙТИ",
        "accessDenied": "ДОСТУП ЗАБОРОНЕНО",
        "months": ["СІЧЕНЬ", "ЛЮТИЙ", "БЕРЕЗЕНЬ", "КВІТЕНЬ", "ТРАВЕНЬ", "ЧЕРВЕНЬ",
                   "ЛИПЕНЬ", "СЕРПЕНЬ", "ВЕРЕСЕНЬ", "ЖОВТЕНЬ", "ЛИСТОПАД", "ГРУДЕНЬ"],
        "weekdays": ["НЕДІЛЯ", "ПОНЕДІЛОК", "ВІВТОРОК", "СЕРЕДА",
                     "ЧЕТВЕР", "П'ЯТНИЦЯ", "СУБОТА"]
    }
}

function detectLanguage(locale) {
    var code = (locale || "").split(/[_\-]/)[0].toLowerCase()
    if (languageOrder.indexOf(code) >= 0)
        return code
    return "en"
}

function t(lang, key) {
    var dict = translations[lang] || translations["en"]
    return dict[key] !== undefined ? dict[key] : translations["en"][key]
}