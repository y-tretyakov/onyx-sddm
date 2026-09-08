#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_DIR="${1:-${ROOT_DIR}/theme/onyx}"

usage() {
    cat <<EOF
Usage: $0 [THEME_DIR] [--help]

Validates the Onyx theme file set (layered):
  1. required files present
  2. metadata.desktop fields valid
  3. theme.conf keys present
  4. QML syntax (qmllint, if available)

  THEME_DIR  theme directory to check (default: theme/onyx)
  -h, --help  show this help and exit
EOF
}

case "${1:-}" in
    -h|--help) usage; exit 0 ;;
esac

status=0

fail() { echo "  - $1" >&2; status=1; }

# --- Layer 1: required files ---
REQUIRED_FILES=(
    "Main.qml"
    "ThemeState.qml"
    "translations.js"
    "PROVENANCE.txt"
    "metadata.desktop"
    "theme.conf"
)

missing=()
for f in "${REQUIRED_FILES[@]}"; do
    if [[ ! -e "${THEME_DIR}/${f}" ]]; then
        missing+=("${f}")
    fi
done
if [[ ${#missing[@]} -gt 0 ]]; then
    echo "FAIL: missing required files:" >&2
    printf '  - %s\n' "${missing[@]}" >&2
    exit 1
fi

# --- Layer 2: metadata.desktop ---
MD="${THEME_DIR}/metadata.desktop"
if ! grep -q '^\[SddmGreeterTheme\]' "${MD}"; then
    fail "metadata.desktop: missing [SddmGreeterTheme] section"
fi
if ! grep -q '^QtVersion=6$' "${MD}"; then
    fail "metadata.desktop: QtVersion must be exactly 6"
fi
main_script="$(grep '^MainScript=' "${MD}" | head -n1 | cut -d= -f2-)"
if [[ -z "${main_script}" ]] || [[ ! -e "${THEME_DIR}/${main_script}" ]]; then
    fail "metadata.desktop: MainScript '${main_script}' not found in theme dir"
fi
config_file="$(grep '^ConfigFile=' "${MD}" | head -n1 | cut -d= -f2-)"
if [[ -z "${config_file}" ]] || [[ ! -e "${THEME_DIR}/${config_file}" ]]; then
    fail "metadata.desktop: ConfigFile '${config_file}' not found in theme dir"
fi

# --- Layer 3: theme.conf ---
TC="${THEME_DIR}/theme.conf"
if ! grep -q '^\[General\]' "${TC}"; then
    fail "theme.conf: missing [General] section"
fi
for key in type color bgColor; do
    if ! grep -Eq "^${key}=" "${TC}"; then
        fail "theme.conf: missing key '${key}'"
    fi
done

# --- Layer 4: QML syntax ---
QML_FILES=()
while IFS= read -r f; do QML_FILES+=("$f"); done < <(find "${THEME_DIR}" -name '*.qml' -type f)
if [[ ${#QML_FILES[@]} -eq 0 ]]; then
    fail "no *.qml files found in theme dir"
fi

QMLINT=""
for cand in qmllint6 /usr/lib/qt6/bin/qmllint qmllint; do
    if command -v "${cand}" >/dev/null 2>&1 || [[ -x "${cand}" ]]; then
        QMLINT="${cand}"
        break
    fi
done

if [[ -z "${QMLINT}" ]]; then
    echo "WARNING: qmllint not found; skipping QML syntax check" >&2
else
    for f in "${QML_FILES[@]}"; do
        if ! "${QMLINT}" "${f}" >/dev/null 2>&1; then
            if ! "${QMLINT}" --unqualified=info --import=info "${f}" >/dev/null 2>&1; then
                fail "QML syntax/type error in ${f}"
            fi
        fi
    done
fi

if [[ ${status} -eq 0 ]]; then
    echo "OK: ${THEME_DIR}"
    exit 0
fi

echo "FAIL: ${THEME_DIR}" >&2
exit 1
