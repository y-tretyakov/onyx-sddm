# CI Distro-Matrix Rework & Distro-independent validate.sh — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Заменить Ubuntu-центричную CI-архитектуру на реальную multi-distro матрицу с Arch/CachyOS как authoritative, и сделать `validate.sh` дистрибутив-независимым (работает от установленного Qt, а не от захардкоженных путей; никаких `WARNING exit 0` при отсутствии метаданных).

**Architecture:** (1) `validate.sh` Layer 4 обнаруживает активный Qt-инсталл через `qtpaths6 --query QT_INSTALL_QML`, падает ошибкой, если root/`*.qmltypes` недоступен; (2) CI: PR-гейт = Ubuntu hosted (compat) + Arch контейнер (authoritative, с offscreen-смоуком); merge-в-dev = полная матрица 8 дистрибутивов через `strategy.matrix` + `container:`. Каждый дистрибутив ставит только runtime-пакеты Qt6 (+ dev-tools где qmllint в dev-пакете); qmltypes лежат в runtime-пакетах (проверено исследованием).

**Tech Stack:** GitHub Actions (`container:`, `strategy.matrix`), bash (`validate.sh`, `scripts/smoke.sh`), Qt6 QML (`qmllint`, `qml6`/`qml`, `qtpaths6`), pacman/dnf/apt/zypper.

**Spec:** замечание пользователя 2026-09-08 «F2 надо не чинить Ubuntu, а переделать CI-архитектуру под реальную distro matrix» + `docs/superpowers/research/2026-09-08-ci-distro-matrix.md` + `docs/ROADMAP.md` + AGENTS.md §3.

---

## Global Constraints

- **Уровни:** 🔴 PRIMARY (authoritative) = Arch, CachyOS. 🟠 COMPATIBILITY = Fedora, Nobara, Ubuntu, Debian, RHEL, openSUSE.
- **PR-гейт:** Arch + Ubuntu. **Merge-в-dev:** полная матрица. (Решение пользователя.)
- Целевой runtime — Qt 6.11 (Arch/CachyOS/openSUSE). Ubuntu 6.4 / Debian 6.4 / RHEL 6.6 / Fedora 6.10 — compatibility, НЕ диктуют QML-архитектуру; их задача — поймать ложные падения lint/load на старых Qt.
- **Никакого distro-aware `exit 0` при отсутствии qmllint/QML-метаданных** — метаданные недоступны = ERROR + job FAIL.
- `validate.sh` полностью дистрибутив-независим: НИКАКИХ хардкод-путей к `/usr/lib/x86_64-linux-gnu/...`. Всё через `qtpaths6` с безопасным фолбэком.
- qmltypes поставляются РАЗНЫМИ пакетами по дистрибутивам: учитывать `qmllint-qt6` (Fedora), `qt6-declarative-dev-tools` (Deb/Ubuntu), `qt6-declarative-tools` (openSUSE), libexec-путь qmllint (Arch/RHEL). Не требовать только `jsroot.qmltypes` — проверять «есть ≥ 1 `*.qmltypes` в QML root».
- SDDM headless в контейнере: `QT_QPA_PLATFORM=offscreen` + `QT_QUICK_BACKEND=software` (оба обязательны).
- Nobara не имеет офиц. образа → `fedora:latest` как прокси (значение изображения совпадает, комментарий в CI).
- openSUSE Leap 15.6 не имеет Qt6 → только `opensuse/tumbleweed:latest`.
- RHEL: UBI9 + EPEL (`qt6-qtdeclarative` 6.6). UBI10 в базовом AppStream — дополнительная запись, не блокер.
- `scripts/preview.sh`, theme QML, docs/code-reviews/ — НЕ трогаем этим этапом.
- Ветка: `stage/1.2-ci-distro-matrix` (из dev). НЕ bump версии (follow-up к 1.2, не ROADMAP-этап) — фиксируется в CHANGELOG как «без bump».

---

## File Map

