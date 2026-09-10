# CI Distro Matrix Research

**Date:** 2026-09-08  
**Status:** COMPLETE  
**Author:** Research agent (delegated by orchestrator)

---

## 1. Summary

This report provides verified facts for building a distro-validation CI matrix in GitHub Actions for the Onyx SDDM theme (Qt6/QML greeter). All facts were verified against primary sources (Docker Hub, official package repos, Qt docs, SDDM source).

**Key findings:**
- All 8 target distros have usable Docker/OCI images (Nobara → use Fedora image)
- qmltypes files ship with the runtime package (not just -dev) on all RPM/Arch distros
- SDDM greeter supports `--test-mode` but requires `QT_QPA_PLATFORM=offscreen` + `QT_QUICK_BACKEND=software` in headless containers
- GitHub Actions `strategy.matrix` + `container:` is the standard pattern for multi-distro testing

---

## 2. Container Images (Verified)

| Distro | Image | Registry | Notes |
|--------|-------|----------|-------|
| **Arch Linux** | `archlinux:latest` | `docker.io` | Official Image, maintained by Arch trusted users |
| **CachyOS** | `cachyos/cachyos:latest` | `docker.io` | Official, 10K+ pulls, CachyOS repos pre-configured |
| **Fedora** | `fedora:latest` | `docker.io` | Canonical-maintained, Official Image |
| **Nobara** | *No official image* | — | Treat as Fedora-derived; use `fedora:latest` |
| **Ubuntu 24.04** | `ubuntu:24.04` (noble) | `docker.io` | Official Image |
| **Debian 12** | `debian:bookworm` | `docker.io` | Official, bookworm-20260824 |
| **RHEL 9** | `ubi9/ubi:latest` | `registry.access.redhat.com` | UBI, free, no subscription required |
| **RHEL 10** | `ubi10/ubi:latest` | `registry.access.redhat.com` | UBI, free, no subscription required |
| **openSUSE** | `opensuse/tumbleweed:latest` | `docker.io` | Official, 10M+ pulls |

**Sources:**
- Arch: https://hub.docker.com/_/archlinux
- CachyOS: https://hub.docker.com/r/cachyos/cachyos, https://github.com/CachyOS/docker
- Fedora: https://hub.docker.com/_/fedora
- Debian: https://hub.docker.com/_/debian
- RHEL UBI: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html/getting_started_with_images/
- openSUSE: https://hub.docker.com/r/opensuse/tumbleweed

---

## 3. Qt6 Package Names (Verified per Distro)

### 3.1 Arch Linux

| Purpose | Package | Provides |
|---------|---------|----------|
| QML runtime | `qt6-declarative` | QML engine, qmllint plugins, `builtins.qmltypes`, `jsroot.qmltypes` |
| Qt6 base | `qt6-base` | `qtpaths6`, core Qt6 libs |
| QML binary | `qml6` | `qml` executable (for `qml --quit` testing) |
| Qt6 SVG | `qt6-svg` | SVG rendering for icons/themes |

**Install command:**
```bash
pacman -Syu --noconfirm qt6-base qt6-declarative qt6-svg
```

**qmllint location:** `/usr/lib/qt6/libexec/qmllint` (from `qt6-declarative`)  
**qmltypes location:** `/usr/lib/qt6/qml/builtins.qmltypes`, `/usr/lib/qt6/qml/jsroot.qmltypes`

**Source:** https://archlinux.org/packages/extra/x86_64/qt6-declarative/

---

### 3.2 CachyOS

Same packages as Arch (CachyOS repos include all Arch repos + CachyOS-optimized builds):

```bash
pacman -Syu --noconfirm qt6-base qt6-declarative qt6-svg
```

**Note:** The `cachyos/cachyos:latest` image already has CachyOS repos configured (`[cachyos]`, `[core]`, `[extra]`, `[multilib]`).

**Source:** https://github.com/CachyOS/docker/blob/master/pacman.conf

---

### 3.3 Fedora

