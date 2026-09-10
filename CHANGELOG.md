# Onyx — Changelog

> Единый учёт версий и этапов Onyx. Правила ведения: `AGENTS.md` §3.1–3.2.
> Формат: «сверху вниз», новая версия выше предыдущих. Историю не переписываем.

---

## [0.2.0-alpha.4] — stage 2.4 · Date + Weekday Reveal · 2026-09-10

**Версия:** `0.2.0-alpha.4` — PATCH-bump внутри milestone Alpha (stage, не веха).
Тег/release НЕ ставились (релиз-тег Alpha — на freeze 2.9).

### Тик-лист ROADMAP (Phase 2 — Alpha)

- [x] 2.1 Windup → boom sequence — `0.2.0-alpha.1`
- [x] 2.2 Tick feedback (flash + halo) — `0.2.0-alpha.2`
- [x] 2.3 Sparks + sec/min/hour bursts — `0.2.0-alpha.3`
- [x] 2.4 Date + weekday reveal — `0.2.0-alpha.4` ✅ THIS
- [ ] 2.5 User & Session pickers — `0.2.0-alpha.5`
- [ ] 2.6 HUD (power / reboot) — `0.2.0-alpha.6`
- [ ] 2.7 i18n core (en + ru + uk) — `0.2.0-alpha.7`
- [ ] 2.8 Wayland virtual cursor ✦ — `0.2.0-alpha.8`
- [ ] 2.9 Alpha freeze — `0.2.9-alpha`

### Статус и следующий шаг

- Сделано: **stage 2.4 — Date + Weekday Reveal** закрыт. Дата и день недели
  собираются посимвольно сразу после ветрапа (один раз при старте, после boom и
  fade-in): `AnimEngine.fadeInFinished` (новый сигнал) → `Main`
  `onFadeInFinished: clock.startDateReveal()` → `ClockRoot.startDateReveal()` →
  `DateBlock.startReveal()`. StaggerText — переиспользуемый per-char ревил
  (master progress NumberAnimation, duration `320 + len*28`, per-char
  opacity/scale/translateY через easedFor с easeOutBack c1=1.70158; charW =
  `stPixelSize*0.72`, шрифт из `themeState.fontFamily`). Дата стартует сразу
  (`dateAnimActive`), день недели — через `weekdayDelayTimer` 420ms
  (`weekdayAnimActive`); вся пара строк мягко blur→sharp: `dateBlurR` 7→0 за
  800ms через GaussianBlur (samples 16) на двух per-line Item layer-слоях.
  Закрыт follow-up ревью 2.3 **F-2.4-1**: `Burst.pixelSize` параметром — sec
  30·s / min 54·s / hour 110·s (30·s остаётся дефолтом компонента).
  gate-прогоны: validate exit 0, smoke exit 0, windup-probe exit 0,
  tickfeedback-probe exit 0, sparks-burst-probe exit 0, date-reveal-probe
  exit 0, verify-theme.sh exit 0 (секции 1–11).
- Следующее: **stage 2.5 — User & Session pickers** (`0.2.0-alpha.5`).
- Подготовить до старта 2.5: визуальная QA date reveal на 1080p/1440p
  (см. Тех. долг); переносится долг CR-F9/CR-F10/F-1.4-b.
- Блокеры: нет.

### Детали изменений (для агентов)

- НОВЫЙ `theme/onyx/components/effects/StaggerText.qml` — per-char reveal.
  required `text`/`s`/`themeState`; `stPixelSize` (default `13*s`),
  `stLetterSpacing`, `stColor`, `stWeight`, `staggerActive`, `progress`; readonly
  `charW = stPixelSize*0.72`, `stDuration = 320 + text.length*28`. На
  `staggerActive` → `progress=0`, restart master (`StaggerText.qml:30-36`).
  `easedFor(i)` — easeOutBack (c1=1.70158, `1 + c3*(raw-1)^3 + c1*(raw-1)^2`),
  на прогресс мапается `t*(N+1)` (`StaggerText.qml:41-49`). Row+Repeater:
  `opacity: e`, `scale: 1-(1-e)*0.08`, `Translate.y: (1-e)*stPixelSize*0.8`
  (`StaggerText.qml:55-73`). Импорт `"../.."` — берёт `themeState` напрямую,
  без root-скоупа.
- `theme/onyx/components/effects/qmldir` — `StaggerText 1.0 StaggerText.qml`.
- `theme/onyx/components/clock/DateBlock.qml` — переписан на StaggerText
  (`DateBlock.qml:3-4` импорт `Qt5Compat.GraphicalEffects` + `"../effects"`).
  Публичные props: `dateAnimActive`/`weekdayAnimActive`/`dateBlurR`
  (`DateBlock.qml:11-13`); `startReveal()` (`DateBlock.qml:27-31`) — `dateBlurR=7`,
  `dateAnimActive=true`, `dateBlurAnim.restart()` (from:7→to:0, 800ms),
  `weekdayDelayTimer.restart()` (420ms). Две строки обёрнуты в Item с
  `layer.enabled: dateBlurR>0.01` + `layer.effect: GaussianBlur{radius: dateBlurR;
  samples: 16}` (per-line, `DateBlock.qml:43-50,63-70`). Дата: 13·s subColor,
  ls 4·s (`stLetterSpacing`); weekday: 18·s mainText Bold, ls 8·s.
  `width: Math.max(dW.implicitWidth, wW.implicitWidth)`,
  `height: dW.height + wW.height + 5*s` — не изменены.
- `theme/onyx/components/effects/AnimEngine.qml:17` — `signal fadeInFinished`;
  emit в `_tick()` фаза 2, когда `fdt >= fadeInDuration`, после `uiOpacity = 1`,
  перед `isWindup = false` (`AnimEngine.qml:96-97`).
- `theme/onyx/components/clock/ClockRoot.qml:12` — `property alias dateBlock:
  dateBlk`; `function startDateReveal() { dateBlk.startReveal() }`
  (`ClockRoot.qml:136`). Три `Effects.Burst` получили `pixelSize`: sec
  `30*clockRoot.s`, min `54*clockRoot.s`, hour `110*clockRoot.s`.
- `theme/onyx/components/effects/Burst.qml:12` — `property real pixelSize:
  30*burst.s` (F-2.4-1); оба Text используют `burst.pixelSize`.
- `theme/onyx/Main.qml:31` — `onFadeInFinished: clock.startDateReveal()`.
- НОВЫЙ `scripts/qa/date-reveal-probe.qml` — poll-based (offscreen render loop
  лагает NumberAnimation и 420ms-таймер против валл-тайма, как в 2.3).
  В `Component.onCompleted`: заморозка живых ticker'ов, ручной
  `clockRoot.startDateReveal()`. Фаза 1 (poll до 500ms): `dateAnimActive` +
  `dateBlurR > 0` + гейт `!weekdayAnimActive` (weekday ещё не стартовал);
  фаза 2 (poll до 2s): `weekdayAnimActive === true` (420ms-задержка отдала);
  фаза 3 (poll до 3s): `dateBlurR === 0` && `dateAnimActive`. Контракт:
  exit 0 = `DATE-REVEAL-PROBE: OK` / exit 1 = `FAIL: <reason>`.
- `scripts/verify-theme.sh` — секция 1: +`effects/StaggerText.qml`; секция 10
  «date-reveal-probe» (offscreen, 18s); секция 11 — registration regressions
  (перенумерована из 10).

### Тех. долг

- F-2.4-1 закрыт. Перенос из 2.3: CR-F9 (HiDPI), CR-F10 (greeter-integration),
  F-1.4-b (`pragma ComponentBehavior`), ADR-2.2-2 (boom-scale parity),
  pillWindowHiding defensive на secRing.
- Новый: «GaussianBlur layer на DateBlock — следить за перфомансом на слабых
  GPU в Beta (аналог замечания sparks 60×16ms): 2 Item-слоя активны только пока
  `dateBlurR > 0.01`, после reveal layer отключается».
- Новый: «визуальная QA 1080p/1440p date reveal (посимвольная сборка, blur
  sharpen, задержка weekday) — токен в план Beta». В offscreen-GaussianBlur
  рендерится корректно (smoke + probe стабильны), на реальном GPU не проверяли.

### Принятые решения

- **ADR-2.4-1 (StaggerText — собственный компонент):** per-char reveal вынесен
  в `effects/StaggerText.qml` (не инлайн component как в оригинале) — компонент
  переиспользуем и не зависит от root-скоупа (`themeState` качается через
  required property, импорт `"../.."`). Blur применён на **per-line** Item-слоях,
  а не на Column — приклейка GaussianBlur к двум строкам раздельно, чтобы строки
  не blur-или друг друга через общий слой и чтобы layer включался точечно.

---

## [0.2.0-alpha.3] — stage 2.3 · Sparks + Bursts · 2026-09-10

**Версия:** `0.2.0-alpha.3` — PATCH-bump внутри milestone Alpha (stage, не веха).
Тег/release НЕ ставились (релиз-тег Alpha — на freeze 2.9).

### Тик-лист ROADMAP (Phase 2 — Alpha)

- [x] 2.1 Windup → boom sequence — `0.2.0-alpha.1`
- [x] 2.2 Tick feedback (flash + halo) — `0.2.0-alpha.2`
- [x] 2.3 Sparks + sec/min/hour bursts — `0.2.0-alpha.3` ✅ THIS
- [ ] 2.4 Date + weekday reveal — `0.2.0-alpha.4`
- [ ] 2.5 User & Session pickers — `0.2.0-alpha.5`
- [ ] 2.6 HUD (power / reboot) — `0.2.0-alpha.6`
- [ ] 2.7 i18n core (en + ru + uk) — `0.2.0-alpha.7`
- [ ] 2.8 Wayland virtual cursor ✦ — `0.2.0-alpha.8`
- [ ] 2.9 Alpha freeze — `0.2.9-alpha`

### Статус и следующий шаг

- Сделано: **stage 2.3 — Sparks + Bursts** закрыт. Sparks — частицы
  (`effects/Sparks.qml`, z:50, центр cx/cy): 60 частиц, жизнь 600–1000ms
  OutQuad-fade, позиция по жизни, интенсивность = `Math.max(sparkWindup,
  sparkImpulse)`; в момент каждого burst `sparkBurst++` перезапускает инстанциатор.
  Bursts — клоны цифры (`effects/Burst.qml`, z:20, white + accent 0.65, 30·s
  Bold): scale 1→2.2 450ms OutCubic + opacity 0.9→0 450ms OutQuad
  (ParallelAnimation) для сек (pill.secCenter), минут (pill.minCenter) и часов
  (центр hourText). Триггеры `maybeSecBurst`/`maybeMinBurst`/`maybeHourBurst`
  (dedupe по lastSec/Min/Hour) + `sparkImpulseAnim` 0→0.8 200ms OutCubic → 0
  500ms OutCubic. Гейт `clockAwake`: при `false` все burst-анимации стопятся,
  opacity/sparkImpulse обнуляются, новые burst не стартуют. Секундная орбиталь
  больше НЕ мерцает при смене секунды (только feedback на минуту). Закрыт
  follow-up ревью 2.2 **F-2.3-1** (одинарный гейт triggerTickFeedback,
  tickFlash только на minute ring). gate-прогоны: validate exit 0, smoke exit 0,
  tickfeedback-probe exit 0, sparks-burst-probe exit 0 (6× стабильно),
  verify-theme.sh exit 0 (секции 1–10).
- Следующее: **stage 2.4 — Date + weekday reveal** (`0.2.0-alpha.4`).
- Подготовить до старта 2.4: ADR-2.2-2 (boom-scale parity) — оформить токеном в
  план; проверить визуально sparks/burst на 1440p (плотность частиц, размер
  клона) — зафиксировать в план 2.4 как визуальную QA-задачу.
- Блокеры: нет.

### Детали изменений (для агентов)

- НОВЫЙ `theme/onyx/components/effects/Sparks.qml` — particle-слой (z:50),
  центр `centerX/centerY`, `sparkIntensity` — целевая интенсивность,
  `burstTick` — счётчик рестартов. Логика: Repeater 60 частиц; каждая частица
  имеет скорость/направление от центра, жизнь 600–1000ms; контейнер
  `IntensityGroup` двигает opacity = `sparkIntensity` (capped), на `burstTick`
  частицы перезапускаются с новой случайной скоростью. Формулы распределения —
  своя компонентная реализация в духе эталона (не копия): см.
  `docs/superpowers/plans/2026-09-10-stage-2.3-sparks-bursts.md` №2.
- НОВЫЙ `theme/onyx/components/effects/Burst.qml` — клон цифры. required
  `text`/`s`/`themeState`; ширина/высота 1 (размер числа задаёт clockRoot);
  `z:20`; `visible: opacity > 0.01`; цвет white с под-слоем accent 0.65;
  `font.pixelSize: 30 * s`, Bold, family `themeState.fontFamily`. Позиция/scale/
  opacity управляются снаружи (x/y/scale/opacity) — писать внутрь компонента
  self-binding нельзя (binding loop), см. Note ниже.
- `theme/onyx/components/effects/qmldir` — module Effects: добавлены
  `Sparks 1.0 Sparks.qml`, `Burst 1.0 Burst.qml`.
