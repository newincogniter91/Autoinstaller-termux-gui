#!/data/data/com.termux/files/usr/bin/bash

# ==============================================================
#  TERMUX-X11 FULL SETUP SCRIPT v3.4
#  Fresh Termux install safe — no repos needed beforehand
#
#  Mode 0 — proot         : No root required. All 18 distros.
#  Mode 1 — chroot-distro : Root required.
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
    echo "║   TERMUX-X11 LINUX DESKTOP SETUP v3.4       ║"
    echo "║     proot · chroot-distro  —  TX11          ║"
    echo "╚══════════════════════════════════════════════╝"
    echo -e "${NC}"
}

check_root() {
    echo -e "${Y}Checking root access...${NC}"
    if ! su -c "id" 2>/dev/null | grep -q "uid=0"; then
        echo -e "${R}✗ Root access not available!${NC}"
        exit 1
    fi
    echo -e "${G}✓ Root access confirmed.${NC}"
}

banner
echo -e "${Y}--- [1/5] Bootstrapping Termux ---${NC}"
export DEBIAN_FRONTEND=noninteractive

echo -e "${Y}  Updating base Termux packages...${NC}"
pkg update -y && pkg upgrade -y
echo -e "${Y}  Adding x11-repo...${NC}"
pkg install -y x11-repo
echo -e "${Y}  Re-reading package lists...${NC}"
pkg update -y
echo -e "${Y}  Installing core runtime packages...${NC}"
pkg install -y termux-x11-nightly pulseaudio virglrenderer-android wget curl bash
echo -e "${G}✓ Termux bootstrap complete.${NC}"
sleep 1

banner
echo -e "${C}╔══════════════════════════════════════════════╗"
echo    "║              SELECT SETUP MODE               ║"
echo    "╠══════════════════════════════════════════════╣"
echo    "║                                              ║"
echo    "║  0) proot           (No root)               ║"
echo    "║  1) chroot-distro   (Root required)         ║"
echo    "║                                              ║"
echo -e "╚══════════════════════════════════════════════╝${NC}"
read -p "Select mode (0-1): " SETUP_TYPE

case $SETUP_TYPE in
    0|1) ;;
    *) echo -e "${R}Invalid choice. Exiting.${NC}"; exit 1 ;;
esac

if [ "$SETUP_TYPE" = "0" ]; then
    pkg install -y proot-distro
    banner
    echo -e "${C}╔══════════════════════════════════════════════╗"
    echo    "║          SELECT YOUR DISTRIBUTION            ║"
    echo    "╠══════════════════════════════════════════════╣"
    echo    "║   0)  Native Termux                         ║"
    echo    "║   1)  Debian                                ║"
    echo    "║   2)  Ubuntu 25.10                          ║"
    echo    "║   3)  Trisquel GNU                          ║"
    echo    "║   4)  Pardus                                ║"
    echo    "║   5)  Arch Linux                            ║"
    echo    "║   6)  Artix Linux                           ║"
    echo    "║   7)  Manjaro                               ║"
    echo    "║   8)  Fedora                                ║"
    echo    "║   9)  AlmaLinux                             ║"
    echo    "║   10) Oracle Linux                          ║"
    echo    "║   11) Rocky Linux                           ║"
    echo    "║   12) Alpine Linux                          ║"
    echo    "║   13) Void Linux                            ║"
    echo    "║   14) OpenSUSE                              ║"
    echo    "║   15) Chimera Linux                         ║"
    echo    "║   16) Adelie Linux                          ║"
    echo    "║   17) Deepin                                ║"
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

    if [ "$PKG_TYPE" != "pkg" ]; then
        echo -e "${Y}--- [2/5] Installing $DNAME via proot-distro ---${NC}"
        proot-distro install "$DISTRO"
        echo -e "${G}✓ $DNAME installed.${NC}"
    else
        echo -e "${G}✓ Native Termux — no proot needed.${NC}"
    fi

