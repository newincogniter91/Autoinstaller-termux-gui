# Termux-X11 Linux Desktop Setup

A single interactive bash script that turns a fresh Termux install into a full Linux desktop running through [Termux-X11](https://github.com/termux/termux-x11) — no extra downloads, no manual repo setup, no guesswork.

Pick a distro, pick a desktop environment, optionally install a set of matching appearance packages, and get a ready-to-use `start.sh` launcher.

---

## ✨ Features

- **Zero-assumption bootstrap** — works on a completely fresh Termux install with no repos configured
- **18 Linux distributions** via [proot-distro](https://github.com/termux/proot-distro), plus a **Native Termux** mode that skips proot entirely for maximum speed
- **5 desktop environments / window managers**: XFCE4, LXQt, MATE, Fluxbox, Openbox
- **Optional appearance pack**: Arc theme, Papirus icons, Noto emoji, clean fonts, Qt5ct, LXAppearance
- **Verified package names** for every distro/package-manager combination — no guessed or deprecated package names
- **Crash fixes baked in** (see [Known Issues Fixed](#known-issues-fixed) below)
- Generates a ready-to-run `~/start.sh` that launches Termux-X11 and your chosen desktop with one command

---

## 📋 Requirements

- [Termux](https://github.com/termux/termux-app) (F-Droid build recommended, not the unmaintained Play Store version)
- [Termux:X11](https://github.com/termux/termux-x11/releases) APK installed on your device
- An Android device with reasonable free storage (2–4 GB depending on the distro/DE you pick)
- **No root required**

---

## 🚀 Quick Start

```bash
curl -O https://raw.githubusercontent.com/newincogniter91/Autoinstaller-termux-gui/main/installer.sh
chmod +x installer.sh
./installer.sh
```

The script will:

1. Update Termux and enable the `x11-repo`
2. Ask you to pick a distribution (or Native Termux)
3. Install it via `proot-distro` (skipped for Native)
4. Ask you to pick a desktop environment
5. Ask whether to install the recommended appearance packages
6. Generate `~/start.sh`

When it's done:

```bash
./start.sh
```

Then open the **Termux:X11** app on your device (the script also tries to launch it automatically).

---

## 🖥️ Supported Distributions

| # | Distro | Package Manager |
|---|--------|-----------------|
| 0 | Native Termux | `pkg` |
| 1 | Debian | `apt` |
| 2 | Ubuntu 25.10 | `apt` |
| 3 | Trisquel GNU | `apt` |
| 4 | Pardus | `apt` |
| 5 | Arch Linux | `pacman` |
| 6 | Artix Linux | `pacman` |
| 7 | Manjaro | `pacman` |
| 8 | Fedora | `dnf` |
| 9 | AlmaLinux | `dnf` |
| 10 | Oracle Linux | `dnf` |
| 11 | Rocky Linux | `dnf` |
| 12 | Alpine Linux | `apk` |
| 13 | Void Linux | `xbps` |
| 14 | OpenSUSE | `zypper` |
| 15 | Chimera Linux | `apk` |
| 16 | Adelie Linux | `apk` |
| 17 | Deepin | `apt` |

> **Note:** MATE is not available in **Native Termux** mode — `mate-session-manager` has never been successfully compiled for Termux's native environment. Choose any proot distro instead if you want MATE.

---

## 🎨 Supported Desktop Environments

| DE / WM | Notes |
|---|---|
| **XFCE4** | Balanced, recommended for most users |
| **LXQt** | Very lightweight, Qt-based |
| **MATE** | Classic GNOME 2 style (not available on Native Termux) |
| **Fluxbox** | Minimal, fastest window manager |
| **Openbox** | Minimal and highly configurable, uses `tint2` as panel |

---

## 🐛 Known Issues Fixed

This script exists because the "obvious" way to set this up breaks in several non-obvious ways. Fixes already applied:

- **`termux-x11-repo` does not exist** — the correct package is `x11-repo`; the script also re-runs `pkg update` after adding it, which is required for the new packages to become visible
- **`x11-utils`, `x11-fonts`, `xorg-xrdb` do not exist in Termux** — removed
- **Missing package names per distro** — corrected across all six package managers (e.g. `fonts-ubuntu` doesn't exist on Debian, `google-noto-emoji-fonts` is actually `google-noto-color-emoji-fonts` on Fedora, `arc-gtk-theme` vs `arc-theme` naming differs between Arch and Debian, etc.)
- **`pypanel` is abandoned / AUR-only on Arch** — replaced with `tint2` everywhere (or `xfce4-panel` / `lxpanel` where `tint2` isn't packaged)
- **Openbox crashing on launch** — `openbox-session` needs `rc.xml`, `menu.xml`, and `autostart` copied from `/etc/xdg/openbox/` on first run; the script does this automatically
- **`Wnck:ERROR assertion failed (base)` / signal 6 crash** — caused by missing `librsvg` (icon themes use SVG) and missing `adwaita-icon-theme` (libwnck's fallback icon). Both are installed on every distro, followed by `gdk-pixbuf-query-loaders --update-cache` to register the SVG loader
- **MATE not starting** — `mate-session-manager` isn't always pulled in by desktop meta-packages; it's now installed explicitly together with `marco`, `mate-panel`, and `caja`

---

## 📁 What Gets Created

- `~/start.sh` — the launcher script, tailored to your distro/DE choice. Starts PulseAudio, VirGL, the Termux-X11 server, opens the Termux:X11 app, and boots your desktop.

---

## ⚠️ Disclaimer

This script installs and configures third-party Linux distributions and desktop environments inside Termux. Use at your own risk. Always keep backups of anything important on your device.

---

## 🤝 Contributing

Found a broken package name on a distro/DE combo not listed here, or a desktop environment that doesn't start correctly? Open an issue or a pull request with:

- The distro and DE you selected
- The exact error message
- Output of `./start.sh` if the crash happens at launch

---

## 📜 License

MIT — do whatever you want with it.