- `theme/onyx/components/clock/ClockRoot.qml` — триггеры bursts и sparks-веб:
  props (`ClockRoot.qml:22-46`): `sparkWindup`, `sparkBurst: Int`, `sparkImpulse`,
  `lastSec/Min/Hour`, `secBurst{Scale,Opacity,Text,X,Y}`, ...hour...;
  `sparkImpulseAnim` Sequential 0→0.8 200ms OutCubic → 0 500ms OutCubic
  (`ClockRoot.qml:102-106`); три `ParallelAnimation` burst (`108-124`): scale
  1→2.2 450ms OutCubic + opacity 0.9→0 450ms OutQuad (ParallelAnimation, а НЕ
  Sequential — Sequential оставил бы цифру невидимой первые 450ms и сломал бы
  timing probe); `onClockAwakeChanged` (`126-133`) стопает анимации и обнуляет
  opacity/sparkImpulse при `!clockAwake`; `maybeSecBurst/Min/Hour`
  (`143-186`) — гейт `clockRoot.clockAwake`, dedupe по last*, coords через
  `pill.mapToItem(clockRoot, …)` / центр `hourText`, `restart()` анимации +
  `sparkBurst++` + `sparkImpulseAnim.restart()`; `Connections` (`188-193`) на
  `_time.curS/curM/curH` (curM — feedback+burst). `Effects.Sparks`
  (`258-267`): `sparkIntensity: Math.max(sparkWindup, sparkImpulse)`,
  `burstTick: sparkBurst`. Три `Effects.Burst` (`308-336`).
- `theme/onyx/Main.qml` — `clockAwake` (не readonly, ставится из state;
  `clockAwake: state.clockAwake` в Main) + гейт `sparkWindup`:
  `engine.isWindup && windupProgress > 0.2 ? (windupProgress - 0.2) * 2.2 : 0` —
  для sparkIntensity (план хотел `windupProgress` напрямую, но после windup
  прогресс навсегда 1.0; без гейта sparks висели бы на 1.76 вечно).
- `theme/onyx/components/clock/IndicatorPill.qml` — readonly `minCenterX/Y`,
  `secCenterX/Y` (центр блоков минут/секунд pill) для позиционирования burst.
- `theme/onyx/components/clock/OrbitalRing.qml` (ringSec в ClockRoot) — убран
  `tickFlash`-проброс на seconds ring (частично было на 2.2, F-2.3-1 финализирует);
  feedback живёт только на minute ring.
- НОВЫЙ `scripts/qa/sparks-burst-probe.qml` — автономный probe (Window 480x200 +
  ThemeState{s:1} + ClockRoot{s:1, clockAwake:true}). Детерминизм: в
  `Component.onCompleted` стопаются живые тикеры (`timeProvider.clockAwake =
  false`, `timeProvider.tickTimer.stop()`), время гонится вручную curS "01"→"02".
  Poll-based (не жёсткие тайминги — offscreen render loop тормозит NumberAnimation):
  полл «burst стартовал» (opacity>0 && impulse>0, budget 300ms), полл «faded»
  (opacity<0.1 && scale>=2.1 && impulse<0.05, budget 1.5s), затем ручные
  curM="42"/curH="07" → minBurstOpacity>0 && hourBurstOpacity>0 && sparkBurst>=3,
  затем гейт: `clockAwake=false` + curS="03" + `maybeSecBurst()` → opacity и
  impulse <0.01. Контракт: exit 0 = OK / exit 1 = FAIL. Запуск:
  `QT_QPA_PLATFORM=offscreen qml6 scripts/qa/sparks-burst-probe.qml`.
- `scripts/verify-theme.sh` — структура секции 1: +`effects/Sparks.qml`,
  +`effects/Burst.qml`; новая секция 9 «sparks-burst-probe», секция 10 —
  registration regressions (перенумерована из 9).
- Note (почему нет self-binding в Burst): свойства x/y/scale/opacity у Item —
  это встроенные свойства трансформации; привязка `x: burst.x` внутри
  компонента, инстанцированного как `burst.x: …`, образует цикл (сказ.
  binding loop). Правильная структура — позиция/масштаб/прозрачность текут из
  clockRoot (мастер-точка), Burst хранит НЕ клоны этих свойств, а
  семантику (text/s/themeState).

### Тех. долг

- F-2.3-1 закрыт. ADR-2.2-2 (boom-scale parity) — перенесён токеном в план 2.4.
- Визуальная QA на реальном greeter (1080p/1440p): плотность sparks,
  размер/позиция burst-клона, поведение при wake — делать на 2.4 до её кода.
- sparks в state preview (Main.qml вне greeter) — проверить, что при
  `testmode`/темах без runSparks sparks не выстреливают (гейт clockAwake уже
  покрывает lock-сценарий; preview-проверка — часть 2.4 QA).

### Принятые решения

- **Параллельность burst-анимаций (ParallelAnimation) вместо Sequential** из
  снипета плана: эталон и собственный probe-контракт плана требуют одновременного
  скейла и fade (450/450ms). Sequential ломал оба.
- **gate `isWindup`** для `sparkWindup`: `windupProgress` после windup = 1.0
  навсегда; гейт держит sparks-интенсивность честной (0 вне windup).
- **Burst-x/y отказ от self-binding** — см. Note: coords из clockRoot.
- **Poll-based probe**: из-за ограничений offscreen render loop валл-тайм
  и тайминг NumberAnimation расходятся (наблюдалось: opacity>0.1 на 550ms);
  жёсткие тайминги давали флаки (2/6 прогонов). Полл стабилен 6/6.

---

## [0.2.0-alpha.2] — stage 2.2 · Tick Feedback (Flash + Halo) · 2026-09-10

**Версия:** `0.2.0-alpha.2` — PATCH-bump внутри milestone Alpha (stage, не веха).
Тег/release НЕ ставились (релиз-тег Alpha — на freeze 2.9).

### Тик-лист ROADMAP (Phase 2 — Alpha)

- [x] 2.1 Windup → boom sequence — `0.2.0-alpha.1`
- [x] 2.2 Tick feedback (flash + halo) — `0.2.0-alpha.2` ✅ THIS
- [ ] 2.3 Sparks + sec/min/hour bursts — `0.2.0-alpha.3`
- [ ] 2.4 Date + weekday reveal — `0.2.0-alpha.4`
- [ ] 2.5 User & Session pickers — `0.2.0-alpha.5`
- [ ] 2.6 HUD (power / reboot) — `0.2.0-alpha.6`
- [ ] 2.7 i18n core (en + ru + uk) — `0.2.0-alpha.7`
- [ ] 2.8 Wayland virtual cursor ✦ — `0.2.0-alpha.8`
- [ ] 2.9 Alpha freeze — `0.2.9-alpha`

### Статус и следующий шаг

- Сделано: **stage 2.2 — Tick Feedback (flash + halo)** закрыт. При смене минуты
  major-тики обеих орбиталей вспыхивают (`tickFlash` 1→0 за 140ms OutQuad:
  alpha `cap 1.0` +0.55·flash, scale `1+0.04·flash`, spotlight-тики не трогаем),
  вокруг центра циферблата расширяется тонкий бордер-ореол (`tickHaloR`
  `16·s→110·s` за 480ms OutCubic, `tickHaloOpacity` `0.5→0` за 480ms OutQuad,
  border `1.5·s` mainText, z:5, центр cx/cy колец). Всё живёт в ClockRoot
  (владелец minute-триггера), триггер — `onCurMChanged` → `triggerTickFeedback()`
  с гейтом `themeState.clockAwake`. Закрыт follow-up ревью 2.1 **F-2.2-1**:
  `AnimEngine.boomFinished` вместо хрупкой привязки curtain к
  `onUiOpacityChanged`. gate-прогоны: validate exit 0, smoke exit 0, windup-probe
  exit 0, tickfeedback-probe exit 0, verify-theme.sh exit 0 (секции 1–9).
- Следующее: **stage 2.3 — Sparks + sec/min/hour bursts** (`0.2.0-alpha.3`):
  `sparkIntensity`/particle-эффекты в момент feedback.
- Подготовить до старта 2.3: ADR-2.2-2 (boom-scale parity) — оформить токеном
  в план 2.3 или Beta; проверить масштаб ореола на 1440p визуально.
- Блокеры: нет.

### Детали изменений (для агентов)

- `theme/onyx/components/clock/ClockRoot.qml` — владелец tick-фида
  (`ClockRoot.qml:15-17`): `tickFlash` / `tickHaloR` / `tickHaloOpacity` (default 0).
  Анимации `tickFlashAnim` 140ms OutQuad 1→0; `tickHaloAnim` SequentialAnimation
  → `tickHaloR` 16·s→110·s 480ms OutCubic; `tickHaloOpacityAnim` 0.5→0 480ms
  OutQuad (значения из эталона Main.qml:194-201). Публичная точка:
  `triggerTickFeedback()` (`ClockRoot.qml:44-52`) — ранний return если
  `!themeState.clockAwake` (единый источник гейта; preview-safe = true вне
  greeter). Halo-круг (`ClockRoot.qml:112-124`): z:5 (кольца 10, pill 1),
  transparent + border `1.5·s` mainText, `visible: tickHaloOpacity > 0.01`,
  радиус = `tickHaloR`, центр `cx/cy` — ореол не пересекает pill
  (`cx+230·s`) и login-панель (геометрия). Flash подключён в оба OrbitalRing
  (`tickFlash: clockRoot.tickFlash`). Триггер — `Connections { target: _time;
  function onCurMChanged() { clockRoot.triggerTickFeedback() } }`.
- `theme/onyx/components/clock/OrbitalRing.qml` — `property real tickFlash: 0`
  (`OrbitalRing.qml:19`). Тик-Rectangle: opacity `cap 1.0`
  (`spotlight ? 1.0 : min(1.0, base + isMajor·flash·0.55)`), scale
  `isMajor ? 1.0 + flash·0.04 : 1.0` (`OrbitalRing.qml:84-86`) — transformOrigin
  не задаём (дефолт Rectangle = Center). Формулы = оригинал Main.qml:470-471.
- `theme/onyx/components/effects/AnimEngine.qml` — `signal boomFinished`
  (`AnimEngine.qml:15`), emit после `boomScale = 35` в конце boom-фазы
  (`AnimEngine.qml:86-87`) перед `_phase = 2`. F-2.2-1 закрыт.
- `theme/onyx/Main.qml` — curtain: удалён хрупкий блок
  `onUiOpacityChanged { if (uiOpacity === 1.0 && boomOverlay.opacity > 0)
  curtainOut.start() }`; вместо него `onBoomFinished: curtainOut.start()`
  (`Main.qml:26-30`). `curtainOut` target `boomOverlay` без изменений.
- `scripts/qa/windup-probe.qml` — счётчик `boomFinishedCount` + `Connections`
  на `engine.onBoomFinished`; `Timer tBoomBtn` 1850ms → `checkBoomFinished()`
  (`count >= 1`, иначе `WINDUP-PROBE: FAIL: boomFinished not emitted`).
- `scripts/qa/tickfeedback-probe.qml` — НОВЫЙ автономный probe (Window +
  ThemeState{s:1} + ClockRoot{s:1}): ручной вызов `triggerTickFeedback()` в
  `Component.onCompleted`, таймлайн 80/550/700ms (flash>0, haloR>16·s,
  haloOpacity>0 → haloR≥105·s, haloOpacity<0.1, flash<0.05 → flash≈0, haloR≈max,
  haloOpacity≈0). Контракт: exit 0 = OK / exit 1 = FAIL.
- `scripts/verify-theme.sh` — секция 8 «tickfeedback-probe» (offscreen, 12s);
  секция 9 — registration regressions (перенумерована из 8).
- Критично для следующих агентов: гейт clockAwake в probe НЕ тестируется
  (readonly, см. Тех. долг) — покрыт ревью; `tickHaloOpacityAnim` и
  `tickHaloAnim` не имеют `running`-привязки к clockAwake — они инициируются
  только из гейтнутого `triggerTickFeedback()`; AnimEngine остаётся глобальным
  движком стартовой последовательности (вкус фида — НЕ в нём).

### Тех. долг

- 🟡 **CR-F9 (отложено; НЕ трогать сейчас):** `s = Screen.height / 768` — на
  перепроверку stage 3.8 (HiDPI & multi-monitor). Переносится.
- 🟡 **CR-F10 (отложено):** реальный SDDM greeter integration test — на
  пользователе. Переносится.
- 🟡 **F-1.4-b (остаётся):** `pragma ComponentBehavior: Bound` — ждёт Qt ≥6.6
  в CI (unqualified-шум безвреден). Переносится.
- 🟡 **F-2.2-3 (гейт clockAwake вне auto-test):** `triggerTickFeedback()` гейт
  `!themeState.clockAwake` НЕ покрыт probe'ом — `clockAwake` readonly, ломать
  ThemeState ради теста нельзя; покрыт qt-qml-review. Не блокирует acceptance,
  чинится при появлении test-harness с моком ThemeState.
- 🟡 **F-2.2-2 (boom scale parity, из ревью 2.1):** `boomScale 1→35` вычисляется,
  но не применяется к `boomOverlay` (опасити-только). При parity-этапе взять
  scale или зафиксировать. Follow-up в план Beta.
