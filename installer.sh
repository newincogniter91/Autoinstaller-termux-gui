#!/data/data/com.termux/files/usr/bin/bash

# ==============================================================
#  TERMUX-X11 FULL SETUP SCRIPT - COMPLETE EDITION v2.7
#  Designed to run on a FRESH Termux install with NO repos.
#
#  Distro: Native Termux (no proot), Debian, Ubuntu, Trisquel,
#          Pardus, Arch, Artix, Manjaro, Fedora, AlmaLinux,
#          Oracle, Rocky, Alpine, Void, OpenSUSE, Chimera,
#          Adelie, Deepin
#  DE/WM:  XFCE4, LXQt, MATE(*), Fluxbox, Openbox
#  (*) MATE NOT available on Native Termux (not in x11-repo)
#  Display: Termux-X11 ONLY
#
#  KEY FIXES v2.6:
#  - librsvg added to ALL distros: icon themes use SVG, without
#    librsvg gdk-pixbuf cannot load them → Wnck crash → signal 6
#  - adwaita-icon-theme added: libwnck needs "image-missing" icon
#    as fallback, without it assertion fails and crashes everything
#  - gdk-pixbuf-query-loaders --update-cache run after every install
#    so the SVG loader is properly registered in the cache
#  - openbox-session used on all distros except Alpine (uses openbox)
#  - openbox config files copied from /etc/xdg/openbox/ on first run
#  - pypanel replaced with tint2 everywhere (pypanel abandoned/AUR)
# ==============================================================

R='\033[0;31m'
G='\033[0;32m'
Y='\033[1;33m'
C='\033[0;36m'
NC='\033[0m'