| File | Действие |
|------|----------|
| `validate.sh` | Rework Layer 1/4: hard-fail при отсутствии qmllint/QML root/`*.qmltypes`; дистрибутив-независимый поиск бинарей |
| `scripts/smoke.sh` | НОВЫЙ: headless offscreen-смоук темы (load + timeout) |
| `.github/workflows/ci.yml` | Переписать: `validate` (Ubuntu) + `validate-arch` (Authoritative) на PR; `distro-matrix` (8 дистрибутивов) на push в dev |
| `CHANGELOG.md` | Новая запись «без bump» + честный тех.долг + решения |
| `docs/ARCHITECTURE.md` | §9 «Development & Testing Strategy» — обновить CI-строку под матрицу |

---

## Task 1: validate.sh — distro-independent QML validation, hard-fail everywhere

**Files:**
- Modify: `validate.sh`

**Interfaces:**
- Consumes: `<THEME_DIR>` (по умолчанию `theme/onyx`).
- Produces: exit 0 = тема валидна; exit ≠0 = провал с конкретным сообщением. Сигнатуры не меняются — обратно совместим с CI.

- [ ] **Step 1: Заменить поиск qmllint на дистрибутив-независимый набор кандидатов**

В `validate.sh` заменить блок (строки 87–93):

```bash
QMLINT=""
for cand in qmllint6 /usr/lib/qt6/bin/qmllint qmllint; do
    if command -v "${cand}" >/dev/null 2>&1 || [[ -x "${cand}" ]]; then
        QMLINT="${cand}"
        break
    fi
done
```

на:

```bash
QMLINT=""
for cand in \
    qmllint6 \
    qmllint-qt6 \
    qmllint \
    /usr/lib/qt6/bin/qmllint \
    /usr/lib/qt6/libexec/qmllint \
    /usr/lib64/qt6/bin/qmllint \
    /usr/lib64/qt6/libexec/qmllint; do
    if command -v "${cand}" >/dev/null 2>&1 || [[ -x "${cand}" ]]; then
        QMLINT="${cand}"
        break
    fi
done
```

- [ ] **Step 2: hard-fail вместо WARNING-skip при отсутствии qmllint**

Заменить строки 95–97:

```bash
if [[ -z "${QMLINT}" ]]; then
    echo "WARNING: qmllint not found; skipping QML syntax check" >&2
else
```

на:

```bash
if [[ -z "${QMLINT}" ]]; then
    fail "qmllint not found (looked for qmllint6/qmllint-qt6/qmllint + Qt6 libexec paths); cannot validate QML"
    exit 1
fi
```

(qmllint обязателен: «метаданные недоступны = ERROR», не no-op.)

- [ ] **Step 3: QML root — qtpaths6 + фолбэк + hard-fail; проверка ≥1 *.qmltypes**

Заменить блок (строки 98–121):

```bash
    # Resolve Qt6 QML root via qtpaths6 (distro-aware), fallback to find.
    QML_ROOT=""
    if command -v qtpaths6 >/dev/null 2>&1; then
        QML_ROOT="$(qtpaths6 --query QT_INSTALL_QML 2>/dev/null)"
    fi
    if [[ -z "${QML_ROOT}" ]] || [[ ! -d "${QML_ROOT}" ]]; then
        QML_ROOT="$(dirname "$(find /usr/lib /usr/local/lib -type f -name jsroot.qmltypes 2>/dev/null | head -n1)")"
    fi

    if [[ -z "${QML_ROOT}" ]] || [[ ! -d "${QML_ROOT}" ]]; then
        fail "Unable to resolve Qt6 QML root (qtpaths6 missing and no jsroot.qmltypes found); cannot type-check"
        exit 1
    fi

    QML_IMPORT_ROOTS=()
    if [[ -n "${QML_ROOT}" ]] && [[ -d "${QML_ROOT}" ]]; then
        QML_IMPORT_ROOTS+=("-I" "${QML_ROOT}")
    fi

    # jsroot.qmltypes обязателен для реальной проверки типов QtQuick/QtQml.
    # Если нет — это сломанное окружение, а не причина молчать: hard FAIL.
    if [[ -n "${QML_ROOT}" ]] && [[ ! -f "${QML_ROOT}/jsroot.qmltypes" ]]; then
        fail "Qt6 QML root '${QML_ROOT}' lacks jsroot.qmltypes (incomplete Qt6 -dev install); cannot type-check"
    fi
```

