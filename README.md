# Onyx SDDM Theme

[![Version](https://img.shields.io/badge/version-0.1.1--mvp-555555.svg?logo=changelog&logoColor=white&style=flat)](CHANGELOG.md)
[![Qt6](https://img.shields.io/badge/Qt-6-41CD52.svg?logo=qt&logoColor=white&style=flat)](https://doc.qt.io/qt-6/)
[![QML](https://img.shields.io/badge/QML-Qt__Quick-41CD52.svg?style=flat)](https://doc.qt.io/qt-6/qtquick-index.html)
[![SDDM](https://img.shields.io/badge/SDDM-greeter-FF6B6B.svg?style=flat)](https://github.com/sddm/sddm)
[![Linux](https://img.shields.io/badge/Linux-Arch--Linux--CachyOS-E34F26.svg?logo=linux&logoColor=white&style=flat)](https://archlinux.org/)
[![Wayland](https://img.shields.io/badge/Wayland-primary-1a73e8.svg?style=flat)](https://wayland.freedesktop.org/)
[![License](https://img.shields.io/badge/License-GPL--3.0-41CD52.svg?style=flat)](LICENSE)

**Onyx** — новый экран входа (SDDM greeter) с орбитальным clockwork-дизайном.

Проект создан с нуля на основе визуального языка оригинальной темы *clockwork/orbital* (Ryoku / Darkkal44), но с полностью переработанной архитектурой, чистым кодом и чёткой дорожной картой.

## Текущий статус

**Phase 1 / MVP** — stage 1.2 закрыт:
- цифровые часы (TimeProvider, 1s timer) + indicator pill (мин|сек) + интеграция в Main.qml
- весь масштаб через `s`; шрифт Sans Serif; проверено: `validate.sh` OK, `qmllint` exit 0, preview-рендер часов + pill
- версия **0.1.1-mvp** · [CHANGELOG](CHANGELOG.md)

**Phase 1 / MVP** — stage 1.1 закрыт:
- верификация root/scaling/background по спеке 1.1 (full-screen root, `s = Screen.height/768`, `bgColor`)
- нет QML errors; `validate.sh` OK; `qmllint` exit 0

**Phase 0 / Foundation** — stage 0.1–0.3 закрыты:
- каркас темы `theme/onyx/` (Main.qml, ThemeState.qml со scale `s`, translations.js, PROVENANCE.txt)
- скрипты `install.sh` / `uninstall.sh` / `validate.sh`
- installable-файлы для SDDM: `metadata.desktop` (QtVersion=6) + `theme.conf`
- CI skeleton (validate + qmllint)

**Следующий шаг:** Phase 1 / stage 1.3 — Minute orbital (static + spotlight).

## Документация

| Документ | Описание |
|----------|----------|
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Архитектура, подсистемы, технические решения |
| [docs/ROADMAP.md](docs/ROADMAP.md) | Дорожная карта, вехи, версии, фазы |
| [docs/SPECS/00-mvp.md](docs/SPECS/00-mvp.md) | Детальные спеки MVP |
| [docs/SPECS/01-alpha.md](docs/SPECS/01-alpha.md) | Детальные спеки Alpha |
| [docs/SPECS/02-beta.md](docs/SPECS/02-beta.md) | Детальные спеки Beta |
| [docs/SPECS/03-rc.md](docs/SPECS/03-rc.md) | Детальные спеки RC |
| [docs/SPECS/04-stable.md](docs/SPECS/04-stable.md) | Детальные спеки Stable |

## Основные элементы (сохраняем дизайн)

- Две орбитали (минуты + секунды) вокруг цифровых часов
- Indicator-pill
- Login-панель (user / session / password)
- HUD (power, reboot, language selector)
- Характерные анимации: windup → boom, sparks, tick-feedback, spotlight

## Целевые платформы

- Arch Linux / CachyOS
- Wayland (primary, Weston kiosk)
- X11 (secondary, с полным паритетом)

## Лицензия

GPL-3.0

---

*Onyx · 2026-09-08*