banner() {
    clear
    echo -e "${C}"
    echo "╔══════════════════════════════════════════════╗"
    echo "║   TERMUX-X11 LINUX DESKTOP SETUP v2.6       ║"
    echo "║   All Distros    - All DEs -     - TX11     ║"
    echo "╚══════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# ==============================================================
# STEP 1 — Bootstrap Termux from scratch
# ==============================================================
banner
echo -e "${Y}--- [1/5] Bootstrapping Termux (fresh install safe) ---${NC}"

export DEBIAN_FRONTEND=noninteractive

install_kali_nethunter_chroot() {
    NH_ROOTFS_URL="https://images.kali.org/nethunter/kali-nethunter-rootfs-minimal-arm64.tar.xz"
    NH_INSTALLER_SCRIPT="https://gitlab.com/kalilinux/nethunter/build-scripts/kali-nethunter-project/-/raw/master/nethunter-rootless/install-nethunter-termux"
    NH_ROOTFS_DIR="/data/local/nh-system"
    NH_ARCHIVE="$HOME/kali-nethunter-rootfs-minimal-arm64.tar.xz"

    echo -e "${Y}--- [Kali NetHunter Chroot] Preparing installation ---${NC}"
    mkdir -p "$NH_ROOTFS_DIR"
    chmod 755 "$(dirname "$NH_ROOTFS_DIR")"

    if command -v nethunter-installer >/dev/null 2>&1; then
        echo -e "${Y}Found nethunter-installer, using official installer...${NC}"
        nethunter-installer || true
    elif command -v wget >/dev/null 2>&1 || command -v curl >/dev/null 2>&1; then
        echo -e "${Y}Fetching official NetHunter Termux installer...${NC}"
        if command -v wget >/dev/null 2>&1; then
            wget -qO- "$NH_INSTALLER_SCRIPT" | bash || true
        else
            curl -fsSL "$NH_INSTALLER_SCRIPT" | bash || true
        fi
    fi

    if [ ! -d "$NH_ROOTFS_DIR" ] || [ -z "$(ls -A "$NH_ROOTFS_DIR" 2>/dev/null)" ]; then
        echo -e "${Y}Downloading Kali NetHunter rootfs...${NC}"
        if command -v wget >/dev/null 2>&1; then
            wget -O "$NH_ARCHIVE" "$NH_ROOTFS_URL"
        else
            curl -L -o "$NH_ARCHIVE" "$NH_ROOTFS_URL"
        fi
        echo -e "${Y}Extracting rootfs to $NH_ROOTFS_DIR ...${NC}"
        if command -v tsu >/dev/null 2>&1; then
            tsu -c "mkdir -p '$NH_ROOTFS_DIR' && tar -xJf '$NH_ARCHIVE' -C '$NH_ROOTFS_DIR'"
        elif [ "$(id -u)" = "0" ]; then
            mkdir -p "$NH_ROOTFS_DIR"
            tar -xJf "$NH_ARCHIVE" -C "$NH_ROOTFS_DIR"
        else
            echo -e "${R}Root privileges are required for Kali NetHunter Chroot installation.${NC}"
            echo -e "${R}Install tsu or run this script as root before retrying.${NC}"
            exit 1
        fi
    fi

    echo -e "${G}✓ Kali NetHunter rootfs ready in $NH_ROOTFS_DIR.${NC}"
}

echo -e "${Y}  Updating base Termux packages...${NC}"
pkg update -y && pkg upgrade -y

echo -e "${Y}  Adding x11-repo...${NC}"
pkg install -y x11-repo

echo -e "${Y}  Re-reading package lists with x11-repo enabled...${NC}"
pkg update -y

echo -e "${Y}  Installing core packages...${NC}"
pkg install -y \
    termux-x11-nightly \
    pulseaudio \
    virglrenderer-android \
    proot-distro \
    wget \
    curl \
    bash

echo -e "${G}✓ Termux bootstrap complete.${NC}"
sleep 1

# ==============================================================
# STEP 2 — Distribution selection
# ==============================================================
banner
echo -e "${C}╔══════════════════════════════════════════════╗"
echo    "║          SELECT YOUR DISTRIBUTION            ║"
echo    "╠══════════════════════════════════════════════╣"
echo    "║                                              ║"
echo    "║   0)  Native Termux (no proot, fastest!)    ║"
echo    "║       ⚠  MATE not available on Native       ║"
echo    "║                                              ║"
echo    "║   --- Debian/Ubuntu based ---                ║"
echo    "║   1)  Debian        (Stable, Recommended)   ║"
echo    "║   2)  Ubuntu 25.10  (Popular, Large repos)  ║"
echo    "║   3)  Trisquel GNU  (Free Debian-based)     ║"
echo    "║   4)  Pardus        (Turkish Debian-based)  ║"
echo    "║                                              ║"
echo    "║   --- Arch based ---                        ║"
echo    "║   5)  Arch Linux    (Advanced users)        ║"
echo    "║   6)  Artix Linux   (Arch, no systemd)      ║"
echo    "║   7)  Manjaro       (Arch, user-friendly)   ║"
echo    "║                                              ║"
echo    "║   --- RPM based ---                         ║"
echo    "║   8)  Fedora        (Modern, cutting-edge)  ║"
echo    "║   9)  AlmaLinux     (RHEL compatible)       ║"
echo    "║   10) Oracle Linux  (Enterprise RHEL)       ║"
echo    "║   11) Rocky Linux   (RHEL compatible)       ║"
echo    "║                                              ║"
echo    "║   --- Independent ---                       ║"
echo    "║   12) Alpine Linux  (Ultra minimal, musl)   ║"
echo    "║   13) Void Linux    (Runit, independent)    ║"
echo    "║   14) OpenSUSE      (YaST, rolling/stable)  ║"
echo    "║   15) Chimera Linux (musl/LLVM based)       ║"
echo    "║   16) Adelie Linux  (musl Alpine-like)      ║"
echo    "║   17) Deepin        (Beautiful Chinese DE)  ║"
echo    "║   18) Kali NetHunter Chroot (Rootful X11) ║"
echo    "║                                              ║"
echo -e "╚══════════════════════════════════════════════╝${NC}"
read -p "Select a distro (0-18): " distro_choice

case $distro_choice in
    0)  DISTRO="native";      PKG_TYPE="pkg";    DNAME="Native Termux"  ;;
    1)  DISTRO="debian";      PKG_TYPE="apt";    DNAME="Debian"         ;;
    2)  DISTRO="ubuntu";      PKG_TYPE="apt";    DNAME="Ubuntu"         ;;
    3)  DISTRO="trisquel";    PKG_TYPE="apt";    DNAME="Trisquel"       ;;
    4)  DISTRO="pardus";      PKG_TYPE="apt";    DNAME="Pardus"         ;;
    5)  DISTRO="archlinux";   PKG_TYPE="pacman"; DNAME="Arch Linux"     ;;
    6)  DISTRO="artix";       PKG_TYPE="pacman"; DNAME="Artix Linux"    ;;
    7)  DISTRO="manjaro";     PKG_TYPE="pacman"; DNAME="Manjaro"        ;;
    8)  DISTRO="fedora";      PKG_TYPE="dnf";    DNAME="Fedora"         ;;
    9)  DISTRO="almalinux";   PKG_TYPE="dnf";    DNAME="AlmaLinux"      ;;
    10) DISTRO="oracle";      PKG_TYPE="dnf";    DNAME="Oracle Linux"   ;;
    11) DISTRO="rockylinux";  PKG_TYPE="dnf";    DNAME="Rocky Linux"    ;;
    12) DISTRO="alpine";      PKG_TYPE="apk";    DNAME="Alpine Linux"   ;;
    13) DISTRO="void";        PKG_TYPE="xbps";   DNAME="Void Linux"     ;;
    14) DISTRO="opensuse";    PKG_TYPE="zypper"; DNAME="OpenSUSE"       ;;
    15) DISTRO="chimera";     PKG_TYPE="apk";    DNAME="Chimera Linux"  ;;
    16) DISTRO="adelie";      PKG_TYPE="apk";    DNAME="Adelie Linux"   ;;
    17) DISTRO="deepin";      PKG_TYPE="apt";    DNAME="Deepin"         ;;
    18) DISTRO="kali-nh-chroot"; PKG_TYPE="chroot"; DNAME="Kali NetHunter Chroot" ;;
    *)  echo -e "${R}Invalid choice. Exiting.${NC}"; exit 1 ;;
