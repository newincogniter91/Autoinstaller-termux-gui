#!/data/data/com.termux/files/usr/bin/bash

# ==============================================================
#  TERMUX-X11 FULL SETUP SCRIPT - COMPLETE EDITION
#  Distro: Adelie, AlmaLinux, Alpine, Arch, Artix, Chimera,
#          Debian, Deepin, Fedora, Manjaro, OpenSUSE, Oracle,
#          Pardus, Rocky, Termux, Trisquel, Ubuntu, Void
#  DE/WM:  XFCE4, LXQt, MATE, Fluxbox, Openbox
#  Display: Termux-X11 ONLY
# ==============================================================

R='\033[0;31m'
G='\033[0;32m'
Y='\033[1;33m'
C='\033[0;36m'
B='\033[1;34m'
NC='\033[0m'

banner() {
    clear
    echo -e "${C}"
    echo "╔══════════════════════════════════════════════╗"
    echo "║    TERMUX-X11 LINUX DESKTOP SETUP v2.0      ║"
    echo "║   All Distros    - All DEs -     - TX11     ║"
    echo "╚══════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# ==============================================================
# 1. SYSTEM UPDATE & CORE PACKAGES
# ==============================================================
banner
echo -e "${Y}--- [1/4] Updating system and installing core packages ---${NC}"

pkg update -y && pkg upgrade -y

pkg install -y termux-x11-repo x11-repo

pkg install -y \
    termux-x11-nightly \
    x11-utils \
    x11-fonts \
    xorg-xrdb \
    pulseaudio \
    virglrenderer-android \
    proot-distro \
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
echo    "║   --- Debian/Ubuntu based ---                ║"
echo    "║   1)  Debian        (Stable, Recommended)   ║"
echo    "║   2)  Ubuntu 25.10  (Popular, Large repos)  ║"
echo    "║   3)  Trisquel GNU  (Free Debian-based)     ║"
echo    "║   4)  Pardus        (Turkish Debian-based)  ║"
echo    "║                                             ║"
echo    "║   --- Arch based ---                        ║"
echo    "║   5)  Arch Linux    (Advanced users)        ║"
echo    "║   6)  Artix Linux   (Arch, no systemd)      ║"
echo    "║   7)  Manjaro       (Arch, user-friendly)   ║"
echo    "║                                             ║"
echo    "║   --- RPM based ---                         ║"
echo    "║   8)  Fedora        (Modern, cutting-edge)  ║"
echo    "║   9)  AlmaLinux     (RHEL compatible)       ║"
echo    "║   10) Oracle Linux  (Enterprise RHEL)       ║"
echo    "║   11) Rocky Linux   (RHEL compatible)       ║"
echo    "║                                             ║"
echo    "║   --- Independent ---                       ║"
echo    "║   12) Alpine Linux  (Ultra minimal, musl)   ║"
echo    "║   13) Void Linux    (Runit, independent)    ║"
echo    "║   14) OpenSUSE      (YaST, rolling/stable)  ║"
echo    "║   15) Chimera Linux (musl/LLVM based)       ║"
echo    "║   16) Adelie Linux  (musl Alpine-like)      ║"
echo    "║   17) Deepin        (Beautiful Chinese DE)  ║"
echo    "║                                             ║"
echo -e "╚══════════════════════════════════════════════╝${NC}"
read -p "Select a distro (1-17): " distro_choice

case $distro_choice in
    1)  DISTRO="debian";      PKG_TYPE="apt";    DNAME="Debian"        ;;
    2)  DISTRO="ubuntu";      PKG_TYPE="apt";    DNAME="Ubuntu"        ;;
    3)  DISTRO="trisquel";    PKG_TYPE="apt";    DNAME="Trisquel"      ;;
    4)  DISTRO="pardus";      PKG_TYPE="apt";    DNAME="Pardus"        ;;
    5)  DISTRO="archlinux";   PKG_TYPE="pacman"; DNAME="Arch Linux"    ;;
    6)  DISTRO="artix";       PKG_TYPE="pacman"; DNAME="Artix Linux"   ;;
    7)  DISTRO="manjaro";     PKG_TYPE="pacman"; DNAME="Manjaro"       ;;
    8)  DISTRO="fedora";      PKG_TYPE="dnf";    DNAME="Fedora"        ;;
    9)  DISTRO="almalinux";   PKG_TYPE="dnf";    DNAME="AlmaLinux"     ;;
    10) DISTRO="oracle";      PKG_TYPE="dnf";    DNAME="Oracle Linux"  ;;
    11) DISTRO="rockylinux";  PKG_TYPE="dnf";    DNAME="Rocky Linux"   ;;
    12) DISTRO="alpine";      PKG_TYPE="apk";    DNAME="Alpine Linux"  ;;
    13) DISTRO="void";        PKG_TYPE="xbps";   DNAME="Void Linux"    ;;
    14) DISTRO="opensuse";    PKG_TYPE="zypper"; DNAME="OpenSUSE"      ;;
    15) DISTRO="chimera";     PKG_TYPE="apk";    DNAME="Chimera Linux" ;;
    16) DISTRO="adelie";      PKG_TYPE="apk";    DNAME="Adelie Linux"  ;;
    17) DISTRO="deepin";      PKG_TYPE="apt";    DNAME="Deepin"        ;;
    *)  echo -e "${R}Invalid choice. Exiting.${NC}"; exit 1 ;;
