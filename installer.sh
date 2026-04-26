#!/data/data/com.termux/files/usr/bin/bash

# ==============================================================
#  TERMUX-X11 FULL SETUP SCRIPT - COMPLETE EDITION v2.4
#  Designed to run on a FRESH Termux install with NO repos.
#
#  Distro: Native Termux (no proot), Debian, Ubuntu, Trisquel,
#          Pardus, Arch, Artix, Manjaro, Fedora, AlmaLinux,
#          Oracle, Rocky, Alpine, Void, OpenSUSE, Chimera,
#          Adelie, Deepin
#  DE/WM:  XFCE4, LXQt, MATE(*), Fluxbox, Openbox
#  (*) MATE NOT available on Native Termux (not in x11-repo)
#  Display: Termux-X11 ONLY
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
    echo "║   TERMUX-X11 LINUX DESKTOP SETUP v2.4       ║"
    echo "║   All Distros    - All DEs -     - TX11     ║"
    echo "╚══════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# ==============================================================
# STEP 1 — Bootstrap Termux from scratch
#
# Correct sequence confirmed by termux-x11 official README,
# LinuxDroidMaster scripts, and ivonblog.com guide:
#
#   1. pkg update + upgrade        (update base packages)
#   2. pkg install x11-repo        (enables the x11 package repo)
#                                   termux-x11-nightly lives here
#                                   NO separate "termux-x11-repo" pkg!
#   3. pkg update                  (re-read package lists with x11-repo)
#   4. pkg install termux-x11-nightly pulseaudio virglrenderer-android
#                                   proot-distro wget curl
#                                   (x11-utils and x11-fonts do NOT
#                                    exist in Termux — do not install them)
# ==============================================================
banner
echo -e "${Y}--- [1/5] Bootstrapping Termux (fresh install safe) ---${NC}"

export DEBIAN_FRONTEND=noninteractive

echo -e "${Y}  Updating base Termux packages...${NC}"
pkg update -y && pkg upgrade -y

echo -e "${Y}  Adding x11-repo (provides termux-x11-nightly)...${NC}"
# x11-repo is the ONLY repo package needed.
# There is no "termux-x11-repo" package — that does not exist.
pkg install -y x11-repo

echo -e "${Y}  Re-reading package lists with x11-repo enabled...${NC}"
pkg update -y

echo -e "${Y}  Installing core packages...${NC}"
# Verified package names that actually exist in Termux repos:
#   termux-x11-nightly  — the X11 server companion (from x11-repo)
#   pulseaudio          — audio server
#   virglrenderer-android — GPU acceleration
#   proot-distro        — for running proot Linux distros
#   wget curl bash      — download/scripting utilities
#
# Packages that do NOT exist in Termux (removed):
#   x11-utils    → does not exist
#   x11-fonts    → does not exist
#   xorg-xrdb    → does not exist in Termux native pkg
#   termux-x11-repo → does not exist (it's x11-repo, not termux-x11-repo)
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
echo    "║                                              ║"
echo -e "╚══════════════════════════════════════════════╝${NC}"
read -p "Select a distro (0-17): " distro_choice

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
    *)  echo -e "${R}Invalid choice. Exiting.${NC}"; exit 1 ;;
esac

echo -e "${G}✓ Selected: $DNAME${NC}"

if [ "$PKG_TYPE" != "pkg" ]; then
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
    # Native: no MATE (mate-session-manager never compiled for Termux)
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
        1) de_choice=1 ;;  # XFCE4
        2) de_choice=2 ;;  # LXQt
        3) de_choice=4 ;;  # Fluxbox
        4) de_choice=5 ;;  # Openbox
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
# Package definitions — all names verified against actual repos
# ==============================================================