esac

echo -e "${G}✓ Selected: $DNAME${NC}"

if [ "$PKG_TYPE" = "chroot" ]; then
    install_kali_nethunter_chroot
elif [ "$PKG_TYPE" != "pkg" ]; then
    echo -e "${Y}--- [2/5] Bootstrapping $DNAME via proot-distro ---${NC}"
    proot-distro install "$DISTRO"
    echo -e "${G}✓ $DNAME installed.${NC}"
else
    echo -e "${G}✓ Native Termux — no proot needed.${NC}"
fi
sleep 1

# ==============================================================
# STEP 3 — Desktop environment selection
# ==============================================================
banner

if [ "$PKG_TYPE" = "pkg" ]; then
    echo -e "${C}╔══════════════════════════════════════════════╗"
    echo    "║       SELECT DESKTOP ENVIRONMENT / WM        ║"
    echo    "╠══════════════════════════════════════════════╣"
    echo    "║                                              ║"
    echo    "║   1) XFCE4    (Balanced - Recommended)      ║"
    echo    "║   2) LXQt     (Very lightweight, fast)      ║"
    echo    "║   3) Fluxbox  (Minimal, fastest, stable)    ║"
    echo    "║   4) Openbox  (Minimal, configurable)       ║"
    echo    "║                                              ║"
    echo    "║   ⚠ MATE unavailable on Native Termux       ║"
    echo    "║     Use a proot distro for MATE             ║"
    echo    "║                                              ║"
    echo -e "╚══════════════════════════════════════════════╝${NC}"
    read -p "Select a desktop (1-4): " de_raw
    case $de_raw in
        1) de_choice=1 ;;
        2) de_choice=2 ;;
        3) de_choice=4 ;;
        4) de_choice=5 ;;
        *) echo -e "${R}Invalid choice.${NC}"; exit 1 ;;
    esac
else
    echo -e "${C}╔══════════════════════════════════════════════╗"
    echo    "║       SELECT DESKTOP ENVIRONMENT / WM        ║"
    echo    "╠══════════════════════════════════════════════╣"
    echo    "║                                              ║"
    echo    "║   --- Full Desktop Environments ---          ║"
    echo    "║   1) XFCE4    (Balanced - Recommended)      ║"
    echo    "║   2) LXQt     (Very lightweight, fast)      ║"
    echo    "║   3) MATE     (Classic GNOME 2 style)       ║"
    echo    "║                                              ║"
    echo    "║   --- Lightweight Window Managers ---        ║"
    echo    "║   4) Fluxbox  (Minimal, fastest, stable)    ║"
    echo    "║   5) Openbox  (Minimal, configurable)       ║"
    echo    "║                                              ║"
    echo -e "╚══════════════════════════════════════════════╝${NC}"
    read -p "Select a desktop (1-5): " de_choice
fi

