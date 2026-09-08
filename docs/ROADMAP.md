# Onyx — Roadmap & Versioning

**Project:** Onyx SDDM Theme  
**Start date:** 2026-09-08  
**Target first Stable:** Q4 2026  

---

## 1. Versioning Scheme

Семантическое версионирование с пре-релизными тегами:

```
MAJOR.MINOR.PATCH[-prerelease]

Примеры:
  0.1.0-mvp
  0.2.0-alpha.1
  0.3.0-beta.1
  0.9.0-rc.1
  1.0.0
```

Правила bump:

| Когда                          | Что bump’аем     | Пример                  |
|--------------------------------|------------------|-------------------------|
| Новый milestone (MVP→Alpha…)   | MINOR + tag      | 0.1.0-mvp → 0.2.0-alpha |
| Новый этап внутри milestone    | PATCH или .N     | 0.2.0-alpha.1 → .2      |
| Breaking change после 1.0      | MAJOR            | 1.x → 2.0.0             |
| Bugfix / polish               | PATCH            | 1.0.0 → 1.0.1           |

---

## 2. Milestones Overview

| Milestone | Version range     | Goal                                      | Exit criteria                                      |
|-----------|-------------------|-------------------------------------------|----------------------------------------------------|
| **MVP**   | 0.1.x-mvp         | Минимально рабочий greeter                | Орбитали + часы + login работают на Wayland        |
| **Alpha** | 0.2.x-alpha       | Полный визуальный язык + базовая i18n     | Все основные элементы + анимации + 3+ языка        |
| **Beta**  | 0.3.x – 0.5.x-beta| Полировка, X11/Wayland parity, fingerprint| Стабильная работа на обеих платформах, все фичи    |
| **RC**    | 0.9.x-rc          | Release Candidate                         | Полное тестирование, packaging, документация       |
| **Stable**| 1.0.0+            | Production-ready                          | Готово к массовому использованию на CachyOS/Arch   |

---

## 3. Phases & Stages (detailed)

### Phase 0 — Foundation (pre-MVP)
**Version:** `0.0.1` → `0.0.9`  
**Goal:** Чистый каркас проекта, tooling, документация.

| Stage | Version     | Deliverables                                      | Done when                          |
|-------|-------------|---------------------------------------------------|------------------------------------|
| 0.1   | 0.0.1       | Репозиторий, ARCHITECTURE, ROADMAP, SPECS skeleton| Docs + empty theme skeleton        |
| 0.2   | 0.0.2       | install/uninstall/validate scripts skeleton       | Скрипты запускаются без ошибок     |
| 0.3   | 0.0.3       | CI skeleton + metadata.desktop + theme.conf       | CI проходит (даже пустой)          |

---

### Phase 1 — MVP
**Version:** `0.1.0-mvp` → `0.1.x-mvp`  
**Goal:** Самый простой работающий greeter с двумя орбиталями.

| Stage | Version       | Focus                                      | Key deliverables |
|-------|---------------|--------------------------------------------|------------------|
| 1.1   | 0.1.0-mvp     | Root + scaling + background                | `s` property, full-screen root, bgColor |
| 1.2   | 0.1.1-mvp     | Digital clock + indicator pill             | curH / pillMin / pillSec |
| 1.3   | 0.1.2-mvp     | Minute orbital (static + spotlight)        | 60 ticks, major/minor, current minute highlight |
| 1.4   | 0.1.3-mvp     | Second orbital (smooth)                    | 60 ticks, smooth second hand via 16 ms timer |
| 1.5   | 0.1.4-mvp     | Login panel (minimal)                      | Password field + sddm.login() |
| 1.6   | 0.1.5-mvp     | Basic auth feedback                        | ACCESS GRANTED / DENIED text |
| 1.7   | 0.1.9-mvp     | MVP freeze + visual QA on 1080p/1440p      | Milestone exit |

**Exit criteria MVP:**
- Greeter запускается под SDDM (Wayland)
- Две орбитали + цифровые часы видны и обновляются
- Можно ввести пароль и залогиниться
- Нет крашей

---

### Phase 2 — Alpha
**Version:** `0.2.0-alpha` → `0.2.x-alpha`  
**Goal:** Полный визуальный язык оригинала + базовая многоязычность.

| Stage | Version         | Focus                                      | Key deliverables |
|-------|-----------------|--------------------------------------------|------------------|
| 2.1   | 0.2.0-alpha.1   | Windup → boom sequence                     | Входная анимация при появлении greeter |
| 2.2   | 0.2.0-alpha.2   | Tick feedback (flash + halo)               | Минутный тик визуально откликается |
| 2.3   | 0.2.0-alpha.3   | Sparks + sec/min/hour bursts               | Искры и burst-эффекты |
| 2.4   | 0.2.0-alpha.4   | Date + weekday reveal                      | Staggered assembly + blur |
| 2.5   | 0.2.0-alpha.5   | User & Session pickers                     | Dropdowns (базовая реализация) |
| 2.6   | 0.2.0-alpha.6   | HUD (power / reboot)                       | Кнопки выключения и перезагрузки |
| 2.7   | 0.2.0-alpha.7   | i18n core (en + ru + uk)                   | translations.js + language switch |
| 2.8   | 0.2.0-alpha.8   | Wayland virtual cursor ✦                   | Корректный курсор без hover-слоя |
| 2.9   | 0.2.9-alpha     | Alpha freeze + visual polish pass          | Milestone exit |

