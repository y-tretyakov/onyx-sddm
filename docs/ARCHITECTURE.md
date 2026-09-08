# Onyx — Architecture Document

**Project:** Onyx SDDM Theme  
**Codename:** Onyx (formerly Ryoku / clockwork/orbital)  
**Type:** Qt6 / QML greeter theme for SDDM  
**Target platforms:** Arch Linux / CachyOS (Wayland primary via Weston kiosk, X11 secondary)  
**Version of this document:** 0.2.2 · 2026-09-08  

---

## 1. Vision & Design Principles

Onyx — это полный redesign экрана входа с нуля, сохраняющий **визуальный язык** оригинального orbital/clockwork дизайна:

- Две орбитали (минуты + секунды) вокруг цифровых часов
- Центральный indicator-pill
- Login-панель (user / session / password)
- HUD (power, reboot, language, session picker)
- Характерные анимации (windup → boom, sparks, tick-feedback, spotlight)

Принципы:

1. **Component-based core** — логика и визуал разбиты на независимые QML-компоненты. `Main.qml` только собирает и связывает.
2. **Responsive scale** — всё масштабируется от `Screen.height / 768`.
3. **Zero external runtime deps** кроме SDDM + Qt6 (declarative, 5compat, svg).
4. **Wayland-first** — корректный виртуальный курсор ✦, отсутствие hover-слоя, который ворует события.
5. **Offline-first** — тема полностью вендорится, install/uninstall не требует сети.
6. **Graceful degradation** — работает в preview-режиме через Qt6 `qml6`/`qml` без `sddm` объекта.
7. **Multilingual by design** — 9+ языков из коробки, auto-detect + manual override.
8. **Clear ownership** — каждый компонент имеет одну ответственность и минимальный публичный API.

---