esac

echo -e "${G}✓ Selected: $DNAME${NC}"
echo -e "${Y}--- [2/4] Installing $DNAME via proot-distro ---${NC}"
proot-distro install $DISTRO
echo -e "${G}✓ $DNAME installed.${NC}"
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
# Build install command per PKG_TYPE and DE
# ==============================================================

case $PKG_TYPE in

    # ---- APT (Debian, Ubuntu, Trisquel, Pardus, Deepin) ----
    apt)
        UPD="apt update -y && apt upgrade -y"
        EXTRA="dbus-x11 xauth fonts-noto"
        case $de_choice in
            1) DE_PKGS="xfce4 xfce4-goodies";                     START="startxfce4";    DE_NAME="XFCE4"    ;;
            2) DE_PKGS="lxqt";                                     START="startlxqt";     DE_NAME="LXQt"     ;;
            3) DE_PKGS="mate-desktop-environment";                 START="mate-session";  DE_NAME="MATE"     ;;
            4) DE_PKGS="fluxbox";                                  START="fluxbox";       DE_NAME="Fluxbox"  ;;
            5) DE_PKGS="openbox openbox-menu pypanel x11-xserver-utils"; START="openbox-session"; DE_NAME="Openbox" ;;
            *) echo -e "${R}Invalid choice.${NC}"; exit 1 ;;
        esac
        INSTALL_CMD="$UPD && apt install -y $DE_PKGS $EXTRA"
        ;;

    # ---- PACMAN (Arch, Artix, Manjaro) ----
    pacman)
        UPD="pacman -Syu --noconfirm"
        EXTRA="dbus xorg-xauth noto-fonts"
        case $de_choice in
            1) DE_PKGS="xfce4 xfce4-goodies";     START="startxfce4";      DE_NAME="XFCE4"    ;;
            2) DE_PKGS="lxqt";                     START="startlxqt";       DE_NAME="LXQt"     ;;
            3) DE_PKGS="mate mate-extra";          START="mate-session";    DE_NAME="MATE"     ;;
            4) DE_PKGS="fluxbox";                  START="fluxbox";         DE_NAME="Fluxbox"  ;;
            5) DE_PKGS="openbox python-pyxdg pypanel xorg-xsetroot"; START="openbox-session"; DE_NAME="Openbox" ;;
            *) echo -e "${R}Invalid choice.${NC}"; exit 1 ;;
        esac
        INSTALL_CMD="$UPD && pacman -S --noconfirm $DE_PKGS $EXTRA"
        ;;

    # ---- DNF (Fedora, AlmaLinux, Oracle, Rocky) ----
    dnf)
        UPD="dnf update -y"
        EXTRA="dbus-x11 xauth google-noto-fonts-common"
        case $de_choice in
            1) DE_PKGS="@xfce-desktop";   START="startxfce4";    DE_NAME="XFCE4"    ;;
            2) DE_PKGS="@lxqt-desktop";   START="startlxqt";     DE_NAME="LXQt"     ;;
            3) DE_PKGS="@mate-desktop";   START="mate-session";  DE_NAME="MATE"     ;;
            4) DE_PKGS="fluxbox";         START="fluxbox";       DE_NAME="Fluxbox"  ;;
            5) DE_PKGS="openbox pypanel xorg-x11-server-utils"; START="openbox-session"; DE_NAME="Openbox" ;;
            *) echo -e "${R}Invalid choice.${NC}"; exit 1 ;;
        esac
        INSTALL_CMD="$UPD && dnf install -y $DE_PKGS $EXTRA"
        ;;

    # ---- APK (Alpine, Chimera, Adelie) ----
    apk)
        UPD="apk update && apk upgrade"
        EXTRA="dbus-x11 xauth font-noto"
        case $de_choice in
            1) DE_PKGS="xfce4 xfce4-extras";   START="startxfce4";    DE_NAME="XFCE4"    ;;
            2) DE_PKGS="lxqt";                  START="startlxqt";     DE_NAME="LXQt"     ;;
            3) DE_PKGS="mate-desktop";          START="mate-session";  DE_NAME="MATE"     ;;
            4) DE_PKGS="fluxbox";               START="fluxbox";       DE_NAME="Fluxbox"  ;;
            5) DE_PKGS="openbox pypanel xsetroot"; START="openbox-session"; DE_NAME="Openbox" ;;
            *) echo -e "${R}Invalid choice.${NC}"; exit 1 ;;
        esac
        INSTALL_CMD="$UPD && apk add $DE_PKGS $EXTRA"
        ;;

    # ---- XBPS (Void Linux) ----
    xbps)
        UPD="xbps-install -Suy"
        EXTRA="dbus-x11 xauth noto-fonts-ttf"
        case $de_choice in
            1) DE_PKGS="xfce4 xfce4-goodies";   START="startxfce4";    DE_NAME="XFCE4"    ;;
            2) DE_PKGS="lxqt";                   START="startlxqt";     DE_NAME="LXQt"     ;;
            3) DE_PKGS="mate mate-extra";        START="mate-session";  DE_NAME="MATE"     ;;
            4) DE_PKGS="fluxbox";                START="fluxbox";       DE_NAME="Fluxbox"  ;;
            5) DE_PKGS="openbox pypanel xsetroot"; START="openbox-session"; DE_NAME="Openbox" ;;
            *) echo -e "${R}Invalid choice.${NC}"; exit 1 ;;
        esac
        INSTALL_CMD="$UPD && xbps-install -y $DE_PKGS $EXTRA"
        ;;

    # ---- ZYPPER (OpenSUSE) ----
    zypper)
        UPD="zypper refresh && zypper update -y"
        EXTRA="dbus-1-x11 xauth noto-sans-fonts"
        case $de_choice in
            1) DE_PKGS="xfce4 xfce4-goodies";      START="startxfce4";    DE_NAME="XFCE4"    ;;
            2) DE_PKGS="lxqt";                      START="startlxqt";     DE_NAME="LXQt"     ;;
            3) DE_PKGS="mate-desktop";              START="mate-session";  DE_NAME="MATE"     ;;
            4) DE_PKGS="fluxbox";                   START="fluxbox";       DE_NAME="Fluxbox"  ;;
            5) DE_PKGS="openbox python3-pyxdg xsetroot"; START="openbox-session"; DE_NAME="Openbox" ;;
            *) echo -e "${R}Invalid choice.${NC}"; exit 1 ;;
        esac
        INSTALL_CMD="$UPD && zypper install -y $DE_PKGS $EXTRA"
        ;;
