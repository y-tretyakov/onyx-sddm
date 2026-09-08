#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
THEME_QML="${ROOT_DIR}/theme/onyx/Main.qml"

usage() {
    cat <<EOF
Usage: $0 [options]

Preview the Onyx SDDM theme with a Qt6 QML runner (qml6, falls back to qml).

  -W, --width N     viewing window width  (via temp wrapper; qml6 has no CLI flag)
  -H, --height N    viewing window height (via temp wrapper; qml6 has no CLI flag)
  -o, --output FILE.png
                    save a screenshot (via temp grabToImage wrapper)
  -h, --help        show this help and exit

Notes:
  - -W/-H set the *viewing window* size, not the theme render resolution.
    Main.qml binds to Screen.width/height, so if -W/-H differ from the
    display resolution the theme renders at Screen size and the window
    shows a cropped or empty view. Without -W/-H the theme fills the
    current screen.
  - -o saves a screenshot at the theme root's natural size
    (= current Screen.width × Screen.height), regardless of -W/-H.
  - True resolution QA at a specific size (1920×1080 / 2560×1440)
    requires a matching display or Xvfb — out of scope for this script
    (tech debt → stage 3.8).
  - qml6/qml expose no --width/--height or --output flags, so size and
    screenshots are produced with temporary wrapper .qml files (in /tmp,
    removed on exit).
  - qml6 cannot inject sddm/config context-properties from the CLI (they
    are provided by the greeter). The theme degrades gracefully via
    ThemeState.isPreview (background #000000). preview/MockSddm.qml +
    preview/MockConfig.qml are fixtures for a future harness and are not
    loaded by this script.
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

while (( $# )); do
    case "$1" in
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
import QtQuick.Window

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
