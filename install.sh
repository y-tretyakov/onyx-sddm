#!/usr/bin/env bash
set -euo pipefail

THEME_NAME="onyx"
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/theme/${THEME_NAME}"
DEST="/usr/share/sddm/themes"

usage() {
    cat <<EOF
Usage: $0 [--dest DIR] [--help]

Installs the Onyx SDDM theme into /usr/share/sddm/themes/onyx.

  --dest DIR   install into DIR instead of /usr/share/sddm/themes
  -h, --help   show this help and exit
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dest) DEST="${2:?--dest requires an argument}"; shift 2 ;;
        -h|--help) usage; exit 0 ;;
        *) echo "error: unknown option: $1" >&2; usage; exit 2 ;;
    esac
done

DEST="${DEST}/${THEME_NAME}"

if [[ "${DEST}" == "/usr/share/sddm/themes/onyx" ]] && [[ "${EUID}" -ne 0 ]]; then
    echo "error: root privileges required for system installation" >&2
    exit 1
fi

if [[ ! -d "${SRC_DIR}" ]]; then
    echo "error: theme source not found at ${SRC_DIR}" >&2
    exit 1
fi

mkdir -p "${DEST}"
cp -a "${SRC_DIR}/." "${DEST}/"
echo "installed: ${DEST}"