# ==============================================================
# Package definitions
# ==============================================================
case $PKG_TYPE in
    pkg)
        APPEAR_PKGS="arc-theme-gnome papirus-icon-theme noto-fonts-emoji ttf-dejavu qt5ct lxappearance"
        case $de_choice in
            1) DE_PKGS="xfce4 xfce4-goodies dbus"
               DE_START="dbus-launch --exit-with-session xfce4-session"
               DE_NAME="XFCE4"   ;;
            2) DE_PKGS="lxqt"
               DE_START="startlxqt"
               DE_NAME="LXQt"    ;;
            4) DE_PKGS="fluxbox"
               DE_START="fluxbox"
               DE_NAME="Fluxbox" ;;
            5) DE_PKGS="openbox openbox-menu tint2 xorg-xsetroot"
               DE_START="openbox-session"
               DE_NAME="Openbox" ;;
        esac
        INSTALL_CMD="pkg install -y $DE_PKGS"
        APPEAR_CMD="pkg install -y $APPEAR_PKGS"
        ;;

    apt|chroot)
        UPD="apt update -y && apt upgrade -y"
        EXTRA="dbus-x11 xauth fonts-noto librsvg2-common adwaita-icon-theme"
        APPEAR_PKGS="arc-theme papirus-icon-theme fonts-noto-color-emoji ttf-dejavu-extra qt5ct lxappearance"
        case $de_choice in
            1) DE_PKGS="xfce4 xfce4-goodies dbus-x11"
               DE_START="dbus-launch --exit-with-session xfce4-session"
               DE_NAME="XFCE4"   ;;
            2) DE_PKGS="lxqt"
               DE_START="startlxqt"
               DE_NAME="LXQt"    ;;
            3) DE_PKGS="mate-desktop-environment dbus-x11"
               DE_START="dbus-launch --exit-with-session mate-session"
               DE_NAME="MATE"    ;;
            4) DE_PKGS="fluxbox"
               DE_START="fluxbox"
               DE_NAME="Fluxbox" ;;
            5) DE_PKGS="openbox openbox-menu tint2 x11-xserver-utils"
               DE_START="openbox-session"
               DE_NAME="Openbox" ;;
            *) echo -e "${R}Invalid choice.${NC}"; exit 1 ;;
        esac
        INSTALL_CMD="$UPD && apt install -y $DE_PKGS $EXTRA && gdk-pixbuf-query-loaders --update-cache 2>/dev/null || true"
        APPEAR_CMD="apt install -y $APPEAR_PKGS && gdk-pixbuf-query-loaders --update-cache 2>/dev/null || true"
        ;;

    pacman)
        UPD="pacman -Syu --noconfirm"
        EXTRA="dbus xorg-xauth noto-fonts librsvg adwaita-icon-theme"
        APPEAR_PKGS="arc-gtk-theme papirus-icon-theme noto-fonts-emoji ttf-ubuntu-font-family qt5ct lxappearance"
        case $de_choice in
            1) DE_PKGS="xfce4 xfce4-goodies dbus"
               DE_START="dbus-launch --exit-with-session xfce4-session"
               DE_NAME="XFCE4"   ;;
            2) DE_PKGS="lxqt"
               DE_START="startlxqt"
               DE_NAME="LXQt"    ;;
            3) DE_PKGS="mate mate-extra dbus"
               DE_START="dbus-launch --exit-with-session mate-session"
               DE_NAME="MATE"    ;;
            4) DE_PKGS="fluxbox"
               DE_START="fluxbox"
               DE_NAME="Fluxbox" ;;
            5) DE_PKGS="openbox tint2 xorg-xsetroot"
               DE_START="openbox-session"
               DE_NAME="Openbox" ;;
            *) echo -e "${R}Invalid choice.${NC}"; exit 1 ;;
        esac
        INSTALL_CMD="$UPD && pacman -S --noconfirm $DE_PKGS $EXTRA && gdk-pixbuf-query-loaders --update-cache"
        APPEAR_CMD="pacman -S --noconfirm $APPEAR_PKGS && gdk-pixbuf-query-loaders --update-cache"
        ;;

    dnf)
        UPD="dnf update -y"
        EXTRA="dbus-x11 xauth google-noto-fonts-common librsvg2 adwaita-icon-theme"
        APPEAR_PKGS="arc-theme papirus-icon-theme google-noto-color-emoji-fonts google-noto-sans-fonts qt5ct lxappearance"
        case $de_choice in
            1) DE_PKGS="@xfce-desktop dbus-x11"
               DE_START="dbus-launch --exit-with-session xfce4-session"
               DE_NAME="XFCE4"   ;;
            2) DE_PKGS="@lxqt-desktop"
               DE_START="startlxqt"
               DE_NAME="LXQt"    ;;
            3) DE_PKGS="mate-session-manager marco mate-panel mate-desktop caja dbus-x11"
               DE_START="dbus-launch --exit-with-session mate-session"
               DE_NAME="MATE"    ;;
            4) DE_PKGS="fluxbox"
               DE_START="fluxbox"
               DE_NAME="Fluxbox" ;;
            5) DE_PKGS="openbox xfce4-panel xorg-x11-server-utils"
               DE_START="openbox-session"
               DE_NAME="Openbox" ;;
            *) echo -e "${R}Invalid choice.${NC}"; exit 1 ;;
        esac
        INSTALL_CMD="$UPD && dnf install -y $DE_PKGS $EXTRA && (gdk-pixbuf-query-loaders-64 --update-cache 2>/dev/null || gdk-pixbuf-query-loaders --update-cache 2>/dev/null || true)"
        APPEAR_CMD="dnf install -y $APPEAR_PKGS && (gdk-pixbuf-query-loaders-64 --update-cache 2>/dev/null || gdk-pixbuf-query-loaders --update-cache 2>/dev/null || true)"
        ;;

    apk)
        UPD="apk update && apk upgrade"
        EXTRA="dbus-x11 xauth font-noto librsvg adwaita-icon-theme"
        APPEAR_PKGS="papirus-icon-theme font-noto font-dejavu qt5ct"
        case $de_choice in
            1) DE_PKGS="xfce4 xfce4-extras dbus-x11"
               DE_START="dbus-launch --exit-with-session xfce4-session"
               DE_NAME="XFCE4"   ;;
            2) DE_PKGS="lxqt lxqt-session"
               DE_START="startlxqt"
               DE_NAME="LXQt"    ;;
            3) DE_PKGS="marco mate-panel mate-session-manager caja dbus-x11"
               DE_START="dbus-launch --exit-with-session mate-session"
               DE_NAME="MATE"    ;;
            4) DE_PKGS="fluxbox"
               DE_START="fluxbox"
               DE_NAME="Fluxbox" ;;
            5) DE_PKGS="openbox tint2 xsetroot"
               DE_START="openbox"
               DE_NAME="Openbox" ;;
            *) echo -e "${R}Invalid choice.${NC}"; exit 1 ;;
        esac
        INSTALL_CMD="$UPD && apk add $DE_PKGS $EXTRA && gdk-pixbuf-query-loaders --update-cache 2>/dev/null || true"
        APPEAR_CMD="$UPD && apk add $APPEAR_PKGS && \
            (apk add lxappearance 2>/dev/null || \
             (echo '@testing https://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories && \
              apk update && apk add lxappearance@testing)) && \
            gdk-pixbuf-query-loaders --update-cache 2>/dev/null || true"
        ;;

    xbps)
        UPD="xbps-install -Suy"
        EXTRA="dbus-x11 xauth noto-fonts-ttf librsvg adwaita-icon-theme"
        APPEAR_PKGS="arc-theme papirus-icon-theme noto-fonts-emoji font-ubuntu-ttf qt5ct lxappearance"
        case $de_choice in
            1) DE_PKGS="xfce4 xfce4-goodies dbus-x11"
               DE_START="dbus-launch --exit-with-session xfce4-session"
               DE_NAME="XFCE4"   ;;
            2) DE_PKGS="lxqt"
               DE_START="startlxqt"
               DE_NAME="LXQt"    ;;
            3) DE_PKGS="mate mate-extra dbus-x11"
               DE_START="dbus-launch --exit-with-session mate-session"
               DE_NAME="MATE"    ;;
            4) DE_PKGS="fluxbox"
               DE_START="fluxbox"
               DE_NAME="Fluxbox" ;;
            5) DE_PKGS="openbox tint2 xsetroot"
               DE_START="openbox-session"
               DE_NAME="Openbox" ;;
            *) echo -e "${R}Invalid choice.${NC}"; exit 1 ;;
        esac
        INSTALL_CMD="$UPD && xbps-install -y $DE_PKGS $EXTRA && gdk-pixbuf-query-loaders --update-cache 2>/dev/null || true"
        APPEAR_CMD="xbps-install -y $APPEAR_PKGS && gdk-pixbuf-query-loaders --update-cache 2>/dev/null || true"
        ;;

    zypper)
        UPD="zypper --non-interactive refresh && zypper --non-interactive update"
        EXTRA="dbus-1-x11 xauth google-noto-fonts librsvg2 adwaita-icon-theme"
        APPEAR_PKGS="metatheme-arc-common papirus-icon-theme google-noto-coloremoji-fonts google-noto-sans-fonts qt5ct lxappearance"
        case $de_choice in
            1) DE_PKGS="xfce4 xfce4-goodies dbus-1-x11"
               DE_START="dbus-launch --exit-with-session xfce4-session"
               DE_NAME="XFCE4"   ;;
            2) DE_PKGS="lxqt"
               DE_START="startlxqt"
               DE_NAME="LXQt"    ;;
            3) DE_PKGS="mate-session-manager marco mate-panel caja dbus-1-x11"
               DE_START="dbus-launch --exit-with-session mate-session"
               DE_NAME="MATE"    ;;
            4) DE_PKGS="fluxbox"
               DE_START="fluxbox"
               DE_NAME="Fluxbox" ;;
            5) DE_PKGS="openbox lxpanel xsetroot"
               DE_START="openbox-session"
               DE_NAME="Openbox" ;;
            *) echo -e "${R}Invalid choice.${NC}"; exit 1 ;;
        esac
        INSTALL_CMD="$UPD && zypper --non-interactive install $DE_PKGS $EXTRA && gdk-pixbuf-query-loaders --update-cache 2>/dev/null || true"
        APPEAR_CMD="zypper --non-interactive install $APPEAR_PKGS && gdk-pixbuf-query-loaders --update-cache 2>/dev/null || true"
        ;;
