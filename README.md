# Onyx SDDM Theme

[![Version](https://img.shields.io/badge/version-0.1.2--mvp-555555.svg?logo=changelog&logoColor=white&style=flat)](CHANGELOG.md)
[![CI](https://img.shields.io/github/actions/workflow/status/y-tretyakov/onyx-sddm/ci.yml?branch=dev&label=CI)](https://github.com/y-tretyakov/onyx-sddm/actions)
[![OS](https://img.shields.io/badge/OS-Arch%7CCachyOS%7CFedora%7CNobara%7CUbuntu%7CDebian%7CopenSUSE%7CRHEL9-41CD52.svg?style=flat)](.github/workflows/ci.yml)
[![Qt6](https://img.shields.io/badge/Qt-6-41CD52.svg?logo=qt&logoColor=white&style=flat)](https://doc.qt.io/qt-6/)
[![QML](https://img.shields.io/badge/QML-Qt__Quick-41CD52.svg?style=flat)](https://doc.qt.io/qt-6/qtquick-index.html)
[![SDDM](https://img.shields.io/badge/SDDM-greeter-FF6B6B.svg?style=flat)](https://github.com/sddm/sddm)
[![Linux](https://img.shields.io/badge/Linux-Linux-E34F26.svg?logo=linux&logoColor=white&style=flat)](https://www.kernel.org/)
[![Wayland](https://img.shields.io/badge/Wayland-primary-1a73e8.svg?style=flat)](https://wayland.freedesktop.org/)
[![License](https://img.shields.io/badge/License-GPL--3.0-41CD52.svg?style=flat)](LICENSE)

**Onyx** — экран входа (SDDM greeter) с орбитальным clockwork-дизайном и общей
мерой масштабирования. Проект создан с нуля на основе визуального языка
оригинальной темы *clockwork/orbital* (Ryoku / Darkkal44), но с полностью
переработанной архитектурой, чистым кодом и чёткой дорожной картой.

Статус: **MVP в процессе** (Phase 1). Уже реализовано: цифровые часы +
indicator pill на орбитально-часовом фоне, валидировано на 8 дистрибутивах
в CI.

## Текущий статус

- **Версия:** `0.1.2-mvp` · Phase 1 / MVP — stage 1.1, 1.2 и 1.3 закрыты.
- **Что сделано:** орбиталь минут (60 тиков, major/minor, spotlight текущей
  минуты) вокруг цифровых часов + indicator pill; цветовой API в ThemeState;
  drift-free синк тика в целую секунду; весь масштаб через `s`; шрифт
  Sans Serif; закрыты CR-F7/F8/F11; `validate.sh` OK, `qmllint` exit 0;
  preview-рендер часов + pill + орбитали.
- **CI:** полная 8-контейнерная матрица (arch, cachyos, fedora, nobara,
  ubuntu, debian, opensuse, rhel9) зелёная.
- **Следующий шаг:** stage 1.4 — Second orbital (smooth).
- Полный учёт этапов и версий — в [CHANGELOG](CHANGELOG.md).

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

- Wayland (primary, Weston kiosk) · X11 (secondary, с паритетом)
- Проверено в CI на 8 дистрибутивах: **Arch, CachyOS, Fedora, Nobara,
  Ubuntu, Debian, openSUSE Tumbleweed, RHEL9-семейство**.

> Примечание об RHEL9: семейство RHEL9 проверяется в CI через **AlmaLinux 9**
> (бинарный ребилд RHEL9), а не через сам RHEL9/UBI9, потому что в UBI9
> отсутствуют X11/xcb/GL рантайм-зависимости EPEL Qt6 (`qt6-qtbase-gui`):
> `libxkbcommon-x11`, `xcb-util-*`, `libinput`, `mesa-libGL`. AlmaLinux 9 даёт
> полный AppStream + работающий EPEL Qt6.

## Разработка / локальные проверки

| Команда | Назначение |
|---------|-----------|
| `./validate.sh` | Слоёная валидация темы: required-файлы, `metadata.desktop`, `theme.conf`, QML-линт (`qmllint`, hard-fail) |
| `./scripts/smoke.sh` | Headless-смоук: offscreen/software загрузка `Main.qml` на 15s без краша (exit 0/1) |
| `./scripts/preview.sh` | Превью-раннер (qml6/qml): `-W/-H` окно, `-o FILE.png` скриншот, `--mock` |
| `./install.sh` | Установка темы в `/usr/share/sddm/themes/onyx` (`--dest` для тестов) |
| `./uninstall.sh` | Удаление темы (идемпотентно) |

## Contributing / Workflow

Вся работа ведётся на ветках `stage/*` → Pull Request в `dev`; `main` — только
для вех стабильности (теги/релизы). CI обязателен: на PR гейт — `validate` +
`validate-arch`, на merge в `dev` — полная 8-дистрибутивная матрица.

## Лицензия

GPL-3.0

---

*Onyx · 2026-09-08*
