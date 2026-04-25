#!/data/data/com.termux/files/usr/bin/bash

# ==============================================================
#  TERMUX-X11 FULL SETUP SCRIPT - COMPLETE EDITION v2.1
#  Distro: Adelie, AlmaLinux, Alpine, Arch, Artix, Chimera,
#          Debian, Deepin, Fedora, Manjaro, OpenSUSE, Oracle,
#          Pardus, Rocky, Trisquel, Ubuntu, Void
#          + Native Termux (no proot)
#  DE/WM:  XFCE4, LXQt, MATE, Fluxbox, Openbox
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
    echo "║   TERMUX-X11 LINUX DESKTOP SETUP v2.1       ║"
    echo "║   All Distros    - All DEs -     - TX11     ║"
    echo "╚══════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# ==============================================================
# 1. SYSTEM UPDATE & CORE PACKAGES
# ==============================================================
banner
echo -e "${Y}--- [1/5] Updating system and installing core packages ---${NC}"

pkg update -y && pkg upgrade -y
pkg install -y termux-x11-repo x11-repo
pkg install -y \
    termux-x11-nightly \
    x11-utils \
    x11-fonts \
    xorg-xrdb \
    pulseaudio \
    virglrenderer-android \
    wget curl bash

echo -e "${G}✓ Core packages installed.${NC}"
sleep 1

# ==============================================================
# 2. DISTRIBUTION SELECTION
# ==============================================================
banner
echo -e "${C}╔══════════════════════════════════════════════╗"
echo    "║          SELECT YOUR DISTRIBUTION            ║"
echo    "╠══════════════════════════════════════════════╣"
echo    "║                                              ║"
echo    "║   0)  Native Termux (no proot, fastest!)    ║"
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
echo    "║                                             ║"
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
    pkg install -y proot-distro
    echo -e "${Y}--- [2/5] Installing $DNAME via proot-distro ---${NC}"
    proot-distro install $DISTRO
    echo -e "${G}✓ $DNAME installed.${NC}"
else
    echo -e "${G}✓ Native Termux — skipping proot-distro.${NC}"
fi
sleep 1

# ==============================================================
# 3. DESKTOP ENVIRONMENT / WINDOW MANAGER SELECTION
# ==============================================================
banner
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

# ==============================================================
# Package lists — all verified per distro/DE
# ==============================================================