## 2. High-level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    SDDM Greeter Process                     │
│  (sddm-greeter-qt6 / weston kiosk on Wayland)               │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                     Onyx Theme                              │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  Main.qml  (root, composition only)                   │  │
│  │                                                       │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌───────────────┐  │  │
│  │  │  ClockRoot  │  │ LoginPanel  │  │     Hud       │  │  │
│  │  └─────────────┘  └─────────────┘  └───────────────┘  │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌───────────────┐  │  │
│  │  │  AnimEngine │  │ VirtualCursor│  │   Overlays    │  │  │
│  │  └─────────────┘  └─────────────┘  └───────────────┘  │  │
│  │  ┌─────────────────────────────────────────────────┐  │  │
│  │  │         ThemeState + i18n (translations.js)     │  │  │
│  │  └─────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────┘  │
│  Assets: font/, icons/, theme.conf, metadata.desktop        │
└─────────────────────────────────────────────────────────────┘
```

### 2.1 Subsystems → Components mapping

| Subsystem              | Primary component(s)                          | Responsibility |
|------------------------|-----------------------------------------------|----------------|
| **Clocking**           | `ClockRoot`, `OrbitalRing`, `IndicatorPill`, `DateReveal` | Орбитали, часы, pill, дата |
| **Login UI**           | `LoginPanel`, `UserPicker`, `SessionPicker`, `PasswordField`, `FingerprintHint` | Вход, выбор пользователя/сессии |
| **HUD**                | `Hud`, `PowerControls`, `LanguageSelector`    | Power/Reboot, язык, статус |
| **Animation Engine**   | `AnimEngine` (+ signals/properties)           | Windup, boom, sparks, tick feedback, squeeze, shake |
| **i18n & State**       | `ThemeState.qml` + `translations.js`          | Язык, цвета, глобальный state |
| **Platform adapters**  | `VirtualCursor`, platform helpers in Main     | Wayland cursor, SDDM vs preview |

---

## 3. File Structure (target)

```
onyx-sddm/
├── docs/
│   ├── ARCHITECTURE.md
│   ├── ROADMAP.md
│   ├── AGENTS.md
│   ├── SPECS/
│   │   ├── 00-mvp.md
│   │   ├── 01-alpha.md
│   │   ├── 02-beta.md
│   │   ├── 03-rc.md
│   │   └── 04-stable.md
│   └── troubleshooting.md
├── theme/
│   └── onyx/
│       ├── Main.qml                 # Только composition + wiring
│       ├── ThemeState.qml           # Глобальный state, цвета, scale, i18n bindings
│       ├── translations.js          # Словари + detectLanguage()
│       ├── metadata.desktop
│       ├── theme.conf
│       ├── PROVENANCE.txt
│       ├── preview.png
│       │
│       ├── components/
│       │   ├── clock/
│       │   │   ├── ClockRoot.qml
│       │   │   ├── OrbitalRing.qml      # Переиспользуемое кольцо (min / sec)
│       │   │   ├── IndicatorPill.qml
│       │   │   └── DateReveal.qml
│       │   ├── login/
│       │   │   ├── LoginPanel.qml
│       │   │   ├── UserPicker.qml
│       │   │   ├── SessionPicker.qml
│       │   │   ├── PasswordField.qml
│       │   │   └── FingerprintHint.qml
│       │   ├── hud/
│       │   │   ├── Hud.qml
│       │   │   ├── PowerControls.qml
│       │   │   └── LanguageSelector.qml
│       │   ├── effects/
│       │   │   ├── AnimEngine.qml
│       │   │   ├── Sparks.qml
│       │   │   └── Burst.qml
│       │   └── platform/
│       │       └── VirtualCursor.qml
│       │
│       ├── font/
│       │   └── Outfit-Black.ttf
│       └── icons/
│           ├── power.svg
│           └── reboot.svg
│
├── scripts/
│   ├── verify-theme.sh
│   └── checksums.sha256
├── install.sh
├── uninstall.sh
├── validate.sh
├── PKGBUILD
├── onyx-sddm-theme.install
├── README.md
├── NOTICE
└── .github/workflows/ci.yml
```

---

## 4. Component Design Rules

1. **Main.qml** — только создаёт и связывает компоненты. Минимум логики.
2. Каждый компонент:
   - Имеет чёткий публичный API (properties + signals)
   - Не лезет в чужие внутренности
   - Получает `scale` (`s`) и нужные куски state снаружи
3. **ThemeState.qml** — единый источник правды:
   - `s` (scale)
   - цвета (`bgColor`, `mainText`, …)
   - время (`curH`, `curM`, `curS`, `curMS`)
   - язык (`language`, `curT`)
   - флаги (`isWayland`, `clockAwake`, `isLight`, …)
4. Анимации централизованы в `AnimEngine` или поднимаются через signals, чтобы не дублировать Timers.
5. Dropdown/menus должны быть самодостаточными и корректно работать и на X11, и на Wayland (см. риски).

---

## 5. Core Technical Decisions

### 5.1 Scaling

The scale factor is calculated only by the visual root:

```qml
readonly property real s: Screen.height / 768
```

`Main.qml` owns the screen-derived scale.

`ThemeState` receives `s` from the root and exposes it as global theme state.

Visual components receive the scale through composition/state and must not independently calculate screen scale.

### 5.2 Time source

- 16 ms Timer (≈60 fps) только пока `clockAwake === true`.
- `clockAwake` = Window.active **или** fingerprint shim active.

### 5.3 Cursor strategy

- **Wayland:** `VirtualCursor.qml`, привязка к `Window.window.cursorPosition` без Behavior.
- **X11:** нативный курсор, виртуальный скрыт.
- Никакого полноэкранного hover-слоя.

### 5.4 Authentication flow

1. Выбор user / session / language.
2. Ввод пароля (или fingerprint / FIDO).
3. `sddm.login(username, password, sessionIndex)`.
4. Feedback через signals → Overlays / AnimEngine.

### 5.5 Internationalization

- `translations.js` + bindings в `ThemeState`.
- Fallback: explicit choice → system locale → `"en"`.
- Persistence: `Qt.labs.localstorage` или theme.conf.

### 5.6 Color system

Все цвета вычисляются в `ThemeState` из `theme.conf` + `isLight`.

---

## 6. Logical Component Tree

```
Main.qml
├── ThemeState                          (global state)
├── background
├── ClockRoot
│   ├── digital hours
│   ├── IndicatorPill
│   ├── OrbitalRing (minutes)
│   ├── OrbitalRing (seconds)
│   ├── DateReveal
│   └── Sparks / Burst (via AnimEngine)
├── LoginPanel
│   ├── UserPicker
│   ├── SessionPicker
│   ├── PasswordField
│   └── FingerprintHint
├── Hud
│   ├── LanguageSelector
│   └── PowerControls
├── VirtualCursor                       (Wayland only)
├── AnimEngine
└── Overlays (access granted/denied, errors…)
```

---

## 7. External Interfaces

| Interface              | Source                  | Usage                                      |
|------------------------|-------------------------|--------------------------------------------|
| `sddm`                 | SDDM greeter            | login(), powerOff(), reboot(), hostName…  |
| `userModel`            | SDDM                    | list of users                              |
| `sessionModel`         | SDDM                    | list of sessions                           |
| `config`               | theme.conf              | read-only theme settings                   |
| `Window.window`        | Qt Quick                | cursorPosition, active                     |
| `Screen`               | Qt Quick                | width / height for scaling                 |
| `Qt.locale()`          | Qt                      | language auto-detect                       |

---

## 8. Known Constraints & Risks

1. **X11 hover bug** на dropdown-ах — требует аккуратного z-order и hit-testing.
2. **Wayland cursor** — нельзя использовать полноэкранный hover-слой.
3. **Fingerprint** props существуют только в lock-shim.
4. **CJK / Arabic** — system font fallback.
5. **HiDPI** — всё через `s`, проверять 2×/3×.
6. **Import paths** — компоненты должны корректно резолвиться и в greeter, и в preview (`qml6` / `qml`).

---

## 9. Development & Testing Strategy

- **Preview:** `qml6` / `qml` с mock `sddm`.
- **Real greeter:** `sddm-greeter-qt6 --test-mode` или VT / spare X display.
- **CI:** validate.sh + checksums + qml syntax check.
- **Visual regression:** screenshot-based (будущее).

---

## 10. Licensing & Provenance

- Theme code: **GPL-3.0**
- Original visual design inspiration: Darkkal44 (qylock) → Ryoku
- New project starts from clean architecture; visual language preserved by design decision, not by code copy.

---

*Onyx Architecture · v0.2.0 · 2026-09-08 · Component-based*
