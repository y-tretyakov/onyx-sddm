#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
RUNNER="qml6"
OUT_PREFIX="/tmp/onyx-mvp"
DISPLAY_NUM=":99"
WAIT_SECS=12

RES="${RES:-}"
RESOLUTIONS=()
if [[ -n "$RES" ]]; then
    RESOLUTIONS=("$RES")
else
    RESOLUTIONS=("1920 1080" "2560 1440")
fi

cleanup() {
    for pid in "${QT_PID:-}" "${XVFB_PID:-}"; do
        [[ -n "$pid" ]] && kill "$pid" 2>/dev/null || true
    done
    pkill -f "Xvfb ${DISPLAY_NUM}" 2>/dev/null || true
}
trap cleanup EXIT

for pair in "${RESOLUTIONS[@]}"; do
    W=$(echo "$pair" | awk '{print $1}')
    H=$(echo "$pair" | awk '{print $2}')
    OUT="${OUT_PREFIX}-${W}x${H}.png"
    SCREEN="${W}x${H}x24"

    echo "[+] Rendering ${W}x${H} ..."

    Xvfb "${DISPLAY_NUM}" -screen 0 "$SCREEN" -nolisten tcp &
    XVFB_PID=$!
    sleep 2

    DISPLAY="${DISPLAY_NUM}" QT_QPA_PLATFORM=xcb QT_QUICK_BACKEND=software \
        timeout 30 "$RUNNER" "$ROOT_DIR/theme/onyx/Main.qml" &
    QT_PID=$!
    sleep "$WAIT_SECS"

    # Capture via ffmpeg (import produces grayscale on some Xvfb configs)
    if ! DISPLAY="${DISPLAY_NUM}" ffmpeg -f x11grab -video_size "${W}x${H}" \
         -i "${DISPLAY_NUM}" -frames:v 1 -y "$OUT" >/dev/null 2>&1; then
        echo "[FAIL] ffmpeg capture failed for ${W}x${H}"
        exit 1
    fi

    if [[ ! -f "$OUT" ]]; then
        echo "[FAIL] PNG not created: $OUT"
        exit 1
    fi

    FILE_SIZE=$(stat -c%s "$OUT")
    echo "[OK] ${W}x${H} → $OUT (${FILE_SIZE} bytes)"

    kill "$QT_PID" 2>/dev/null || true
    wait "$QT_PID" 2>/dev/null || true
    kill "$XVFB_PID" 2>/dev/null || true
    wait "$XVFB_PID" 2>/dev/null || true
    unset QT_PID XVFB_PID
    sleep 1
done

echo "[ OK ] renders:1920x1080 ${OUT_PREFIX}-1920x1080.png, 2560x1440 ${OUT_PREFIX}-2560x1440.png"
exit 0
