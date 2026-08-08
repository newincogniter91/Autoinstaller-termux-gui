# Termux-X11 Linux Desktop Setup

A single interactive bash script that turns a fresh Termux install into a full Linux desktop running through [Termux-X11](https://github.com/termux/termux-x11) — no extra downloads, no manual repo setup, no guesswork.

Pick a distro, pick a desktop environment, optionally install a set of matching appearance packages, and get a ready-to-use `start.sh` launcher. Later, run the same script again to cleanly uninstall a desktop environment or an entire system.

---

## ✨ Features

- **Zero-assumption bootstrap** — works on a completely fresh Termux install with no repos configured
- **18 Linux distributions** via [proot-distro](https://github.com/termux/proot-distro), plus a **Native Termux** mode that skips proot entirely for maximum speed
- **Experimental chroot-distro mode** — root-based alternative via [sabamdarif/chroot-distro](https://github.com/sabamdarif/chroot-distro), installed via `pip`, for better performance on rooted devices
- **5 desktop environments / window managers**: XFCE4, LXQt, MATE, Fluxbox, Openbox
- **Optional appearance pack**: Arc theme, Papirus icons, Noto emoji, clean fonts, Qt5ct, LXAppearance
- **Built-in uninstaller** — scans every installed environment (Native, proot, chroot-distro), tells you which desktop environments it finds, and lets you remove just the DE or the whole system
- **Verified package names** for every distro/package-manager combination — no guessed or deprecated package names
- **Crash fixes baked in** (see [Known Issues Fixed](#known-issues-fixed) below)
- Generates a ready-to-run `~/start.sh` that launches Termux-X11 and your chosen desktop with one command

---

## 📋 Requirements

- [Termux](https://github.com/termux/termux-app) (F-Droid build recommended, not the unmaintained Play Store version)
- [Termux:X11](https://github.com/termux/termux-x11/releases) APK installed on your device
- An Android device with reasonable free storage (2–4 GB depending on the distro/DE you pick)
- **No root required** for the default proot / Native Termux mode
- **Root required** only if you choose the experimental chroot-distro mode

---

## 🚀 Quick Start

```bash
pkg install wget -y
wget https://raw.githubusercontent.com/newincogniter91/Autoinstaller-termux-gui/main/installer.sh
chmod +x installer.sh
./installer.sh
```

The script opens with a simple choice:

```
0) Install a Linux desktop
1) Uninstall a desktop or system
```

### Installing

1. Update Termux and enable the `x11-repo`
2. Pick a setup mode: **proot / Native Termux** (recommended, no root) or **chroot-distro** (experimental, root required)
3. Pick a distribution
4. Pick a desktop environment
5. Optionally install the recommended appearance packages
6. Get a ready `~/start.sh`

```bash
./start.sh
```

Then open the **Termux:X11** app on your device (the script also tries to launch it automatically).

### Uninstalling

Run the script again and choose option **1**. It will:

1. Scan Native Termux, every installed proot-distro container, and (if present) every chroot-distro container
2. List every desktop environment it finds, e.g. `proot: debian — XFCE4`
3. Let you choose to remove **only the desktop environment** (keeping the base OS) or **the entire system/container**

---

## 🖥️ Supported Distributions (proot / Native mode)

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

### chroot-distro mode (experimental)

Debian, Ubuntu 25.10, Arch Linux, Fedora, Alpine Linux, OpenSUSE, Void Linux.

---

## ⚠️ About chroot-distro mode

chroot-distro mode is provided as an **alternative** for rooted devices and is **not guaranteed to work on every device**. Whether it works depends on your specific root manager (Magisk, KernelSU, APatch, or other), kernel version, and Android build.

The correct working sequence — reached after a lot of trial and error — is:

```bash
# Outside the chroot, in Termux itself:
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1
virgl_test_server_android &
termux-x11 :0 -ac &
# open the Termux:X11 app

# Enter the chroot, sharing Termux's own /tmp so the X11 socket is visible inside:
chroot-distro login debian --bind $TMPDIR:/tmp -- bash -c 'export DISPLAY=:0 XDG_RUNTIME_DIR=/tmp/runtime-root PULSE_SERVER=127.0.0.1 GALLIUM_DRIVER=virpipe; mkdir -p $XDG_RUNTIME_DIR; chmod 700 $XDG_RUNTIME_DIR; dbus-launch --exit-with-session xfce4-session'
```

Key points, each of which caused a real failure when missing:

- `termux-x11`, `pulseaudio`, and `virgl_test_server_android` are bionic (Android/Termux) binaries — they **cannot** run inside the chroot (a glibc environment) and must stay outside it
- `--bind $TMPDIR:/tmp` is chroot-distro's own documented flag for sharing a host path into the container — this is what actually exposes the Termux-X11 socket inside; a manual `mount --bind` done outside the tool gets silently overridden by chroot-distro's own `/tmp` handling
- `termux-x11 :0 -ac` needs the `-ac` flag to disable X11 access control, or the chrooted client can be rejected
- The whole `bash -c '...'` block **must** use single quotes, not double quotes — with double quotes, Termux's own shell tries to expand `$DISPLAY`/`$XDG_RUNTIME_DIR` *before* entering the chroot (where they're empty), instead of letting Debian's shell expand them after
- `XDG_RUNTIME_DIR` must be explicitly created (`mkdir -p` + `chmod 700`) inside the chroot — XFCE4/D-Bus need it and won't create it themselves
- Stale X11 socket files from a previous crashed session (`$TMPDIR/.X11-unix`) must be cleared before starting a new one, or the new server can't bind
- Because of the wide variety of root implementations on Android, **this mode may still fail on some devices**. If it does, restart the script and choose **proot / Native Termux** instead — that mode is stable and well tested

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
- **chroot-distro `Cannot open display`** — the real fix needed several parts together: the tool's own `--bind $TMPDIR:/tmp` flag to share the X11 socket, single quotes around the inner `bash -c` block (double quotes let Termux expand the variables too early, before they had any value), explicit `XDG_RUNTIME_DIR` creation inside the chroot, and clearing stale `.X11-unix` socket files left behind by a previous crashed session
- **chroot-distro uninstall not detecting installed desktops** — fixed by reading the containers directory directly (`ls` on chroot-distro's own documented data location) instead of parsing the tool's decorative, color-formatted `list` output

---

## 📁 What Gets Created

- `~/start.sh` — the launcher script, tailored to your distro/DE choice. Starts PulseAudio, VirGL, the Termux-X11 server, opens the Termux:X11 app, and boots your desktop.

---

## ⚠️ Disclaimer

This script installs and configures third-party Linux distributions and desktop environments inside Termux. Use at your own risk. Always keep backups of anything important on your device. The chroot-distro mode in particular is experimental and may not work on your device — see the section above.

---

## 🤝 Contributing

Found a broken package name on a distro/DE combo not listed here, or a desktop environment that doesn't start correctly? Open an issue or a pull request with:

- The distro and DE you selected
- Which mode you used (proot / Native / chroot-distro)
- The exact error message
- Output of `./start.sh` if the crash happens at launch

---

## 📜 License

MIT — do whatever you want with it.
