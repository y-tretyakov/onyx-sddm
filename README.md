# Onyx SDDM Theme

[![Version](https://img.shields.io/badge/version-0.2.0--alpha.7-555555.svg?logo=changelog&logoColor=white&style=flat)](CHANGELOG.md)
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

Статус: **Alpha в процессе** (Phase 2). Уже реализовано: i18n Core (трехъязычные
словари en/ru/uk, auto-detect `Qt.locale().name`, LangPicker в HUD,
stage 2.7); HUD power/reboot
(иконки-кнопки reboot + power в hudContainer, hover-состояние, sddm.wiring,
stage 2.6); user & session pickers
(два dropdown'а из userModel/sessionModel, влияют на `sddm.login`, stage 2.5);
date + weekday reveal (посимвольная сборка после windup→boom→fade-in, stage 2.4);
sparks + bursts (stage 2.3); tick feedback (flash + halo) при смене минуты
(stage 2.2); windup → boom → fade-in sequence при появлении greeter'а (stage 2.1);
весь MVP (1.1–1.8) закрыт.

## Текущий статус

- **Версия:** `0.2.0-alpha.7` · Phase 2 / Alpha — [x] 2.1 (windup→boom), [x] 2.2 (tick feedback), [x] 2.3 (sparks + bursts), [x] 2.4 (date + weekday reveal), [x] 2.5 (user & session pickers), [x] 2.6 (HUD: power/reboot), [x] 2.7 (i18n core) закрыты.
- **Что сделано:** на 2.7 — i18n Core: `translations.js` (`.pragma library`,
  словари en/ru/uk + `detectLanguage()` + `t()`-fallback), `language`/
  `curT`-состояние в Main (`Tr.detectLanguage(Qt.locale().name)`),
  `components/hud/LangPicker.qml` (dropdown в hudRow, signal `selected`),
  SessionPicker `fallbackName` привязан к `curT["session"]`; offscreen
  `i18n-probe` — секция 13 verify-theme (registration → 14).
  На 2.6 — HUD power/reboot: два icon-кнопки в hudContainer
  (`components/hud/HudAction.qml` — лист-кнопка с hover: scale 1.12 +
  ColorOverlay-перекраска; `components/hud/HudActions.qml` — строка
  `[reboot | power]` с разделителем), вызывают `sddm.reboot()` /
  `sddm.powerOff()` под `typeof sddm` guard; иконки `icons/{power,reboot}.svg`
  (Material, Apache-2.0, PROVENANCE дополнен); offscreen `hud-probe`
  (click-through + hover) — секция 12 verify-theme (registration → 13).
  На 2.5 — два новых dropdown'а в стиле орбитального clockwork:
  `components/login/UserPicker.qml` (внутри LoginPanel, меню открывается вверх от
  trigger) и `components/login/SessionPicker.qml` (самостоятельный компонент в
  верхней правой hud-зоне, меню вниз). Оба читают роли через helper-ListView
  без `userModel.data()` (ADR-1.8-1), выбор пользователя/сессии влияет на
  `sddm.login(user, pass, sessionIndex)` через `LoginPanel._submit`; добавлен
  автономный `user-session-probe` в verify-theme.
- **CI:** локальная фулл-gate («validate + smoke + verify-theme секции 1–14») на
  ветках stage — exit 0 на каждом этапе; 8-контейнерная матрица GitHub Actions
  зелёная на `dev` (по состоянию на stage 2.4).
- **Следующий шаг:** Alpha 2.8 — Wayland Virtual Cursor (`0.2.0-alpha.8`).
- Полный учёт этапов и версий — в [CHANGELOG](CHANGELOG.md).

## Установка (MVP)

### Одна строка (после релиза по тегу)

```bash
curl -fsSL https://raw.githubusercontent.com/y-tretyakov/onyx-sddm/0.1.11-mvp/install.sh | sudo bash -s -- --release 0.1.11-mvp
```

Скачивает тему по тегу релиза и ставит системно.

### Системная установка

```bash
sudo ./install.sh
```

Скрипт копирует `theme/onyx` в `/usr/share/sddm/themes/onyx`.

### Пользовательская установка (без root)

```bash
./install.sh --dest ~/.local/share/sddm/themes
```

> Отмечено: установка в домашний каталог работает, только если в системе
> настроен поиск SDDM тем в пользовательских путях (иначе greeter их не найдёт).

### Включение темы

В `/etc/sddm.conf`:

```ini
[Theme]
Current=onyx
```

Либо через системный инструментарий распределения (например, на дистрибутивах
с графической настройкой SDDM). После включения — перезапустить SDDM.

### Удаление

```bash
sudo ./uninstall.sh
```

Если тема ставилась в своё место — удалять с тем же `--dest`:

```bash
./uninstall.sh --dest ~/.local/share/sddm/themes
```

### Проверка

```bash
ls /usr/share/sddm/themes/onyx
./scripts/verify-theme.sh   # exit 0 — всё в порядке
```

### Примечания

- Минимальные требования: **Qt 6** (SDDM ≥ 0.20 с Qt6-greeter).
- Primary — Wayland, secondary — X11.
- Превью/smoke работают без живого greeter: тема «graceful» деградирует
  в preview-режиме (SMOKE/preview не требуют работающего SDDM).

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