esac

# ==============================================================
# STEP 3b — Install DE
# ==============================================================
echo -e "${G}✓ Selected: $DE_NAME${NC}"
echo -e "${Y}--- [3/5] Installing $DE_NAME in $DNAME ---${NC}"
echo -e "${Y}    (This may take several minutes...)${NC}"

if [ "$PKG_TYPE" = "pkg" ]; then
    bash -c "$INSTALL_CMD"
elif [ "$PKG_TYPE" = "chroot" ]; then
    CHROOT_INSTALL_SCRIPT="$NH_ROOTFS_DIR/tmp/install-desktop.sh"
    mkdir -p "$NH_ROOTFS_DIR/tmp"
    cat > "$CHROOT_INSTALL_SCRIPT" <<EOF
#!/bin/bash
set -e
$INSTALL_CMD
EOF
    chmod +x "$CHROOT_INSTALL_SCRIPT"

    if command -v tsu >/dev/null 2>&1; then
        tsu -c "mount -t proc proc '$NH_ROOTFS_DIR'/proc || true && mount -t sysfs sys '$NH_ROOTFS_DIR'/sys || true && mount --bind /dev '$NH_ROOTFS_DIR'/dev || true && chroot '$NH_ROOTFS_DIR' /bin/bash /tmp/install-desktop.sh; RET=\$?; umount '$NH_ROOTFS_DIR'/proc || true; umount '$NH_ROOTFS_DIR'/sys || true; umount -l '$NH_ROOTFS_DIR'/dev || true; exit \$RET"
    elif [ "$(id -u)" = "0" ]; then
        mount -t proc proc "$NH_ROOTFS_DIR"/proc || true
        mount -t sysfs sys "$NH_ROOTFS_DIR"/sys || true
        mount --bind /dev "$NH_ROOTFS_DIR"/dev || true
        chroot "$NH_ROOTFS_DIR" /bin/bash /tmp/install-desktop.sh
        RET=$?
        umount "$NH_ROOTFS_DIR"/proc || true
        umount "$NH_ROOTFS_DIR"/sys || true
        umount -l "$NH_ROOTFS_DIR"/dev || true
        exit $RET
    else
        echo -e "${R}Root privileges are required to install Kali NetHunter Chroot desktop packages.${NC}"
        echo -e "${R}Use tsu or run this script as root.${NC}"
        exit 1
    fi
