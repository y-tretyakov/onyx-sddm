# Onyx — Changelog

> Единый учёт версий и этапов Onyx. Правила ведения: `AGENTS.md` §3.1–3.2.
> Формат: «сверху вниз», новая версия выше предыдущих. Историю не переписываем.

---

## [0.1.0-mvp] — stage 1.1 · Root + scaling + background · 2026-09-08

**Версия:** `0.1.0-mvp` (MINOR bump после stage 1.1; тег/релиз НЕ ставится — это stage, не веха)

### Тик-лист (копия ROADMAP — Phase 1)

| Stage | Version   | Focus                              | Key deliverables                         | Done |
|-------|-----------|------------------------------------|------------------------------------------|------|
| 1.1   | 0.1.0-mvp | Root + scaling + background        | `s` property, full-screen root, bgColor  | [x]  |
| 1.2   | 0.1.1-mvp | Digital clock + indicator pill     | curH / pillMin / pillSec                 | [ ]  |

### Статус и следующий шаг

- Сделано: код root/scaling/background (заложен в Phase 0) верифицирован по спеке 1.1 — full-screen root, `s = Screen.height/768`, `bgColor` из theme.conf/`#000000`; `sddm-greeter-qt6 --test-mode` — полноэкранное чёрное окно 1920×1080, нет QML errors; preview через `qml6` рендерится чисто (graceful degradation, `isPreview` guard работает); `./validate.sh` OK; `qmllint` exit 0; version → 0.1.0-mvp.
- Следующее: **stage 1.2 — Digital clock + indicator pill** (curH, большой цифровой час, pill минуты/секунды).
- Подготовить до старта: mock `sddm`/`config` + preview-раннер для рендера без живой greeter; preview.png появится с первым визуалом.
- Блокеры: нет.

### Детали изменений (для агентов)

- Верификация проводилась, НОВЫХ файлов/компонентов НЕТ (код уже удовлетворял спеке из Phase 0).
- `theme/onyx/Main.qml:1-15` — root `Rectangle` full-screen (`Screen.width/height`), `color: state.bgColor`, `readonly property real s: Screen.height / 768`, инстанцирует `ThemeState { id: state; s: root.s }`.
- `theme/onyx/ThemeState.qml:1-16` — `property real s` (из визуального root), `isPreview` (sddm-less guard), `bgColor` из theme.conf (`config`) с fallback `#000000`.
- `theme/onyx/theme.conf:1-7` — `[General]` с `bgColor=#000000`.
- `theme/onyx/metadata.desktop:1-7` — installable (`MainScript=Main.qml`, `ConfigFile=theme.conf`, `QtVersion=6`).
- Проверено: `sddm-greeter-qt6 --test-mode` (greeter), `qml6` (preview), `./validate.sh` (OK), `qmllint` (exit 0).

### Тех. долг

- `qmlscene` на машине — Qt5.15, несовместим с versionless `import QtQuick` (Qt6). Для превью использовать `qml6`/`qml`. Желателен постоянный preview-раннер (qml6 + mock sddm/config) к stage 1.2+.
- Нет `preview.png` — появится со stage 1.2+ (первый визуал).
- Необязательный polish: `metadata.desktop` без поля `Author=` (не требование спеки 1.1, можно добавить позже).

### Принятые решения

- Stage 1.1 = верификация + bump (код уже удовлетворял спеке из Phase 0), без нового Background-компонента (решение пользователя 2026-09-08).
- MINOR bump (`0.0.3` → `0.1.0-mvp`) — переход от Foundation (0.x) к MVP (0.1.x).

---

## [0.0.3] — stage 0.3 · CI skeleton + metadata.desktop + theme.conf · 2026-09-08

**Версия:** `0.0.3` (PATCH bump после stage 0.3; тег/релиз не ставился — это stage, не веха)

### Тик-лист (копия ROADMAP — Phase 0)

| Stage | Version | Deliverables                                      | Done |
|-------|---------|---------------------------------------------------|------|
| 0.1   | 0.0.1   | Репозиторий, ARCHITECTURE, ROADMAP, SPECS skeleton | [x]  |
| 0.2   | 0.0.2   | install/uninstall/validate scripts skeleton        | [x]  |
| 0.3   | 0.0.3   | CI skeleton + metadata.desktop + theme.conf        | [x]  |

### Статус и следующий шаг

- Сделано: тема стала installable для SDDM (metadata.desktop + theme.conf); root/scale скелет починены (follow-up F1/F2/F6); validate.sh расширен (F3); CI skeleton добавлен; version → 0.0.3.
- Следующее: **Phase 1 / stage 1.1 — Root + scaling + background** (первый реальный greeter-код).
- Подготовить до старта: preview-мод (qmlscene/QuickShell) для `sddm`-less рендера; mock `sddm`/`config` для превью.
- Блокеры: нет. Follow-up F1/F2/F3/F6 закрыты в 0.3; F4 (install.sh conf.d) — в RC/4.1; F7 (синоним F3) — закрыт.

### Детали изменений (для агентов)