case $PKG_TYPE in

    # ====================================================================
    # NATIVE TERMUX (pkg / x11-repo)
    # Notes:
    #   XFCE4: pkg=xfce4, launcher=dbus-launch --exit-with-session xfce4-session
    #   LXQt:  pkg=lxqt,  launcher=startlxqt (includes lxqt-session)
    #   MATE:  pkg=mate-desktop (Termux x11-repo meta), launcher=mate-session
    #          mate-session-manager is bundled inside mate-desktop in x11-repo
    #   Fluxbox: pkg=fluxbox, launcher=fluxbox
    #   Openbox: pkg=openbox + openbox-menu + pypanel + xorg-xsetroot
    #            launcher=openbox (openbox-session does NOT exist in Termux)
    #   Appearance: arc-theme-gnome, papirus-icon-theme, noto-fonts-emoji,
    #               ttf-dejavu, qt5ct, lxappearance — all in x11-repo
    # ====================================================================
    pkg)
        APPEAR_PKGS="arc-theme-gnome papirus-icon-theme noto-fonts-emoji ttf-dejavu qt5ct lxappearance"
        case $de_choice in
            1) DE_PKGS="xfce4 xfce4-goodies dbus"
               START="dbus-launch --exit-with-session xfce4-session"
               DE_NAME="XFCE4"   ;;
            2) DE_PKGS="lxqt"
               START="startlxqt"
               DE_NAME="LXQt"    ;;
            3) DE_PKGS="mate-desktop dbus"
               START="dbus-launch --exit-with-session mate-session"
               DE_NAME="MATE"    ;;
            4) DE_PKGS="fluxbox"
               START="fluxbox"
               DE_NAME="Fluxbox" ;;
            5) DE_PKGS="openbox openbox-menu pypanel xorg-xsetroot"
               START="openbox"
               DE_NAME="Openbox" ;;
            *) echo -e "${R}Invalid choice.${NC}"; exit 1 ;;
        esac
        INSTALL_CMD="pkg install -y $DE_PKGS"
        APPEAR_CMD="pkg install -y $APPEAR_PKGS"
        ;;

    # ====================================================================
    # APT — Debian, Ubuntu, Trisquel, Pardus, Deepin
    # Notes:
    #   XFCE4: xfce4 + xfce4-goodies. Launcher: dbus-launch xfce4-session
    #   LXQt:  lxqt (meta includes lxqt-session). Launcher: startlxqt
    #   MATE:  mate-desktop-environment (includes mate-session-manager,
    #          marco, mate-panel, caja). Launcher: mate-session
    #          mate-session-manager is a dependency, always pulled in.
    #   Fluxbox: fluxbox. Launcher: fluxbox
    #   Openbox: openbox + openbox-menu + pypanel + x11-xserver-utils
    #            Launcher: openbox (NOT openbox-session, doesn't exist on apt)
    #   Appearance: arc-theme, papirus-icon-theme, fonts-noto-color-emoji,
    #               ttf-dejavu-extra (NOT fonts-ubuntu, doesn't exist on Debian),
    #               qt5ct, lxappearance
    # ====================================================================
    apt)
        UPD="apt update -y && apt upgrade -y"
        EXTRA="dbus-x11 xauth fonts-noto"
        APPEAR_PKGS="arc-theme papirus-icon-theme fonts-noto-color-emoji ttf-dejavu-extra qt5ct lxappearance"
        case $de_choice in
            1) DE_PKGS="xfce4 xfce4-goodies dbus-x11"
               START="dbus-launch --exit-with-session xfce4-session"
               DE_NAME="XFCE4"   ;;
            2) DE_PKGS="lxqt sddm"
               START="startlxqt"
               DE_NAME="LXQt"    ;;
            3) DE_PKGS="mate-desktop-environment dbus-x11"
               START="dbus-launch --exit-with-session mate-session"
               DE_NAME="MATE"    ;;
            4) DE_PKGS="fluxbox"
               START="fluxbox"
               DE_NAME="Fluxbox" ;;
            5) DE_PKGS="openbox openbox-menu pypanel x11-xserver-utils"
               START="openbox"
               DE_NAME="Openbox" ;;
            *) echo -e "${R}Invalid choice.${NC}"; exit 1 ;;
        esac
        INSTALL_CMD="$UPD && apt install -y $DE_PKGS $EXTRA"
        APPEAR_CMD="apt install -y $APPEAR_PKGS"
        ;;

    # ====================================================================
    # PACMAN — Arch, Artix, Manjaro
    # Notes:
    #   XFCE4: xfce4 + xfce4-goodies. Launcher: dbus-launch xfce4-session
    #   LXQt:  lxqt (meta group, includes lxqt-session). Launcher: startlxqt
    #   MATE:  mate + mate-extra (mate group includes mate-session-manager,
    #          marco, mate-panel, caja). mate-extra adds pluma, atril, etc.
    #          Launcher: mate-session
    #   Fluxbox: fluxbox. Launcher: fluxbox
    #   Openbox: openbox + pypanel + xorg-xsetroot
    #            Launcher: openbox (openbox-session is just an alias for openbox on Arch)
    #   Appearance: arc-gtk-theme (NOT arc-theme on Arch), papirus-icon-theme,
    #               noto-fonts-emoji, ttf-ubuntu-font-family, qt5ct, lxappearance
    # ====================================================================
    pacman)
        UPD="pacman -Syu --noconfirm"
        EXTRA="dbus xorg-xauth noto-fonts"
        APPEAR_PKGS="arc-gtk-theme papirus-icon-theme noto-fonts-emoji ttf-ubuntu-font-family qt5ct lxappearance"
        case $de_choice in
            1) DE_PKGS="xfce4 xfce4-goodies dbus"
               START="dbus-launch --exit-with-session xfce4-session"
               DE_NAME="XFCE4"   ;;
            2) DE_PKGS="lxqt"
               START="startlxqt"
               DE_NAME="LXQt"    ;;
            3) DE_PKGS="mate mate-extra dbus"
               START="dbus-launch --exit-with-session mate-session"
               DE_NAME="MATE"    ;;
            4) DE_PKGS="fluxbox"
               START="fluxbox"
               DE_NAME="Fluxbox" ;;
            5) DE_PKGS="openbox pypanel xorg-xsetroot"
               START="openbox"
               DE_NAME="Openbox" ;;
            *) echo -e "${R}Invalid choice.${NC}"; exit 1 ;;
        esac
        INSTALL_CMD="$UPD && pacman -S --noconfirm $DE_PKGS $EXTRA"
        APPEAR_CMD="pacman -S --noconfirm $APPEAR_PKGS"
        ;;

    # ====================================================================
    # DNF — Fedora, AlmaLinux, Oracle, Rocky
    # Notes:
    #   XFCE4: @xfce-desktop group. Launcher: dbus-launch xfce4-session
    #   LXQt:  @lxqt-desktop group. Launcher: startlxqt
    #   MATE:  mate-session-manager is NOT always in @mate-desktop on DNF distros.
    #          Install explicitly: mate-session-manager + marco + mate-panel +
    #          mate-desktop + caja + dbus-x11
    #          Launcher: dbus-launch mate-session
    #   Fluxbox: fluxbox. Launcher: fluxbox
    #   Openbox: openbox + pypanel + xorg-x11-server-utils
    #            Launcher: openbox
    #   Appearance: arc-theme, papirus-icon-theme,
    #               google-noto-color-emoji-fonts (NOT google-noto-emoji-fonts),
    #               google-noto-sans-fonts, qt5ct, lxappearance
    # ====================================================================
    dnf)
        UPD="dnf update -y"
        EXTRA="dbus-x11 xauth google-noto-fonts-common"
        APPEAR_PKGS="arc-theme papirus-icon-theme google-noto-color-emoji-fonts google-noto-sans-fonts qt5ct lxappearance"
        case $de_choice in
            1) DE_PKGS="@xfce-desktop dbus-x11"
               START="dbus-launch --exit-with-session xfce4-session"
               DE_NAME="XFCE4"   ;;
            2) DE_PKGS="@lxqt-desktop"
               START="startlxqt"
               DE_NAME="LXQt"    ;;
            3) DE_PKGS="mate-session-manager marco mate-panel mate-desktop caja dbus-x11"
               START="dbus-launch --exit-with-session mate-session"
               DE_NAME="MATE"    ;;
            4) DE_PKGS="fluxbox"
               START="fluxbox"
               DE_NAME="Fluxbox" ;;
            5) DE_PKGS="openbox pypanel xorg-x11-server-utils"
               START="openbox"
               DE_NAME="Openbox" ;;
            *) echo -e "${R}Invalid choice.${NC}"; exit 1 ;;
        esac
        INSTALL_CMD="$UPD && dnf install -y $DE_PKGS $EXTRA"
        APPEAR_CMD="dnf install -y $APPEAR_PKGS"
        ;;

    # ====================================================================
    # APK — Alpine, Chimera, Adelie
    # Notes:
    #   XFCE4: xfce4 + xfce4-extras (meta in Alpine). Launcher: dbus-launch xfce4-session
    #   LXQt:  lxqt + lxqt-session (session manager separate in Alpine!)
    #          Launcher: startlxqt
    #   MATE:  mate-desktop is NOT a full meta on Alpine.
    #          Need: marco mate-panel mate-session-manager caja dbus-x11
    #          Launcher: dbus-launch mate-session
    #   Fluxbox: fluxbox. Launcher: fluxbox
    #   Openbox: openbox + pypanel + xsetroot
    #            Launcher: openbox
    #   Appearance: arc-theme NOT in Alpine repos (removed).
    #               papirus-icon-theme OK, font-noto OK (includes emoji),
    #               font-dejavu OK, qt5ct OK,
    #               lxappearance in testing repo (fallback added)
    # ====================================================================
    apk)
        UPD="apk update && apk upgrade"
        EXTRA="dbus-x11 xauth font-noto"
        APPEAR_PKGS="papirus-icon-theme font-noto font-dejavu qt5ct"
        case $de_choice in
            1) DE_PKGS="xfce4 xfce4-extras dbus-x11"
               START="dbus-launch --exit-with-session xfce4-session"
               DE_NAME="XFCE4"   ;;
            2) DE_PKGS="lxqt lxqt-session"
               START="startlxqt"
               DE_NAME="LXQt"    ;;
            3) DE_PKGS="marco mate-panel mate-session-manager caja dbus-x11"
               START="dbus-launch --exit-with-session mate-session"
               DE_NAME="MATE"    ;;
            4) DE_PKGS="fluxbox"
               START="fluxbox"
               DE_NAME="Fluxbox" ;;
            5) DE_PKGS="openbox pypanel xsetroot"
               START="openbox"
               DE_NAME="Openbox" ;;
            *) echo -e "${R}Invalid choice.${NC}"; exit 1 ;;
        esac
        INSTALL_CMD="$UPD && apk add $DE_PKGS $EXTRA"
        APPEAR_CMD="$UPD && apk add $APPEAR_PKGS && \
            (apk add lxappearance 2>/dev/null || \
             (echo '@testing https://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories && \
              apk update && apk add lxappearance@testing))"
        ;;

    # ====================================================================
    # XBPS — Void Linux
    # Notes:
    #   XFCE4: xfce4 + xfce4-goodies. Launcher: dbus-launch xfce4-session
    #   LXQt:  lxqt (meta includes lxqt-session on Void). Launcher: startlxqt
    #   MATE:  mate (meta group on Void includes mate-session-manager,
    #          marco, mate-panel, caja). mate-extra adds extra apps.
    #          Launcher: dbus-launch mate-session
    #   Fluxbox: fluxbox. Launcher: fluxbox
    #   Openbox: openbox + pypanel + xsetroot
    #            Launcher: openbox
    #   Appearance: arc-theme OK in Void, papirus-icon-theme OK,
    #               noto-fonts-emoji OK, font-ubuntu-ttf (NOT font-ubuntu!),
    #               qt5ct OK, lxappearance OK
    # ====================================================================
    xbps)
        UPD="xbps-install -Suy"
        EXTRA="dbus-x11 xauth noto-fonts-ttf"
        APPEAR_PKGS="arc-theme papirus-icon-theme noto-fonts-emoji font-ubuntu-ttf qt5ct lxappearance"
        case $de_choice in
            1) DE_PKGS="xfce4 xfce4-goodies dbus-x11"
               START="dbus-launch --exit-with-session xfce4-session"
               DE_NAME="XFCE4"   ;;
            2) DE_PKGS="lxqt"
               START="startlxqt"
               DE_NAME="LXQt"    ;;
            3) DE_PKGS="mate mate-extra dbus-x11"
               START="dbus-launch --exit-with-session mate-session"
               DE_NAME="MATE"    ;;
            4) DE_PKGS="fluxbox"
               START="fluxbox"
               DE_NAME="Fluxbox" ;;
            5) DE_PKGS="openbox pypanel xsetroot"
               START="openbox"
               DE_NAME="Openbox" ;;
            *) echo -e "${R}Invalid choice.${NC}"; exit 1 ;;
        esac
        INSTALL_CMD="$UPD && xbps-install -y $DE_PKGS $EXTRA"
        APPEAR_CMD="xbps-install -y $APPEAR_PKGS"
        ;;

    # ====================================================================
    # ZYPPER — OpenSUSE
    # Notes:
    #   XFCE4: xfce4 + xfce4-goodies. Launcher: dbus-launch xfce4-session
    #   LXQt:  lxqt (pattern). Launcher: startlxqt
    #   MATE:  On OpenSUSE the pattern is "mate" (zypper install -t pattern mate).
    #          But for proot (no systemd) install individual pkgs:
    #          mate-session-manager marco mate-panel caja dbus-1-x11
    #          Launcher: dbus-launch mate-session
    #   Fluxbox: fluxbox. Launcher: fluxbox
    #   Openbox: openbox + python3-pyxdg + xsetroot
    #            Launcher: openbox
    #   Appearance: metatheme-arc-common (NOT arc-gtk-theme, that's OBS-only),
    #               papirus-icon-theme OK,
    #               google-noto-coloremoji-fonts (correct OpenSUSE name),
    #               google-noto-sans-fonts OK, qt5ct OK, lxappearance OK
    # ====================================================================
    zypper)
        UPD="zypper --non-interactive refresh && zypper --non-interactive update"
        EXTRA="dbus-1-x11 xauth google-noto-fonts"
        APPEAR_PKGS="metatheme-arc-common papirus-icon-theme google-noto-coloremoji-fonts google-noto-sans-fonts qt5ct lxappearance"
        case $de_choice in
            1) DE_PKGS="xfce4 xfce4-goodies dbus-1-x11"
               START="dbus-launch --exit-with-session xfce4-session"
               DE_NAME="XFCE4"   ;;
            2) DE_PKGS="lxqt"
               START="startlxqt"
               DE_NAME="LXQt"    ;;
            3) DE_PKGS="mate-session-manager marco mate-panel caja dbus-1-x11"
               START="dbus-launch --exit-with-session mate-session"
               DE_NAME="MATE"    ;;
            4) DE_PKGS="fluxbox"
               START="fluxbox"
               DE_NAME="Fluxbox" ;;
            5) DE_PKGS="openbox python3-pyxdg xsetroot"
               START="openbox"
               DE_NAME="Openbox" ;;
            *) echo -e "${R}Invalid choice.${NC}"; exit 1 ;;
        esac
        INSTALL_CMD="$UPD && zypper --non-interactive install $DE_PKGS $EXTRA"
        APPEAR_CMD="zypper --non-interactive install $APPEAR_PKGS"
        ;;