на:

```bash
    # Resolve the active Qt6 installation (distro-independent).
    QML_ROOT=""
    QT_VERSION=""
    if command -v qtpaths6 >/dev/null 2>&1; then
        QML_ROOT="$(qtpaths6 --query QT_INSTALL_QML 2>/dev/null)"
        QT_VERSION="$(qtpaths6 --query QT_VERSION 2>/dev/null)"
    fi

    # Fallback: locate any *.qmltypes under the system Qt QML dirs.
    if [[ -z "${QML_ROOT}" ]] || [[ ! -d "${QML_ROOT}" ]]; then
        QML_ROOT="$(dirname "$(find /usr/lib /usr/local/lib -type f -name '*.qmltypes' 2>/dev/null | grep -E '/(qml|qml6)/.*qmltypes$' | head -n1)")"
    fi

    if [[ -z "${QML_ROOT}" ]] || [[ ! -d "${QML_ROOT}" ]]; then
        fail "Unable to resolve Qt6 QML root (qtpaths6 unavailable and no *.qmltypes found); cannot type-check"
        exit 1
    fi

    # Distro-agnostic metadata check: Fedora ships plugins.qmltypes, others
    # builtins/jsroot. Requiring ≥1 *.qmltypes covers all supported distros.
    QMLTYPES_COUNT="$(find "${QML_ROOT}" -maxdepth 1 -name '*.qmltypes' 2>/dev/null | wc -l)"
    if [[ "${QMLTYPES_COUNT}" -eq 0 ]]; then
        fail "Qt6 QML root '${QML_ROOT}' has no *.qmltypes metadata; cannot type-check"
        exit 1
    fi

    echo "  Qt version:  ${QT_VERSION:-unknown}"
    echo "  Qt QML root: ${QML_ROOT}"

    QML_IMPORT_ROOTS=("-I" "${QML_ROOT}")
```

- [ ] **Step 4: Версионировать help-текст (Layer 4 описание)**

Заменить в `usage()` строку:

```
  4. QML syntax (qmllint, if available)
```

на:

```
  4. QML syntax (qmllint, hard-fail if tooling/metadata missing)
```

- [ ] **Step 5: Проверка локально (CachyOS, Qt 6.11)**

```bash
cd /home/code_warlord/DEV/onyx-sddm
bash -n validate.sh
./validate.sh; echo "exit=$?"
```
Expected: синтаксически чисто; `OK: .../theme/onyx`, `exit=0`. Вывод содержит `Qt version: 6.11.x` и `Qt QML root: /usr/lib/qt6/qml`.

- [ ] **Step 6: Негативный сценарий (метаданные недоступны → FAIL) — не здесь, в Task 3 Step 4**

Подтверждение ветки «нет qmllint/root/qmltypes → hard FAIL» выполняется деструктивным прогоном в Task 3 Step 4 (sed-подмена find-корней). Здесь достаточно убедиться, что в коде НЕТ `WARNING`/`skip`-веток: `grep -n "WARNING: qmllint not found\|skipping QML" validate.sh` → пусто.

- [ ] **Step 7: Commit**

```bash
git add validate.sh
git commit -m "fix(validate): distro-independent Qt detection, hard-fail on missing tooling (CR-CI-1)

- resolve QML root via qtpaths6 QT_INSTALL_QML + find-fallback on *.qmltypes
- qmllint search: qmllint6/qmllint-qt6/qmllint + Qt6 libexec paths
- remove WARNING/skip branch: missing qmllint or metadata now hard FAIL
- metadata check accepts any *.qmltypes (covers Fedora plugins.qmltypes)"
```