else
    proot-distro login "$DISTRO" -- bash -c "$INSTALL_CMD"
fi

echo -e "${G}✓ $DE_NAME installed.${NC}"
sleep 1

# ==============================================================
# STEP 4 — Optional appearance packages
# ==============================================================
banner
echo -e "${C}╔══════════════════════════════════════════════╗"
echo    "║         RECOMMENDED APPEARANCE PACKAGES      ║"
echo    "╠══════════════════════════════════════════════╣"
echo    "║                                              ║"
echo    "║  • Arc Theme / Metatheme  (Modern GTK)      ║"
echo    "║  • Papirus Icons          (Icon pack)       ║"
echo    "║  • Noto Color Emoji       (Emoji support)   ║"
echo    "║  • DejaVu / Ubuntu Fonts  (Clean fonts)     ║"
echo    "║  • Qt5ct                  (Qt theming tool) ║"
echo    "║  • LXAppearance           (GTK switcher)    ║"
echo    "║                                              ║"
echo -e "╚══════════════════════════════════════════════╝${NC}"
echo ""
read -p "$(echo -e ${Y})Install recommended appearance packages? [Y/n]: $(echo -e ${NC})" appear_choice
appear_choice="${appear_choice:-Y}"

if [[ "$appear_choice" =~ ^[Yy]$ ]]; then
    echo -e "${Y}--- [4/5] Installing appearance packages ---${NC}"
    if [ "$PKG_TYPE" = "pkg" ]; then
        bash -c "$APPEAR_CMD"
    elif [ "$PKG_TYPE" = "chroot" ]; then
        CHROOT_APPEAR_SCRIPT="$NH_ROOTFS_DIR/tmp/install-appearance.sh"
        mkdir -p "$NH_ROOTFS_DIR/tmp"
        cat > "$CHROOT_APPEAR_SCRIPT" <<EOF
#!/bin/bash
set -e
$APPEAR_CMD
EOF
        chmod +x "$CHROOT_APPEAR_SCRIPT"
        if command -v tsu >/dev/null 2>&1; then
            tsu -c "mount -t proc proc '$NH_ROOTFS_DIR'/proc || true && mount -t sysfs sys '$NH_ROOTFS_DIR'/sys || true && mount --bind /dev '$NH_ROOTFS_DIR'/dev || true && chroot '$NH_ROOTFS_DIR' /bin/bash /tmp/install-appearance.sh; RET=\$?; umount '$NH_ROOTFS_DIR'/proc || true; umount '$NH_ROOTFS_DIR'/sys || true; umount -l '$NH_ROOTFS_DIR'/dev || true; exit \$RET"
        elif [ "$(id -u)" = "0" ]; then
            mount -t proc proc "$NH_ROOTFS_DIR"/proc || true
            mount -t sysfs sys "$NH_ROOTFS_DIR"/sys || true
            mount --bind /dev "$NH_ROOTFS_DIR"/dev || true
            chroot "$NH_ROOTFS_DIR" /bin/bash /tmp/install-appearance.sh
            RET=$?
            umount "$NH_ROOTFS_DIR"/proc || true
            umount "$NH_ROOTFS_DIR"/sys || true
            umount -l "$NH_ROOTFS_DIR"/dev || true
            exit $RET
        else
            echo -e "${R}Root privileges are required to install appearance packages in Kali NetHunter Chroot.${NC}"
            echo -e "${R}Use tsu or run this script as root.${NC}"
            exit 1
        fi
    else
        proot-distro login "$DISTRO" -- bash -c "$APPEAR_CMD"
    fi
    APPEAR_INSTALLED=true
    echo -e "${G}✓ Appearance packages installed.${NC}"
else
    echo -e "${Y}⚠ Skipping appearance packages.${NC}"
    APPEAR_INSTALLED=false
fi
sleep 1