elif [ "$SETUP_TYPE" = "1" ]; then
    check_root
    echo -e "${Y}--- [2/5] Installing chroot-distro ---${NC}"
    pkg update -y
    pkg install coreutils sudo python mount-utils -y
    pip install chroot-distro

    banner
    echo -e "${C}╔══════════════════════════════════════════════╗"
    echo    "║     SELECT CHROOT-DISTRO DISTRIBUTION        ║"
    echo    "╠══════════════════════════════════════════════╣"
    echo    "║   1) debian                                 ║"
    echo    "║   2) ubuntu:25.10                           ║"
    echo    "║   3) alpine                                 ║"
    echo    "║   4) archlinux                              ║"
    echo    "║   5) fedora                                 ║"
    echo    "║   6) opensuse                               ║"
    echo    "║   7) void                                   ║"
    echo -e "╚══════════════════════════════════════════════╝${NC}"
    read -p "Select a distro (1-7): " cd_choice

    case $cd_choice in
        1) DISTRO="debian";       PKG_TYPE="apt";    DNAME="Debian"       ;;
        2) DISTRO="ubuntu:25.10"; PKG_TYPE="apt";    DNAME="Ubuntu"       ;;
        3) DISTRO="alpine";       PKG_TYPE="apk";    DNAME="Alpine Linux" ;;
        4) DISTRO="archlinux";    PKG_TYPE="pacman"; DNAME="Arch Linux"   ;;
        5) DISTRO="fedora";       PKG_TYPE="dnf";    DNAME="Fedora"       ;;
        6) DISTRO="opensuse";     PKG_TYPE="zypper"; DNAME="OpenSUSE"     ;;
        7) DISTRO="void";         PKG_TYPE="xbps";   DNAME="Void Linux"   ;;
        *) echo -e "${R}Invalid choice.${NC}"; exit 1 ;;
    esac

    DISTRO_LOGIN="${DISTRO%%:*}"

    echo -e "${Y}--- [3/5] Setting up $DNAME via chroot-distro ---${NC}"
    su -c "/data/data/com.termux/files/usr/bin/chroot-distro download $DISTRO"
    su -c "/data/data/com.termux/files/usr/bin/chroot-distro install $DISTRO"

    echo -e "${Y}  Verifying installation...${NC}"
    if [ -d "/data/data/com.termux/files/usr/var/lib/chroot-distro/containers/$DISTRO_LOGIN" ] || su -c "[ -d /var/lib/chroot-distro/containers/$DISTRO_LOGIN ]" 2>/dev/null; then
        echo -e "${G}✓ $DNAME directory verified.${NC}"
    else
        echo -e "${R}✗ Installation failed — Container directory not found.${NC}"
        exit 1
    fi
fi
sleep 1

banner
if [ "$PKG_TYPE" = "pkg" ]; then
    echo -e "${C}╔══════════════════════════════════════════════╗"
    echo    "║       SELECT DESKTOP ENVIRONMENT / WM        ║"
    echo    "╠══════════════════════════════════════════════╣"
    echo    "║   1) XFCE4                                  ║"
    echo    "║   2) LXQt                                   ║"
    echo    "║   3) Fluxbox                                ║"
    echo    "║   4) Openbox                                ║"
    echo -e "╚══════════════════════════════════════════════╝${NC}"
    read -p "Select a desktop (1-4): " de_raw
    case $de_raw in
        1) de_choice=1 ;; 2) de_choice=2 ;;
        3) de_choice=4 ;; 4) de_choice=5 ;;
        *) echo -e "${R}Invalid choice.${NC}"; exit 1 ;;
    esac
else
    echo -e "${C}╔══════════════════════════════════════════════╗"
    echo    "║       SELECT DESKTOP ENVIRONMENT / WM        ║"
    echo    "╠══════════════════════════════════════════════╣"
    echo    "║   1) XFCE4                                  ║"
    echo    "║   2) LXQt                                   ║"
    echo    "║   3) MATE                                   ║"
    echo    "║   4) Fluxbox                                ║"
    echo    "║   5) Openbox                                ║"
    echo -e "╚══════════════════════════════════════════════╝${NC}"
    read -p "Select a desktop (1-5): " de_choice
fi