---

## Task 2: scripts/smoke.sh — headless offscreen smoke of the theme

**Files:**
- Create: `scripts/smoke.sh`

**Interfaces:**
- Consumes: тема в `theme/onyx/Main.qml`; окружение `QT_QPA_PLATFORM`/`QT_QUICK_BACKEND` (выставляет сам).
- Produces: exit 0 = тема загрузилась и отработала ≥15 с без ошибок; exit ≠0 = fail с логом. Используется в authoritative-контейнере.

- [ ] **Step 1: Написать scripts/smoke.sh**

```bash
#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
THEME_QML="${ROOT_DIR}/theme/onyx/Main.qml"
SMOKE_SECS="${SMOKE_SECS:-15}"

usage() {
    cat <<EOF
Usage: $0

Headless smoke of the Onyx theme: loads Main.qml with the Qt6 QML runner
in offscreen/software mode and requires it to survive SMOKE_SECS seconds
(default 15) without a load error.

Exit 0  = theme loaded and rendered offscreen (graceful timeout or clean exit)
Exit !0 = load error / crash early (log printed)

Requires: qml6 (or qml), QT offscreen platform support.
Set SMOKE_SECS to override the grace period (CI uses 15).
EOF
}

case "${1:-}" in
    -h|--help) usage; exit 0 ;;
esac

[[ -f "${THEME_QML}" ]] || { echo "ERROR: theme not found at ${THEME_QML}" >&2; exit 1; }

RUNNER=""
if command -v qml6 >/dev/null 2>&1; then
    RUNNER="qml6"
elif command -v qml >/dev/null 2>&1; then
    RUNNER="qml"
else
    echo "ERROR: no QML runner found (qml6 or qml)" >&2
    exit 1
fi

export QT_QPA_PLATFORM=offscreen
export QT_QUICK_BACKEND=software

echo "Runner:  ${RUNNER}"
echo "Theme:   ${THEME_QML}"
echo "Smoke s: ${SMOKE_SECS}"

LOG="$(mktemp)"
rc=0
timeout "${SMOKE_SECS}" "${RUNNER}" "${THEME_QML}" >"${LOG}" 2>&1 || rc=$?

echo "--- runner log (last 40 lines) ---"
tail -n 40 "${LOG}"
echo "--- exit: ${rc} ---"
rm -f "${LOG}"

# 124 = graceful timeout: theme ran without crashing -> PASS.
# 0   = clean self-exit -> PASS. Anything else -> FAIL.
if [[ "${rc}" -eq 0 || "${rc}" -eq 124 ]]; then
    echo "SMOKE OK: theme survived ${SMOKE_SECS}s offscreen"
    exit 0
fi

echo "SMOKE FAIL: runner exited ${rc} before grace period" >&2
exit 1
```

- [ ] **Step 2: chmod +x и локальный прогон (CachyOS)**

```bash
cd /home/code_warlord/DEV/onyx-sddm
chmod +x scripts/smoke.sh
bash -n scripts/smoke.sh && echo SYNTAX_OK
./scripts/smoke.sh; echo "smoke exit=$?"
```
Expected: `SMOKE OK: theme survived 15s offscreen`, `smoke exit=0`. Лог без фатальных ошибок.

- [ ] **Step 3: Проверка негативного сценария (сломанный QML → FAIL)**

```bash
cd /home/code_warlord/DEV/onyx-sddm
cp theme/onyx/Main.qml /tmp/Main.qml.bak
printf 'import QtQuick\nItem { unreferenced_broken ${ } }\n' > theme/onyx/Main.qml
./scripts/smoke.sh; echo "smoke exit=$?"   # ожидаем !=0 (load error)
mv /tmp/Main.qml.bak theme/onyx/Main.qml
./scripts/smoke.sh; echo "smoke exit=$?"   # снова 0
```
Expected: первый прогон проваливается (или ошибки loader), финальный `smoke exit=0`.

- [ ] **Step 4: Commit**