esac

# ==============================================================
# Install DE
# ==============================================================
echo -e "${G}✓ Selected: $DE_NAME${NC}"
echo -e "${Y}--- [3/5] Installing $DE_NAME inside $DNAME ---${NC}"
echo -e "${Y}(This may take several minutes...)${NC}"

if [ "$PKG_TYPE" = "pkg" ]; then
    bash -c "$INSTALL_CMD"
else
    proot-distro login $DISTRO -- bash -c "$INSTALL_CMD"
fi

echo -e "${G}✓ $DE_NAME installed inside $DNAME.${NC}"
sleep 1

# ==============================================================
# 4. APPEARANCE PACKAGES (OPTIONAL)
# ==============================================================
banner
echo -e "${C}╔══════════════════════════════════════════════╗"
echo    "║         RECOMMENDED APPEARANCE PACKAGES      ║"
echo    "╠══════════════════════════════════════════════╣"
echo    "║                                              ║"
echo    "║  The following packages will be installed:  ║"
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
read -p "$(echo -e ${Y})Do you want to install the recommended appearance packages? [Y/n]: $(echo -e ${NC})" appear_choice
appear_choice="${appear_choice:-Y}"

if [[ "$appear_choice" =~ ^[Yy]$ ]]; then
    echo -e "${Y}--- [4/5] Installing appearance packages inside $DNAME ---${NC}"
    if [ "$PKG_TYPE" = "pkg" ]; then
        bash -c "$APPEAR_CMD"
    else
        proot-distro login $DISTRO -- bash -c "$APPEAR_CMD"
    fi
    APPEAR_INSTALLED=true
    echo -e "${G}✓ Appearance packages installed.${NC}"