case $PKG_TYPE in
    pkg)
        APPEAR_PKGS="arc-theme-gnome papirus-icon-theme noto-fonts-emoji ttf-dejavu qt5ct lxappearance"
        case $de_choice in
            1) DE_PKGS="xfce4 xfce4-goodies dbus" DE_START="dbus-launch --exit-with-session xfce4-session" DE_NAME="XFCE4" ;;
            2) DE_PKGS="lxqt" DE_START="startlxqt" DE_NAME="LXQt" ;;
            4) DE_PKGS="fluxbox" DE_START="fluxbox" DE_NAME="Fluxbox" ;;
            5) DE_PKGS="openbox openbox-menu tint2 xorg-xsetroot" DE_START="openbox-session" DE_NAME="Openbox" ;;
        esac
        INSTALL_CMD="pkg install -y $DE_PKGS"
        APPEAR_CMD="pkg install -y $APPEAR_PKGS"
        ;;
    apt)
        UPD="apt update -y && apt upgrade -y"
        EXTRA="dbus-x11 xauth fonts-noto librsvg2-common adwaita-icon-theme"
        APPEAR_PKGS="arc-theme papirus-icon-theme fonts-noto-color-emoji ttf-dejavu-extra qt5ct lxappearance"
        case $de_choice in
            1) DE_PKGS="xfce4 xfce4-goodies dbus-x11" DE_START="dbus-launch --exit-with-session xfce4-session" DE_NAME="XFCE4" ;;
            2) DE_PKGS="lxqt" DE_START="startlxqt" DE_NAME="LXQt" ;;
            3) DE_PKGS="mate-desktop-environment dbus-x11" DE_START="dbus-launch --exit-with-session mate-session" DE_NAME="MATE" ;;
            4) DE_PKGS="fluxbox" DE_START="fluxbox" DE_NAME="Fluxbox" ;;
            5) DE_PKGS="openbox openbox-menu tint2 x11-xserver-utils" DE_START="openbox-session" DE_NAME="Openbox" ;;
        esac
        INSTALL_CMD="$UPD && apt install -y $DE_PKGS $EXTRA && gdk-pixbuf-query-loaders --update-cache 2>/dev/null || true"
        APPEAR_CMD="apt install -y $APPEAR_PKGS && gdk-pixbuf-query-loaders --update-cache 2>/dev/null || true"
        ;;
    pacman)
        UPD="pacman -Syu --noconfirm"
        EXTRA="dbus xorg-xauth noto-fonts librsvg adwaita-icon-theme"
        APPEAR_PKGS="arc-gtk-theme papirus-icon-theme noto-fonts-emoji ttf-ubuntu-font-family qt5ct lxappearance"
        case $de_choice in
            1) DE_PKGS="xfce4 xfce4-goodies dbus" DE_START="dbus-launch --exit-with-session xfce4-session" DE_NAME="XFCE4" ;;
            2) DE_PKGS="lxqt" DE_START="startlxqt" DE_NAME="LXQt" ;;
            3) DE_PKGS="mate mate-extra dbus" DE_START="dbus-launch --exit-with-session mate-session" DE_NAME="MATE" ;;
            4) DE_PKGS="fluxbox" DE_START="fluxbox" DE_NAME="Fluxbox" ;;
            5) DE_PKGS="openbox tint2 xorg-xsetroot" DE_START="openbox-session" DE_NAME="Openbox" ;;
        esac
        INSTALL_CMD="$UPD && pacman -S --noconfirm $DE_PKGS $EXTRA && gdk-pixbuf-query-loaders --update-cache"
        APPEAR_CMD="pacman -S --noconfirm $APPEAR_PKGS && gdk-pixbuf-query-loaders --update-cache"
        ;;
    dnf)
        UPD="dnf update -y"
        EXTRA="dbus-x11 xauth google-noto-fonts-common librsvg2 adwaita-icon-theme"
        APPEAR_PKGS="arc-theme papirus-icon-theme google-noto-color-emoji-fonts google-noto-sans-fonts qt5ct lxappearance"
        case $de_choice in
            1) DE_PKGS="@xfce-desktop dbus-x11" DE_START="dbus-launch --exit-with-session xfce4-session" DE_NAME="XFCE4" ;;
            2) DE_PKGS="@lxqt-desktop" DE_START="startlxqt" DE_NAME="LXQt" ;;
            3) DE_PKGS="mate-session-manager marco mate-panel mate-desktop caja dbus-x11" DE_START="dbus-launch --exit-with-session mate-session" DE_NAME="MATE" ;;
            4) DE_PKGS="fluxbox" DE_START="fluxbox" DE_NAME="Fluxbox" ;;
            5) DE_PKGS="openbox xfce4-panel xorg-x11-server-utils" DE_START="openbox-session" DE_NAME="Openbox" ;;
        esac
        INSTALL_CMD="$UPD && dnf install -y $DE_PKGS $EXTRA && (gdk-pixbuf-query-loaders-64 --update-cache 2>/dev/null || gdk-pixbuf-query-loaders --update-cache 2>/dev/null || true)"
        APPEAR_CMD="dnf install -y $APPEAR_PKGS && (gdk-pixbuf-query-loaders-64 --update-cache 2>/dev/null || gdk-pixbuf-query-loaders --update-cache 2>/dev/null || true)"
        ;;
    apk)
        UPD="apk update && apk upgrade"
        EXTRA="dbus-x11 xauth font-noto librsvg adwaita-icon-theme"
        APPEAR_PKGS="papirus-icon-theme font-noto font-dejavu qt5ct"
        case $de_choice in
            1) DE_PKGS="xfce4 xfce4-extras dbus-x11" DE_START="dbus-launch --exit-with-session xfce4-session" DE_NAME="XFCE4" ;;
            2) DE_PKGS="lxqt lxqt-session" DE_START="startlxqt" DE_NAME="LXQt" ;;
            3) DE_PKGS="marco mate-panel mate-session-manager caja dbus-x11" DE_START="dbus-launch --exit-with-session mate-session" DE_NAME="MATE" ;;
            4) DE_PKGS="fluxbox" DE_START="fluxbox" DE_NAME="Fluxbox" ;;
            5) DE_PKGS="openbox tint2 xsetroot" DE_START="openbox" DE_NAME="Openbox" ;;
        esac
        INSTALL_CMD="$UPD && apk add $DE_PKGS $EXTRA && gdk-pixbuf-query-loaders --update-cache 2>/dev/null || true"
        APPEAR_CMD="$UPD && apk add $APPEAR_PKGS && (apk add lxappearance 2>/dev/null || (echo '@testing https://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories && apk update && apk add lxappearance@testing)) && gdk-pixbuf-query-loaders --update-cache 2>/dev/null || true"
        ;;
    xbps)
        UPD="xbps-install -Suy"
        EXTRA="dbus-x11 xauth noto-fonts-ttf librsvg adwaita-icon-theme"
        APPEAR_PKGS="arc-theme papirus-icon-theme noto-fonts-emoji font-ubuntu-ttf qt5ct lxappearance"
        case $de_choice in
            1) DE_PKGS="xfce4 xfce4-goodies dbus-x11" DE_START="dbus-launch --exit-with-session xfce4-session" DE_NAME="XFCE4" ;;
            2) DE_PKGS="lxqt" DE_START="startlxqt" DE_NAME="LXQt" ;;
            3) DE_PKGS="mate mate-extra dbus-x11" DE_START="dbus-launch --exit-with-session mate-session" DE_NAME="MATE" ;;
            4) DE_PKGS="fluxbox" DE_START="fluxbox" DE_NAME="Fluxbox" ;;
            5) DE_PKGS="openbox tint2 xsetroot" DE_START="openbox-session" DE_NAME="Openbox" ;;
        esac
        INSTALL_CMD="$UPD && xbps-install -y $DE_PKGS $EXTRA && gdk-pixbuf-query-loaders --update-cache 2>/dev/null || true"
        APPEAR_CMD="xbps-install -y $APPEAR_PKGS && gdk-pixbuf-query-loaders --update-cache 2>/dev/null || true"
        ;;
    zypper)
        UPD="zypper --non-interactive refresh && zypper --non-interactive update"
        EXTRA="dbus-1-x11 xauth google-noto-fonts librsvg2 adwaita-icon-theme"
        APPEAR_PKGS="metatheme-arc-common papirus-icon-theme google-noto-coloremoji-fonts google-noto-sans-fonts qt5ct lxappearance"
        case $de_choice in
            1) DE_PKGS="xfce4 xfce4-goodies dbus-1-x11" DE_START="dbus-launch --exit-with-session xfce4-session" DE_NAME="XFCE4" ;;
            2) DE_PKGS="lxqt" DE_START="startlxqt" DE_NAME="LXQt" ;;
            3) DE_PKGS="mate-session-manager marco mate-panel caja dbus-1-x11" DE_START="dbus-launch --exit-with-session mate-session" DE_NAME="MATE" ;;
            4) DE_PKGS="fluxbox" DE_START="fluxbox" DE_NAME="Fluxbox" ;;
            5) DE_PKGS="openbox lxpanel xsetroot" DE_START="openbox-session" DE_NAME="Openbox" ;;
        esac
        INSTALL_CMD="$UPD && zypper --non-interactive install $DE_PKGS $EXTRA && gdk-pixbuf-query-loaders --update-cache 2>/dev/null || true"
        APPEAR_CMD="zypper --non-interactive install $APPEAR_PKGS && gdk-pixbuf-query-loaders --update-cache 2>/dev/null || true"
        ;;