```bash
git add scripts/smoke.sh
git commit -m "feat(ci): headless offscreen smoke script (scripts/smoke.sh)

- loads Main.qml via qml6/qml with QT_QPA_PLATFORM=offscreen + QT_QUICK_BACKEND=software
- exit 0 on 15s grace (timeout/default) or clean exit; FAIL on early crash
- used as authoritative runtime gate in primary Arch/CachyOS containers"
```

---

## Task 3: Rewrite .github/workflows/ci.yml — distro matrix

**Files:**
- Rewrite: `.github/workflows/ci.yml`

**Interfaces:**
- Consumes: `validate.sh` (distro-independent), `scripts/smoke.sh`, факты исследования (образы/пакеты).
- Produces: PR-гейт (Ubuntu + Arch-authorized) + полная матрица на push в dev; каждый job печатает checked SHA.

- [ ] **Step 1: Полностью переписать workflow**

Записать `.github/workflows/ci.yml` целиком (squash-замена):

```yaml
name: ci

on:
  push:
    branches: [main, dev]
  pull_request:

jobs:
  # --- PR gate: fast hosted compatibility (Ubuntu, Qt 6.4) ---
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Print checked SHA
        run: |
          echo "Checked SHA (PR head): ${GITHUB_SHA}"
          echo "Ref: ${GITHUB_REF}"

      - name: Install Qt6 QML tooling
        run: |
          sudo apt-get update
          sudo apt-get install -y --no-install-recommends \
            qt6-declarative-dev \
            qt6-declarative-dev-tools \
            qt6-qmllint-plugins \
            qml-qt6 \
            qml6-module-qtquick \
            qt6-svg-dev

      - name: Validate theme (structural + qmllint hard)
        run: ./validate.sh

  # --- PR gate: authoritative Arch container (Qt 6.11 + offscreen smoke) ---
  validate-arch:
    runs-on: ubuntu-latest
    container: archlinux:latest
    steps:
      - uses: actions/checkout@v4

      - name: Print checked SHA
        run: |
          echo "Checked SHA (PR head): ${GITHUB_SHA}"
          echo "Ref: ${GITHUB_REF}"

      - name: Install Qt6 QML tooling (Arch)
        run: >
          pacman -Syu --noconfirm
          git qt6-base qt6-declarative qt6-svg

      - name: Validate theme (structural + qmllint hard)
        run: ./validate.sh

      - name: Offscreen smoke (authoritative runtime)
        run: ./scripts/smoke.sh

  # --- Full distro matrix: run on merge to dev/main (push event) ---
  distro-matrix:
    if: github.event_name == 'push'
    needs: [validate, validate-arch]
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        include:
          - distro: arch
            image: archlinux:latest
            install: pacman -Syu --noconfirm git qt6-base qt6-declarative qt6-svg
          - distro: cachyos
            image: cachyos/cachyos:latest
            install: pacman -Syu --noconfirm git qt6-base qt6-declarative qt6-svg
          - distro: fedora
            image: fedora:latest
            install: dnf install -y git qt6-qtbase qt6-qtdeclarative qt6-qtdeclarative-devel qt6-qtsvg
          # Nobara has no official container image; it is Fedora-derived and
          # shares package names. Runtime-specific QA (Wayland/gaming) is done
          # on physical hardware outside CI.
          - distro: nobara
            image: fedora:latest
            install: dnf install -y git qt6-qtbase qt6-qtdeclarative qt6-qtdeclarative-devel qt6-qtsvg
          - distro: ubuntu
            image: ubuntu:24.04
            install: apt-get update && apt-get install -y --no-install-recommends git qt6-declarative-dev qt6-declarative-dev-tools qt6-qmllint-plugins qml-qt6 qml6-module-qtquick qt6-svg-dev
          - distro: debian
            image: debian:bookworm
            install: apt-get update && apt-get install -y --no-install-recommends git qt6-declarative-dev qt6-declarative-dev-tools qt6-qmllint-plugins qml-qt6 qml6-module-qtquick qt6-svg-dev
          - distro: rhel9
            image: registry.access.redhat.com/ubi9/ubi:latest
            install: dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm && dnf install -y git qt6-qtbase qt6-qtdeclarative qt6-qtsvg
          - distro: opensuse
            image: opensuse/tumbleweed:latest
            install: zypper --non-interactive install git qt6-base qt6-declarative qt6-declarative-tools qt6-svg
    container:
      image: ${{ matrix.image }}
    steps:
      - uses: actions/checkout@v4

      - name: Print checked SHA
        run: |
          echo "Checked SHA (PR head): ${GITHUB_SHA}"
          echo "Ref: ${GITHUB_REF}"

      - name: Install Qt6 QML tooling (${{ matrix.distro }})
        run: ${{ matrix.install }}

      - name: Validate theme (structural + qmllint hard)
        run: ./validate.sh

      - name: Offscreen smoke (authoritative only)
        if: matrix.distro == 'arch' || matrix.distro == 'cachyos'
        run: ./scripts/smoke.sh
```