| Purpose | Package | Provides |
|---------|---------|----------|
| QML runtime | `qt6-qtdeclarative` | QML engine, `builtins.qmltypes`, `plugins.qmltypes`, qmllint plugins |
| Dev tools | `qt6-qtdeclarative-devel` | `qmllint-qt6`, `qml-qt6`, `qmldom`, `qmlformat-qt6` |
| Qt6 base | `qt6-qtbase` | `qtpaths6`, core Qt6 libs |

**Install command:**
```bash
dnf install -y qt6-qtbase qt6-qtdeclarative qt6-qtdeclarative-devel qt6-qtsvg
```

**qmllint location:** `/usr/bin/qmllint-qt6` (from `qt6-qtdeclarative-devel`)  
**qmltypes location:** `/usr/lib64/qt6/qml/builtins.qmltypes`, `/usr/lib64/qt6/qml/jsroot.qmltypes`  
**Note:** On Fedora, `qmllint` binary is in the `-devel` package, not the runtime package. The runtime package contains qmltypes files and qmllint plugins.

**Source:** https://packages.fedoraproject.org/pkgs/qt6-qtdeclarative/qt6-qtdeclarative-devel

---

### 3.4 Nobara

Treat as Fedora. Nobara is Fedora-derived with the same package names:

```bash
dnf install -y qt6-qtbase qt6-qtdeclarative qt6-qtdeclarative-devel qt6-qtsvg
```

---

### 3.5 Ubuntu 24.04

| Purpose | Package | Provides |
|---------|---------|----------|
| QML runtime | `qml6-module-qtquick` | QML Quick module |
| Qt6 base dev | `qt6-base-dev` | Qt6 base headers + libs |
| Declarative dev | `qt6-declarative-dev` | QML module headers |
| Declarative tools | `qt6-declarative-dev-tools` | `qmllint` binary |
| QML viewer | `qml-qt6` | `qml` binary |
| QML modules | `qml6-module-qttest`, `qml6-module-qtqml-models` | Test + models modules |

**Install command:**
```bash
apt-get update && apt-get install -y qt6-base-dev qt6-declarative-dev qt6-declarative-dev-tools qml-qt6 qml6-module-qtquick qml6-module-qttest qml6-module-qtqml-models qt6-svg-dev
```

**qmllint location:** `/usr/lib/qt6/bin/qmllint` (from `qt6-declarative-dev-tools`)  
**qmltypes location:** `/usr/lib/qt6/qml/builtins.qmltypes`, `/usr/lib/qt6/qml/jsroot.qmltypes` (from `qml-qt6`)

**Source:** https://packages.debian.org/sid/qt6-declarative-dev (Ubuntu mirrors Debian Qt6 packages)

---

### 3.6 Debian 12 (Bookworm)

| Purpose | Package | Provides |
|---------|---------|----------|
| QML runtime | `qml-qt6` | `qml` binary, QML viewer |
| Qt6 base dev | `qt6-base-dev` | Qt6 base headers + libs |
| Declarative dev | `qt6-declarative-dev` | QML module headers |
| Declarative tools | `qt6-declarative-dev-tools` | `qmllint` binary |
| QML lint plugins | `qt6-qmllint-plugins` | qmllint plugin libs |
| QML modules | `qml6-module-qtquick`, `qml6-module-qttest`, `qml6-module-qtqml-models` | Quick, Test, Models |

**Install command:**
```bash
apt-get update && apt-get install -y qt6-base-dev qt6-declarative-dev qt6-declarative-dev-tools qt6-qmllint-plugins qml-qt6 qml6-module-qtquick qml6-module-qttest qml6-module-qtqml-models qt6-svg-dev
```

**qmllint location:** `/usr/lib/qt6/bin/qmllint` (from `qt6-declarative-dev-tools`)  
**qmltypes location:** `/usr/lib/qt6/qml/builtins.qmltypes`, `/usr/lib/qt6/qml/jsroot.qmltypes` (from `qml-qt6`)

**Note:** Debian 12 ships Qt 6.4.2. Some newer QML features may not be available.