# ==============================================================
# STEP 5 — Extra autostart for Fluxbox / Openbox
# ==============================================================
FLUXBOX_INIT=""
if [ "$DE_NAME" = "Fluxbox" ]; then
    FLUXBOX_INIT='mkdir -p ~/.fluxbox && fluxbox-generate_menu 2>/dev/null || true'
fi

OPENBOX_INIT=""
if [ "$DE_NAME" = "Openbox" ]; then
    OPENBOX_INIT='
mkdir -p ~/.config/openbox
[ ! -f ~/.config/openbox/rc.xml ]    && cp /etc/xdg/openbox/rc.xml    ~/.config/openbox/ 2>/dev/null || true
[ ! -f ~/.config/openbox/menu.xml ]  && cp /etc/xdg/openbox/menu.xml  ~/.config/openbox/ 2>/dev/null || true
[ ! -f ~/.config/openbox/autostart ] && cp /etc/xdg/openbox/autostart ~/.config/openbox/ 2>/dev/null || true
grep -q "tint2" ~/.config/openbox/autostart 2>/dev/null || cat >> ~/.config/openbox/autostart << OBAUTO
xsetroot -solid "#2d2d2d" &
tint2 &
OBAUTO'
fi

# ==============================================================
# STEP 6 — Generate ~/start.sh launcher
# ==============================================================
echo -e "${Y}--- [5/5] Creating ~/start.sh launcher ---${NC}"

# ---- Native Termux launcher ----
if [ "$PKG_TYPE" = "pkg" ]; then

cat > ~/start.sh << STARTSCRIPT
#!/data/data/com.termux/files/usr/bin/bash
# Native Termux + $DE_NAME — Termux-X11
R='\033[0;31m'; G='\033[0;32m'; Y='\033[1;33m'; C='\033[0;36m'; NC='\033[0m'

echo -e "\${C}╔══════════════════════════════╗\${NC}"
echo -e "\${C}║  Native Termux + $DE_NAME  \${NC}"
echo -e "\${C}╚══════════════════════════════╝\${NC}"

echo -e "\${Y}Stopping old sessions...\${NC}"
kill -9 \$(pgrep -f "termux.x11") 2>/dev/null
pkill -f pulseaudio          2>/dev/null
pkill -f virgl_test_server   2>/dev/null
sleep 1

echo -e "\${Y}Starting PulseAudio...\${NC}"
pulseaudio --start   --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1"   --exit-idle-time=-1
sleep 1

echo -e "\${Y}Starting VirGL acceleration...\${NC}"
virgl_test_server_android &
VIRGL_PID=\$!
sleep 1

export XDG_RUNTIME_DIR=\${TMPDIR}
export PULSE_SERVER=127.0.0.1
export GALLIUM_DRIVER=virpipe
export MESA_GL_VERSION_OVERRIDE=4.0

$FLUXBOX_INIT
$OPENBOX_INIT

echo -e "\${G}Launching $DE_NAME via Termux-X11...\${NC}"
termux-x11 :0 -xstartup "$DE_START" &
sleep 3

am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity >/dev/null 2>&1

wait
echo -e "\${Y}Session ended. Cleaning up...\${NC}"
kill \$VIRGL_PID 2>/dev/null
pkill -f pulseaudio 2>/dev/null
echo -e "\${G}Done.\${NC}"
STARTSCRIPT

# ---- chroot launcher ----
elif [ "$PKG_TYPE" = "chroot" ]; then

cat > ~/start.sh << STARTSCRIPT
#!/data/data/com.termux/files/usr/bin/bash
# Kali NetHunter Chroot + $DE_NAME — Termux-X11
R='\033[0;31m'; G='\033[0;32m'; Y='\033[1;33m'; C='\033[0;36m'; NC='\033[0m'
NH_ROOTFS_DIR="/data/local/nh-system"

echo -e "\${C}╔══════════════════════════════════════════════╗\${NC}"
echo -e "\${C}║  Kali NetHunter Chroot / $DE_NAME  \${NC}"
echo -e "\${C}╚══════════════════════════════════════════════╝\${NC}"

echo -e "\${Y}Stopping old sessions...\${NC}"
kill -9 \$(pgrep -f "termux.x11") 2>/dev/null
pkill -f pulseaudio 2>/dev/null
pkill -f virgl_test_server 2>/dev/null
sleep 1

echo -e "\${Y}Starting PulseAudio...\${NC}"
pulseaudio --start   --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1"   --exit-idle-time=-1
sleep 1

echo -e "\${Y}Starting VirGL acceleration...\${NC}"
virgl_test_server_android &
VIRGL_PID=\$!
sleep 1

echo -e "\${Y}Starting Termux-X11 server on :1 ...\${NC}"
export XDG_RUNTIME_DIR=\${TMPDIR}
export PULSE_SERVER=127.0.0.1
export DISPLAY=:1
export GALLIUM_DRIVER=virpipe
export MESA_GL_VERSION_OVERRIDE=4.0
termux-x11 :1 >/dev/null &
sleep 3

am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity >/dev/null 2>&1
sleep 1