esac

echo -e "${G}✓ Selected: $DE_NAME${NC}"
echo -e "${Y}--- [3/4] Installing $DE_NAME inside $DNAME ---${NC}"
echo -e "${Y}(This may take several minutes...)${NC}"
proot-distro login $DISTRO -- bash -c "$INSTALL_CMD"
echo -e "${G}✓ $DE_NAME installed inside $DNAME.${NC}"
sleep 1

# ==============================================================
# 4. GENERATE AUTOSTART CONFIG FOR FLUXBOX/OPENBOX
# ==============================================================

# Extra config for Fluxbox autostart
FLUXBOX_EXTRA=""
if [ "$DE_NAME" == "Fluxbox" ]; then
    FLUXBOX_EXTRA='
    # Generate Fluxbox menu on first run
    mkdir -p ~/.fluxbox
    fluxbox-generate_menu 2>/dev/null || true'
fi

# Extra config for Openbox autostart
OPENBOX_EXTRA=""
if [ "$DE_NAME" == "Openbox" ]; then
    OPENBOX_EXTRA='
    # Set up Openbox autostart
    mkdir -p ~/.config/openbox
    cat > ~/.config/openbox/autostart <<OBAUTO
# Make background gray
xsetroot -solid gray
# Launch PyPanel taskbar
pypanel &
OBAUTO'
fi

