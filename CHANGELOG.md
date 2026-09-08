# Onyx — Changelog

> Единый учёт версий и этапов Onyx. Правила ведения: `AGENTS.md` §3.1–3.2.
> Формат: «сверху вниз», новая версия выше предыдущих. Историю не переписываем.

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