- 🟡 **Перенос из 0.2.0-alpha.1:** `pillWindowHiding: true` на secRing без
  pillWin* (defensive, без визуального эффекта). Переносится.
- **Sparks / `sparkIntensity`** — по плану в 2.3 (ADR-2.2-3 подтверждает).
- Новых долгов stage 2.2, кроме перечисленных, нет.

### Принятые решения

- **ADR-2.2-1 (tick feedback живёт в ClockRoot):** flash/halo-properties и
  триггер — в ClockRoot (владелец minute-триггера `_time` и halo-декорации),
  а не в AnimEngine: это свойство clock-модуля, а не глобальной стартовой
  последовательности. AnimEngine остаётся движком windup/boom/fade-in.
  F-2.2-1 (`boomFinished`) закрыт в 2.2.
- **ADR-2.2-2 (boom — только opacity):** `boomScale 1→35` вычисляется, но не
  применяется (анимация шторки opacity-only). Зафиксировано из замечаний ревью
  2.1; при parity-этапе (Beta) взять scale или зафиксировать (см. Тех. долг).
- **ADR-2.2-3 (sparks → 2.3):** sparks/`sparkIntensity` осознанно вне 2.2 —
  этап 2.2 = flash + halo по спеке; частицы — 2.3 (Sparks + bursts).
- **ADR-2.2-4 (гейт — единый источник):** `themeState.clockAwake` — единственный
  источник для UI-анимаций (`triggerTickFeedback()` гейтится им); двойная
  проверка `&& !_time.clockAwake` в функции — страховка, не второй источник.

---

## [0.2.0-alpha.1] — stage 2.1 · Windup → Boom Sequence · 2026-09-10

**Версия:** `0.2.0-alpha.1` — вход в milestone Alpha (MINOR MVP→Alpha).
Тег/release НЕ ставились — это stage, не веха (релиз-тег Alpha — на freeze 2.9).

### Тик-лист ROADMAP (Phase 2 — Alpha)

- [x] 2.1 Windup → boom sequence — `0.2.0-alpha.1` ✅ THIS
- [ ] 2.2 Tick feedback (flash + halo) — `0.2.0-alpha.2`
- [ ] 2.3 Sparks + sec/min/hour bursts — `0.2.0-alpha.3`
- [ ] 2.4 Date + weekday reveal — `0.2.0-alpha.4`
- [ ] 2.5 User & Session pickers — `0.2.0-alpha.5`
- [ ] 2.6 HUD (power / reboot) — `0.2.0-alpha.6`
- [ ] 2.7 i18n core (en + ru + uk) — `0.2.0-alpha.7`
- [ ] 2.8 Wayland virtual cursor ✦ — `0.2.0-alpha.8`
- [ ] 2.9 Alpha freeze — `0.2.9-alpha`

### Статус и следующий шаг

- Сделано: **stage 2.1 — Windup → Boom Sequence** закрыт. При появлении greeter'а
  орбитали «заводятся» (windup ≤ ~1600ms, Easing.InQuint, windupOffset 0→150000),
  затем scale+opacity boom, затем fade-in UI (`uiOpacity` 0→1). Реализовано через
  собственный AnimEngine (QtObject + 16ms tick), который уважает
  `clockAwake` / `windupEnabled`. validate/smoke PASS, windup-probe (MockMain)
  exit 0, verify-theme.sh PASS (секция 7).
- Следующее: **stage 2.2 — Tick feedback (flash + halo)** (`0.2.0-alpha.2`):
  трещины/halo/эмулированные детали по спеке (`docs/SPECS/01-alpha.md`);
  AnimEngine переиспользуется.
- Подготовить до старта 2.2: никакие.
- Блокеры: нет.

### Детали изменений (для агентов)

- `theme/onyx/components/effects/AnimEngine.qml` — НОВЫЙ QtObject-движок
  reveal-последовательности. Публичный API: `startReveal()` / `abort()`;
  фазовый 16ms `_tick()` (`AnimEngine.qml:31-37,64-98`): фаза 0 — windup
  (`windupOffset = eased(0,150000,t,_easeInQuint)`, `windupDegMin = offset*5`,
  `windupDegSec = offset*10`); фаза 1 — boom (`boomScale 1→35`,
  `boomOpacity 0→1`); фаза 2 — fade-in (`uiOpacity 0→1`, Easing.OutCubic,
  350ms). Гейт `clockAwake`: `running: engine.isWindup && engine.clockAwake`
  + ранний return в `_tick()`.
- `theme/onyx/components/effects/qmldir` — модуль `Effects`, `AnimEngine 1.0`.
- `theme/onyx/Main.qml` — `Effects.AnimEngine:26-34`, проводка
  `windupDegMin`/`windupDegSec` в ClockRoot и `clockAwake: state.clockAwake`
  в TimeProvider (`Main.qml:36-43`); `uiLayer` opacity = `engine.uiOpacity`:46-48;
  `boomOverlay` (z:9999, `state.blastColor`, opacity = `engine.boomOpacity`):70-77;
  `curtainOut` 180ms NumberAnimation (снятие boom-шторки):79-87;
  `Component.onCompleted` → `engine.startReveal()`:95-100.
- `theme/onyx/components/clock/ClockRoot.qml:12-13,45,67` — пропсы `windupDegMin`
  / `windupDegSec`; `positionDeg` вычитает windup-кик:
  `-(float/60)*360 - windupDeg*` (минутное/секундное кольцо).
- `theme/onyx/ThemeState.qml:12-23` — `clockAwake` (isPreview→true, иначе
  `Window.active`), `windupEnabled` (читает `config.enableWindup`, default true),
  `blastColor "#FFFFFF"`.
- `theme/onyx/components/clock/TimeProvider.qml:24` — `smoothTimer`
  `running: provider.clockAwake` — закрывает долг 0.1.11 «clockAwake gating
  16ms таймера».
- `theme/onyx/theme.conf` — `enableWindup=true`.
- `scripts/qa/windup-probe.qml` — MockMain live-проверка: startReveal →
  проверки `windupOffset > 0` (560ms/1300ms), boom, fade-in (`uiOpacity = 1`),
  ring-mix (`windupDegMin`/`windupDegSec` попадают на кольца). exit 0.
- `scripts/verify-theme.sh:130-135` — секция 7 «windup-probe» (offscreen, 18s).
- Критично для следующих агентов: AnimEngine НЕ использует NumberAnimation —
  весь reveal на 16ms tick (см. ADR ниже); `clockAwake` гейтит и TimeProvider,
  и AnimEngine; `windupEnabled=false` → `uiOpacity=1` мгновенно (без анимации).

### Тех. долг

- 🟡 **CR-F9 (отложено; НЕ трогать сейчас):** `s = Screen.height / 768` — на
  перепроверку stage 3.8 (HiDPI & multi-monitor). Переносится.
- 🟡 **CR-F10 (отложено):** реальный SDDM greeter integration test — на
  пользователе. Переносится.
- 🟡 **F-1.4-b (остаётся):** `pragma ComponentBehavior: Bound` — ждёт Qt ≥6.6
  в CI (unqualified-шум безвреден). Переносится.
- 🟡 **Перенос из 0.1.11:** `pillWindowHiding: true` на secRing без pillWin*
  (defensive, без визуального эффекта).
- Follow-up'ы: в записи 0.1.11 F-записей не было; тех. долг 0.1.10
  (CR-F9/F10/F-1.4-b) перенесён выше. Долг 0.1.11 «clockAwake gating 16ms
  таймера» — ЗАКРЫТ в stage 2.1 (`TimeProvider.qml:24`).
- Новых тех. долгов в stage 2.1 нет.

### Принятые решения

- **ADR-2.1-1 (AnimEngine, а не NumberAnimation):** windup/boom/fade-in
  реализованы через собственный движок (QtObject + 16ms tick), а не через
  NumberAnimation — ради гейта `clockAwake` (анимации обязаны «спать», когда
  окно неактивно) и переиспользования движка в следующих alpha-эффектах
  (2.2 tick feedback, 2.3 sparks/bursts).

---

## [0.1.11-mvp] — stage 1.8 · Nobara P0 regression fix · 2026-09-10

**Версия:** `0.1.11-mvp` — PATCH-bump внутри MVP (bugfix/regression fix).
Тег `0.1.11-mvp` + GitHub Release созданы 2026-09-10.

### Тик-лист ROADMAP (Phase 1 — MVP)

- [x] 1.1 Root + scaling + background — `0.1.0-mvp` ✅
- [x] 1.2 Digital clock + indicator pill — `0.1.1-mvp` ✅
- [x] 1.3 Minute orbital (static + spotlight) — `0.1.2-mvp` ✅
- [x] 1.4 Second orbital (smooth) — `0.1.3-mvp` ✅
- [x] 1.5 Login panel (minimal) — `0.1.4-mvp` ✅
- [x] 1.6 Basic auth feedback — `0.1.5-mvp` ✅
- [x] 1.7 MVP freeze — `0.1.9-mvp` ✅
- [x] 1.8 Nobara P0 regression fix — `0.1.11-mvp` ✅ THIS

- [x] Milestone: MVP (0.1.x-mvp) — релиз-тег ждёт апрува
- [ ] 2.1 Windup → boom sequence — `0.2.0-alpha.1`

### Статус и следующий шаг

- Сделано: P0 regression fix после MVP-релиза на реальном SDDM (Nobara 44).
  Логин реально работает: username виден (helper-ListView с delegate-roles),
  Enter/NumpadEnter логинят (`_submit` с empty-guard → `sddm.login`), non-original
  rotating hand удалён, обе орбитали вращаются против часовой стрелки каждая со
  своей скоростью (мин — 1 об/час, сек — 1 об/мин) через `positionDeg` из
  непрерывных float-значений. validate exit 0, verify-theme.sh PASS.
- Следующий шаг: Alpha 2.1 (windup→boom).
- Блокеров нет.

### Детали изменений (для агентов)

- `components/login/LoginPanel.qml` — helper ListView `userHelper` (model:
  `userModel.count`, delegate с role-данными: `userName`/`loginName`), свойства
  `currentUserName` / `currentLoginName` для label; `_submit()` с empty-guard
  (пароль/логин не пустые → `sddm.login(currentLoginName, password,
  sessionModel.lastIndex)`); `Keys.onPressed` для Return/Enter; нигде в проекте
  больше нет `userModel.data(` — удалены все вызовы.
- `components/clock/OrbitalRing.qml:12-13` — `required property real positionDeg`;
  `deg = index*6 + positionDeg` (вместо старого `angleDeg = index*6 - 90`);
  relDeg/spotlight через `relAngle`; удалён `smoothHand` (non-original rotating
  hand по original Ryoku — не предполагался).
- `components/clock/ClockRoot.qml:39,61` — минутное кольцо: `positionDeg:
  -(curMinuteFloat/60)*360`; секундное кольцо: `-(curSecondFloat/60)*360`;
  `pillWindowHiding: true` на обоих кольцах.
- `components/clock/TimeProvider.qml` — `curMinuteFloat` (дроп-in
  `curSecondFloat`-стиля, 16ms тик через `tickSmooth`).
- `scripts/verify-theme.sh` — regression-grep: `userModel.data(` → FAIL,
  `smoothHand` → FAIL, `currentIndex` (для MinutesBypass) → FAIL.
- `theme/onyx/Main.qml` — QML6 Connections signal-handler syntax:
  `onLoginSucceeded:` → `function onLoginSucceeded() {}`,
  `onLoginFailed:` → `function onLoginFailed() {}`.
- `theme/onyx/components/login/LoginPanel.qml` — cached `Window.window` as
  `property var windowWin` to avoid repeated `.window` accesses; Connections
  target uses `windowWin`.

### Тех. долг

- `pillWindowHiding: true` на secRing без pillWin* (defensive, без визуального
  эффекта — pillWindow на секундном кольце не реализован).
- Optional: clockAwake gating 16ms таймера (не входило в scope багфикса).

### Принятые решения

- **ADR-1.8-1 (отказ от `userModel.data()`):** `userModel.data()` выбрасывал
  exception на SDDM в Nobara 44, ломая и лейбл имени, и submit. Переход на
  delegate-roles helper (ListView с model=userModel.count) — проверенный паттерн
  для SDDM greeter'ов, robust к平台specific особенностям.
- **ADR-1.8-2 (CCW через positionDeg):** вращение кольца вместо стрелки по
  оригиналу Ryoku; CCW-по-умолчанию через отрицательный `positionDeg`:
  `-(float/60)*360`. Минутное кольцо 1 об/час (float/60), секундное — 1 об/мин.
- **ADR-1.8-3 (удаление smoothHand):** non-original rotating hand удалён —
  по оригиналу Ryoku стрелки нет, есть только вращение цифр по кольцу.

---

## [0.1.10-mvp] — stage bugfix · Ryoku layout fidelity · 2026-09-10

**Версия:** `0.1.10-mvp` — PATCH-bump внутри MVP после bugfix-этапа. Тег/release
не ставились — ждёт апрува пользователя (manual-gate).

### Тик-лист ROADMAP (Phase 1 — MVP)