# ==============================================================
# 5. CREATE start.sh LAUNCHER
# ==============================================================
echo -e "${Y}--- [4/4] Creating ~/start.sh launcher ---${NC}"

cat > ~/start.sh <<STARTSCRIPT
#!/data/data/com.termux/files/usr/bin/bash

# ============================================================
#  START SCRIPT
#  Distro  : $DNAME  ($DISTRO)
#  Desktop : $DE_NAME
#  Display : Termux-X11 (no VNC)
# ============================================================

R='\033[0;31m'
G='\033[0;32m'
Y='\033[1;33m'
C='\033[0;36m'
NC='\033[0m'

echo -e "\${C}╔══════════════════════════════════╗\${NC}"
echo -e "\${C}║  Starting: $DNAME + $DE_NAME\${NC}"
echo -e "\${C}╚══════════════════════════════════╝\${NC}"

# --- Kill old sessions ---
echo -e "\${Y}Cleaning up previous sessions...\${NC}"
pkill -f "termux-x11"       2>/dev/null
pkill -f "pulseaudio"       2>/dev/null
pkill -f "virgl_test_server" 2>/dev/null
sleep 1

# --- Start Termux-X11 ---
echo -e "\${Y}Starting Termux-X11 display server on :0 ...\${NC}"
termux-x11 :0 -xstartup "" &
TX11_PID=\$!
sleep 2

# --- Start PulseAudio ---
echo -e "\${Y}Starting PulseAudio...\${NC}"
pulseaudio --start \
    --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" \
    --exit-idle-time=-1
sleep 1

# --- Start VirGL hardware acceleration ---
echo -e "\${Y}Starting VirGL hardware acceleration...\${NC}"
virgl_test_server_android &
VIRGL_PID=\$!
sleep 1

echo -e "\${G}✓ Services ready. Open the Termux-X11 app now!\${NC}"
echo -e "\${C}Launching $DE_NAME in $DNAME...\${NC}"
sleep 2

# --- Launch proot-distro session ---
proot-distro login $DISTRO --shared-tmp -- bash -c "
    export DISPLAY=:0
    export GALLIUM_DRIVER=virpipe
    export MESA_GL_VERSION_OVERRIDE=4.0
    export PULSE_SERVER=tcp:127.0.0.1
    export XDG_RUNTIME_DIR=/tmp/runtime-root
    mkdir -p \\\$XDG_RUNTIME_DIR
    chmod 700 \\\$XDG_RUNTIME_DIR
    $FLUXBOX_EXTRA
    $OPENBOX_EXTRA
    export DBUS_SESSION_BUS_ADDRESS=\\\$(dbus-daemon --session --print-address --fork 2>/dev/null)
    $START
"

# --- Cleanup on exit ---
echo -e "\${Y}Session ended. Cleaning up...\${NC}"
kill \$TX11_PID   2>/dev/null
kill \$VIRGL_PID  2>/dev/null
pkill -f pulseaudio 2>/dev/null
echo -e "\${G}Goodbye!\${NC}"
STARTSCRIPT

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
echo "╠══════════════════════════════════════════════╣"
echo "║  HOW TO START:                               ║"
echo "║                                              ║"
echo "║  1. Install the Termux-X11 APK from:        ║"
echo "║     github.com/termux/termux-x11/releases   ║"
echo "║                                              ║"
echo "║  2. In Termux, run:                          ║"
echo "║     ./start.sh                               ║"
echo "║                                              ║"
echo "║  3. Open the Termux-X11 app on your device  ║"
echo "║                                              ║"
echo "╚══════════════════════════════════════════════╝"
echo -e "${NC}"