- [ ] **Step 2: YAML-линт**

```bash
cd /home/code_warlord/DEV/onyx-sddm
python3 -c "import yaml,sys; yaml.safe_load(open('.github/workflows/ci.yml')); print('YAML_OK')"
```
(если `pyyaml` нет — `pip install pyyaml` или `sudo dnf/pacman -S python-yaml`; иначе использовать `ruby -e 'require"yaml"; p YAML.load_file(...)'`). Expected: `YAML_OK`.

- [ ] **Step 3: Валидация рабочих эвристик на локальном Qt**

```bash
cd /home/code_warlord/DEV/onyx-sddm
./validate.sh; echo "validate exit=$?"
./scripts/smoke.sh; echo "smoke exit=$?"
```
Expected: оба exit 0 (локально Qt 6.11, эвристики те же, что в контейнерах).

- [ ] **Step 4: Debug — проверка ветки hard-fail через временный env-хук (опция)**

Для ручного подтверждения «нет метаданных = FAIL» — временно подменить каталог, чтобы `find` не нашёл `.qmltypes` (исполняется локально, потом откат):

```bash
cd /home/code_warlord/DEV/onyx-sddm
sed -i 's|/usr/lib /usr/local/lib|/nonexistent-root /nonexistent-root2|' validate.sh
./validate.sh; echo "validate exit=$?"   # expected !=0, сообщение про root
git checkout -- validate.sh
./validate.sh; echo "validate exit=$?"   # expected 0
```
Expected: средний прогон exit ≠0 с «Unable to resolve Qt6 QML root»; финальный exit 0. После проверки `git checkout -- validate.sh` (файл не коммитим с хуком).

- [ ] **Step 5: Commit**

```bash
git add .github/workflows/ci.yml
git commit -m "ci: distro matrix (Arch/CachyOS authoritative) + PR gate; hard QML gate everywhere (CR-CI-2)

- PR gate: validate (Ubuntu, Qt 6.4 compat) + validate-arch (Arch 6.11, offscreen smoke)
- push to dev: distro-matrix runs Arch, CachyOS, Fedora, Nobara, Ubuntu, Debian,
  RHEL9, openSUSE via strategy.matrix + container image per distro
- qmltypes live in runtime pkgs; only dev-tools needed where qmllint lives there
- no distro-specific exit-0 degradation; each job prints checked SHA"
```

---

## Task 4: Docs — CHANGELOG + ARCHITECTURE

**Files:**
- Modify: `CHANGELOG.md`
- Modify: `docs/ARCHITECTURE.md`

**Interfaces:**
- Consumes: этой записи изменения (validate.sh, smoke.sh, ci.yml).
- Produces: честный учёт follow-up + актуальная архитектура CI в ARCHITECTURE §9.

- [ ] **Step 1: CHANGELOG — новая запись «без bump»**