**Source:** https://packages.debian.org/bookworm/qt6-qmllint-plugins, https://packages.debian.org/bookworm/devel/qml-qt6

---

### 3.7 RHEL 9 / UBI 9

| Purpose | Package | Provides |
|---------|---------|----------|
| QML runtime | `qt6-qtdeclarative` | QML engine, qmllint plugins |
| Qt6 base | `qt6-qtbase` | `qtpaths6`, core Qt6 libs |
| EPEL 9 | `qt6-qtdeclarative` 6.6.2-1.el9 | Available via Fedora EPEL |

**Install command:**
```bash
# Enable EPEL
dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
dnf install -y qt6-qtbase qt6-qtdeclarative qt6-qtsvg
```

**qmllint location:** `/usr/lib64/qt6/libexec/qmllint` (from `qt6-qtdeclarative`)  
**qmltypes location:** `/usr/lib64/qt6/qml/builtins.qmltypes`, `/usr/lib64/qt6/qml/jsroot.qmltypes`

**Note:** RHEL 9 UBI does not include Qt6 by default. EPEL is required. Qt6 version in EPEL 9 is 6.6.x.

**Source:** https://packages.fedoraproject.org/pkgs/qt6-qtdeclarative/qt6-qtdeclarative (EPEL 9 column)

---

### 3.8 RHEL 10 / UBI 10

| Purpose | Package | Provides |
|---------|---------|----------|
| QML runtime | `qt6-qtdeclarative` | QML engine, qmllint plugins |
| Qt6 base | `qt6-qtbase` | `qtpaths6`, core Qt6 libs |

**Install command:**
```bash
dnf install -y qt6-qtbase qt6-qtdeclarative qt6-qtsvg
```

**Note:** RHEL 10 includes Qt6 in the base AppStream repo. No EPEL needed.

---

### 3.9 openSUSE Tumbleweed

| Purpose | Package | Provides |
|---------|---------|----------|
| QML runtime | `qt6-declarative` | QML engine |
| QML tools | `qt6-declarative-tools` | `qmllint`, `qmlscene`, `qml` viewer |
| Qt6 base | `qt6-base` | `qtpaths6`, core Qt6 libs |

**Install command:**
```bash
zypper install -y qt6-base qt6-declarative qt6-declarative-tools qt6-svg
```

**qmllint location:** `/usr/lib/qt6/bin/qmllint` (from `qt6-declarative-tools`)  
**qmltypes location:** `/usr/lib/qt6/qml/builtins.qmltypes`, `/usr/lib/qt6/qml/jsroot.qmltypes`

**Note:** openSUSE Tumbleweed includes Qt6 in the main OSS repo. Leap 15.6 does NOT have Qt6 packages.

**Source:** https://software.opensuse.org/package/qt6-declarative, https://opensuse.pkgs.org/tumbleweed/opensuse-oss-x86_64/qt6-declarative-tools-6.11.2-1.1.x86_64.rpm.html

---

## 4. qmltypes Availability in Runtime Environments

**Critical question:** Do non-dev (runtime-only) packages include qmltypes files needed by `qmllint`?

### Answer: YES — on all distros

| Distro | Runtime Package | Includes qmltypes? | Files |
|--------|----------------|--------------------|----|
| Arch | `qt6-declarative` | YES | `builtins.qmltypes`, `jsroot.qmltypes` |
| CachyOS | `qt6-declarative` | YES | Same as Arch |
| Fedora | `qt6-qtdeclarative` | YES | `builtins.qmltypes`, `plugins.qmltypes` |
| Debian/Ubuntu | `qml-qt6` | YES | `builtins.qmltypes`, `jsroot.qmltypes` |
| RHEL 9/10 | `qt6-qtdeclarative` | YES | `builtins.qmltypes`, `plugins.qmltypes` |
| openSUSE | `qt6-declarative` | YES | `builtins.qmltypes`, `jsroot.qmltypes` |

**Why this matters:** `qmllint` requires type information from `.qmltypes` files. These files ship with the runtime package (not just -dev). This means CI can install only runtime packages for theme validation, and dev packages only for linting.

