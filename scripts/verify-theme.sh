#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
THEME_DIR="${ROOT_DIR}/theme/onyx"

usage() {
    cat <<EOF
Usage: $0

End-to-end validation of the Onyx SDDM theme (local checks only):
  1. Structure — required theme files present and readable
  2. metadata.desktop — Version= and X-SDDM-ThemeName= present
  3. theme.conf — readable, has key=value pairs
  4. validate.sh — full validation pass (repo root)
5. smoke.sh — headless load test, SMOKE_SECS=12
   6. auth-feedback-probe.qml — offscreen probe (qml6 / qml)
   7. windup-probe.qml — offscreen windup/boom/fade-in + ring-mix probe
8. tickfeedback-probe.qml — offscreen tick feedback flash/halo probe
    9. sparks-burst-probe.qml — offscreen sparks intensity/burst probe
   10. date-reveal-probe.qml — offscreen date+weekday stagger reveal probe
   11. user-session-probe.qml — offscreen pickers + sddm.login wiring probe
12. hud-probe.qml — offscreen reboot/power click-through + hover surface probe
   13. i18n-probe.qml — language detection + translation switch + fallback probe
   14. virtual-cursor-probe.qml — cursor hidden on non-Wayland + instant x/y binding probe
   15. registration regressions (forbidden tokens)

Every check prints [ OK ] or [ FAIL ]; any [ FAIL ] exits 1 immediately.
Final success line: [ OK ] verify OK. Exit 0 = all passed.

Requires: bash, qml6 (or qml), QT offscreen platform support.
No root privileges; does not touch /usr/share.
EOF
}

case "${1:-}" in
    -h|--help) usage; exit 0 ;;
esac

ok()   { echo "[ OK ] $1"; }
fail() { echo "[ FAIL ] $1" >&2; exit 1; }

# --- 1. Theme structure ---
echo "--- 1. structure ---"
for f in Main.qml ThemeState.qml theme.conf metadata.desktop translations.js PROVENANCE.txt; do
    if [[ -r "${THEME_DIR}/${f}" ]]; then
        ok "${f} present"
    else
        fail "${f} missing or unreadable in theme/onyx"
    fi
done

if [[ -n "$(ls -A "${THEME_DIR}/font/" 2>/dev/null)" ]]; then
    ok "theme/onyx/font/ has files"
else
    fail "theme/onyx/font/ empty"
fi

if [[ -n "$(ls -A "${THEME_DIR}/icons/" 2>/dev/null)" ]]; then
    ok "theme/onyx/icons/ has files"
else
    fail "theme/onyx/icons/ empty"
fi

for f in clock/ClockRoot.qml clock/DateBlock.qml clock/IndicatorPill.qml clock/OrbitalRing.qml clock/TimeProvider.qml effects/AnimEngine.qml effects/qmldir effects/Sparks.qml effects/Burst.qml effects/StaggerText.qml login/LoginPanel.qml login/AuthFeedback.qml login/UserPicker.qml login/SessionPicker.qml hud/LangPicker.qml hud/HudAction.qml hud/HudActions.qml platform/VirtualCursor.qml; do
    if [[ -r "${THEME_DIR}/components/${f}" ]]; then
        ok "components/${f} present"
    else
        fail "components/${f} missing or unreadable"
    fi
done

# --- 2. metadata.desktop ---
echo "--- 2. metadata.desktop ---"
if grep -q '^Version=' "${THEME_DIR}/metadata.desktop"; then
    ok "Version= present"
else
    fail "Version= missing in metadata.desktop"
fi
if grep -q '^X-SDDM-ThemeName=' "${THEME_DIR}/metadata.desktop"; then
    ok "X-SDDM-ThemeName= present"
else
    fail "X-SDDM-ThemeName= missing in metadata.desktop"
fi

# --- 3. theme.conf ---
echo "--- 3. theme.conf ---"
if [[ -r "${THEME_DIR}/theme.conf" ]]; then
    ok "theme.conf readable"
else
    fail "theme.conf unreadable"
fi
if grep -qE '^[A-Za-z0-9_]+=' "${THEME_DIR}/theme.conf"; then
    ok "theme.conf has key=value pairs"
else
    fail "theme.conf has no key=value pairs"
fi

# --- 4. validate.sh ---
echo "--- 4. validate.sh ---"
if "${ROOT_DIR}/validate.sh"; then
    ok "validate.sh passed"
else
    fail "validate.sh failed"
fi

# --- 5. smoke.sh ---
echo "--- 5. smoke.sh (SMOKE_SECS=12) ---"
SMOKE_LOG="$(mktemp)"
if SMOKE_SECS=12 "${ROOT_DIR}/scripts/smoke.sh" >"${SMOKE_LOG}" 2>&1; then
    rm -f "${SMOKE_LOG}"
    ok "smoke passed (12s offscreen)"
