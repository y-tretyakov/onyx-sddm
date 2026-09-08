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
  4. QML syntax (qmllint, hard-fail if tooling/metadata missing)

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

if [[ -z "${QMLINT}" ]]; then
    fail "qmllint not found (looked for qmllint6/qmllint-qt6/qmllint + Qt6 libexec paths); cannot validate QML"
    exit 1
fi
# Resolve the active Qt6 installation (distro-independent).
QML_ROOT=""
QT_VERSION=""
if command -v qtpaths6 >/dev/null 2>&1; then
    QML_ROOT="$(qtpaths6 --query QT_INSTALL_QML 2>/dev/null)"
    QT_VERSION="$(qtpaths6 --query QT_VERSION 2>/dev/null)"
fi

# Fallback: locate any *.qmltypes under the system Qt QML dirs.
if [[ -z "${QML_ROOT}" ]] || [[ ! -d "${QML_ROOT}" ]]; then
    QML_ROOT="$(dirname "$(find /usr/lib /usr/local/lib -type f -name '*.qmltypes' 2>/dev/null | grep -E '/qml/[^/]+\.qmltypes$|/qml6/[^/]+\.qmltypes$' | head -n1)")"
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

for f in "${QML_FILES[@]}"; do
    ok=1
    out="$("${QMLINT}" "${QML_IMPORT_ROOTS[@]}" "${f}" 2>&1)" || ok=0
    if [[ ${ok} -eq 1 ]]; then
        continue
    fi
    ok2=1
    out2="$("${QMLINT}" "${QML_IMPORT_ROOTS[@]}" --unqualified=info --import=info "${f}" 2>&1)" || ok2=0
    if [[ ${ok2} -eq 1 ]]; then
        continue
    fi
    fail "QML syntax/type error in ${f}"
    if [[ -n "${out}" ]]; then printf '      %s\n' "${out}" >&2; fi
    if [[ -n "${out2}" ]]; then printf '      %s\n' "${out2}" >&2; fi
done

if [[ ${status} -eq 0 ]]; then
    echo "OK: ${THEME_DIR}"
    exit 0
fi

echo "FAIL: ${THEME_DIR}" >&2
exit 1
