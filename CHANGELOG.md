# Onyx — Changelog

> Единый учёт версий и этапов Onyx. Правила ведения: `AGENTS.md` §3.1–3.2.
> Формат: «сверху вниз», новая версия выше предыдущих. Историю не переписываем.

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