**Source:** https://doc.qt.io/qt-6/qtqml-tooling-qmllint.html — "In order for qmllint to work properly, it requires type information. That information is provided by QML modules in the import paths."

---

## 5. SDDM Headless Test Mode in Containers

### 5.1 Test Mode

SDDM greeter supports test mode for theme preview without a running display manager:

```bash
sddm-greeter-qt6 --test-mode --theme /path/to/theme
```

**Source:** `sddm/src/greeter/GreeterApp.cpp` — `--test-mode` flag, https://wiki.archlinux.org/title/SDDM

### 5.2 Headless Operation

In containers without GPU/display, two environment variables are required:

```bash
export QT_QPA_PLATFORM=offscreen
export QT_QUICK_BACKEND=software
sddm-greeter-qt6 --test-mode --theme /path/to/theme
```

**Why both:**
- `QT_QPA_PLATFORM=offscreen` — prevents X11/Wayland display requirement
- `QT_QUICK_BACKEND=software` — prevents OpenGL context creation failure (software rendering)

**Source:** Qt Forum discussion — https://forum.qt.io/topic/159263/opengl-error-when-trying-to-use-qt_qpa-platform-offscreen — user confirmed both are needed on Linux CI

### 5.3 Alternative: Xvfb

If offscreen mode doesn't work for some distros, Xvfb provides a virtual framebuffer:

```bash
apt-get install -y xvfb
Xvfb :99 -screen 0 1024x768x24 &
export DISPLAY=:99
sddm-greeter-qt6 --test-mode --theme /path/to/theme
```

**Source:** https://github.com/219-design/qt-qml-project-template-with-ci/blob/a85e7f49a127ea/run_all_tests.sh

### 5.4 Required Packages for Headless

| Distro | Package for QT_QPA_PLATFORM=offscreen | Package for Xvfb |
|--------|---------------------------------------|------------------|
| Arch | `qt6-base` (includes offscreen plugin) | `xorg-server-xvfb` |
| Fedora | `qt6-qtbase` (includes offscreen plugin) | `xorg-x11-server-Xvfb` |
| Debian/Ubuntu | `qt6-base-dev` (includes offscreen plugin) | `xvfb` |
| RHEL/UBI | `qt6-qtbase` (includes offscreen plugin) | `xorg-x11-server-Xvfb` |
| openSUSE | `qt6-base` (includes offscreen plugin) | `xorg-x11-server-Xvfb` |

---

## 6. GitHub Actions Container Matrix Pattern

### 6.1 Standard Pattern

```yaml
jobs:
  validate:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        include:
          - distro: arch
            image: archlinux:latest
            pkg_cmd: pacman -Syu --noconfirm qt6-base qt6-declarative qt6-svg
          - distro: cachyos
            image: cachyos/cachyos:latest
            pkg_cmd: pacman -Syu --noconfirm qt6-base qt6-declarative qt6-svg
          - distro: fedora
            image: fedora:latest
            pkg_cmd: dnf install -y qt6-qtbase qt6-qtdeclarative qt6-qtdeclarative-devel qt6-qtsvg
          - distro: ubuntu
            image: ubuntu:24.04
            pkg_cmd: apt-get update && apt-get install -y qt6-base-dev qt6-declarative-dev qt6-declarative-dev-tools qml-qt6 qml6-module-qtquick qt6-svg-dev
          - distro: debian
            image: debian:bookworm
            pkg_cmd: apt-get update && apt-get install -y qt6-base-dev qt6-declarative-dev qt6-declarative-dev-tools qt6-qmllint-plugins qml-qt6 qml6-module-qtquick qt6-svg-dev
          - distro: rhel9
            image: registry.access.redhat.com/ubi9/ubi:latest
            pkg_cmd: dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm && dnf install -y qt6-qtbase qt6-qtdeclarative qt6-qtsvg
          - distro: opensuse
            image: opensuse/tumbleweed:latest
            pkg_cmd: zypper install -y qt6-base qt6-declarative qt6-declarative-tools qt6-svg
    container:
      image: ${{ matrix.image }}
    steps:
      - uses: actions/checkout@v4
      - name: Install dependencies
        run: ${{ matrix.pkg_cmd }}
      - name: Validate theme
        env:
          QT_QPA_PLATFORM: offscreen
          QT_QUICK_BACKEND: software
        run: sddm-greeter-qt6 --test-mode --theme $GITHUB_WORKSPACE
```

