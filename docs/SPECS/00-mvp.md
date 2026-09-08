# Onyx — Detailed Specs: MVP (0.1.x-mvp)

**Milestone:** MVP  
**Version range:** 0.1.0-mvp → 0.1.9-mvp  
**Goal:** Минимально жизнеспособный greeter с двумя орбиталями, цифровыми часами и работающим логином.

---

## Global Constraints for MVP

- Только Wayland (Weston kiosk) как primary target.
- Никакой i18n (hardcoded English / Russian labels ok).
- Никаких dropdown-меню (user/session — пока фиксированные или самые простые).
- Никаких fingerprint / FIDO.
- Никаких сложных анимаций (windup/boom/sparks — только базовая fade-in).
- Component-based structure (Main.qml + components/*).
- Scale factor `s = Screen.height / 768` обязателен с первого коммита.

---

## Stage 1.1 — Root + Scaling + Background  
**Version:** `0.1.0-mvp`

### Requirements

1. `Main.qml` — root composition (Rectangle) + подключение ThemeState и компонентов.
2. Свойство:
   ```qml
   readonly property real s: Screen.height / 768
   ```
3. Цвет фона из `theme.conf` или hardcode `#000000`.
4. `metadata.desktop` и `theme.conf` существуют и корректны.
5. Тема устанавливается через `install.sh` (даже если пока stub).

### Acceptance

- [ ] `sddm-greeter-qt6 --test-mode` показывает чёрный (или цветной) полный экран.
- [ ] Нет QML errors в journal.

---

## Stage 1.2 — Digital Clock + Indicator Pill  
**Version:** `0.1.1-mvp`

### Requirements

1. Центральный контейнер часов (`clockContainer`).
2. Большие цифры часов (`curH`) — `Font.Black`, размер ≈ `110 * s`.
3. Indicator-pill справа от часов:
   - Размер ≈ 330×90 (× s)
   - Левая половина — минуты (или пусто)
   - Правая половина — секунды
4. Время обновляется хотя бы раз в секунду (можно простой Timer 1000 ms).

### Acceptance

- [ ] Часы показывают актуальное время.
- [ ] Pill виден и содержит минуты/секунды.
- [ ] Всё масштабируется на 1080p и 1440p.

---

## Stage 1.3 — Minute Orbital  
**Version:** `0.1.2-mvp`

### Requirements

1. `Repeater` из 60 элементов (минуты).
2. Каждый элемент — тик + число (для major).
3. Major ticks: `index % 5 === 0`.
4. Spotlight / highlight текущей минуты:
   - Увеличенный размер шрифта
   - Более высокая opacity
5. Радиус кольца ≈ `320 * s`.
6. Угол: `index * 6°` с нормализацией.

### Visual rules (preserve original language)

| Element          | Base size     | Spotlight peak |
|------------------|---------------|----------------|
| Major minute     | ~22–26 * s    | ~58 * s        |
| Minor minute     | ~15 * s       | —              |
| Tick length      | visual only   | —              |

### Acceptance

- [ ] 60 тиков равномерно расположены по кругу.
- [ ] Текущая минута визуально выделена (spotlight).
- [ ] При смене минуты highlight перемещается.

---

## Stage 1.4 — Second Orbital (smooth)  
**Version:** `0.1.3-mvp`

### Requirements

1. Второе кольцо (меньше радиус, ≈ `260–280 * s`).
2. 60 тиков секунд.
3. Плавное движение через 16 ms Timer + `curMS`.
4. `clockAwake` логика уже желательна (но можно упростить).

### Acceptance

- [ ] Секундная стрелка/тики плавно движутся.
- [ ] Нагрузка на CPU приемлема (не 100% на одном ядре).

---

## Stage 1.5 — Minimal Login Panel  
**Version:** `0.1.4-mvp`

### Requirements

1. Поле пароля (`TextInput` / `TextField`).
2. Кнопка или Enter → `sddm.login(username, password, sessionIndex)`.
3. Username можно hardcode первого пользователя или взять `userModel.lastIndex`.
4. Session — `sessionModel.lastIndex`.

### Acceptance

- [ ] Можно ввести пароль и успешно залогиниться.
- [ ] При ошибке — хотя бы текстовое сообщение.

---

## Stage 1.6 — Basic Auth Feedback  
**Version:** `0.1.5-mvp`

### Requirements

1. Текст «ACCESS GRANTED ✦» / «ACCESS DENIED ✦».
2. Простая fade-анимация появления.
3. При ошибке — краткое красное сообщение.

### Acceptance

- [ ] Feedback виден при успехе и неудаче.

---

## Stage 1.7 — MVP Freeze  
**Version:** `0.1.9-mvp`

### Checklist

- [ ] Все stages 1.1–1.6 закрыты.
- [ ] Visual QA на 1920×1080 и 2560×1440.
- [ ] `validate.sh` и `verify-theme.sh` проходят.
- [ ] README содержит инструкцию «как поставить MVP».
- [ ] Нет известных крашей.

**После freeze:** переход к Alpha (0.2.0-alpha.1).

---

*Spec · MVP · Onyx · 2026-09-08*