- [x] 1.1 Root + scaling + background — `0.1.0-mvp` ✅
- [x] 1.2 Digital clock + indicator pill — `0.1.1-mvp` ✅
- [x] 1.3 Minute orbital (static + spotlight) — `0.1.2-mvp` ✅
- [x] 1.4 Second orbital (smooth) — `0.1.3-mvp` ✅
- [x] 1.5 Login panel (minimal) — `0.1.4-mvp` ✅
- [x] 1.6 Basic auth feedback — `0.1.5-mvp` ✅
- [x] 1.7 MVP freeze — `0.1.9-mvp` ✅
- [x] bugfix Ryoku layout fidelity — `0.1.10-mvp` ✅ THIS

- [x] Milestone: MVP (0.1.x-mvp) — релиз-тег ждёт апрува
- [ ] 2.1 Windup → boom sequence — `0.2.0-alpha.1`

### Статус и следующий шаг

- Сделано: закрыты 4 P0-бага (замирание часов, 60 smooth-hand'ов, Enter не
  работал, перекрытие логин-панелью) + приведён layout/палитра/типографика к
  оригиналу Ryoku 1-в-1; validate exit 0, verify-theme.sh починен.
- Следующий шаг: manual-gate Юрия (реальный greeter-цикл, визуальная проверка
  нового layout 1080/1440) → PR dev→main, tag 0.1.10-mvp, GitHub Release;
  далее Alpha 0.2.0-alpha.1.
- Блокеров нет.

### Детали изменений (для агентов)

