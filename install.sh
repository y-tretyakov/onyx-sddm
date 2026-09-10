#!/usr/bin/env bash
set -euo pipefail

THEME_NAME="onyx"
REPO_BASE="https://github.com/y-tretyakov/onyx-sddm"
DEST="/usr/share/sddm/themes"
RELEASE_TAG=""

_resolve_root() {
    local src="${BASH_SOURCE[0]}"
    if [[ -n "${src}" && -f "${src}" ]]; then
        cd "$(dirname "${src}")" && pwd
    else
        pwd
    fi
}

usage() {
    cat <<EOF
Usage: $0 [--dest DIR] [--release TAG] [--help]

Installs the Onyx SDDM theme into /usr/share/sddm/themes/onyx.

  --dest DIR     install into DIR instead of /usr/share/sddm/themes
  --release TAG  download theme from GitHub release TAG (requires curl + tar)
  -h, --help     show this help and exit
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dest)     DEST="${2:?--dest requires an argument}"; shift 2 ;;
        --release)  RELEASE_TAG="${2:?--release requires a TAG}"; shift 2 ;;
        -h|--help)  usage; exit 0 ;;
        *) echo "error: unknown option: $1" >&2; usage; exit 2 ;;
    esac
done

DEST="${DEST}/${THEME_NAME}"

if [[ "${DEST}" == "/usr/share/sddm/themes/onyx" ]] && [[ "${EUID}" -ne 0 ]]; then
    echo "error: root privileges required for system installation" >&2
    exit 1
fi

_root_dir="$( _resolve_root )"
SRC_DIR="${_root_dir}/theme/${THEME_NAME}"
_tmp=""
_clean() { [[ -n "${_tmp}" && -d "${_tmp}" ]] && rm -rf "${_tmp}"; }
trap _clean EXIT

if [[ ! -d "${SRC_DIR}" ]]; then
    if [[ -z "${RELEASE_TAG}" ]]; then
        echo "error: theme source not found at ${SRC_DIR}" >&2
        echo "Hint: pass --release TAG to download from GitHub." >&2
        exit 1
    fi

    for _bin in curl tar; do
        if ! command -v "${_bin}" &>/dev/null; then
            echo "error: ${_bin} is required but not installed" >&2
            exit 1
        fi
    done

    _tmp="$(mktemp -d)"
    _url="${REPO_BASE}/archive/refs/tags/${RELEASE_TAG}.tar.gz"
    echo "downloading ${_url} ..."
    if ! curl -fsSL -o "${_tmp}/release.tar.gz" "${_url}"; then
        echo "error: failed to download ${_url}" >&2
        exit 1
    fi
    tar -xzf "${_tmp}/release.tar.gz" -C "${_tmp}" --strip-components=1
    SRC_DIR="${_tmp}/theme/${THEME_NAME}"
fi

if [[ ! -d "${SRC_DIR}" ]]; then
    echo "error: theme not found inside archive at ${SRC_DIR}" >&2
    exit 1
fi

mkdir -p "${DEST}"
cp -a "${SRC_DIR}/." "${DEST}/"
echo "installed: ${DEST}"
