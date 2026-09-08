# Onyx — Detailed Specs: Alpha (0.2.x-alpha)

**Milestone:** Alpha  
**Version range:** 0.2.0-alpha.1 → 0.2.9-alpha  
**Goal:** Полный визуальный язык оригинального orbital/clockwork дизайна + базовая многоязычность + Wayland cursor.

---

## Global Constraints for Alpha

- Используем component-based структуру (Main.qml + components/* + translations.js).
- Все размеры через `s`.
- Анимации должны уважать `clockAwake`.
- Dropdown’ы можно сделать упрощёнными (ещё не финальный hit-testing fix).

---

## Stage 2.1 — Windup → Boom Sequence  
**Version:** `0.2.0-alpha.1`

### Requirements

1. При появлении greeter’а:
   - `windupOffset` анимируется 0 → 150000 за ~1600 ms (`Easing.InQuint`).
   - Орбитали «заводятся».
2. После windup — boom (scale + opacity flash).
3. Затем fade-in UI (`uiOpacity` 0 → 1).

### Acceptance

- [ ] Запуск greeter’а выглядит «механически» — орбитали раскручиваются.
- [ ] Нет дёрганья на 60 fps.

---

## Stage 2.2 — Tick Feedback (flash + halo)  
**Version:** `0.2.0-alpha.2`

### Requirements

1. При смене минуты (`onCurMChanged`):
   - `tickFlash` → краткая вспышка opacity/scale major-тиков.
   - `tickHaloR` + `tickHaloOpacity` — расширяющийся ореол.
2. Длительность ≈ 300–500 ms.

### Acceptance

- [ ] Каждая новая минута «откликается» визуально.
- [ ] Ореол не перекрывает login panel / HUD.

---

## Stage 2.3 — Sparks + Bursts  
**Version:** `0.2.0-alpha.3`

### Requirements

1. Spark particles (небольшой Repeater) при определённых событиях.
2. `secBurst` / `minBurst` / `hourBurst` — краткий всплеск цифры.
3. `sparkIntensity` + life-fade.

### Acceptance

- [ ] Искры появляются и красиво исчезают.
- [ ] Burst на смене секунды/минуты/часа ощущается.

---

## Stage 2.4 — Date + Weekday Reveal  
**Version:** `0.2.0-alpha.4`

### Requirements

1. Дата и день недели появляются staggered (посимвольно или с задержкой).
2. Мягкий blur → sharp (`dateBlurR`).
3. Один раз при старте (после boom).

### Acceptance

- [ ] Дата «собирается» элегантно.
- [ ] Не мешает основным элементам.

---

## Stage 2.5 — User & Session Pickers  
**Version:** `0.2.0-alpha.5`

### Requirements

1. Два dropdown’а (user + session).
2. Используют `userModel` / `sessionModel`.
3. Базовый MouseArea + ListView / Column.
4. Выбранные значения влияют на `sddm.login(...)`.

### Acceptance

- [ ] Можно выбрать пользователя и сессию.
- [ ] Login использует выбранные значения.

---

## Stage 2.6 — HUD (Power / Reboot)  
**Version:** `0.2.0-alpha.6`

### Requirements

1. Кнопки Power Off и Reboot (иконки SVG).
2. Вызов `sddm.powerOff()` / `sddm.reboot()`.
3. Расположение в HUD-зоне (обычно справа / снизу справа).

### Acceptance

- [ ] Кнопки работают.
- [ ] Есть hover-состояние.

---

## Stage 2.7 — i18n Core (en + ru + uk)  
**Version:** `0.2.0-alpha.7`

### Requirements

1. `translations.js` с тремя языками.
2. Auto-detect через `Qt.locale().name`.
3. Language selector в HUD (простой).
4. Все user-facing строки через `curT[...]`.

### Acceptance

- [ ] Переключение языка меняет все строки.
- [ ] Fallback на English работает.

---

## Stage 2.8 — Wayland Virtual Cursor ✦  
**Version:** `0.2.0-alpha.8`

### Requirements

1. Виртуальный курсор только на Wayland.
2. Привязка к `Window.window.cursorPosition` **без** Behavior (или ≤ 16 ms).
3. Никакого полноэкранного hover-слоя.
4. На X11 — нативный курсор, виртуальный скрыт.

### Acceptance

- [ ] На Wayland курсор ✦ следует за мышью мгновенно.
- [ ] Hover/click на UI-элементах работают с первого касания.

---

## Stage 2.9 — Alpha Freeze  
**Version:** `0.2.9-alpha`

### Checklist

- [ ] Все stages 2.1–2.8 закрыты.
- [ ] Визуальный язык соответствует оригинальному orbital/clockwork.
- [ ] 3 языка работают.
- [ ] Wayland cursor корректен.
- [ ] Visual QA на основных разрешениях.
- [ ] Нет регрессий логина.

**После freeze:** переход к Beta.

---

*Spec · Alpha · Onyx · 2026-09-08*
