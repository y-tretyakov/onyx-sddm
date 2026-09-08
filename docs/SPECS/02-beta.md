# Onyx — Detailed Specs: Beta (0.3.x – 0.5.x-beta)

**Milestone:** Beta  
**Version range:** 0.3.0-beta.1 → 0.5.9-beta  
**Goal:** Паритет X11/Wayland, полная i18n, fingerprint, устранение hover-bug, light theme, performance.

---

## Stage 3.1 — Full Language Set  
**Version:** `0.3.0-beta.1`

### Requirements

Языки: `en, uk, ru, de, fr, es, it, ko, zh` (9 штук).

- Все строки в `translations.js`.
- CJK идут через system font fallback.
- Language selector показывает native names.

### Acceptance

- [ ] Каждый язык полностью переведён (нет missing keys).
- [ ] Переключение мгновенное.

---

## Stage 3.2 — Language Persistence  
**Version:** `0.3.0-beta.2`

### Requirements

1. Выбор языка сохраняется между сессиями.
2. Предпочтительный способ: `Qt.labs.localstorage`.
3. Fallback: чтение/запись через install-time default в `theme.conf`.

### Acceptance

- [ ] После ребута выбранный язык остаётся.

---

## Stage 3.3 — X11 Hover / Dropdown Hit-testing Fix  
**Version:** `0.3.0-beta.3`

### Requirements (критично)

Это был главный баг предыдущей итерации.

1. Dropdown’ы (language, user, session) должны корректно получать `containsMouse` / `onEntered` / `onClicked` на **X11**.
2. Нельзя использовать полноэкранный hover-слой.
3. Возможные подходы:
   - Тщательный z-order + `z` на меню выше всего.
   - `MouseArea` только на реальной геометрии пунктов.
   - Избегать overlapping transparent items.
   - При необходимости — custom hit-testing через `mapToItem`.

### Acceptance

- [ ] На X11 можно открыть любой dropdown и выбрать любой пункт с первого раза.
- [ ] Нет «мёртвых» зон.
- [ ] На Wayland поведение не деградировало.

---

## Stage 3.4 — Fingerprint Sensor Hint + Success Burst  
**Version:** `0.3.0-beta.4`

### Requirements

1. Поддержка props из lock-shim:
   - `sddm.fingerprintHint`
   - `sddm.fingerprintReady`
   - `sddm.fingerprintState` (`idle` / `success` / …)
2. UI hint появляется только когда props существуют.
3. При `success` — radial spark burst.

### Acceptance

- [ ] В чистом SDDM greeter hint невидим (graceful).
- [ ] В shim — работает и даёт feedback.

---

## Stage 3.5 — Ring Squeeze on Password Focus  
**Version:** `0.4.0-beta.1`

### Requirements

При фокусе на поле пароля (или первом символе) орбитали слегка сжимаются (`ringScale` 1.0 → 0.97 → 1.0).

### Acceptance

- [ ] Ощущение, что «механизм слушает».

---

## Stage 3.6 — Error Shake + Improved Feedback  
**Version:** `0.4.0-beta.2`

### Requirements

1. При `LoginFailed` — короткий shake поля ввода / pill (`jitterX/Y`).
2. Улучшенный текст ошибки (красный, с иконкой если нужно).

### Acceptance

- [ ] Ошибка пароля ощущается физически.

---

## Stage 3.7 — Light Theme Mode  
**Version:** `0.4.0-beta.3`

### Requirements

1. `themeMode=light|dark` в `theme.conf`.
2. Все цвета пересчитываются через `isLight`.
3. Контраст колец и текста достаточный в обоих режимах.

### Acceptance

- [ ] Переключение light/dark работает без перезапуска greeter (или с минимальным).

---

## Stage 3.8 — HiDPI & Multi-monitor Sanity  
**Version:** `0.4.0-beta.4`

### Requirements

1. Проверка на 2× и 3× scaling.
2. Корректное поведение при разных aspect ratio (ultrawide, 16:10, 4:3).
3. Primary screen only (SDDM greeter обычно один).

### Acceptance

- [ ] На 4K @ 2× всё выглядит sharp и правильно масштабировано.

---

## Stage 3.9 — Performance Pass  
**Version:** `0.5.0-beta.1`

### Requirements

1. `clockAwake` строго соблюдается.
2. Минимум overdraw.
3. Effects (blur, glow) не убивают FPS на слабом GPU.
4. Timer 16 ms только когда нужен.

### Acceptance

- [ ] Idle greeter почти не грузит CPU.
- [ ] 60 fps на анимациях.

---

## Stage 3.10 — Beta Freeze  
**Version:** `0.5.9-beta`

### Checklist

- [ ] X11 и Wayland паритет.
- [ ] 9 языков + persistence.
- [ ] Fingerprint support.
- [ ] Light/Dark.
- [ ] Нет критических hover-багов.
- [ ] Performance acceptable.

**После freeze:** переход к RC.

---

*Spec · Beta · Onyx · 2026-09-08*