- `ThemeState.qml` — палитра оригинала (pillColor #080808, pillBorder #1a1a1a,
  pillDivider #222222, dimText #666666, subText #555555, tickAccent #FF7A18,
  error #FF4444); удалены pillBgColor/pillMinutesColor/pillSecondsColor/denyColor.
- `components/clock/TimeProvider.qml` — `syncTick()` вызывается в конце `update()`
  (часы больше не замирают после 1-й секунды); добавлен `curSecond` (int).
- `components/clock/OrbitalRing.qml` — полный рерайт под оригинал: smooth-hand
  ОДИН Rectangle вне Repeater (`smoothAngle`, transformOrigin Bottom),
  spotlight = `pow(1-|relAngle|/5.5, 1.6)`, пик 58·s при >0.70, scale 1.15
  при >0.6 + Behavior 280ms, вращение цифр радиально, цифры минут на
  minR+30·s (снаружи), секунд на secR−30·s (внутри); параметризация тиков/цифр.
- `components/clock/IndicatorPill.qml` — капсула radius 45·s, минуты 54·s
  Font.Black x=85·s, секунды 30·s Font.Bold x=255·s, divider 1×35·s x=170·s.
- `components/clock/DateBlock.qml` (новый) — дата 13·s ls4 subText + день недели
  18·s ls8 Bold, toUpperCase; месяцы EN hardcoded (i18n = Alpha 2.7).
- `components/clock/ClockRoot.qml` (новый) + `qmldir` — контейнер часов: cx=40·s,
  minR=400·s, secR=520·s, часы (110·s Font.Black ls−2·s) слева от pill
  (rightMargin 40·s), дата справа (leftMargin 110·s); pill-window скрытия цифр
  минут; второй uniforms на кольце; `property alias timeProvider`.
- `Main.qml` + `qmldir` — ClockRoot слева (сам якорится), LoginPanel bottom-right
  (rightMargin 80·s / bottomMargin 80·s, width 350·s), AuthFeedback над панелью
  справа; DigitalClock.qml удалён (поглощён ClockRoot).
- `components/login/LoginPanel.qml` — Enter/NumpadEnter через Keys.onPressed
  (+ фолбэк на корневом Item), focus:true + Timer 300ms forceActiveFocus +
  re-grab при активации окна, username 18·s Bold ls8 dimText, пароль 14·s
  ls10 AlignRight.
- `scripts/verify-theme.sh` — структура: DigitalClock → ClockRoot + DateBlock
  (в этой же задаче).
- Follow-up (ревью #22): шрифт Outfit-Black vendored
  (`theme/onyx/font/Outfit-Black.ttf`, OFL-1.1, из оригинала 1-в-1),
  FontLoader в Main.qml (инъекция имени в ThemeState); smooth-hand укорочён
  до 0.75·радиуса; pill-window на мин-кольце переведён на прямые
  биндинги вместо Connections/onWidthChanged.

### Тех. долг

- CR-F9 (HiDPI scale) — открыт.
- CR-F10 (реальный login integration) — открыт.
- F-1.4-b (pragma ComponentBehavior) — ждёт Qt≥6.6 в CI.
- Ручной визуальный контроль нового layout (память кладки, pill-window на
  мин-кольце) — на пользователе.
- One-liner curl проверить после релиза.
- Placeholder-pass — 2.x.

### Принятые решения

- **ADR-bugfix-1 (эталон — оригинал):** layout/значения 1-в-1 из
  `sddm/theme/ryoku/Main.qml`, оригинал не модифицируется.
- **ADR-bugfix-2 (вращение цифр минут):** цифры минут ВРАЩАЮТСЯ (по оригиналу),
  несмотря на раннюю формулировку баг-дока.
- **ADR-bugfix-3 (spotlight до 58·s):** по UI Spec (в коде оригинала тира нет).
- **ADR-bugfix-4 (ClockRoot поглощает DigitalClock):** один владелец assembly;
  HUD вне скоупа (Alpha 2.5/2.6).

---

## [0.1.9-mvp] — stage 1.7 · MVP Freeze · 2026-09-10

**Версия:** `0.1.9-mvp` — финальный этап MVP (freeze). Тег/release НЕ ставились —
ожидает апрува пользователя (next: PR dev→main, tag 0.1.9-mvp + GitHub Release,
далее 0.2.0-alpha.1).

### Тик-лист ROADMAP (Phase 1 — MVP)

- [x] 1.1 Root + scaling + background — `0.1.0-mvp` ✅
- [x] 1.2 Digital clock + indicator pill — `0.1.1-mvp` ✅
- [x] 1.3 Minute orbital (static + spotlight) — `0.1.2-mvp` ✅
- [x] 1.4 Second orbital (smooth) — `0.1.3-mvp` ✅
- [x] 1.5 Login panel (minimal) — `0.1.4-mvp` ✅
- [x] 1.6 Basic auth feedback — `0.1.5-mvp` ✅
- [x] 1.7 MVP freeze — `0.1.9-mvp` ✅ THIS

- [x] Milestone: MVP (0.1.x-mvp) — релиз-тег ожидает апрува
- [ ] 2.1 Windup → boom sequence — `0.2.0-alpha.1`

### Статус и следующий шаг

- Сделано: **stage 1.7 — MVP freeze** закрыт. Regression sweep PASS (scan чист,
  trailing newline во всех 8 QML, hex только в ThemeState, масштаб только через
  `s`, validate exit 0, smoke 15s exit 0, probe exit 0, стресс 5×10s exit 0 —
  флуктуаций нет). `verify-theme.sh` создан (структура + validate + smoke +
  probe). Visual QA 1920×1080 и 2560×1440 PASS через Xvfb (контент всех зон,
  gap pill→panel 241/321px, s=H/768, ширины соответствуют). README — раздел
  «Установка (MVP)» + one-liner curl. `install.sh --release TAG` добавлен.
  `metadata.desktop` обновлён до 0.1.9-mvp.
- Следующее: **апрув Юрия** (manual-gate: реальный greeter-цикл DENIED/GRANTED,
  повторный login, focus/Enter, смена user/session, 1080/1440 на мониторе,
  чистая установка/uninstall/reinstall) → затем PR dev→main, tag 0.1.9-mvp,
  GitHub Release; далее Alpha 0.2.0-alpha.1.
- Подготовить к Alpha: принцип «один владелец auth-состояния».
- Блокеры: нет (апрув — не блокер, а ветка flow).

### Детали изменений (для агентов)

- `scripts/verify-theme.sh` — новый скрипт, проверки 1–7 (структура +
  validate + smoke + probe), локальный end-to-end.
- `scripts/qa/visual-qa.sh` — новый скрипт, прогоны на 1920×1080 и 2560×1440
  через Xvfb.
- `install.sh` — добавлен флаг `--release TAG`, `_resolve_root` pip-фоллбэк.
- `README.md` — раздел «Установка (MVP)» + one-liner curl, бейдж версии
  обновлён до 0.1.9--mvp, «Текущий статус» обновлён.
- `theme/onyx/metadata.desktop` — `Version=0.1.9-mvp`, добавлен
  `X-SDDM-ThemeName=Onyx`.

### Тех. долг

- CR-F9 (HiDPI scale) — открыт.
- CR-F10 (реальный login integration) — открыт.
- F-1.4-b (pragma ComponentBehavior) — ждёт Qt≥6.6 в CI.
- Manual-gate реального greeter — на пользователе.
- Локальный прогон `curl | sudo bash` one-liner — проверить после релиза.
- Fake-placeholder pass — 2.x.
- Perf-финал: стресс 5×10s без флуктуаций, базлайн без регрессий (42.8–53%).

### Принятые решения

- **ADR-1.7-1 (freeze):** этап без новых фич; правки — только фиксы из QA;
  `install.sh --release` и README-раздел — явное требование пользователя
  (one-liner установка), принято.
- **ADR-1.7-2 (Xvfb QA):** 1080/1440 честно через `Xvfb -screen 0 WxHx24` +
  software; `offscreen:size=` в Qt 6.11 не работает — отброшен.
- **ADR-1.7-3 (verify-theme.sh):** локальный end-to-end (структура + validate +
  smoke + probe), в CI не добавляется (гейт прежний validate/validate-arch).
- **ADR-1.7-4 (manual-gate):** реальный auth-цикл и инсталл-цикл — на
  пользователе (CI/greeter не способен).
- **ADR-1.7-5 (Alpha-принцип):** у auth-состояния один владелец; не плодить
  loading/failed по компонентам; состояние Authenticating — задача Alpha.

---

## [0.1.5-mvp] — stage 1.6 · Basic Auth Feedback · 2026-09-10

**Версия:** `0.1.5-mvp` (PATCH bump в милстоуне MVP; тег/релиз НЕ ставится)

### Тик-лист ROADMAP (Phase 1 — MVP)

- [x] 1.1 Root + scaling + background — `0.1.0-mvp` ✅
- [x] 1.2 Digital clock + indicator pill — `0.1.1-mvp` ✅
- [x] 1.3 Minute orbital (static + spotlight) — `0.1.2-mvp` ✅
- [x] 1.4 Second orbital (smooth) — `0.1.3-mvp` ✅
- [x] 1.5 Login panel (minimal) — `0.1.4-mvp` ✅
- [x] 1.6 Basic auth feedback — `0.1.5-mvp` ✅ THIS
- [ ] 1.7 MVP freeze — `0.1.9-mvp`

### Статус и следующий шаг

- Сделано: **stage 1.6 — Basic Auth Feedback** закрыт. Компонент
  `AuthFeedback` — текст «ACCESS GRANTED ✦» / «ACCESS DENIED ✦»
  (Unicode ✦ `\u2726`), fade in 250ms, auto-hide granted 2200ms / denied
  5000ms, fade out 400ms, скрытие через opacity. Публичное API:
  `showSuccess()` / `showDenied()`. Цвет ошибки `denyColor "#FF5252"`
  добавлен в `ThemeState`. В `Main.qml` — `Connections` на
  `sddm.loginSucceeded` / `sddm.loginFailed` с preview-safe target
  (`typeof sddm !== "undefined" ? sddm : null`). `LoginPanel` получил
  `id: loginPanel`. `AuthFeedback` размещён над панелью (`bottom:
  loginPanel.top`, `bottomMargin: 12*s`). QA: автономный probe
  (`scripts/qa/auth-feedback-probe.qml`) — обе ветки OK (slide1 denied
  active/granted, slide2 success), exit 0; validate/smoke(preview)/
  preview-gate PASS; perf-baseline: CPU avg **48.8%** (max 52.8%, spikes
  0) software offscreen — между baseline 42.8% (1.5) и 53% (1.4),
  регрессий нет; live-greeter probe (`sddm-greeter-qt6 --test-mode`)
  выжил 15s без ошибок.
- Следующее: **stage 1.7 — MVP freeze** (`0.1.9-mvp`).
- Подготовить до старта 1.7: manual sanity реального входа на живом
  greeter (пользователь); visual QA на 1920×1080 и 2560×1440;
  «как поставить MVP» в README (требование freeze); fake-placeholder и
  симметрия pill/час — пасс 2.x.
- Блокеры: нет.

### Детали изменений (для агентов)

- `theme/onyx/components/login/AuthFeedback.qml` — новый компонент
  `AuthFeedback`. `_show():33-42` — внутренняя логика fade in/out + auto-hide;
  `showSuccess()` / `showDenied()`:44-45 — публичный API; текст задан
  литералами («ACCESS GRANTED ✦» / «ACCESS DENIED ✦»); `textLabel`
  приватный — детерминация ветки через `fb.active` + `fb._granted`.
- `theme/onyx/Main.qml` — `id: loginPanel`:43; `AuthFeedback` инстанс
  `Login.AuthFeedback`:48-54 (`bottom: loginPanel.top`, `bottomMargin:
  12*s`); `Connections { target: typeof sddm !== "undefined" ? sddm : null
  }`:56-60 (`onLoginSucceeded` → `authFeedback.showSuccess()`,
  `onLoginFailed` → `authFeedback.showDenied()`).
- `theme/onyx/ThemeState.qml:26` — добавлен `property string denyColor:
  "#FF5252"`.
- `scripts/qa/auth-feedback-probe.qml` — автономный probe (без
  qmltestrunner), обе ветки OK, exit 0; текст не читается через
  `textLabel` (приватный) — ассерты используют `fb.active` +
  `fb._granted` (детерминированно).
- Критично для следующих агентов: `AuthFeedback` НЕ слушает сигналы
  `sddm` сам — подключение в `Main.qml` через `Connections`; текст
  компонента не доступен снаружи (приватный `textLabel`); probe
  работает автономно, CI-интеграция пока не расширена.

### Тех. долг

- 🟡 **CR-F9 (отложено; НЕ трогать сейчас):** `s = Screen.height / 768`
  масштабирует только по высоте; формула-кандидат
  `Math.min(Screen.width/1366, Screen.height/768)` — перепроверить на stage
  3.8 (HiDPI & multi-monitor).
- 🟡 **CR-F10 (отложено):** реальный SDDM greeter integration test — на
  пользователе; manual sanity реального входа — в план stage 1.7.
- 🟡 **F-1.4-b (остаётся):** `pragma ComponentBehavior: Bound` → некогда
  актуализировать, когда CI поднимет Qt ≥6.6 (unqualified-шум безвреден).
- 🟡 **Perf INFO:** CPU avg 48.8% (max 52.8%, spikes 0) software offscreen
  — между baseline 42.8% (1.5) и 53% (1.4), регрессий нет.
- 🟡 **Probe без CI-интеграции:** автономный probe
  (`scripts/qa/auth-feedback-probe.qml`) работает, но не интегрирован в
  CI-пайплайн.

### Принятые решения (ADR)

- **ADR-1.6-1 (публичный API):** `showSuccess()` / `showDenied()` —
  компонент НЕ слушает сигналы `sddm` сам; подключение к greeter — в
  `Main.qml` через `Connections`. Разделение ответственности: компонент
  знает как показать; Main знает когда.
- **ADR-1.6-2 (preview-safe):** target `typeof sddm !== "undefined" ? sddm
  : null` — вне greeter `Connections` неактивна; компонент рендерится без
  ошибок в preview/offscreen.
- **ADR-1.6-3 (fade + auto-hide):** 250ms fade in, hold granted 2200ms /
  denied 5000ms, 400ms fade out; скрытие через `opacity: 0` (не
  `visible: false`) — не перехватывает ввод.
- **ADR-1.6-4 (цвет):** `denyColor` в `ThemeState` — единый источник
  цвета ошибки (единообразно с остальными цветами темы).
- **ADR-1.6-5 (текст):** литералы по спеке («ACCESS GRANTED ✦» /
  «ACCESS DENIED ✦»); i18n — на stage 3.x (рано для локализации).
- **ADR-1.6-6 (QA-инструмент):** probe автономный (без qmltestrunner);
  harness не вводили; CI не расширялся — достаточный уровень для MVP.

---

## [0.1.4-mvp] — stage 1.5 · Login Panel (minimal) · 2026-09-10

**Версия:** `0.1.4-mvp` (PATCH bump в милстоуне MVP; тег/релиз НЕ ставится)

### Тик-лист ROADMAP (Phase 1 — MVP)

- [x] 1.1 Root + scaling + background — `0.1.0-mvp` ✅
- [x] 1.2 Digital clock + indicator pill — `0.1.1-mvp` ✅
- [x] 1.3 Minute orbital (static + spotlight) — `0.1.2-mvp` ✅
- [x] 1.4 Second orbital (smooth) — `0.1.3-mvp` ✅
- [x] 1.5 Login panel (minimal) — `0.1.4-mvp` ✅ THIS
- [ ] 1.6 Basic auth feedback — `0.1.5-mvp`
- [ ] 1.7 MVP freeze — `0.1.9-mvp`

### Статус и следующий шаг

- Сделано: **stage 1.5 — Login Panel (minimal)** закрыт. Минимальная
  логин-панель: label имени пользователя + password input + Enter →
  `sddm.login(user, password, sessionIndex)`; сессия/имя по умолчанию
  `sessionModel.lastIndex` / `userModel.lastIndex`; graceful preview
  (isPreview guard, label «preview»); закрыт тех.долг **F-1.4-a**
  (детерминированный выбор `qmllint` в `validate.sh` — Qt6-бинарник
  приоритетен).
- QA: панель не пересекает числа колец (зазор 32px, ADR-1.5-5);
  perf baseline: CPU avg **42.8%** (max 48%, spikes 0) software offscreen —
  ЛУЧШЕ baseline stage 1.4 (53%); `sddm-greeter-qt6 --test-mode --theme ...`
  пережил 15s без ошибок (live-probe на Arch); smoke 8s PASS; validate PASS
  (qmllint Qt6.11 hard; unqualified warnings для `sddm`/`userModel`/
  `sessionModel` — ожидаемы).
- Следующее: **stage 1.6 — Basic auth feedback** (`0.1.5-mvp`).
- Подготовить до старта 1.6: manual sanity реального входа на живом greeter
  (пользователь, после установки); симметрия pill/час — визуальный пасс 2.x;
  fake-placeholder — пасс 2.x.
- Блокеры: нет.

### Детали изменений (для агентов)

- `theme/onyx/components/login/LoginPanel.qml` — новый компонент LoginPanel.
  `_submit():7-17` — Enter → `sddm.login(user, password, sessionIndex)`,
  сессия/имя по умолчанию `sessionModel.lastIndex` / `userModel.lastIndex`;
  `userLabel:35-48` — label имени пользователя («preview» в graceful preview);
  `textField:49-67` — password input (`echoMode: Password`,
  `Keys.onReturnPressed`/`onEnterPressed` → `_submit()`).
- `theme/onyx/Main.qml` — импорт Login:3 (`"components/login" as Login`),
  инстанс `Login.LoginPanel`:41-47 (bottom-center, `bottomMargin: 120*s`, ниже
  колец).
- `validate.sh` — порядок кандидатов `qmllint` ~88-95: Qt6-бинарники
  (`/usr/lib/qt6/{libexec,bin}/qmllint`, `/usr/lib64/qt6/...`) приоритетнее,
  чем голый `qmllint` из PATH (F-1.4-a закрыт).
- Критично для следующих агентов: submit — только Enter, кнопки нет
  (ADR-1.5-3); placeholderText НЕ вводим — фейковый `Text` при пустом поле,
  полное решение — пасс 2.x (ADR-1.5-8).

### Тех. долг

- 🟡 **CR-F9 (отложено; НЕ трогать сейчас):** `s = Screen.height / 768`
  масштабирует только по высоте; формула-кандидат
  `Math.min(Screen.width/1366, Screen.height/768)` — перепроверить на stage 3.8
  (HiDPI & multi-monitor).
- 🟡 **CR-F10 (отложено):** реальный SDDM greeter integration test — на
  пользователе; manual sanity реального входа — в план stage 1.6.
- 🟡 **F-1.4-b (остаётся):** `pragma ComponentBehavior: Bound` → некогда
  актуализировать, когда CI поднимет Qt ≥6.6 (unqualified-шум безвреден).
- 🟡 **placeholder-решение (пасс 2.x):** `placeholderText`/`placeholderColor` на
  TextInput НЕ вводим — qml6 runner (Qt 6.11, offscreen) не создаёт тему с ними
  («Did not load any objects», exit 2); placeholder — фейковый `Text` при пустом
  поле, полное решение — пасс 2.x.
- 🟡 **Perf INFO (baseline):** CPU avg 42.8% (max 48%, spikes 0) software
  offscreen — ЛУЧШЕ baseline stage 1.4 (53%); на HW ниже.

### Принятые решения (ADR)

- **ADR-1.5-1 (минимализм):** панель строго минимальная — label +
  password + Enter; ничего лишнего в MVP.
- **ADR-1.5-2 (session/имя auto):** по умолчанию `sessionModel.lastIndex` /
  `userModel.lastIndex` (фолбэк 0 / «user» при отсутствии моделей).
- **ADR-1.5-3 (Enter без кнопки):** submit — только Enter
  (`Keys.onReturnPressed`/`onEnterPressed`); кнопка входа не вводится.
- **ADR-1.5-4 (graceful preview):** isPreview guard — `_submit()` возвращается
  сразу, label «preview»; панель рендерится без живого greeter.
- **ADR-1.5-5 (позиционирование):** панель не пересекает числа колец —
  зазор 32px.
- **ADR-1.5-6 (i18n placeholder):** локализация placeholder — inline/фейковый
  пасс 2.x.
- **ADR-1.5-7 (детерминизм линта):** F-1.4-a закрыт — `validate.sh` выбирает
  Qt6-бинарник `qmllint` приоритетно.
- **ADR-1.5-8 (drop placeholderText):** свойство TextInput отклонено — qml6
  runner (Qt 6.11, offscreen) не создаёт тему с ним («Did not load any objects»,
  exit 2); placeholder — фейковый `Text` при пустом поле, пасс 2.x.

---

## [0.1.3-mvp] — stage 1.4 · Second Orbital (smooth) · 2026-09-10

**Версия:** `0.1.3-mvp` (PATCH bump в милстоуне MVP; тег/релиз НЕ ставится — это stage, не веха)

### Тик-лист ROADMAP (Phase 1 — MVP)

- [x] 1.1 Root + scaling + background — `0.1.0-mvp` ✅
- [x] 1.2 Digital clock + indicator pill — `0.1.1-mvp` ✅
- [x] 1.3 Minute orbital (static + spotlight) — `0.1.2-mvp` ✅
- [x] 1.4 Second orbital (smooth) — `0.1.3-mvp` ✅ THIS
- [ ] 1.5 Login panel (minimal) — `0.1.4-mvp`
- [ ] 1.6 Basic auth feedback — `0.1.5-mvp`
- [ ] 1.7 MVP freeze — `0.1.9-mvp`

### Статус и следующий шаг

- Сделано: **stage 1.4 — Second Orbital (smooth)** закрыт. Второй (секундный)
  инстанс `OrbitalRing` (`radiusS: 270`) с плавным маркером `smoothPosition`
  (rotation = `smoothPosition*6`), источник `curSecondFloat` в `TimeProvider`
  (16 ms тик, значение из `Date()` — без накопленного дрейфа). Единый renderer
  без форка компонента — различия только параметрами (ADR-1.4-1). Visual QA:
  60/60 тиков на обоих кольцах, маркер на дробных позициях, две раздельные
  полосы чисел (зазор ~40 px на реальном скрине). CPU: avg 53%
  software-renderer, 100%-spikes НЕТ (на HW ниже). Закрыты follow-up'ы
  ревью: **CR-F9/F10** остаются (учтены без кода).
- Следующее: **stage 1.5 — Login panel (minimal)** (`0.1.4-mvp`).
- Подготовить до старта 1.5: визуальная симметрия pill vs час-цифры (INFO из
  QA 1.3/1.4); `validate.sh` qmllint-приоритет (F-1.4-a).
- Блокеры: нет.

### Детали изменений (для агентов)

- `theme/onyx/components/clock/OrbitalRing.qml` — добавлены параметры:
  `property real radiusS: 320`, `property real smoothPosition: -1`;
  `width/height = 2*radiusS*s`, `radius = radiusS*s`; внутри делегата
  Repeater — плавный маркер `Rectangle` (visible при `smoothPosition >= 0`,
  rotation `smoothPosition*6`). Критично: компонент параметризован, один для
  обоих колец.
- `theme/onyx/components/clock/TimeProvider.qml` — добавлено:
  `property real curSecondFloat` (не readonly — обязательная правка против
  ошибки readonly на свойство с `=`); `smoothTimer` (16 ms, repeat, running);
  `function tickSmooth()` — пересчёт из `Date().getSeconds() +
  getMilliseconds()/1000`.
- `theme/onyx/Main.qml` — второй `Clock.OrbitalRing` (`id: secondRing`,
  `radiusS: 270`, `currentIndex: Math.floor(curSecondFloat % 60)`,
  `smoothPosition: curSecondFloat`), оба кольца объявлены ДО `DigitalClock`
  (z-порядок — цифры поверх колец).
- Критично для следующих агентов: минуты — `currentIndex = curMinute` БЕЗ
  `smoothPosition` (статичный spotlight); секунды — плавный маркер через
  `smoothPosition`; проба `pragma ComponentBehavior: Bound` — результат ниже
  (откатена).

### Тех. долг

- 🟡 **CR-F9 (отложено; НЕ трогать сейчас):** `s = Screen.height / 768`
  масштабирует только по высоте; формула-кандидат
  `Math.min(Screen.width/1366, Screen.height/768)` — перепроверить на stage 3.8
  (HiDPI & multi-monitor) после появления реальных HUD/login-панелей.
- 🟡 **CR-F10 (отложено):** реальный SDDM greeter integration test — после
  появления интерактивных панелей login (stage ~1.5+).
- 🟡 **F-1.4-a (новый):** `validate.sh` выбирает `qmllint` из PATH первым
  (`/usr/bin/qmllint` = Qt5 1.0), а не Qt6-бинарник
  (`/usr/lib/qt6/bin/qmllint`) — детерминизм линта ухудшен. Фикс приоритета —
  следующий этап (мелкий, отдельный).
- 🟡 **F-1.4-b (решение — откат):** прагма `pragma ComponentBehavior: Bound`
  НЕ внедряется сейчас — откачена в эксперименте: (1) старый qmllint 1.0 в
  PATH падает с «Unknown options», (2) прагма требует Qt ≥6.6, а CI validate
  на Ubuntu 6.4.2 её не поддержит в любом случае. Актуализировать, когда CI
  поднимет Qt ≥6.6 (unqualified-шум безвреден).
- 🟡 **Визуальный пасс 2.x:** CPU avg 53% в software-renderer — приемлемо;
  pill/час симметрия — визуальный пасс 2.x.

### Принятые решения (ADR)

- **ADR-1.4-1 (один renderer):** секунды используют `OrbitalRing` без форка;
  различия — только параметры (`radiusS 270`, `currentIndex =
  floor(curSecondFloat)`, `smoothPosition = curSecondFloat`).
- **ADR-1.4-2 (плавность через маркер):** плавность обеспечивается отдельным
  маркером `rotation = smoothPosition*6`; подсветка тика (spotlight) остаётся
  дискретной на `currentIndex`. Визуальная сплошность — за счёт маркера, не
  анимации между тиками.
- **ADR-1.4-3 (абсолютное время без дрейфа):** `curSecondFloat` всегда
  пересчитывается из `Date()` (не инкрементальный счётчик) — накопленного
  дрейфа нет.
- **ADR-1.4-4 (clockAwake упрощён):** в MVP НЕ реализуем логику
  «бодрствования» (спека допускает «можно упростить»); `smoothTimer` работает
  постоянно; `clockAwake` — начиная с этапов HUD/анимаций.
- **ADR-1.4-5 (числа на секундном кольце):** те же визуальные правила, что и
  на минутном (числа на major + spotlight) — единый компонент без спец-флагов.

---

## [0.1.2-mvp] — stage 1.3 · Minute Orbital · 2026-09-09

**Версия:** `0.1.2-mvp` (PATCH bump в милстоуне MVP; тег/релиз НЕ ставится — это stage, не веха)

### Тик-лист ROADMAP (Phase 1 — MVP)

- [x] 1.1 Root + scaling + background — `0.1.0-mvp` ✅
- [x] 1.2 Digital clock + indicator pill — `0.1.1-mvp` ✅
- [x] 1.3 Minute orbital (static + spotlight) — `0.1.2-mvp` ✅ THIS
- [ ] 1.4 Second orbital (smooth) — `0.1.3-mvp`
- [ ] 1.5 Login panel (minimal) — `0.1.4-mvp`
- [ ] 1.6 Basic auth feedback — `0.1.5-mvp`
- [ ] 1.7 MVP freeze — `0.1.9-mvp`

### Статус и следующий шаг

- Сделано: **stage 1.3 — Minute Orbital** закрыт. Орбиталь минут
  (`OrbitalRing.qml`): 60 тиков на круге `R = 320*s`, major (каждый 5-й) с
  числом, minor без числа, spotlight текущей минуты через `currentIndex`
  (увеличенный шрифт, полная opacity, удлинённый тик). Числа размещены
  ГОРИЗОНТАЛЬНО без радиального поворота. В `TimeProvider` добавлен
  drift-free `syncTick()` — тик перепланируется ровно на начало следующей
  целой секунды. Цвета вынесены в ThemeState (color API), DigitalClock /
  IndicatorPill переведены на `themeState` без хардкодов. Закрыты follow-up'ы
  ревью: **CR-F7** (явный EUID-check в `install.sh`), **CR-F8** (`cp -r` →
  `cp -a`), **CR-F11** (удалён `--mock` из `preview.sh` — вариант A принят
  пользователем); **CR-F9/F10** учтены в дизайне без кода.
- Следующее: **stage 1.4 — Second orbital (smooth)** (`0.1.3-mvp`).
- Подготовить до старта 1.4: визуальная симметрия pill vs час-цифры (INFO из
  QA 1.3); проба `pragma ComponentBehavior: Bound` на Qt 6.4 CI.
- Блокеры: нет.

### Детали изменений (для агентов)

- `theme/onyx/components/clock/OrbitalRing.qml:1-78` — новый компонент
  (в `qmldir`: `OrbitalRing 1.0`). Полярная позиция: `x/y = центр + R·cos/sin`,
  `angleDeg = index*6 − 90` (индекс 0 — в 12 часов), `R = width/2 = 320*s`.
  Тик-линия центрирована на линию кольца за счёт `rotation: angleDeg + 90`.
  Числа — горизонтальные, `numberOffset = 18*s` от конца тика. Spotlight:
  `isCurrent = (index === ring.currentIndex)` → `spotlightFontSize 18*s`
  (пик ~58*s у major), opacity 1.0, тик 3*s. Компонент параметризован
  (`tickCount`, font sizes, tick lengths, opacities) — переиспользуем для 1.4.
- `theme/onyx/Main.qml:17-22` — `Clock.OrbitalRing` (namespaced directory
  import), `currentIndex: clock.timeProvider.curMinute`, `anchors.centerIn: parent`.
- `theme/onyx/components/clock/TimeProvider.qml:9-14,28-37` —
  `readonly property int curMinute`; `syncTick()`: `interval = 1000 −
  ms` → таймер срабатывает в ровную целую секунду (drift-free); `update()` +
  `syncTick()` в `Component.onCompleted`.
- `theme/onyx/ThemeState.qml:16-26` — color API: `mainTextColor #FFFFFF`,
  `pillBgColor #1A1A1A`, `pillBorderColor #333333`, `pillDividerColor #444444`,
  `pillMinutesColor #CCCCCC`, `pillSecondsColor #888888`,
  `orbitalTickColor #FFFFFF`, `orbitalTextColor #CCCCCC`,
  `fontFamily "Sans Serif"`. Полная конфигурируемость — stage 3.7 (light theme).
- `theme/onyx/components/clock/DigitalClock.qml:6-8,27-41` +
  `theme/onyx/components/clock/IndicatorPill.qml:6-16` — потребляют
  `themeState` (шрифт/цвета), хардкоды цветов удалены.
- `install.sh:29-33,40` — явная проверка root при дефолтном пути
  `/usr/share/sddm/themes/onyx` (CR-F7); `cp -r` → `cp -a` (CR-F8).
- `scripts/preview.sh:6,10,31-39,54-56,73` — удалён `--mock` (CR-F11, вариант
  A); graceful preview через `ThemeState.isPreview` остаётся;
  `preview/MockSddm.qml` + `MockConfig.qml` — fixtures на будущий harness.
- `theme/onyx/metadata.desktop:7` — добавлено `Version=0.1.2-mvp`.
- Критично для следующих агентов: кольцо `R = 320*s` (width 640*s); числа
  орбитали ГОРИЗОНТАЛЬНЫ (не вращаются); spotlight переключается мгновенно
  через `currentIndex` (без анимаций — MVP-констрейнт); тик синкается в целую
  секунду (`syncTick`) — без дрейфа к дробным секундам.

### Тех. долг

- 🟡 **CR-F9 (отложено; НЕ трогать сейчас):** `s = Screen.height / 768`
  масштабирует только по высоте; формула-кандидат
  `Math.min(Screen.width/1366, Screen.height/768)` — перепроверить на stage 3.8
  (HiDPI & multi-monitor) после появления реальных HUD/login-панелей.
  Решение осознанное: без детальной композиции выбор формулы необоснован.
- 🟡 **CR-F10 (отложено):** реальный SDDM greeter integration test — после
  появления интерактивных панелей login (stage ~1.5+); сейчас `scripts/smoke.sh`
  (offscreen QML-рантайм) + graceful preview как компромисс MVP.
- 🟡 **`pragma ComponentBehavior: Bound`** — проба на Qt 6.4 CI с инжекцией
  `currentIndex` и `themeState`: жёсткая безопасность контекста компонента;
  отложено с stage 1.4+ (не блокируем 1.3).
- 🟡 **Визуальный пасс 1.4/2.x:** двузначный цифровой формат орбитали (`07`) и
  диагональная симметрия pill vs час-цифры (INFO из QA 1.3) — в визуальный
  пасс stage 1.4 и/или 2.9.
- Здесь «нет» не пишем — долг остаётся (закрыты только F7/F8/F11).

### Принятые решения (ADR)

- **ADR-1.3-1 (spotlight мгновенный):** spotlight текущей минуты переключается
  без анимаций — MVP-констрейнт (никаких сложных анимаций); плавность — 1.4+.
- **ADR-1.3-2 (горизонтальные числа):** числа орбитали размещены
  ГОРИЗОНТАЛЬНО без радиального поворота (читаемость — MVP); вариант ревьюера
  (вращение вдоль круга) отклонён в этом stage; follow-up 2.x — editor-of.
- **ADR-1.3-3 (spotlight на некратной 5-ке):** текущая минута получает
  spotlight + число, даже если не кратна 5 (`visible: isMajor || isCurrent`).
- **ADR-1.3-4 (тик на линии кольца):** тик-линия центрирована на линию кольца
  за счёт `rotation = angleDeg + 90` (тик «на» кольце, а не от края).
- **ADR-1.3-5 (цвета в ThemeState):** цветовой API живёт в ThemeState, НЕ в
  theme.conf; полная конфигурируемость — stage 3.7 (light theme); ThemeState —
  единственный источник цветов (ARCHITECTURE §4.3, §5.6).
- **ADR-1.3-6 (переиспользуемость OrbitalRing):** компонент параметризован
  (`tickCount`, font sizes, tick lengths, opacities) и переиспользуется для
  stage 1.4 (Second orbital, smooth) и далее.
- **ADR-1.3-7 (формула масштаба):** `Screen.height / 768` остаётся; CR-F9
  отложен ОСОЗНАННО; min-кандидат — на перепроверку в 3.8.
- **ADR-1.3-8 (preview без --mock):** `scripts/preview.sh` работает в graceful
  preview БЕЗ `--mock` (вариант A принят пользователем); моки остаются
  fixtures на будущий harness.

---

## [0.1.1-mvp] — stage 1.2 · review follow-ups (CR-F7…F11) · 2026-09-08

**Версия:** без bump (follow-up-запись CR-F7…F11; не ROADMAP-этап; версия остаётся `0.1.1-mvp`)

### Статус и следующий шаг

- Сделано: **НИЧЕГО по коду** — только зафиксированы в CHANGELOG замечания
  пользователя по коду stage 1.2 (CR-F7…F11) как тех. долга / follow-up'ов для
  будущих этапов. Изменён ТОЛЬКО `CHANGELOG.md` (ветка `stage/1.2-followup-notes`);
  код, скрипты, README, `.github/`, `docs/` и `docs/code-reviews/` НЕ трогались.
- Следующее: **stage 1.3 — Minute Orbital** (`0.1.2-mvp`).
- **Follow-up'ы CR-F7…F11 ОБЯЗАТЕЛЬНО входят в план stage 1.3** (AGENTS.md §3.3:
  «follow-up из ревью обязаны попасть в план СЛЕДУЮЩЕГО этапа»): F7/F8 — быстрый
  UX-pass по `install.sh`; F11 — выбор варианта A/B (первый в очереди); F9/F10 —
  только проверка/учёт без кода (детали в «Принятые решения»).
- Блокеры: нет.

### Тик-лист ROADMAP (Phase 1 — MVP)

- [x] 1.1 Root + scaling + background — `0.1.0-mvp` ✅
- [x] 1.2 Digital clock + indicator pill — `0.1.1-mvp` ✅ (matrix fix: opensuse/rhel9 green)
- [ ] 1.3 Minute orbital (static + spotlight) — `0.1.2-mvp`
- [ ] 1.4 Second orbital (smooth) — `0.1.3-mvp`
- [ ] 1.5 Login panel (minimal) — `0.1.4-mvp`
- [ ] 1.6 Basic auth feedback — `0.1.5-mvp`
- [ ] 1.7 MVP freeze — `0.1.9-mvp`

### Детали изменений (для агентов)

- Изменён ТОЛЬКО `CHANGELOG.md` (эта запись). Commits / push НЕ делались.
- Замечания пользователя касаются следующих файлов (для будущих агентов):
  - `install.sh:6` — дефолтный `DEST="/usr/share/sddm/themes"` без явной
    EUID-проверки; `install.sh:35` — `cp -r "${SRC_DIR}/." "${DEST}/"`.
  - `theme/onyx/Main.qml:10` — `readonly property real s: Screen.height / 768`
    (масштаб только по высоте; НЕ менять сейчас).
  - `scripts/smoke.sh` — offscreen-загрузка QML-рантайма, а не настоящий SDDM
    greeter (осознанный компромисс MVP).
  - `scripts/preview.sh:15,37-38,62,83` + `preview/MockSddm.qml` +
    `preview/MockConfig.qml` — `--mock` только предупреждает, моки не
    инжектируются.
- Полные формулировки и варианты решений по каждому CR — в «Тех. долг» и
  «Принятые решения».

### Тех. долг

- 🟡 **CR-F7 (низкий, UX):** `install.sh` требует root при дефолтном пути
  `/usr/share/sddm/themes`, но явно EUID не проверяет — обычный пользователь
  сейчас получит просто ошибку от `mkdir`. Рекомендация пользователя — явная
  проверка:
  ```bash
  if [[ "${DEST}" == "/usr/share/sddm/themes" ]] && [[ "${EUID}" -ne 0 ]]; then
      echo "error: root privileges required for system installation" >&2
      exit 1
  fi
  ```
  UX-улучшение, не критично, но лучше. Чинить: quick-pass в stage 1.3.

- 🟡 **CR-F8 (низкий, UX):** `install.sh:35` — `cp -r "${SRC_DIR}/." "${DEST}/"`
  работает, но для установщика предпочтительнее `cp -a` (предсказуемо сохраняет
  атрибуты). Не must-have. Чинить: quick-pass в stage 1.3.

- 🟡 **CR-F9 (отложено; INFO-forwarded, аналогично CR-5; НЕ трогать сейчас):**
  `theme/onyx/Main.qml:10` — `s = Screen.height / 768` масштабирует ТОЛЬКО по
  высоте; на ультрашироких/нестандартных экранах могут появиться вопросы
  композиции. Будущее решение-кандидат:
  `s = Math.min(Screen.width/1366, Screen.height/768)`. Вопрос следующего этапа,
  когда появятся реальные HUD/login-панели; перепроверить также на stage 3.8
  (HiDPI & multi-monitor) и при multi-monitor-задачах. Не блокер.

- 🟡 **CR-F10 (отложено; осознанный компромисс MVP):** `scripts/smoke.sh`
  проверяет загрузку QML-рантайма (offscreen), но не настоящий SDDM greeter.
  Для MVP решение хорошее — компенсируется graceful preview через
  `typeof sddm === "undefined"` (ThemeState.isPreview). Позже нужен отдельный
  реальный SDDM integration test (с появлением login/интерактива, ~1.5+).
  Сейчас НЕ усложнять. Не блокер.

- ⚠️ **CR-F11 (средний; ПЕРВЫЙ в очереди):** `scripts/preview.sh --mock`
  фактически ничего не мокает: флаг только выводит warning и идёт в graceful
  preview (README/--help честно говорят «--mock only warns»), но имя флага
  misleading — звучит как функция. `preview/MockSddm.qml` и
  `preview/MockConfig.qml` существуют как подготовленная инфраструктура, но
  реально не инжектируются (полная инжекция `sddm`/`config` требует C++-хендла
  или кастомного runner — context-properties создаёт greeter). Это не баг, а
  несостыковка интерфейса. Оба варианта решения зафиксированы, выбор — при
  планировании следующего затронутого этапа:
  - **Вариант A (лучший сейчас):** убрать `--mock` до появления настоящего
    harness.
  - **Вариант B:** переименовать в `--preview-mode` или `--graceful-preview`.

### Принятые решения

- **CR-F9 (формула масштаба):** `Screen.height / 768` — осознанный выбор до
  появления HUD/login-панелей; без них нельзя обоснованно выбрать формулу
  (`min`-кандидат отмечен на будущее). Изменение сейчас отклонено.
- **CR-F10 (smoke-test вместо реального greeter):** осознанный компромисс MVP;
  реальный SDDM integration test — на будущее (после появления интерактивных
  панелей login).
- **CR-F11 (`--mock`):** правка отложена осознанно — решение (вариант A или B)
  принимается при планировании stage 1.3, где F11 первым в очереди. Оба варианта
  зафиксированы в «Тех. долг».
- **CR-F7…F11 в план stage 1.3:** по AGENTS.md §3.3 follow-up'ы из ревью
  обязаны попасть в план СЛЕДУЮЩЕГО этапа. Распределение по 1.3: F7/F8 — UX-pass
  по `install.sh`; F11 — выбор варианта A/B; F9/F10 — учёт в дизайне орбиталей
  без кода (после появления детальной композиции).

---

## [0.1.1-mvp] — stage 1.2 · CI distro-matrix fix (opensuse/rhel9) · 2026-09-08

**Версия:** без bump (follow-up к stage 1.2; не ROADMAP-этап)

### Статус и следующий шаг

- Сделано: 8-контейнерная матрица дистрибутивов приведена к зелёному — все
  ветки push-триггера `dev` проходят `validate` + `validate-arch` + все 8
  matrix-контейнеров PASS (arch, cachyos, fedora, nobara, ubuntu, debian,
  opensuse, rhel9). Исправлены два контейнера: opensuse (имена пакетов qt6
  через `-devel` мета-пакеты; `zypper refresh` перед установкой) и rhel9
  (UBI9 заменён на AlmaLinux 9; EPEL + AppStream Qt6 вместо UBI-only).
  Добавлен `workflow_dispatch` — ручной запуск полной матрицы для
  верификации. Защита `dev` настроена: required PR, required status checks
  (validate, validate-arch), conversations resolved; approval requirement
  отключён (solo-разработка).
- Следующее: **stage 1.3 — Minute Orbital** (`0.1.2-mvp`).
- Блокеры: нет.

### Тик-лист ROADMAP (Phase 1 — MVP)

- [x] 1.1 Root + scaling + background — `0.1.0-mvp` ✅
- [x] 1.2 Digital clock + indicator pill — `0.1.1-mvp` ✅ (matrix fix: opensuse/rhel9 green)
- [ ] 1.3 Minute orbital (static + spotlight) — `0.1.2-mvp`
- [ ] 1.4 Second orbital (smooth) — `0.1.3-mvp`
- [ ] 1.5 Login panel (minimal) — `0.1.4-mvp`
- [ ] 1.6 Basic auth feedback — `0.1.5-mvp`
- [ ] 1.7 MVP freeze — `0.1.9-mvp`

### Детали изменений (для агентов)

- `.github/workflows/ci.yml` — единственный изменённый файл (PR #13,
  merge commit `aac7ae2`, ветка `stage/1.2-ci-matrix-fix`). Ключевые строки
  install для следующих агентов:
  - **opensuse (Tumbleweed):** `zypper --non-interactive --gpg-auto-import-keys
    refresh && zypper --non-interactive install git qt6-base-devel
    qt6-base-common-devel qt6-declarative-devel qt6-declarative-tools
    qt6-svg-devel` — голые имена `qt6-base`/`qt6-declarative` не существуют
    в Tumbleweed OSS; нужно `*-devel` мета-пакеты.
  - **rhel9 (AlmaLinux 9):** `dnf install -y epel-release && dnf install -y
    git qt6-qtbase qt6-qtdeclarative qt6-qtdeclarative-devel qt6-qtsvg` —
    UBI9 заменён на `almalinux:9` (полный AppStream + CRB, EPEL qt6
    работает).
  - **workflow_dispatch:** добавлен `on: workflow_dispatch`; guard строки
    `distro-matrix` = `push || workflow_dispatch` (строка 61 ci.yml).
  - **Защита dev (GitHub):** required PR, required status checks =
    `validate` + `validate-arch`, conversations resolved required; approval
    requirement отключён (solo-flow).
- Верификация: workflow_dispatch run `34256636320` (на ветке) — success
  8/8; push-триггер run `34258135671` (dev) — success 8/8.

### Тех. долг

- RHEL9 в матрице работает через AlmaLinux 9 (бинарный ребилд RHEL9), а
  не через сам RHEL9/UBI9 — UBI9 AppStream/CRB не содержит X11/xcb/GL
  рантайм-зависимостей, необходимых для EPEL qt6-qtbase-gui. Если появится
  свободный RHEL9-раннер или UBI10 — перепроверить (HIGH, пометка для
  будущего этапа packaging/RC).
- Защита `dev` работает без approval requirement — осознанное решение
  (solo-разработка, self-review + CI). При добавлении контрибьюторов —
  включить approval.
- Полноценный `sddm-greeter-qt6 --test-mode` runtime — отложен до stage
  1.3+/1.5 (ATM `scripts/smoke.sh` заменяет).

### Принятые решения

- **UBI9 → AlmaLinux 9:** UBI9 — минимальный образ без AppStream/CRB Qt6
  runtime-зависимостей; AlmaLinux 9 — полный бесплатный ребилд RHEL9 с EPEL
  qt6; комментарий в ci.yml (строки 89–92) фиксирует причину.
- **Approval requirement отключён на `dev`:** solo-разработка; CI (validate +
  validate-arch) = единственный gates; решение пользователя, зафиксировано
  при настройке branch protection.
- **workflow_dispatch как канал верификации:** позволяет запустить полную
  8-контейнерную матрицу вручную (ветка, dev, main) без push-события;
  guard `push || workflow_dispatch` на джобе `distro-matrix`.

---

## [0.1.1-mvp] — stage 1.2 · CI distro-matrix rework · 2026-09-08

**Версия:** без bump (follow-up к stage 1.2; не ROADMAP-этап)

### Статус и следующий шаг

- Сделано: `validate.sh` переведён на дистрибутив-независимую детекцию активного Qt
  (qtpaths6 `QT_INSTALL_QML`, фолбэк find по `*.qmltypes`); qmllint и QML-метаданные
  обязательны — нет веток «WARNING skip»; добавлен `scripts/smoke.sh` (headless
  offscreen load Main.qml); CI переписан на distro-матрицу: PR = Ubuntu (compat) +
  Arch (authoritative, Qt 6.11, offscreen smoke), merge в dev = Arch/CachyOS/Fedora/
  Nobara/Ubuntu/Debian/RHEL9/openSUSE.
- Следующее: **stage 1.3 — Minute Orbital** (`0.1.2-mvp`).
- Блокеры: нет.

### Тик-лист ROADMAP (Phase 1 — MVP)

- [x] 1.1 Root + scaling + background — `0.1.0-mvp` ✅
- [x] 1.2 Digital clock + indicator pill — `0.1.1-mvp` ✅
- [ ] 1.3 Minute orbital (static + spotlight) — `0.1.2-mvp`
- [ ] 1.4 Second orbital (smooth) — `0.1.3-mvp`
- [ ] 1.5 Login panel (minimal) — `0.1.4-mvp`
- [ ] 1.6 Basic auth feedback — `0.1.5-mvp`
- [ ] 1.7 MVP freeze — `0.1.9-mvp`

### Детали изменений (для агентов)

- `validate.sh` — qmllint candidates: `qmllint6`, `qmllint-qt6`, `qmllint`,
  `/usr/lib/qt6/bin/qmllint`, `/usr/lib/qt6/libexec/qmllint`,
  `/usr/lib64/qt6/{bin,libexec}/qmllint`; QML root через `qtpaths6 --query
  QT_INSTALL_QML` + фолбэк find `*.qmltypes`; hard-fail при отсутствии qmllint,
  root или `*.qmltypes` (приём ≥1 файла: Fedora даёт `plugins.qmltypes`, Arch/etc
  `builtins.qmltypes`/`jsroot.qmltypes`).
- `scripts/smoke.sh` — новый; `QT_QPA_PLATFORM=offscreen` +
  `QT_QUICK_BACKEND=software`; grace 15s (`SMOKE_SECS`); exit 0 при timeout/clean,
  FAIL при раннем краше.
- `.github/workflows/ci.yml` — rewrite: `validate` (Ubuntu hosted, Qt 6.4),
  `validate-arch` (archlinux:latest, Qt 6.11, smoke), `distro-matrix` (push-only,
  matrix: arch, cachyos, fedora, nobara→fedora, ubuntu 24.04, debian bookworm,
  ubi9+EPEL, opensuse tumbleweed; smoke только arch/cachyos).
- Research facts: qmltypes живут в runtime-пакетах; SDDM headless требует оба env;
  Qt spread 6.4 (Deb/Ubuntu)…6.11 (Arch/CachyOS/openSUSE); Nobara — нет образа;
  Leap 15.6 без Qt6.

### Тех. долг

- RHEL 10 (UBI10, Qt6 в базовом AppStream) не в матрице — добавить при необходимости.
- Полноценный `sddm-greeter-qt6 --test-mode` runtime — отложен до этапа с реальным
  Wayland/сессиями (1.3+/1.5); `scripts/smoke.sh` пока заменяет.
- Git-agnostic хранилище: контейнер-образ `qt6.11-qmltooling` из прошлого hotfix
  больше не нужен (заменён archlinux:latest) — запись о нём в нижней записи
  остаётся исторической.

### Принятые решения

- PRIMARY/authoritative = Arch + CachyOS (rolling, Qt 6.11, реальная эксплуатация
  SDDM); COMPATIBILITY = Fedora/Nobara/Ubuntu/Debian/RHEL/openSUSE.
- PR-гейт = 2 джоба (быстро); merge-в-dev = полная матрица (дёшево, раз на merge).
- Отказ от WARNING-skip в validate.sh: отсутствие CI-тулинга = дефект окружения,
  а не причина молчать.

---

## [0.1.1-mvp] — stage 1.2 · review follow-ups (CR-F1…F6) · 2026-09-08

**Версия:** без bump (не этап по ROADMAP — follow-up pass к stage 1.2; версия остаётся `0.1.1-mvp`)

### Статус и следующий шаг

- Сделано: закрыты 6 замечаний ревью Stage 1.2 — CR-F1 (TimeProvider владеет 1s-таймером через `property Timer tickTimer`), CR-F2 (реальный Qt6 QML type-check в CI: `qt6-declarative-dev` + `qml6-module-qtqml`, hard-fail при отсутствии `jsroot.qmltypes`, authority-проверка Qt 6.11), CR-F3 (явный checked-SHA в CI-отчётах), CR-F4 (честный тех.долг в CHANGELOG), CR-F5 (честная семантика preview `-W/-H` vs `Screen`), CR-F6 (явное вертикальное центрирование в DigitalClock вместо baseline-on-Rect).
- Следующее: **stage 1.3 — Minute Orbital** (`0.1.2-mvp`).
- Блокеры: нет (после закрытия F1..F6).

### Тик-лист ROADMAP (Phase 1 — MVP)

- [x] 1.1 Root + scaling + background — `0.1.0-mvp` ✅
- [x] 1.2 Digital clock + indicator pill — `0.1.1-mvp` ✅ (follow-up F1..F6 в этом hotfix)
- [ ] 1.3 Minute orbital (static + spotlight) — `0.1.2-mvp`
- [ ] 1.4 Second orbital (smooth) — `0.1.3-mvp`
- [ ] 1.5 Login panel (minimal) — `0.1.4-mvp`
- [ ] 1.6 Basic auth feedback — `0.1.5-mvp`
- [ ] 1.7 MVP freeze — `0.1.9-mvp`

### Детали изменений (для агентов)

- `components/clock/TimeProvider.qml` — CR-F1: `import QtQml` (QtObject и Timer — тип модуля QtQml, НЕ QtQuick); `property Timer tickTimer: Timer{interval:1000; running:true; repeat:true; onTriggered: provider.update()}` — TimeProvider стал владельцем таймера.
- `components/clock/DigitalClock.qml` — CR-F1: inline `Timer {}` удалён (DigitalClock только потребляет `_time.update()`); CR-F6: `anchors.baseline: pillItem.baseline` → `anchors.verticalCenter: parent.verticalCenter` (запрет baseline на Rect).
- `validate.sh:98-133` — Layer 4: QML root через `qtpaths6 --query QT_INSTALL_QML` (distro-aware) + find-фолбэк на `jsroot.qmltypes` (locals без bin от qtpaths6); jsroot обязателен → hard FAIL; degraded-skip удалён.
- `.github/workflows/ci.yml` — install: `qt6-declarative-dev` (jsroot.qmltypes + транзитивно qmllint/qtpaths6) + `qml6-module-qtqml` (Timer) + `qml6-module-qtquick`; шаг «QML syntax check (hard)» через `QT_INSTALL_QML`; добавлен job `qt6-authority` (Qt 6.11 контейнер `ghcr.io/onyx-sddm/qt6.11-qmltooling:latest`, runtime-smoke + qmllint; warning, если образ не существует).
- `scripts/preview.sh` — CR-F5: проверена честная семантика в `--help` Notes (`-W/-H` задают только wrapper-окно; рендер по `Screen.width/height`; `-o` = натуральный размер).
- Проверено: qmllint Qt6.11 (exit 0), `./validate.sh` (OK), preview-smoke (PNG создаётся), тик живых секунд (md5 двух скриншотов различаются).

### Тех. долг

- Контейнерный образ `ghcr.io/onyx-sddm/qt6.11-qmltooling:latest` НЕ собран — job `qt6-authority` пока в warning-режиме. Построить образ (Qt 6.11 + qmltooling + qtpaths6) = следующий follow-up.
- Полный исторический тех.долг stage 1.1/1.2 — в записях ниже и в `docs/ARCHITECTURE.md`.

### Принятые решения

- `property Timer tickTimer: Timer{}` в TimeProvider — итоговое решение F1 (одобрено пользователем): Qt 6.11 runtime-ориентир; прямой child `Timer{}` внутри `QtObject` в Qt 6.11.2 фатален («Cannot assign to non-existent default property»).
- Ubuntu Qt 6.4 в CI остаётся primary compatibility-lint; authority-проверка Qt 6.11 — контейнерный job (не блокер при отсутствии образа).
- Baseline текста поверх прямоугольника-пилла запрещён: вертикальное центрирование в Row-предке (F6) — pixel-perfect и предсказуемо.

---

## [0.1.1-mvp] — stage 1.2 · Digital clock + indicator pill · 2026-09-08

**Версия:** `0.1.1-mvp` (PATCH bump после stage 1.2; тег/релиз НЕ ставится — это stage, не веха)

### Статус и следующий шаг

- Сделано: TimeProvider (1s timer, curH/curM/curS), DigitalClock (hours 110×s, Sans Serif Black), IndicatorPill (330×90×s, min|sec, divider), Main.qml integration (centered).
- Следующее: **stage 1.3 — Minute Orbital** (`0.1.2-mvp`).
- Блокеры: нет.

### Тик-лист ROADMAP (Phase 1 — MVP)

- [x] 1.1 Root + scaling + background — `0.1.0-mvp` ✅
- [x] 1.2 Digital clock + indicator pill — `0.1.1-mvp` ✅ THIS
- [ ] 1.3 Minute orbital (static + spotlight) — `0.1.2-mvp`
- [ ] 1.4 Second orbital (smooth) — `0.1.3-mvp`
- [ ] 1.5 Login panel (minimal) — `0.1.4-mvp`
- [ ] 1.6 Basic auth feedback — `0.1.5-mvp`
- [ ] 1.7 MVP freeze — `0.1.9-mvp`

### Детали изменений (для агентов)

- `components/clock/TimeProvider.qml` — QtObject, Timer 1000ms, `curH`/`curM`/`curS` (zero-padded strings), `curTime` ("HH:MM"). Created Task 1.
- `components/clock/IndicatorPill.qml` — Rectangle 330×90×s, left=minText, center=divider, right=secText. Created Task 2.
- `components/clock/DigitalClock.qml` — Row container: hourText (110×s, Sans Serif Black, #FFFFFF) + IndicatorPill. Created Task 3.
- `Main.qml:17-21` — DigitalClock instance (Clock.DigitalClock namespaced directory import), anchored `centerIn: parent`, `s=root.s`. Task 4.
- Отклонение от плана: Timer в TimeProvider объявлен как `property Timer tickTimer` — в runtime Qt 6.11.2 прямой child `Timer {}` внутри `QtObject` фатален («Cannot assign to non-existent default property»), компонент не грузится; плановый `import "X.qml" as X` не работает в Qt6.11 для компонентов theme — используем namespaced directory import (Main) и sibling-resolution (DigitalClock).

### Тех. долг

- На момент закрытия 1.2: CI on Ubuntu 6.4 не мог резолвить `Timer` (отсутствие `jsroot.qmltypes` / `qml6-module-qtqml`); закрыто в hotfix CR-F2.
- Baseline `Text`↔`Rectangle` в `DigitalClock.qml` — заменён на явное вертикальное центрирование (CR-F6).
- Authority-проверка Qt 6.11 (контейнер `qt6.11-qmltooling`) — образ ещё не собран, job в warning-режиме (CR-F2/тех. долг).

### Принятые решения

- TimeProvider — отдельный QtObject (не в ThemeState), потому что время ортогонально конфигурации темы.
- Шрифт `"Sans Serif"` (Qt generic fallback) для всех текстовых элементов — Inter не bundled и недоступен на целевых системах как системный; Inter bundling — отдельный этап (stage 2.x+). `"Sans Serif"` гарантирует работу в preview и в greeter на любом дистрибутиве.
- pill color: фон `#1A1A1A`, минуты `#CCCCCC`, секунды `#888888` — достаточно контрастно на чёрном фоне, не отвлекая от основных часов.

---

## [0.1.0-mvp] — stage 1.1 · hotfix preview/ARCHITECTURE · 2026-09-08

**Версия:** без bump (горячий фикс после follow-up pass; версия остаётся `0.1.0-mvp`)

### Статус и следующий шаг

- Сделано: явный `import QtQuick.Window` в генерируемом wrapper'е `scripts/preview.sh` (риск `Window is not a type` на части Qt6-сборок); честная семантика `-W/-H`/`-o` (тема рендерится по `Screen`, а не по окну; скриншот — натуральный размер theme root); ARCHITECTURE.md синхронизирован на `qml6`/`qml` (убраны `qmlscene`/`QuickShell`).
- Следующее: **stage 1.2 — Digital clock + indicator pill** (`0.1.1-mvp`).
- Блокеры: нет.

### Детали изменений (для агентов)

- `scripts/preview.sh` — wrapper-heredoc: `import QtQuick` + `import QtQuick.Window`; usage/Notes: `-W/-H` = размер viewing window, theme root следует `Screen.width/height`; `-o` = grabToImage в натуральном размере item (= Screen). Xvfb для честных разрешений — tech debt.
- `docs/ARCHITECTURE.md:28,257,263` — замены `QuickShell`/`qmlscene` → `qml6`/`qml`; версия док. 0.2.2.
- Код темы не менялся.

### Тех. долг

- Честный рендер конкретного разрешения (1920×1080 / 2560×1440) в превью требует Xvfb или greeter на дисплее нужного разрешения — отложено (R4/CR-4 related; естественный дом stage 3.8 HiDPI & multi-monitor).

### Принятые решения

- Хотя на локальной машине (Qt 6.11.2) `import QtQuick` один даёт `Window` работоспособным (за счёт depends-модуля), явный импорт обязателен для переносимости — принято, реализовано.
- `-W/-H` НЕ позиционируются как «изменение разрешения темы» — честно задокументировано в `--help`.

---

## [0.1.0-mvp] — stage 1.1 · review follow-ups (CR-1…CR-5) · 2026-09-08

**Версия:** без bump (не этап по ROADMAP — follow-up pass к stage 1.1; версия остаётся `0.1.0-mvp`)

### Статус и следующий шаг

- Сделано: применены замечания ревью Stage 1.1 (veredict APPROVED WITH MINOR FINDINGS): CR-1 (scale ownership синхронизирован в ARCHITECTURE), CR-2 (validate.sh — 4 слоя проверки, включая qmllint), CR-3 (в AGENTS.md §8 — правило явных CI-доказательств), CR-4 (scripts/preview.sh + моки sddm/config), ревью-файл переименован по конвенции `YYYY-MM-DD-stage-X-Y.md` (2026-09-08-stage-1.1.md).
- Следующее: **stage 1.2 — Digital clock + indicator pill** (`0.1.1-mvp`). CR-5 (multi-screen Screen.width/height) — INFO, проверить при stage 3.8 (HiDPI/multi-monitor) или раньше по возможности.
- Блокеры: нет.

### Детали изменений (для агентов)

- `docs/ARCHITECTURE.md:5.1` — scale ownership: scale считает ТОЛЬКО `Main.qml`; `ThemeState` получает `s`; компоненты потребляют через composition/state (CR-1). Версия документа → 0.2.1.
- `validate.sh:1-113` — слоёная валидация: required files → metadata.desktop (QtVersion exact 6, MainScript/ConfigFile existence) → theme.conf keys (type/color/bgColor) → qmllint (приоритет Qt6 бинаря: `qmllint6` → `/usr/lib/qt6/bin/qmllint` → `qmllint`; fallback-флаги `--unqualified=info --import=info`) (CR-2).
- `scripts/preview.sh:1-151` — превью-раннер Qt6 (qml6 auto-detect, не qmlscene); `--mock`, `-W/-H` (временный wrapper-Window), `-o` (grabToImage-скриншот через временный wrapper); trap cleanup EXIT INT TERM (CR-4).
- `preview/MockSddm.qml` — QtObject-заглушка `sddm` (hostName + стабы login/powerOff/reboot); `preview/MockConfig.qml` — QtObject `bgColor` (CR-4).
- `AGENTS.md:§8` — требование явных CI-доказательств в отчёте закрытия этапа (workflow name, commit SHA, run ID, jobs PASS/FAIL) (CR-3).
- `docs/code-reviews/2026-09-08-stage-1.1.md` — ревью Stage 1.1 (переименовано из `Stage 1.1 Code Review.md`).
- Код темы `theme/onyx/**` НЕ менялся (CR-5 — на будущее, INFO).
- Git: commits follow-up pass (7 коммитов), PR → merge в `dev`.

### Тех. долг

- Полная инжекция `sddm`/`config` в превью требует C++-хендла или кастомного qml runner (context-properties создаёт greeter). Сейчас `--mock` — best-effort с warning (CR-4, частично).
- CR-5 (multi-screen `Screen.width/height`) — проверить при stage 3.8. Вопрос открыт: один greeter на экран или нет.
- `preview.png` — появится с первым визуалом (stage 1.2+).

### Принятые решения

- Follow-up pass к Stage 1.1 выполнен сразу после ревью, до старта Stage 1.2 (AGENTS.md §3.3 — follow-up'ы из ревью обязаны войти в план следующего этапа).
- Для превью используем `qml6`/`qml`; `qmlscene` (Qt5.15) исключён.
- validate.sh: приоритет Qt6-qmllint выше голого `qmllint` (на CachyOS `qmllint` = Qt5.15, чтобы не давать ложный FAIL на валидном Qt6-коде).

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