else
    rc=$?
    echo "--- smoke log ---" >&2
    cat "${SMOKE_LOG}" >&2 || true
    rm -f "${SMOKE_LOG}"
    fail "smoke failed (exit ${rc})"
fi

# --- 6. auth-feedback-probe ---
echo "--- 6. auth-feedback-probe ---"
RUNNER=""
if command -v qml6 >/dev/null 2>&1; then
    RUNNER="qml6"
elif command -v qml >/dev/null 2>&1; then
    RUNNER="qml"
else
    fail "no QML runner found (qml6 or qml)"
fi

if QT_QPA_PLATFORM=offscreen timeout 12 "${RUNNER}" "${ROOT_DIR}/scripts/qa/auth-feedback-probe.qml"; then
    ok "auth-feedback-probe passed (480x200 offscreen)"
else
    fail "auth-feedback-probe failed"
fi

# --- 7. windup-probe ---
echo "--- 7. windup-probe ---"
if QT_QPA_PLATFORM=offscreen timeout 18 "${RUNNER}" "${ROOT_DIR}/scripts/qa/windup-probe.qml"; then
    ok "windup-probe passed (windup→boom→fadeIn + ring windup mix)"
else
    fail "windup-probe failed"
fi

# --- 8. tickfeedback-probe ---
echo "--- 8. tickfeedback-probe ---"
if QT_QPA_PLATFORM=offscreen timeout 12 "${RUNNER}" "${ROOT_DIR}/scripts/qa/tickfeedback-probe.qml"; then
    ok "tickfeedback-probe passed (flash + halo live values)"
else
    fail "tickfeedback-probe failed"
fi

# --- 9. sparks-burst-probe ---
echo "--- 9. sparks-burst-probe ---"
if QT_QPA_PLATFORM=offscreen timeout 12 "${RUNNER}" "${ROOT_DIR}/scripts/qa/sparks-burst-probe.qml"; then
    ok "sparks-burst-probe passed (intensity spike + sec/min/hour bursts)"
else
    fail "sparks-burst-probe failed"
fi

# --- 10. date-reveal-probe ---
echo "--- 10. date-reveal-probe ---"
if QT_QPA_PLATFORM=offscreen timeout 18 "${RUNNER}" "${ROOT_DIR}/scripts/qa/date-reveal-probe.qml"; then
    ok "date-reveal-probe passed (date/weekday stagger + blur sharpen)"
else
    fail "date-reveal-probe failed"
fi

# --- 11. user-session-probe ---
echo "--- 11. user-session-probe ---"
if QT_QPA_PLATFORM=offscreen timeout 12 "${RUNNER}" "${ROOT_DIR}/scripts/qa/user-session-probe.qml"; then
    ok "user-session-probe passed (UserPicker/SessionPicker selection wiring)"
else
    fail "user-session-probe failed"
fi

# --- 12. hud-probe ---
echo "--- 12. hud-probe ---"
if QT_QPA_PLATFORM=offscreen timeout 12 "${RUNNER}" "${ROOT_DIR}/scripts/qa/hud-probe.qml"; then
    ok "hud-probe passed (reboot/power click-through + hover surface)"
else
    fail "hud-probe failed"
fi

# --- 13. i18n-probe ---
echo "--- 13. i18n-probe ---"
if QT_QPA_PLATFORM=offscreen timeout 12 "${RUNNER}" "${ROOT_DIR}/scripts/qa/i18n-probe.qml"; then
    ok "i18n-probe passed (language detect + switch + fallback)"
else
    fail "i18n-probe failed"
fi

# --- 14. virtual-cursor-probe ---
echo "--- 14. virtual-cursor-probe ---"
if QT_QPA_PLATFORM=offscreen timeout 12 "${RUNNER}" "${ROOT_DIR}/scripts/qa/virtual-cursor-probe.qml"; then
    ok "virtual-cursor-probe passed (hidden off-Wayland + instant x/y)"
else
    fail "virtual-cursor-probe failed"
fi

# --- 15. registration regressions ---
echo "--- 15. registration regressions ---"
for _bad in "userModel.data(" "smoothHand" "currentIndex"; do
    if rg -F -l --glob "*.qml" "$_bad" theme/onyx/components/clock/; then
        echo "FAIL: forbidden token '$_bad' present in clock components" >&2
        exit 1
    fi
done
# ADR-1.8-1: pickers read roles via helper-ListView, never userModel.data().
if rg -F -l --glob "*.qml" "userModel.data(" theme/onyx/components/login/ theme/onyx/Main.qml; then
    echo "FAIL: forbidden token 'userModel.data(' present in login components" >&2
    exit 1
fi
echo "registration regressions: PASS"

echo "[ OK ] verify OK"
exit 0