echo -e "\${G}Launching Kali NetHunter GUI...\${NC}"

if command -v tsu >/dev/null 2>&1; then
    tsu -c "mount -t proc proc \$NH_ROOTFS_DIR/proc || true && mount -t sysfs sys \$NH_ROOTFS_DIR/sys || true && mount --bind /dev \$NH_ROOTFS_DIR/dev || true && chroot \$NH_ROOTFS_DIR /bin/bash -lc 'export DISPLAY=:1 PULSE_SERVER=127.0.0.1 && if command -v kex >/dev/null 2>&1; then kex start; else $DE_START; fi'"
elif [ "\$(id -u)" = "0" ]; then
    mount -t proc proc "\$NH_ROOTFS_DIR"/proc || true
    mount -t sysfs sys "\$NH_ROOTFS_DIR"/sys || true
    mount --bind /dev "\$NH_ROOTFS_DIR"/dev || true
    chroot "\$NH_ROOTFS_DIR" /bin/bash -lc "export DISPLAY=:1 PULSE_SERVER=127.0.0.1 && if command -v kex >/dev/null 2>&1; then kex start; else $DE_START; fi"
else
    echo -e "\${R}Root privileges are required to launch Kali NetHunter Chroot GUI.\${NC}"
    echo -e "\${R}Use tsu or run this script as root.\${NC}"
    exit 1
fi

echo -e "\${Y}Session ended. Cleaning up...\${NC}"
kill \$VIRGL_PID 2>/dev/null
pkill -f pulseaudio 2>/dev/null
echo -e "\${G}Done.\${NC}"
STARTSCRIPT

# ---- proot-distro launcher ----
else

cat > ~/start.sh << STARTSCRIPT
#!/data/data/com.termux/files/usr/bin/bash
# $DNAME proot + $DE_NAME — Termux-X11
R='\033[0;31m'; G='\033[0;32m'; Y='\033[1;33m'; C='\033[0;36m'; NC='\033[0m'

echo -e "\${C}╔══════════════════════════════╗\${NC}"
echo -e "\${C}║  $DNAME + $DE_NAME  \${NC}"
echo -e "\${C}╚══════════════════════════════╝\${NC}"

echo -e "\${Y}Stopping old sessions...\${NC}"
kill -9 \$(pgrep -f "termux.x11") 2>/dev/null
pkill -f pulseaudio          2>/dev/null
pkill -f virgl_test_server   2>/dev/null
sleep 1

echo -e "\${Y}Starting PulseAudio...\${NC}"
pulseaudio --start   --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1"   --exit-idle-time=-1
sleep 1

echo -e "\${Y}Starting VirGL acceleration...\${NC}"
virgl_test_server_android &
VIRGL_PID=\$!
sleep 1

echo -e "\${Y}Starting Termux-X11 server on :0 ...\${NC}"
export XDG_RUNTIME_DIR=\${TMPDIR}
termux-x11 :0 >/dev/null &
sleep 3

am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity >/dev/null 2>&1
sleep 1

echo -e "\${G}Launching $DE_NAME in $DNAME...\${NC}"

proot-distro login $DISTRO --shared-tmp -- bash -c "
  export DISPLAY=:0
  export PULSE_SERVER=127.0.0.1
  export GALLIUM_DRIVER=virpipe
  export MESA_GL_VERSION_OVERRIDE=4.0
  export XDG_RUNTIME_DIR=/tmp/runtime-root
  mkdir -p \$XDG_RUNTIME_DIR && chmod 700 \$XDG_RUNTIME_DIR
  $FLUXBOX_INIT
  $OPENBOX_INIT
  $DE_START
"

echo -e "\${Y}Session ended. Cleaning up...\${NC}"
kill \$VIRGL_PID 2>/dev/null
pkill -f pulseaudio 2>/dev/null
echo -e "\${G}Done.\${NC}"
STARTSCRIPT

fi

chmod +x ~/start.sh

# ==============================================================
# Done
# ==============================================================
banner
echo -e "${G}"
echo "╔══════════════════════════════════════════════╗"
echo "║            ✓  SETUP COMPLETE!               ║"
echo "╠══════════════════════════════════════════════╣"
echo "║  Distro  : $DNAME"
echo "║  Desktop : $DE_NAME"
echo "║  Display : Termux-X11"
if [ "$APPEAR_INSTALLED" = true ]; then
echo "║  Appearance packages : Installed ✓"
else
echo "║  Appearance packages : Skipped"
fi
echo "╠══════════════════════════════════════════════╣"
echo "║  HOW TO START:                               ║"
echo "║                                              ║"
echo "║  1. Install Termux-X11 APK from:            ║"
echo "║     github.com/termux/termux-x11/releases   ║"
echo "║                                              ║"
echo "║  2. Run in Termux:   ./start.sh              ║"
echo "║                                              ║"
echo "║  3. Open the Termux-X11 app on your device  ║"
echo "║                                              ║"
echo "╚══════════════════════════════════════════════╝"
echo -e "${NC}"