- `theme/onyx/metadata.desktop:1-7` — `[SddmGreeterTheme]`, `QtVersion=6`, `MainScript=Main.qml`, `ConfigFile=theme.conf` — тема теперь детектится SDDM.
- `theme/onyx/theme.conf:1-7` — `[General]` скелет (`type=color`, `color`, `fontSize`, `themeMode`, `language`, `bgColor`).
- `theme/onyx/Main.qml:1-14` — `import QtQuick` (Qt6, без 2.0); `width/height: Screen.width/height`; корневой `Rectangle` красится из `state.bgColor`; `readonly property real s: Screen.height / 768`; инстанцирует `ThemeState { id: state; s: root.s }`.
- `theme/onyx/ThemeState.qml:1-16` — `s` как обычное `property real s: 1` (значение приходит из визуального root — НЕ считается через `Screen` в QtObject); добавлены `isPreview` (sddm-less guard) и `bgColor` (fallback `#000000` из theme.conf через `config`).
- `validate.sh:22-28` — REQUIRED_FILES дополнен `metadata.desktop` + `theme.conf`.
- `.github/workflows/ci.yml` — job `validate` (actions/checkout@v4; `validate.sh` + robust qmllint detection (`qt6-declarative-dev-tools` on Ubuntu; binary detection loop for `qmllint6`/`qmllint`/`/usr/lib/qt6/bin/qmllint`); QML linted with `--unqualified=info --import=info` to neutralise benign Qt 6.4 / SDDM globals warnings; real errors still fail CI).
- ADR (F2): scale вычисляется в визуальном root, ThemeState — единый владелец значения; `bgColor` в ThemeState с preview-safe fallback.
- Git: commits stage 0.3 (Tasks 1–6), PR → merge в `dev`.

### Тех. долг

- install.sh НЕ пишет `/etc/sddm.conf.d/` с `Current=onyx` — осознанно вне scope 0.3 (F4 → RC/4.1).
- CI НЕ проверяет checksums/`verify-theme.sh` — это stage 4.3 (CI completeness).
- `qmllint` runs with `--unqualified=info --import=info` (Qt 6.4 qmllint exits non-zero on ANY warning; two benign warning classes — SDDM-injected `sddm`/`config` globals and missing `jsroot.qmltypes` base-module fallback on Ubuntu — are demoted to info; real syntax/type errors still fail CI). Accepted, documented CI behaviour.
- Нет `preview.png` — появится с первым визуалом (MVP, stage 1.1+).

### Принятые решения

- `metadata.desktop`/`theme.conf` создаём в 0.3 (по ROADMAP, как и планировалось в 0.1/0.2).
- F2 решён передачей scale из визуального root, а не через `Screen` в bare-`QtObject` — самый надёжный паттерн по review; ThemeState остаётся единым источником scale.
- `bgColor` вынесен в ThemeState (color API, ARCHITECTURE §4.3) с fallback на `#000000` при отсутствии `config`/`sddm` (превью).
- CI skeleton минимальный: validate.sh + qmllint; checksums/verify — stage 4.3.

---


**Версия:** `0.0.2` (PATCH bump после stage 0.2; тег/релиз не ставился — это stage, не веха)

### Тик-лист (копия ROADMAP — Phase 0)

| Stage | Version | Deliverables                                      | Done |
|-------|---------|---------------------------------------------------|------|
| 0.1   | 0.0.1   | Репозиторий, ARCHITECTURE, ROADMAP, SPECS skeleton | [x]  |
| 0.2   | 0.0.2   | install/uninstall/validate scripts skeleton        | [x]  |
| 0.3   | 0.0.3   | CI skeleton + metadata.desktop + theme.conf        | [ ]  |

### Статус и следующий шаг

- Сделано: три скрипта-каркаса в корне репо, протестированы на /tmp (install/uninstall) и на ошибках (validate).
- Следующее: **stage 0.3 — CI skeleton + metadata.desktop + theme.conf**.
- Подготовить до старта: выбрать суть CI-работ (validate.sh + qmllint в GitHub Actions), определить содержимое metadata.desktop (Desktop Entry для SDDM).
- Блокеры: нет.

### Детали изменений (для агентов)

- `install.sh:1-36` — копирует `theme/onyx/.` → `--dest`/`/usr/share/sddm/themes/onyx`; поддержка `--dest`, `-h/--help`; exit 0/1/2.
- `uninstall.sh:1-34` — удаляет каталог темы; идемпотентный exit 0.
- `validate.sh:1-46` — проверка required-набора `Main.qml`, `ThemeState.qml`, `translations.js`, `PROVENANCE.txt`; exit 0/1; дефолт `theme/onyx`.
- Общий паттерн: `set -euo pipefail`, `BASH_SOURCE[0]` для относительных путей, messages на английском.
- `metadata.desktop`/`theme.conf` сознательно НЕ в required (stage 0.3 добавит их в validate и установит дефолт SDDM-темы).
- Git: commits stage 0.2, PR → merge в `dev` (история в git log).

### Тех. долг

- Нет обработки многопользовательской установки/бэкапа конфигов SDDM (потом: stage 4.1 packaging).
- validate.sh НЕ проверяет `metadata.desktop`/`theme.conf` до stage 0.3.
- install.sh не перезаписывает `sddm.conf` `Current=` (дефолт-тема — вне scope до 0.3).

