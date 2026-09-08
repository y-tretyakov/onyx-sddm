---
name: sddm-theme
description: >-
  Expert knowledge for building, debugging and packaging SDDM greeter themes
  (Qt6/QML). Use when working on SDDM login screens, greeter themes, theme.conf,
  metadata.desktop, sddm object API, userModel/sessionModel, Wayland weston
  kiosk, X11 greeter, fingerprint shim, install scripts, or any SDDM-specific
  QML behaviour. Do NOT use for general Qt/QML coding unrelated to the greeter.
license: MIT
compatibility: >-
  Designed for Claude Code, GitHub Copilot, Cursor, and similar agents.
  Primary target: Arch Linux / CachyOS + SDDM + Qt6.
disable-model-invocation: false
metadata:
  author: onyx-project
  version: "1.0"
  qt-version: "6.x"
  sddm-version: "0.21+"
  category: domain
---

# SDDM Theme Skill

You are an expert in **SDDM greeter themes** written in Qt6/QML.

This skill covers the full lifecycle: architecture of a theme, the `sddm` object
API, models, configuration, Wayland vs X11 differences, packaging for Arch, and
the common traps that make greeters black-screen, ignore clicks, or lose the
cursor.

**Announce at start (when applicable):**  
"I'm using the sddm-theme skill."

---

## 1. Theme anatomy (required files)

A minimal installable theme lives under `/usr/share/sddm/themes/<name>/`:

```
<name>/
├── Main.qml              # entry point (required)
├── metadata.desktop      # required
├── theme.conf            # optional but strongly recommended
├── preview.png / .gif    # catalogue only, not required at runtime
├── components/           # our modular structure (optional but preferred)
├── font/
├── icons/
└── translations.js       # if i18n is used
```

### metadata.desktop

```ini
[SddmGreeterTheme]
Name=Onyx
Description=Orbital clockwork login theme
Author=...
Type=sddm-theme
MainScript=Main.qml
ConfigFile=theme.conf
QtVersion=6
```

- `QtVersion=6` is mandatory for Qt6 greeter (`sddm-greeter-qt6`).
- `MainScript` must point to the real entry QML.

### theme.conf

```ini
[General]
type=color
color=#000000
fontSize=12
themeMode=dark
language=auto
```

Values are exposed to QML as the read-only `config` object  
(`config.stringValue`, `config.boolValue`, etc. depending on SDDM version;  
prefer reading known keys safely with fallbacks).

---

## 2. The `sddm` object (runtime API)

Available only inside a real greeter (or a carefully written mock).

| Member | Type | Purpose |
|--------|------|---------|
| `sddm.login(user, password, sessionIndex)` | method | Start session |
| `sddm.powerOff()` | method | Power off |
| `sddm.reboot()` | method | Reboot |
| `sddm.suspend()` / `hibernate()` | method | Optional power actions |
| `sddm.hostName` | string | Hostname |
| `sddm.canPowerOff` / `canReboot` / … | bool | Capability flags |
| `sddm.loginFailed` | signal | Wrong password / failure |
| `sddm.loginSucceeded` | signal | Success (rarely needed in theme) |

**Fingerprint / lock-shim extras** (exist only in some lock-screen shims,  
**not** in pure SDDM greeter):

- `sddm.fingerprintHint` (bool)
- `sddm.fingerprintReady` (bool)
- `sddm.fingerprintState` (`"idle"` / `"success"` / …)

Always guard:

```qml
readonly property bool fpVisible:
    (typeof sddm !== "undefined")
    && sddm.fingerprintHint === true
    && sddm.fingerprintReady === true
```

### Preview / QuickShell / qmlscene

When `sddm` is missing or incomplete:

```qml
property bool isQuickshell: typeof sddm === "undefined" || sddm.hostName === undefined
```

Theme must still render and not crash. Mock login can no-op or print to console.

---

## 3. Models

### userModel

- `userModel.lastIndex` — last used user
- `userModel.rowCount()` / roles: `name`, `realName`, `icon`, …
- Typical pattern: hidden `ListView`/`ComboBox` helper + custom UI

### sessionModel

- `sessionModel.lastIndex`
- roles: `name`, `file`, `exec`, …
- Same helper pattern as users

Never assume models are non-empty; always provide fallbacks.

---

## 4. Scaling & geometry

Canonical pattern used by high-quality themes:

```qml
readonly property real s: Screen.height / 768
```

All sizes, margins, font sizes, radii → multiply by `s`.

Target reference heights: 768, 1080, 1440, 2160.  
Test at least 1920×1080 and one HiDPI (2×) configuration.

---

## 5. Wayland vs X11 (critical)

### Wayland (primary on modern CachyOS / Niri / Hyprland)

- Greeter often runs under **weston --shell=kiosk-shell.so** (or similar).
- Native cursor may be **absent**.
- Theme must draw its own cursor glyph if needed.
- **Never** put a full-screen `MouseArea` / hover layer that steals events —  
  this breaks dropdowns and buttons.

Recommended cursor approach:

```qml
// Read position directly from the window; do not use a capturing MouseArea
readonly property real cursorX: Window.window ? Window.window.cursorPosition.x : 0
readonly property real cursorY: Window.window ? Window.window.cursorPosition.y : 0
```

Virtual cursor item only visible when `Qt.platform.name` contains `"wayland"`.

### X11

- Native cursor works.
- Hide the virtual cursor.
- Dropdown / `MouseArea` hit-testing is fragile: watch z-order, overlapping  
  transparent items, and parent `MouseArea`s that swallow events.

**Rule:** any menu/dropdown must be tested on **both** Wayland and X11 before  
the stage is accepted.

---

## 6. Performance rules

- 16 ms (~60 fps) timer **only** while the greeter is visible / focused:

```qml
readonly property bool clockAwake:
    ((typeof sddm !== "undefined") && sddm.fingerprintHint === true)
    || Window.active
```

- Stop heavy animations when `!clockAwake`.
- Avoid unnecessary `GraphicalEffects` over the whole screen.
- Prefer simple opacity/scale animations over continuous blur/shaders on weak GPUs.

---

## 7. Authentication UX contract

1. User selects user + session (+ language).
2. Focus password field (or fingerprint hint).
3. On Enter / Login button → `sddm.login(...)`.
4. On `loginFailed` → clear password (optional), show error, run error feedback  
   (shake / red text). Never leave the UI in a stuck state.
5. Success is handled by SDDM (session starts); theme may show a short  
   “ACCESS GRANTED” flash if desired.

Numpad Enter must also trigger login (common omission).

---

## 8. Packaging (Arch / CachyOS)

Typical layout of the **repository** (not the installed theme):

```
onyx-sddm/
├── theme/onyx/           # the actual theme files
├── install.sh            # copies theme, writes /etc/sddm.conf.d/, enables sddm
├── uninstall.sh
├── validate.sh
├── scripts/checksums.sha256
├── scripts/verify-theme.sh
├── PKGBUILD
├── onyx-sddm-theme.install   # pacman install/remove messages
└── ...
```

### install.sh expectations

- Install theme to `/usr/share/sddm/themes/onyx`
- Optionally write `/etc/sddm.conf.d/99-theme.conf` with `Current=onyx`
- Do **not** require network at install time (theme is vendored)
- Support `--uninstall` / dedicated uninstall script
- Be idempotent

### PKGBUILD

- Package only the theme files (and maybe a small note)
- `install=` script for post-message tips
- Dependencies: `sddm`, `qt6-declarative`, `qt6-5compat`, `qt6-svg`  
  (and `weston` if the default greeter path relies on it)

### Integrity

- `scripts/checksums.sha256` + `verify-theme.sh` for offline verification
- CI should run validate + checksum check

---

## 9. Common failure modes & fixes

| Symptom | Likely cause | Direction |
|---------|--------------|-----------|
| Black screen | QML error, missing import, wrong QtVersion | `journalctl -u sddm -b`, run greeter in test mode |
| No cursor on Wayland | Theme doesn't draw one, weston kiosk | Implement VirtualCursor, no full-screen grabber |
| Clicks / hover dead on menus | Full-screen MouseArea or bad z-order | Remove capturing layer; fix stacking |
| Theme ignored | Wrong `Current=` or theme not in `/usr/share/sddm/themes` | Check conf.d and directory name |
| Login does nothing | Not calling `sddm.login`, wrong sessionIndex | Wire signal, log arguments in test |
| High CPU idle | 16 ms timer always running | Gate on `clockAwake` / `Window.active` |
| Fonts missing CJK | Only Outfit bundled | Rely on system fallback (Noto Sans CJK etc.) |

Useful commands:

```bash
journalctl -u sddm -b
sddm-greeter-qt6 --test-mode --theme /path/to/theme
grep -R "Current=" /etc/sddm.conf /etc/sddm.conf.d
```

---

## 10. Component-based theme rules (Onyx)

- `Main.qml` = composition only.
- Global state, scale, colours, language → `ThemeState.qml`.
- One responsibility per component under `components/`.
- Public API = properties + signals; no reaching into children of siblings.
- All user-visible strings go through `translations.js` / `curT`.
- Dropdowns must be tested on X11 and Wayland before acceptance.

---

## 11. Testing checklist (minimum for any stage that touches UI)

- [ ] Starts under `sddm-greeter-qt6 --test-mode`
- [ ] No QML errors in journal
- [ ] Scale looks correct on 1080p and 1440p
- [ ] Password + Enter logs in (or fails gracefully)
- [ ] Wayland: virtual cursor visible and non-blocking
- [ ] X11: native cursor, menus clickable
- [ ] Power / Reboot actions reachable (if in scope)
- [ ] `clockAwake` stops the 16 ms timer when unfocused

---

## 12. What this skill does **not** cover

- General QML style (use `qt-qml`)
- Writing unit tests (use `qt-qml-test` / `tdd`)
- Pure visual design tokens (use `qt-ui-design`)
- Non-SDDM lock screens (Hyprlock, swaylock, etc.) unless they reuse the same QML

---

*sddm-theme skill · v1.0 · Onyx project*