else
    echo -e "${Y}⚠ Skipping appearance packages.${NC}"
    APPEAR_INSTALLED=false
fi
sleep 1

# ==============================================================
# 5. AUTOSTART EXTRAS FOR FLUXBOX / OPENBOX
# ==============================================================

FLUXBOX_EXTRA=""
if [ "$DE_NAME" = "Fluxbox" ]; then
    FLUXBOX_EXTRA='mkdir -p ~/.fluxbox && fluxbox-generate_menu 2>/dev/null || true'
fi

OPENBOX_AUTOSTART=""
if [ "$DE_NAME" = "Openbox" ]; then
    OPENBOX_AUTOSTART='mkdir -p ~/.config/openbox
cat > ~/.config/openbox/autostart <<OBAUTO
xsetroot -solid gray &
pypanel &
OBAUTO'
fi

# ==============================================================
# 6. CREATE start.sh LAUNCHER
# ==============================================================
echo -e "${Y}--- [5/5] Creating ~/start.sh launcher ---${NC}"

# ---- NATIVE TERMUX launcher (no proot) ----
if [ "$PKG_TYPE" = "pkg" ]; then

cat > ~/start.sh <<STARTSCRIPT
#!/data/data/com.termux/files/usr/bin/bash
# START: Native Termux + $DE_NAME — Termux-X11