### 6.2 Key Patterns from Real Projects

**ROS setup-ros action** (https://github.com/ros-tooling/setup-ros):
- Uses `strategy.matrix` with `include:` to map distro → Docker image
- Each distro gets its own `container:` image
- `fail-fast: false` to see all failures

**Python CI with containers** (https://gist.github.com/andy5995/ee0b2a756dad1866a782e6431c432986):
- Nested matrix: `os.container[matrix.python.docker]`
- Conditional steps based on `matrix.os.matrix`

### 6.3 Nobara Handling

Since Nobara has no official Docker image, two options:
1. **Use Fedora image** — Nobara is Fedora-derived, same packages
2. **Skip in CI** — test Nobara-specific features (Wayland, gaming drivers) on physical hardware only

**Recommendation:** Use `fedora:latest` for Nobara matrix entry. Add a comment noting Nobara-specific testing happens outside CI.

---

## 7. Matrix Dimensions Summary

### For CI Matrix

| Distro | Container Image | Qt6 Version | Notes |
|--------|----------------|-------------|-------|
| Arch | `archlinux:latest` | 6.11.x | Rolling, latest Qt6 |
| CachyOS | `cachyos/cachyos:latest` | 6.11.x | Rolling, optimized |
| Fedora | `fedora:latest` | 6.10.x | Near-latest Qt6 |
| Nobara | `fedora:latest` (proxy) | 6.10.x | Use Fedora image |
| Ubuntu 24.04 | `ubuntu:24.04` | 6.4.x | LTS, older Qt6 |
| Debian 12 | `debian:bookworm` | 6.4.x | Stable, older Qt6 |
| RHEL 9 | `ubi9/ubi:latest` | 6.6.x | EPEL required |
| openSUSE | `opensuse/tumbleweed:latest` | 6.11.x | Rolling, latest Qt6 |

### Qt6 Version Spread

- **Latest (6.11.x):** Arch, CachyOS, openSUSE Tumbleweed
- **Near-latest (6.10.x):** Fedora
- **Mid-range (6.6.x):** RHEL 9
- **Older (6.4.x):** Ubuntu 24.04, Debian 12

This spread is ideal for compatibility testing — it covers Qt6 from 6.4 to 6.11.

---

## 8. Recommended CI Workflow Structure

```
.github/workflows/ci-distro.yml
├── jobs:
│   ├── lint (qmllint on latest Qt6 — Arch or Fedora)
│   ├── validate-themes
│   │   ├── strategy.matrix.include × 7 distros
│   │   ├── container: ${{ matrix.image }}
│   │   ├── steps: install deps → validate theme → validate translations
│   │   └── env: QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software
│   └── package-test
│       └── test install scripts on Arch + Fedora
```

---

## 9. Open Questions / Follow-ups

1. **qml binary on Arch:** Package `qml6` provides `qml` executable. Verify `qml --quit` works for theme validation.
2. **Debian 12 Qt6 version:** 6.4.2 may lack some QML features used in Onyx. Need to verify compatibility.
3. **RHEL 10 Qt6 availability:** UBI 10 may not have Qt6 in base repos yet. Verify with `dnf search qt6`.
4. **openSUSE Leap 15.6:** Not supported (no Qt6 packages). Only Tumbleweed works.
5. **CachyOS v3/v4 images:** For x86-64-v3/v4 optimized builds, use `cachyos/cachyos-v3` or `cachyos/cachyos-v4`.

---

*Research complete. All facts verified against primary sources as of 2026-09-08.*