Добавить ЗАПИСЬ ПОСЛЕ шапки (строки 4–6), до существующей `## [0.1.1-mvp] — stage 1.2 · review follow-ups`:

```markdown
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
```

- [ ] **Step 2: ARCHITECTURE.md §9 — обновить CI-строку**

Заменить в `docs/ARCHITECTURE.md`, строка 265:

```
- **CI:** validate.sh + checksums + qml syntax check.
```

на:

```
- **CI:** validate.sh (distro-independent, qmllint hard) + scripts/smoke.sh (offscreen).
  Матрица JSON: Arch/CachyOS authoritative (Qt 6.11), Fedora/Nobara/Ubuntu/Debian/
  RHEL9/openSUSE compatibility (Qt 6.4…6.10). PR — быстрая пара (Arch+Ubuntu),
  merge в dev — полная матрица. Подробности: .github/workflows/ci.yml.
```

и обновить в шапке документа строку версии:

```
**Version of this document:** 0.2.2 · 2026-09-08
```

на:

```
**Version of this document:** 0.2.3 · 2026-09-08
```

- [ ] **Step 3: Проверка согласованности**

`grep -n "0.2.3\|WARNING: qmllint not found\|jsroot.qmltypes\|distro-matrix\|smoke.sh" docs/ARCHITECTURE.md validate.sh .github/workflows/ci.yml CHANGELOG.md` — убедиться: WARNING-строки больше нет, `jsroot.qmltypes` в validate.sh не хардкодит (только в комментариях), версия документа 0.2.3.

- [ ] **Step 4: Commit**

```bash
git add CHANGELOG.md docs/ARCHITECTURE.md
git commit -m "docs: CI distro-matrix in ARCHITECTURE §9 + CHANGELOG entry (CR-CI-3)"
```

---

## Task 5: Plan file + validation + PR

- [ ] **Step 1: Коммит плана и research-файла**

```bash
git add docs/superpowers/plans/2026-09-08-ci-distro-matrix-rework.md \
        docs/superpowers/research/2026-09-08-ci-distro-matrix.md
git commit -m "docs: CI distro-matrix rework plan + research report"
```

- [ ] **Step 2: Полная локальная валидация**

```bash
cd /home/code_warlord/DEV/onyx-sddm
bash -n validate.sh && bash -n scripts/smoke.sh
./validate.sh; echo "validate exit=$?"
./scripts/smoke.sh; echo "smoke exit=$?"
python3 -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml'))" && echo YAML_OK
```
Expected: SYNTAX_OK, validate exit=0, smoke exit=0, YAML_OK.

- [ ] **Step 3: Push + PR**

```bash
git push -u origin stage/1.2-ci-distro-matrix
gh pr create --base dev --head stage/1.2-ci-distro-matrix \
  --title "ci: distro matrix (Arch/CachyOS authoritative) + distro-independent validate.sh" \
  --body "По решению пользователя: F2 переделан из «починить Ubuntu jsroot» в перестройку CI-архитектуры (см. ревью 2026-09-08):

- validate.sh: distro-independent Qt detection (qtpaths6 QT_INSTALL_QML + find *.qmltypes), hard-fail на qmllint/метаданные — никаких WARNING-exit0
- scripts/smoke.sh: headless offscreen load Main.qml (QT_QPA_PLATFORM=offscreen + QT_QUICK_BACKEND=software), grace 15s
- ci.yml: PR = validate (Ubuntu compat) + validate-arch (Arch 6.11 authoritative + smoke); merge в dev = distro-matrix (arch, cachyos, fedora, nobara, ubuntu, debian, rhel9, opensuse), smoke на arch/cachyos
- research: docs/superpowers/research/2026-09-08-ci-distro-matrix.md (образы/пакеты/факты)"
```

- [ ] **Step 4: Дождаться CI, получить PASS**

`gh pr checks --watch`. PR-гейт (validate + validate-arch) должен PASS. Если FAIL — вернуть оркестратору job+run ID + логи.

---

*Plan · CI distro-matrix rework · Onyx · 2026-09-08*