R='\033[0;31m'
G='\033[0;32m'
Y='\033[1;33m'
C='\033[0;36m'
NC='\033[0m'

echo -e "\${C}╔══════════════════════════════════╗\${NC}"
echo -e "\${C}║  Native Termux + $DE_NAME         \${NC}"
echo -e "\${C}╚══════════════════════════════════╝\${NC}"

echo -e "\${Y}Cleaning up old sessions...\${NC}"
kill -9 \$(pgrep -f "termux.x11") 2>/dev/null
pkill -f pulseaudio 2>/dev/null
pkill -f virgl_test_server 2>/dev/null
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

echo -e "\${Y}Starting Termux-X11 on :0 ...\${NC}"
export XDG_RUNTIME_DIR=\${TMPDIR}
termux-x11 :0 >/dev/null &
sleep 3

am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity >/dev/null 2>&1
sleep 1

echo -e "\${G}✓ Open the Termux-X11 app now!\${NC}"
echo -e "\${C}Launching $DE_NAME...\${NC}"

export DISPLAY=:0
export PULSE_SERVER=127.0.0.1
export GALLIUM_DRIVER=virpipe
export MESA_GL_VERSION_OVERRIDE=4.0
export XDG_RUNTIME_DIR=\${TMPDIR}
$FLUXBOX_EXTRA
$OPENBOX_AUTOSTART
$START

