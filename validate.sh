#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_DIR="${1:-${ROOT_DIR}/theme/onyx}"

usage() {
    cat <<EOF
Usage: $0 [THEME_DIR] [--help]

Validates the Onyx theme file set.

  THEME_DIR  theme directory to check (default: theme/onyx)
  -h, --help  show this help and exit
EOF
}

case "${1:-}" in
    -h|--help) usage; exit 0 ;;
esac

REQUIRED_FILES=(
    "Main.qml"
    "ThemeState.qml"
    "translations.js"
    "PROVENANCE.txt"
)

status=0
missing=()

for f in "${REQUIRED_FILES[@]}"; do
    if [[ ! -e "${THEME_DIR}/${f}" ]]; then
        missing+=("${f}")
        status=1
    fi
done

if [[ ${status} -eq 0 ]]; then
    echo "OK: ${THEME_DIR}"
    exit 0
fi

echo "FAIL: ${THEME_DIR} missing:" >&2
printf '  - %s\n' "${missing[@]}" >&2
exit 1