case $PKG_TYPE in

    # ----------------------------------------------------------
    # NATIVE TERMUX
    # Verified available in x11-repo / main Termux repo:
    #   xfce4, xfce4-goodies, dbus, lxqt, fluxbox,
    #   openbox, pypanel, xorg-xsetroot
    # Launcher: termux-x11 :0 -xstartup "..."  (official method)
    # ----------------------------------------------------------
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
            5) DE_PKGS="openbox pypanel xorg-xsetroot"
               DE_START="openbox"
               DE_NAME="Openbox" ;;
        esac
        INSTALL_CMD="pkg install -y $DE_PKGS"
        APPEAR_CMD="pkg install -y $APPEAR_PKGS"
        ;;

    # ----------------------------------------------------------
    # APT — Debian, Ubuntu, Trisquel, Pardus, Deepin
    # ----------------------------------------------------------
    apt)
        UPD="apt update -y && apt upgrade -y"
        EXTRA="dbus-x11 xauth fonts-noto"
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
            5) DE_PKGS="openbox openbox-menu pypanel x11-xserver-utils"
               DE_START="openbox"
               DE_NAME="Openbox" ;;
            *) echo -e "${R}Invalid choice.${NC}"; exit 1 ;;
        esac
        INSTALL_CMD="$UPD && apt install -y $DE_PKGS $EXTRA"
        APPEAR_CMD="apt install -y $APPEAR_PKGS"
        ;;

    # ----------------------------------------------------------
    # PACMAN — Arch, Artix, Manjaro
    # ----------------------------------------------------------
    pacman)
        UPD="pacman -Syu --noconfirm"
        EXTRA="dbus xorg-xauth noto-fonts"
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
            5) DE_PKGS="openbox pypanel xorg-xsetroot"
               DE_START="openbox"
               DE_NAME="Openbox" ;;
            *) echo -e "${R}Invalid choice.${NC}"; exit 1 ;;
        esac
        INSTALL_CMD="$UPD && pacman -S --noconfirm $DE_PKGS $EXTRA"
        APPEAR_CMD="pacman -S --noconfirm $APPEAR_PKGS"
        ;;

    # ----------------------------------------------------------
    # DNF — Fedora, AlmaLinux, Oracle, Rocky
    # ----------------------------------------------------------
    dnf)
        UPD="dnf update -y"
        EXTRA="dbus-x11 xauth google-noto-fonts-common"
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
            5) DE_PKGS="openbox pypanel xorg-x11-server-utils"
               DE_START="openbox"
               DE_NAME="Openbox" ;;
            *) echo -e "${R}Invalid choice.${NC}"; exit 1 ;;
        esac
        INSTALL_CMD="$UPD && dnf install -y $DE_PKGS $EXTRA"
        APPEAR_CMD="dnf install -y $APPEAR_PKGS"
        ;;

    # ----------------------------------------------------------
    # APK — Alpine, Chimera, Adelie
    # ----------------------------------------------------------
    apk)
        UPD="apk update && apk upgrade"
        EXTRA="dbus-x11 xauth font-noto"
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
            5) DE_PKGS="openbox pypanel xsetroot"
               DE_START="openbox"
               DE_NAME="Openbox" ;;
            *) echo -e "${R}Invalid choice.${NC}"; exit 1 ;;
        esac
        INSTALL_CMD="$UPD && apk add $DE_PKGS $EXTRA"
        APPEAR_CMD="$UPD && apk add $APPEAR_PKGS && \
            (apk add lxappearance 2>/dev/null || \
             (echo '@testing https://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories && \
              apk update && apk add lxappearance@testing))"
        ;;

    # ----------------------------------------------------------
    # XBPS — Void Linux
    # ----------------------------------------------------------
    xbps)
        UPD="xbps-install -Suy"
        EXTRA="dbus-x11 xauth noto-fonts-ttf"
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
            5) DE_PKGS="openbox pypanel xsetroot"
               DE_START="openbox"
               DE_NAME="Openbox" ;;
            *) echo -e "${R}Invalid choice.${NC}"; exit 1 ;;
        esac
        INSTALL_CMD="$UPD && xbps-install -y $DE_PKGS $EXTRA"
        APPEAR_CMD="xbps-install -y $APPEAR_PKGS"
        ;;

    # ----------------------------------------------------------
    # ZYPPER — OpenSUSE
    # ----------------------------------------------------------
    zypper)
        UPD="zypper --non-interactive refresh && zypper --non-interactive update"
        EXTRA="dbus-1-x11 xauth google-noto-fonts"
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
            5) DE_PKGS="openbox python3-pyxdg xsetroot"
               DE_START="openbox"
               DE_NAME="Openbox" ;;
            *) echo -e "${R}Invalid choice.${NC}"; exit 1 ;;
        esac
        INSTALL_CMD="$UPD && zypper --non-interactive install $DE_PKGS $EXTRA"
        APPEAR_CMD="zypper --non-interactive install $APPEAR_PKGS"
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
# STEP 5 — Extra init for Fluxbox / Openbox
# ==============================================================
FLUXBOX_INIT=""
if [ "$DE_NAME" = "Fluxbox" ]; then
    FLUXBOX_INIT='mkdir -p ~/.fluxbox && fluxbox-generate_menu 2>/dev/null || true'
fi

OPENBOX_INIT=""
if [ "$DE_NAME" = "Openbox" ]; then
    OPENBOX_INIT='mkdir -p ~/.config/openbox
cat > ~/.config/openbox/autostart << OBAUTO
xsetroot -solid gray &
pypanel &
OBAUTO'
fi

# ==============================================================
# STEP 6 — Generate ~/start.sh
# ==============================================================
echo -e "${Y}--- [5/5] Creating ~/start.sh launcher ---${NC}"

# ---- Native Termux launcher ----
# Uses termux-x11 :0 -xstartup "..." — the official documented method.
# The DE is passed directly as -xstartup so no separate DISPLAY export needed.
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
pkill -f pulseaudio            2>/dev/null
pkill -f virgl_test_server     2>/dev/null
sleep 1

echo -e "\${Y}Starting PulseAudio...\${NC}"
pulseaudio --start \
  --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" \
  --exit-idle-time=-1
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
pkill -f pulseaudio            2>/dev/null
pkill -f virgl_test_server     2>/dev/null
sleep 1

echo -e "\${Y}Starting PulseAudio...\${NC}"
pulseaudio --start \
  --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" \
  --exit-idle-time=-1
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
  mkdir -p \\\$XDG_RUNTIME_DIR && chmod 700 \\\$XDG_RUNTIME_DIR
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