echo -e "\${Y}Session ended. Cleaning up...\${NC}"
kill \$VIRGL_PID 2>/dev/null
pkill -f pulseaudio 2>/dev/null
echo -e "\${G}Goodbye!\${NC}"
STARTSCRIPT

# ---- PROOT-DISTRO launcher ----
else

cat > ~/start.sh <<STARTSCRIPT
#!/data/data/com.termux/files/usr/bin/bash
# START: $DNAME proot + $DE_NAME — Termux-X11

R='\033[0;31m'
G='\033[0;32m'
Y='\033[1;33m'
C='\033[0;36m'
NC='\033[0m'

echo -e "\${C}╔══════════════════════════════════╗\${NC}"
echo -e "\${C}║  $DNAME + $DE_NAME\${NC}"
echo -e "\${C}╚══════════════════════════════════╝\${NC}"

echo -e "\${Y}Cleaning up old sessions...\${NC}"
kill -9 \$(pgrep -f "termux.x11") 2>/dev/null
pkill -f pulseaudio 2>/dev/null
pkill -f virgl_test_server 2>/dev/null
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

echo -e "\${Y}Starting Termux-X11 on :0 ...\${NC}"
export XDG_RUNTIME_DIR=\${TMPDIR}
termux-x11 :0 >/dev/null &
sleep 3

am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity >/dev/null 2>&1
sleep 1

echo -e "\${G}✓ Open the Termux-X11 app now!\${NC}"
echo -e "\${C}Launching $DE_NAME in $DNAME...\${NC}"

proot-distro login $DISTRO --shared-tmp -- bash -c "
  export DISPLAY=:0
  export PULSE_SERVER=127.0.0.1
  export GALLIUM_DRIVER=virpipe
  export MESA_GL_VERSION_OVERRIDE=4.0
  export XDG_RUNTIME_DIR=/tmp/runtime-root
  mkdir -p \\\$XDG_RUNTIME_DIR && chmod 700 \\\$XDG_RUNTIME_DIR
  $FLUXBOX_EXTRA
  $OPENBOX_AUTOSTART
  $START
"

echo -e "\${Y}Session ended. Cleaning up...\${NC}"
kill \$VIRGL_PID 2>/dev/null
pkill -f pulseaudio 2>/dev/null
echo -e "\${G}Goodbye!\${NC}"
STARTSCRIPT

fi

chmod +x ~/start.sh

# ==============================================================
# DONE
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
echo "║  Appearance: Installed ✓"
else
echo "║  Appearance: Skipped"
fi
echo "╠══════════════════════════════════════════════╣"
echo "║  HOW TO START:                               ║"
echo "║                                              ║"
echo "║  1. Install the Termux-X11 APK from:        ║"
echo "║     github.com/termux/termux-x11/releases   ║"
echo "║                                              ║"
echo "║  2. In Termux, run:  ./start.sh              ║"
echo "║                                              ║"
echo "║  3. Open the Termux-X11 app on your device  ║"
echo "║                                              ║"
echo "╚══════════════════════════════════════════════╝"
echo -e "${NC}"