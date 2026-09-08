#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
THEME_QML="${ROOT_DIR}/theme/onyx/Main.qml"
MOCK_SDDM="${ROOT_DIR}/preview/MockSddm.qml"
MOCK_CONFIG="${ROOT_DIR}/preview/MockConfig.qml"

usage() {
    cat <<EOF
Usage: $0 [options]

Preview the Onyx SDDM theme with a Qt6 QML runner (qml6, falls back to qml).

  --mock            best-effort injection of sddm/config mocks (see note)
  -W, --width N     window width  (via temp wrapper; qml6 has no CLI flag)
  -H, --height N    window height (via temp wrapper; qml6 has no CLI flag)
  -o, --output FILE.png
                    save a screenshot (via temp grabToImage wrapper)
  -h, --help        show this help and exit

Notes:
  - qml6/qml expose no --width/--height or --output flags, so size and
    screenshots are produced with temporary wrapper .qml files (in /tmp,
    removed on exit). Without -W/-H the size follows the current screen.
  - qml6 cannot inject sddm/config context-properties from the CLI (they
    are provided by the greeter). --mock only warns; the theme degrades
    gracefully via ThemeState.isPreview (background #000000). Fixtures:
    preview/MockSddm.qml + preview/MockConfig.qml for a future harness.
EOF
}

RUNNER=""
detect_runner() {
    if command -v qml6 >/dev/null 2>&1; then
        RUNNER="qml6"
    elif command -v qml >/dev/null 2>&1; then
        RUNNER="qml"
    else
        echo "ERROR: no QML runner found (qml6 or qml). Install qt6-declarative." >&2
        exit 1
    fi
}

WIDTH=""
HEIGHT=""
OUTPUT=""
MOCK=0

while (( $# )); do
    case "$1" in
        --mock) MOCK=1 ;;
        -W|--width)
            [[ $# -ge 2 ]] || { echo "$0: $1 requires an argument" >&2; exit 1; }
            WIDTH="$2"; shift ;;
        -H|--height)
            [[ $# -ge 2 ]] || { echo "$0: $1 requires an argument" >&2; exit 1; }
            HEIGHT="$2"; shift ;;
        -o|--output)
            [[ $# -ge 2 ]] || { echo "$0: $1 requires an argument" >&2; exit 1; }
            OUTPUT="$2"; shift ;;
        -h|--help) usage; exit 0 ;;
        *) echo "$0: unknown option: $1" >&2; usage >&2; exit 1 ;;
    esac
    shift
done

detect_runner

if [[ "${MOCK}" -eq 1 ]]; then
    echo "WARNING: full sddm injection requires the greeter context; " \
         "mocks provided at ${MOCK_SDDM} + ${MOCK_CONFIG} for future harness. " \
         "Running graceful preview (ThemeState.isPreview)." >&2
fi

[[ -f "${THEME_QML}" ]] || { echo "ERROR: theme not found at ${THEME_QML}" >&2; exit 1; }

need_wrapper=0
if [[ -n "${WIDTH}" || -n "${HEIGHT}" || -n "${OUTPUT}" ]]; then
    need_wrapper=1
fi

WRAPPER=""
cleanup() { [[ -n "${WRAPPER}" && -f "${WRAPPER}" ]] && rm -f "${WRAPPER}"; }
trap cleanup EXIT INT TERM

build_wrapper() {
    local w="${WIDTH:-640}"
    local h="${HEIGHT:-480}"
    WRAPPER="$(mktemp --suffix=.qml)"

    local qml
    read -r -d '' qml <<EOF || true
import QtQuick

Window {
    width: ${w}
    height: ${h}
    visible: true
    title: "Onyx preview"
    color: "#000000"

    Loader {
        id: themeLoader
        anchors.fill: parent
        source: "${THEME_QML}"
    }

$(
    if [[ -n "${OUTPUT}" ]]; then
        cat <<INNER
    Timer {
        interval: 1500
        running: true
        repeat: false
        onTriggered: {
            themeLoader.item.grabToImage(function(result) {
                result.saveToFile("${OUTPUT}")
                Qt.quit()
            })
        }
    }

    Component.onCompleted: {
        themeLoader.statusChanged.connect(function() {
            if (themeLoader.status === Loader.Error)
                Qt.quit()
        })
    }
INNER
    fi
)
}
EOF
    printf '%s\n' "${qml}" > "${WRAPPER}"
}

run_preview() {
    local extra=()
    if [[ "${RUNNER}" == "qml" ]]; then
        extra+=(--no-scaling)
    fi
    if [[ "${need_wrapper}" -eq 1 ]]; then
        build_wrapper
        "${RUNNER}" "${extra[@]}" "${WRAPPER}"
    else
        "${RUNNER}" "${extra[@]}" "${THEME_QML}"
    fi
}

run_preview
