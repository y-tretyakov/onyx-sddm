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