esac

echo -e "${G}✓ Selected: $DE_NAME${NC}"
echo -e "${Y}--- [4/5] Installing $DE_NAME in $DNAME ---${NC}"

if [ "$PKG_TYPE" = "pkg" ]; then
    bash -c "$INSTALL_CMD"
elif [ "$SETUP_TYPE" = "0" ]; then
    proot-distro login "$DISTRO" -- bash -c "$INSTALL_CMD"
else
    su -c "/data/data/com.termux/files/usr/bin/chroot-distro login $DISTRO_LOGIN -- /bin/sh -c '$INSTALL_CMD'"
fi
echo -e "${G}✓ $DE_NAME installed.${NC}"
sleep 1

banner
echo -e "${Y}Install recommended appearance packages? [Y/n]: ${NC}"
read appear_choice
appear_choice="${appear_choice:-Y}"

if [[ "$appear_choice" =~ ^[Yy]$ ]]; then
    echo -e "${Y}--- [5/5] Installing appearance packages ---${NC}"
    if [ "$PKG_TYPE" = "pkg" ]; then
        bash -c "$APPEAR_CMD"
    elif [ "$SETUP_TYPE" = "0" ]; then
        proot-distro login "$DISTRO" -- bash -c "$APPEAR_CMD"
    else
        su -c "/data/data/com.termux/files/usr/bin/chroot-distro login $DISTRO_LOGIN -- /bin/sh -c '$APPEAR_CMD'"
    fi
    APPEAR_INSTALLED=true
    echo -e "${G}✓ Appearance packages installed.${NC}"