**Exit criteria Alpha:**
- Все основные визуальные элементы оригинала присутствуют
- Анимации работают
- 3 языка
- Wayland cursor корректен
- Login + power/reboot работают

---

### Phase 3 — Beta
**Version:** `0.3.0-beta` → `0.5.x-beta`  
**Goal:** Паритет X11/Wayland, fingerprint, полная i18n, устранение hover-bug, polish.

| Stage | Version         | Focus                                      | Key deliverables |
|-------|-----------------|--------------------------------------------|------------------|
| 3.1   | 0.3.0-beta.1    | Full language set (9 languages)            | en, uk, ru, de, fr, es, it, ko, zh |
| 3.2   | 0.3.0-beta.2    | Language persistence                       | localstorage или theme.conf |
| 3.3   | 0.3.0-beta.3    | X11 hover / dropdown hit-testing fix       | Надёжные меню на X11 |
| 3.4   | 0.3.0-beta.4    | Fingerprint sensor hint + success burst    | fpState support |
| 3.5   | 0.4.0-beta.1    | Ring squeeze on password focus             | Микро-взаимодействие |
| 3.6   | 0.4.0-beta.2    | Error shake + improved feedback            | Визуальный отклик на ошибки |
| 3.7   | 0.4.0-beta.3    | Light theme mode                           | isLight + theme.conf |
| 3.8   | 0.4.0-beta.4    | HiDPI & multi-monitor sanity               | Проверка 2×/3×, разные aspect ratios |
| 3.9   | 0.5.0-beta.1    | Performance pass (timer, effects)          | clockAwake, reduce overdraw |
| 3.10  | 0.5.9-beta      | Beta freeze                                | Milestone exit |

**Exit criteria Beta:**
- Стабильная работа на Wayland **и** X11
- Все 9 языков
- Fingerprint support (shim)
- Нет известных критических hover/click багов
- Light/Dark режимы

---

### Phase 4 — Release Candidate
**Version:** `0.9.0-rc.1` → `0.9.x-rc`  
**Goal:** Packaging, документация, полный QA, подготовка к 1.0.

| Stage | Version       | Focus                                      | Key deliverables |
|-------|---------------|--------------------------------------------|------------------|
| 4.1   | 0.9.0-rc.1    | PKGBUILD + install scripts final           | Чистая установка/удаление |
| 4.2   | 0.9.0-rc.2    | Full documentation (README, troubleshooting)| Пользовательская документация |
| 4.3   | 0.9.0-rc.3    | CI completeness + checksums                | verify-theme.sh 100% |
| 4.4   | 0.9.0-rc.4    | Visual regression checklist                | Ручной + скриншот QA |
| 4.5   | 0.9.0-rc.5    | Accessibility pass (contrast, focus)       | Базовая a11y |
| 4.6   | 0.9.9-rc      | RC freeze                                  | Готово к Stable |

**Exit criteria RC:**
- `makepkg` / `install.sh` работают идеально
- Документация полная
- Нет open critical bugs
- QA checklist закрыт

---

### Phase 5 — Stable
**Version:** `1.0.0`  
**Goal:** Production release.

| Stage | Version | Focus                    | Key deliverables          |
|-------|---------|--------------------------|---------------------------|
| 5.1   | 1.0.0   | First stable release     | Tag, announcement, AUR    |
| 5.2   | 1.0.x   | Hotfixes                 | Только bugfixes           |
| 5.3   | 1.1.0+  | Minor features           | Новые языки, мелкие UX    |

---

## 4. Parallel Workstreams (после MVP)

- **Visual design** — точная калибровка размеров, opacities, easing (по UI Spec оригинала)
- **Platform** — Wayland / X11 parity
- **i18n** — расширение языков
- **Packaging** — Arch/CachyOS, возможно Flatpak/AppImage later (низкий приоритет)
- **Testing harness** — mock sddm + automated visual checks

---

## 5. Success Metrics (Stable 1.0)

- [ ] Работает из коробки на CachyOS (Niri / Noctalia / Hyprland / KDE)
- [ ] Время до интерактивности < 400 ms
- [ ] 0 крашей за 100 логинов
- [ ] Hover/click на всех dropdown’ах работают на X11 и Wayland
- [ ] 9 языков без missing strings
- [ ] Полностью оффлайн install
- [ ] Документация позволяет новичку установить за < 5 минут

---

*Onyx Roadmap · v0.1.0 · 2026-09-08*
