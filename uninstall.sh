#!/usr/bin/env bash
set -euo pipefail

THEME_NAME="onyx"
DEST="/usr/share/sddm/themes"

usage() {
    cat <<EOF
Usage: $0 [--dest DIR] [--help]

Removes the Onyx SDDM theme from /usr/share/sddm/themes/onyx.

  --dest DIR   remove from DIR instead of /usr/share/sddm/themes
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

if [[ ! -d "${DEST}" ]]; then
    echo "not installed: ${DEST}"
    exit 0
fi

rm -rf "${DEST}"
echo "removed: ${DEST}"