else
    echo -e "${Y}⚠ Skipping appearance packages.${NC}"
    APPEAR_INSTALLED=false
fi
sleep 1

FLUXBOX_INIT=""
if [ "$DE_NAME" = "Fluxbox" ]; then
    FLUXBOX_INIT='mkdir -p ~/.fluxbox && fluxbox-generate_menu 2>/dev/null || true'
fi

OPENBOX_INIT=""
if [ "$DE_NAME" = "Openbox" ]; then
    OPENBOX_INIT='mkdir -p ~/.config/openbox
[ ! -f ~/.config/openbox/rc.xml ]    && cp /etc/xdg/openbox/rc.xml    ~/.config/openbox/ 2>/dev/null || true
[ ! -f ~/.config/openbox/menu.xml ]  && cp /etc/xdg/openbox/menu.xml  ~/.config/openbox/ 2>/dev/null || true
[ ! -f ~/.config/openbox/autostart ] && cp /etc/xdg/openbox/autostart ~/.config/openbox/ 2>/dev/null || true
grep -q "tint2" ~/.config/openbox/autostart 2>/dev/null || printf "\nxsetroot -solid \"#2d2d2d\" &\ntint2 &\n" >> ~/.config/openbox/autostart'
fi

echo -e "${Y}--- Creating ~/start.sh launcher ---${NC}"

if [ "$PKG_TYPE" = "pkg" ]; then

cat > ~/start.sh << STARTSCRIPT
#!/data/data/com.termux/files/usr/bin/bash
R='\033[0;31m'; G='\033[0;32m'; Y='\033[1;33m'; C='\033[0;36m'; NC='\033[0m'
echo -e "\${C}[ Native Termux + $DE_NAME ]\${NC}"
kill -9 \$(pgrep -f "termux.x11") 2>/dev/null
pkill -f pulseaudio 2>/dev/null
pkill -f virgl_test_server 2>/dev/null
sleep 1
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1
sleep 1
virgl_test_server_android &
VIRGL_PID=\$!
sleep 1
export XDG_RUNTIME_DIR=\${TMPDIR}
export PULSE_SERVER=127.0.0.1
export GALLIUM_DRIVER=virpipe
export MESA_GL_VERSION_OVERRIDE=4.0
$FLUXBOX_INIT
$OPENBOX_INIT
termux-x11 :0 -xstartup "$DE_START" &
sleep 3
am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity >/dev/null 2>&1
wait
kill \$VIRGL_PID 2>/dev/null
pkill -f pulseaudio 2>/dev/null
echo -e "\${G}Done.\${NC}"
STARTSCRIPT