### Принятые решения

- Скрипты — bash, `set -euo pipefail`, без зависимостей, английские сообщения.
- `--dest` для тестируемости в CI/tmp; дефолт `/usr/share/sddm/themes/onyx` (стандарт SDDM).
- `scripts/verify-theme.sh`/`checksums.sha256` перенесены в stage 4.3 (CI completeness).

---

## [0.0.1] — stage 0.1 · Theme skeleton · 2026-09-08

**Версия:** `0.0.1` (PATCH bump после stage 0.1; тег/релиз не ставился — это stage, не веха)

### Тик-лист (копия ROADMAP — Phase 0)

| Stage | Version | Deliverables                                      | Done |
|-------|---------|---------------------------------------------------|------|
| 0.1   | 0.0.1   | Репозиторий, ARCHITECTURE, ROADMAP, SPECS skeleton | [x]  |
| 0.2   | 0.0.2   | install/uninstall/validate scripts skeleton        | [ ]  |
| 0.3   | 0.0.3   | CI skeleton + metadata.desktop + theme.conf        | [ ]  |

### Тик-лист (копия ROADMAP — Milestones)

| Milestone | Version        | Goal                                      | Done |
|-----------|----------------|-------------------------------------------|------|
| MVP       | 0.1.x-mvp      | Минимально рабочий greeter                | [ ]  |
| Alpha     | 0.2.x-alpha    | Полный визуальный язык + базовая i18n     | [ ]  |
| Beta      | 0.3.x–0.5.x    | X11/Wayland parity, fingerprint, polish   | [ ]  |
| RC        | 0.9.x-rc       | Release Candidate                         | [ ]  |
| Stable    | 1.0.0+         | Production-ready                          | [ ]  |

### Статус и следующий шаг

- Сделано: каркас темы `theme/onyx/` + план этапа; доки (ARCHITECTURE/ROADMAP/SPECS/LICENSE) были заложены bootstrap-коммитом.
- Следующее: **stage 0.2 — install/uninstall/validate scripts skeleton**.
- Подготовить до старта: выбрать целевой путь установки темы (`/usr/share/sddm/themes/onyx`); определить минимально валидное поведение скриптов-заглушек (ROADMAP: «Скрипты запускаются без ошибок»).
- Блокеры: нет.

### Детали изменений (для агентов)

- `theme/onyx/Main.qml:1-15` — корневой `Rectangle`, composition only (ARCHITECTURE §4.1). Плейсхолдер: текст «Onyx», `font.pixelSize: 32`. Со stage 1.1 сюда подключаются `ThemeState` + background + компоненты.
- `theme/onyx/ThemeState.qml:1-7` — `QtObject` с `readonly property real s: Screen.height / 768` (обязателен с первого коммита, MVP Global Constraints). Здесь появятся цвета / время / язык / флаги (ARCHITECTURE §4.3).
- `theme/onyx/translations.js:1` — `.pragma library`; словари придут в Phase 2 (Alpha).
- `theme/onyx/PROVENANCE.txt:1-10` — атрибуция: дизайн-вдохновение Ryoku (Darkkal44, qylock), GPL-3.0, clean re-implementation.
- `theme/onyx/components/{clock,login,hud,effects,platform}/.gitkeep` — целевые каталоги компонентов.
- `theme/onyx/font/.gitkeep`, `theme/onyx/icons/.gitkeep` — для Outfit-Black.ttf и SVG-иконок.
- `docs/superpowers/plans/2026-09-08-stage-0.1-theme-skeleton.md` — план этапа (3 задачи).
- Git: commits `1f59153`, `eca85bf`, `cc884cc`; merged PR #1 → `dev` (`6442c2e`, squash); ветка `stage/0.1-foundation` удалена.
- Проверено: `qmllint` exit 0 для Main.qml и ThemeState.qml; ревью diff при приёмке.

### Тех. долг

- Нет `metadata.desktop` / `theme.conf` — осознанно перенесены в stage 0.3 (тема пока не детектится SDDM; НЕ чинить раньше 0.3).
- Нет `preview.png` — появится при первом визуале (MVP).
- Нет версии в теме (напр. в metadata.desktop) — появится со stage 0.3.
- Remote: HTTPS + gh credential helper (SSH-ключ не настроен на машине) — тех-долг окружения, не блокер; при желании перейти на SSH-ключ.
- Нет `install.sh` / `uninstall.sh` / `validate.sh` — это stage 0.2, не пропуск.

### Принятые решения

- Stage 0.1 = только каркас темы; `metadata.desktop`/`theme.conf` строго в stage 0.3 (по ROADMAP; никакого «заодно»).
- `.agents/skills` закоммичены (bootstrap) — репозиторий самодостаточен для оркестрации.
- Версия после stage 0.1 → `0.0.1`, git-tag/GitHub Release на этап НЕ ставится (это право только вех).
- Preview-режим (qmlscene) без `sddm` объекта — остаётся приоритетом с первого кода (graceful degradation).

---