elif [ "$SETUP_TYPE" = "0" ]; then

cat > ~/start.sh << STARTSCRIPT
#!/data/data/com.termux/files/usr/bin/bash
R='\033[0;31m'; G='\033[0;32m'; Y='\033[1;33m'; C='\033[0;36m'; NC='\033[0m'
echo -e "\${C}[ $DNAME proot + $DE_NAME ]\${NC}"
kill -9 \$(pgrep -f "termux.x11") 2>/dev/null
pkill -f pulseaudio 2>/dev/null
pkill -f virgl_test_server 2>/dev/null
sleep 1
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1
sleep 1
virgl_test_server_android &
VIRGL_PID=\$!
sleep 1
export XDG_RUNTIME_DIR=\${TMPDIR}
termux-x11 :0 >/dev/null &
sleep 3
am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity >/dev/null 2>&1
sleep 1
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
kill \$VIRGL_PID 2>/dev/null
pkill -f pulseaudio 2>/dev/null
echo -e "\${G}Done.\${NC}"
STARTSCRIPT

else

DE_INNER_CMD="export DISPLAY=:0; export PULSE_SERVER=127.0.0.1; export GALLIUM_DRIVER=virpipe; export MESA_GL_VERSION_OVERRIDE=4.0; export XDG_RUNTIME_DIR=/tmp/runtime-chroot; mkdir -p \$XDG_RUNTIME_DIR; chmod 700 \$XDG_RUNTIME_DIR"
[ -n "$FLUXBOX_INIT" ] && DE_INNER_CMD="$DE_INNER_CMD; $FLUXBOX_INIT"
[ -n "$OPENBOX_INIT" ] && DE_INNER_CMD="$DE_INNER_CMD; $OPENBOX_INIT"
DE_INNER_CMD="$DE_INNER_CMD; $DE_START"

cat > ~/start.sh << STARTSCRIPT
#!/data/data/com.termux/files/usr/bin/bash
R='\033[0;31m'; G='\033[0;32m'; Y='\033[1;33m'; C='\033[0;36m'; NC='\033[0m'
echo -e "\${C}[ $DNAME chroot-distro + $DE_NAME ]\${NC}"

kill -9 \$(pgrep -f "termux.x11") 2>/dev/null
pkill -f pulseaudio 2>/dev/null
pkill -f virgl_test_server 2>/dev/null
sleep 1

pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1
sleep 1
virgl_test_server_android &
VIRGL_PID=\$!
sleep 1

export XDG_RUNTIME_DIR=\${TMPDIR}
termux-x11 :0 >/dev/null &
sleep 3
am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity >/dev/null 2>&1
sleep 1

echo -e "\${G}Launching $DE_NAME in $DNAME (chroot-distro)...\${NC}"

# IL FIX DEFINITIVO: Forza il bind-mount fisico del socket X11 dentro il chroot
CHROOT_FS="/data/data/com.termux/files/usr/var/lib/chroot-distro/containers/$DISTRO_LOGIN"
su -c "mkdir -p \${CHROOT_FS}/tmp/.X11-unix && (grep -q \${CHROOT_FS}/tmp/.X11-unix /proc/mounts || mount --bind \${TMPDIR}/.X11-unix \${CHROOT_FS}/tmp/.X11-unix) && /data/data/com.termux/files/usr/bin/chroot-distro login $DISTRO_LOGIN -- /bin/sh -c '$DE_INNER_CMD'"

kill \$VIRGL_PID 2>/dev/null
pkill -f pulseaudio 2>/dev/null
echo -e "\${G}Done.\${NC}"
STARTSCRIPT

fi

chmod +x ~/start.sh

banner
echo -e "${G}✓ SETUP COMPLETE!${NC}"
echo "Run ./start.sh to launch."
