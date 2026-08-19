#!/data/data/com.termux/files/usr/bin/bash

# ==============================================================
#  TERMUX-X11 FULL SETUP SCRIPT v5.5
#  Fresh Termux install safe — no repos needed beforehand
#
#  ACTION 0 — Install a Linux desktop
#    Mode 0: proot / Native Termux (no root, all 18 distros)
#    Mode 1: chroot-distro [EXPERIMENTAL] (requires root, pip-installed)
#
#  ACTION 1 — Uninstall
#    Scans proot-distro containers, chroot-distro containers, and
#    Native Termux for installed desktop environments, lists what
#    it finds, and lets you remove just the DE or the whole system.
#
#  DE/WM: XFCE4, LXQt, MATE(*), KDE Plasma(*), GNOME(*), Fluxbox, Openbox
#  (*) MATE / KDE Plasma / GNOME not available on Native Termux
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
    echo "║   TERMUX-X11 LINUX DESKTOP SETUP v6.0       ║"
    echo "║  proot · Native · chroot-distro  —  TX11    ║"
    echo "╚══════════════════════════════════════════════╝"
    echo -e "${NC}"
}

check_root() {
    echo -e "${Y}Checking root access...${NC}"
    if ! su -c "id" 2>/dev/null | grep -q "uid=0"; then
        echo -e "${R}✗ Root access not available!${NC}"
        echo -e "${Y}  chroot-distro requires a rooted device.${NC}"
        echo -e "${Y}  Use proot / Native Termux instead.${NC}"
        exit 1
    fi
    echo -e "${G}✓ Root access confirmed.${NC}"
}

# Binary used to detect each DE, independent of package manager
de_binary() {
    case "$1" in
        xfce4)   echo "xfce4-session"  ;;
        lxqt)    echo "startlxqt"      ;;
        mate)    echo "mate-session"   ;;
        kde)     echo "startplasma-x11";;
        gnome)   echo "gnome-session"  ;;
        fluxbox) echo "fluxbox"        ;;
        openbox) echo "openbox"        ;;
    esac
}

de_label() {
    case "$1" in
        xfce4)   echo "XFCE4"   ;;
        lxqt)    echo "LXQt"    ;;
        mate)    echo "MATE"    ;;
        kde)     echo "KDE Plasma" ;;
        gnome)   echo "GNOME"   ;;
        fluxbox) echo "Fluxbox" ;;
        openbox) echo "Openbox" ;;
    esac
}

# Packages to remove per package manager + DE key
# (mirrors the install package lists so removal is consistent)
de_remove_pkgs() {
    local pkgtype="$1" dekey="$2"
    case "$pkgtype" in
        pkg)
            case "$dekey" in
                xfce4)   echo "xfce4 xfce4-goodies dbus" ;;
                lxqt)    echo "lxqt" ;;
                fluxbox) echo "fluxbox" ;;
                openbox) echo "openbox openbox-menu tint2 xorg-xsetroot" ;;
            esac ;;
        apt)
            case "$dekey" in
                xfce4)   echo "xfce4 xfce4-goodies" ;;
                lxqt)    echo "lxqt" ;;
                mate)    echo "mate-desktop-environment" ;;
                kde)     echo "kde-plasma-desktop dolphin konsole" ;;
                gnome)   echo "gnome-core gnome-terminal" ;;
                fluxbox) echo "fluxbox" ;;
                openbox) echo "openbox openbox-menu tint2" ;;
            esac ;;
        pacman)
            case "$dekey" in
                xfce4)   echo "xfce4 xfce4-goodies" ;;
                lxqt)    echo "lxqt" ;;
                mate)    echo "mate mate-extra" ;;
                kde)     echo "plasma-desktop konsole dolphin plasma-nm powerdevil kde-gtk-config" ;;
                gnome)   echo "gnome-shell gnome-control-center gnome-terminal nautilus" ;;
                fluxbox) echo "fluxbox" ;;
                openbox) echo "openbox tint2" ;;
            esac ;;
        dnf)
            case "$dekey" in
                xfce4)   echo "@xfce-desktop" ;;
                lxqt)    echo "@lxqt-desktop" ;;
                mate)    echo "mate-session-manager marco mate-panel mate-desktop caja" ;;
                kde)     echo "@kde-desktop-environment" ;;
                gnome)   echo "@gnome-desktop" ;;
                fluxbox) echo "fluxbox" ;;
                openbox) echo "openbox xfce4-panel" ;;
            esac ;;
        apk)
            case "$dekey" in
                xfce4)   echo "xfce4 xfce4-extras" ;;
                lxqt)    echo "lxqt lxqt-session" ;;
                mate)    echo "marco mate-panel mate-session-manager caja" ;;
                kde)     echo "plasma-desktop-meta kde-applications-base" ;;
                gnome)   echo "gnome gnome-apps-core" ;;
                fluxbox) echo "fluxbox" ;;
                openbox) echo "openbox tint2" ;;
            esac ;;
        xbps)
            case "$dekey" in
                xfce4)   echo "xfce4 xfce4-goodies" ;;
                lxqt)    echo "lxqt" ;;
                mate)    echo "mate mate-extra" ;;
                kde)     echo "kde5 kde5-baseapps" ;;
                gnome)   echo "gnome" ;;
                fluxbox) echo "fluxbox" ;;
                openbox) echo "openbox tint2" ;;
            esac ;;
        zypper)
            case "$dekey" in
                xfce4)   echo "xfce4 xfce4-goodies" ;;
                lxqt)    echo "lxqt" ;;
                mate)    echo "mate-session-manager marco mate-panel caja" ;;
                kde)     echo "pattern:kde_plasma" ;;
                gnome)   echo "pattern:gnome_basic pattern:gnome_x11" ;;
                fluxbox) echo "fluxbox" ;;
                openbox) echo "openbox lxpanel" ;;
            esac ;;
    esac
}

de_remove_cmd() {
    local pkgtype="$1" pkgs="$2"
    case "$pkgtype" in
        pkg)    echo "pkg uninstall -y $pkgs" ;;
        apt)    echo "apt purge -y $pkgs && apt autoremove -y" ;;
        pacman) echo "pacman -Rns --noconfirm $pkgs" ;;
        dnf)    echo "dnf remove -y $pkgs" ;;
        apk)    echo "apk del $pkgs" ;;
        xbps)   echo "xbps-remove -Ry $pkgs" ;;
        zypper) echo "zypper --non-interactive remove $pkgs" ;;
    esac
}

# ==============================================================
# MAIN MENU
# ==============================================================
banner
echo -e "${C}╔══════════════════════════════════════════════╗"
echo    "║               WHAT DO YOU WANT?              ║"
echo    "╠══════════════════════════════════════════════╣"
echo    "║                                              ║"
echo    "║   0) Install a Linux desktop                ║"
echo    "║   1) Uninstall a desktop or system           ║"
echo    "║                                              ║"
echo -e "╚══════════════════════════════════════════════╝${NC}"
while true; do
    read -p "Select an option (0-1): " ACTION
    case $ACTION in
        0|1) break ;;
        *) echo -e "${R}Invalid choice. Please try again.${NC}" ;;
    esac
done

# ================================================================
# ================================================================
#   ACTION 1 — UNINSTALL
# ================================================================
# ================================================================
if [ "$ACTION" = "1" ]; then

    banner
    echo -e "${Y}Scanning for installed environments...${NC}"
    echo ""

    FOUND_LABELS=()
    FOUND_SOURCE=()   # native | proot | chroot
    FOUND_DISTRO=()   # distro name (blank for native)
    FOUND_PKGTYPE=()  # package manager
    FOUND_DEKEY=()    # xfce4/lxqt/mate/fluxbox/openbox, or "" if base OS only

    # ---- Native Termux ----
    NATIVE_FOUND=0
    for dekey in xfce4 lxqt fluxbox openbox; do
        bin=$(de_binary "$dekey")
        if command -v "$bin" >/dev/null 2>&1; then
            FOUND_LABELS+=("Native Termux — $(de_label "$dekey")")
            FOUND_SOURCE+=("native")
            FOUND_DISTRO+=("")
            FOUND_PKGTYPE+=("pkg")
            FOUND_DEKEY+=("$dekey")
            NATIVE_FOUND=1
        fi
    done
    [ "$NATIVE_FOUND" = "0" ] && echo -e "${Y}  Native Termux: no desktop environment found.${NC}"

    # ---- proot-distro containers ----
    if command -v proot-distro >/dev/null 2>&1; then
        PLIST=$(proot-distro list 2>/dev/null | awk 'NR>2 {print $1}' | grep -v '^$')
        if [ -n "$PLIST" ]; then
            while IFS= read -r pd; do
                [ -z "$pd" ] && continue
                # Guess package manager from distro name
                case "$pd" in
                    debian|ubuntu|trisquel|pardus|deepin) ptype="apt" ;;
                    archlinux|artix|manjaro) ptype="pacman" ;;
                    fedora|almalinux|oracle|rockylinux) ptype="dnf" ;;
                    alpine|chimera|adelie) ptype="apk" ;;
                    void) ptype="xbps" ;;
                    opensuse) ptype="zypper" ;;
                    *) ptype="apt" ;;
                esac
                FOUND_ANY_DE=0
                for dekey in xfce4 lxqt mate kde gnome fluxbox openbox; do
                    bin=$(de_binary "$dekey")
                    if proot-distro login "$pd" -- /bin/sh -c "command -v $bin" >/dev/null 2>&1; then
                        FOUND_LABELS+=("proot: $pd — $(de_label "$dekey")")
                        FOUND_SOURCE+=("proot")
                        FOUND_DISTRO+=("$pd")
                        FOUND_PKGTYPE+=("$ptype")
                        FOUND_DEKEY+=("$dekey")
                        FOUND_ANY_DE=1
                    fi
                done
                if [ "$FOUND_ANY_DE" = "0" ]; then
                    FOUND_LABELS+=("proot: $pd — (base OS, no DE)")
                    FOUND_SOURCE+=("proot")
                    FOUND_DISTRO+=("$pd")
                    FOUND_PKGTYPE+=("$ptype")
                    FOUND_DEKEY+=("")
                fi
            done <<< "$PLIST"
        else
            echo -e "${Y}  proot-distro: no containers installed.${NC}"
        fi
    else
        echo -e "${Y}  proot-distro: not installed.${NC}"
    fi

    # ---- chroot-distro containers (experimental) ----
    # NOTE: "chroot-distro list" produces decorative/colored table
    # output not meant for scripting, which silently broke detection
    # here before. Read the containers directory directly instead —
    # this is the same DATA LOCATION the tool documents itself
    # (/data/data/com.termux/files/usr/var/lib/chroot-distro).
    CHROOT_DISTRO_CONTAINERS_DIR="/data/data/com.termux/files/usr/var/lib/chroot-distro/containers"
    if command -v chroot-distro >/dev/null 2>&1 && su -c "id" 2>/dev/null | grep -q "uid=0"; then
        unset LD_PRELOAD
        CLIST=$(sudo sh -c "ls -1 '$CHROOT_DISTRO_CONTAINERS_DIR' 2>/dev/null")
        if [ -n "$CLIST" ]; then
            while IFS= read -r cd_name; do
                [ -z "$cd_name" ] && continue
                case "$cd_name" in
                    debian|ubuntu*|pardus|deepin) ptype="apt" ;;
                    archlinux) ptype="pacman" ;;
                    fedora) ptype="dnf" ;;
                    alpine) ptype="apk" ;;
                    void) ptype="xbps" ;;
                    opensuse) ptype="zypper" ;;
                    *) ptype="apt" ;;
                esac
                FOUND_ANY_DE=0
                for dekey in xfce4 lxqt mate kde gnome fluxbox openbox; do
                    bin=$(de_binary "$dekey")
                    if sudo chroot-distro login "$cd_name" -- /bin/sh -c "command -v $bin" >/dev/null 2>&1; then
                        FOUND_LABELS+=("chroot-distro: $cd_name — $(de_label "$dekey")")
                        FOUND_SOURCE+=("chroot")
                        FOUND_DISTRO+=("$cd_name")
                        FOUND_PKGTYPE+=("$ptype")
                        FOUND_DEKEY+=("$dekey")
                        FOUND_ANY_DE=1
                    fi
                done
                if [ "$FOUND_ANY_DE" = "0" ]; then
                    FOUND_LABELS+=("chroot-distro: $cd_name — (base OS, no DE)")
                    FOUND_SOURCE+=("chroot")
                    FOUND_DISTRO+=("$cd_name")
                    FOUND_PKGTYPE+=("$ptype")
                    FOUND_DEKEY+=("")
                fi
            done <<< "$CLIST"
        else
            echo -e "${Y}  chroot-distro: no containers installed.${NC}"
        fi
    else
        echo -e "${Y}  chroot-distro: not installed or root unavailable.${NC}"
    fi

    echo ""

    if [ "${#FOUND_LABELS[@]}" = "0" ]; then
        echo -e "${R}Nothing found to uninstall.${NC}"
        exit 0
    fi

    banner
    echo -e "${C}╔══════════════════════════════════════════════╗"
    echo    "║        SELECT WHAT TO UNINSTALL              ║"
    echo    "╠══════════════════════════════════════════════╣"
    for i in "${!FOUND_LABELS[@]}"; do
        printf "  %2d) %s\n" "$((i+1))" "${FOUND_LABELS[$i]}"
    done
    echo -e "╚══════════════════════════════════════════════╝${NC}"
    while true; do
        read -p "Select an entry (1-${#FOUND_LABELS[@]}): " sel
        if [[ "$sel" =~ ^[0-9]+$ ]]; then
            idx=$((sel-1))
            [ -n "${FOUND_LABELS[$idx]:-}" ] && break
        fi
        echo -e "${R}Invalid choice. Please try again.${NC}"
    done

    SRC="${FOUND_SOURCE[$idx]}"
    DIST="${FOUND_DISTRO[$idx]}"
    PTYPE="${FOUND_PKGTYPE[$idx]}"
    DEKEY="${FOUND_DEKEY[$idx]}"

    echo ""
    echo -e "${Y}Selected: ${FOUND_LABELS[$idx]}${NC}"
    echo -e "${C}╔══════════════════════════════════════════════╗"
    echo    "║              CHOOSE AN ACTION                ║"
    echo    "╠══════════════════════════════════════════════╣"
    if [ -n "$DEKEY" ]; then
    echo    "║   1) Remove ONLY the desktop environment     ║"
    fi
    if [ "$SRC" != "native" ]; then
    echo    "║   2) Remove the ENTIRE system/container      ║"
    fi
    echo    "║   3) Cancel                                  ║"
    echo -e "╚══════════════════════════════════════════════╝${NC}"
    while true; do
        read -p "Select an action: " uact
        case "$uact" in
            1) [ -n "$DEKEY" ] && break ;;
            2) [ "$SRC" != "native" ] && break ;;
            3) break ;;
        esac
        echo -e "${R}Invalid choice. Please try again.${NC}"
    done

    case "$uact" in
        1)
            if [ -z "$DEKEY" ]; then
                echo -e "${R}No desktop environment detected here to remove.${NC}"
                exit 1
            fi
            PKGS=$(de_remove_pkgs "$PTYPE" "$DEKEY")
            RCMD=$(de_remove_cmd "$PTYPE" "$PKGS")
            echo -e "${Y}Removing $(de_label "$DEKEY")...${NC}"
            case "$SRC" in
                native) bash -c "$RCMD" ;;
                proot)  proot-distro login "$DIST" -- bash -c "$RCMD" ;;
                chroot) unset LD_PRELOAD; sudo chroot-distro login "$DIST" -- /bin/sh -c "$RCMD" ;;
            esac
            echo -e "${G}✓ $(de_label "$DEKEY") removed.${NC}"
            ;;
        2)
            if [ "$SRC" = "native" ]; then
                echo -e "${R}Cannot remove the entire Native Termux system.${NC}"
                exit 1
            fi
            read -p "Type YES to confirm full removal of '$DIST': " confirm
            if [ "$confirm" != "YES" ]; then
                echo -e "${Y}Cancelled.${NC}"
                exit 0
            fi
            case "$SRC" in
                proot)  proot-distro remove "$DIST" ;;
                chroot) sudo chroot-distro remove "$DIST" ;;
            esac
            echo -e "${G}✓ $DIST removed entirely.${NC}"
            ;;
        *)
            echo -e "${Y}Cancelled.${NC}"
            ;;
    esac

    exit 0
fi

# ================================================================
# ================================================================
#   ACTION 0 — INSTALL
# ================================================================
# ================================================================

# ==============================================================
# STEP 1 — Bootstrap Termux (fresh install safe)
# Correct sequence confirmed by termux-x11 official README:
#   1. pkg update + upgrade
#   2. pkg install x11-repo        ← ONLY repo pkg needed
#                                    "termux-x11-repo" does NOT exist
#   3. pkg update                  ← re-read lists after adding repo
#   4. pkg install packages
#      NOTE: x11-utils, x11-fonts, xorg-xrdb do NOT exist in Termux
# ==============================================================
banner
echo -e "${Y}--- [1/6] Bootstrapping Termux ---${NC}"
export DEBIAN_FRONTEND=noninteractive

echo -e "${Y}  Updating base Termux packages...${NC}"
pkg update -y && pkg upgrade -y

echo -e "${Y}  Adding x11-repo (provides termux-x11-nightly)...${NC}"
pkg install -y x11-repo

echo -e "${Y}  Re-reading package lists with x11-repo enabled...${NC}"
pkg update -y

echo -e "${Y}  Installing core runtime packages...${NC}"
pkg install -y termux-x11-nightly pulseaudio virglrenderer-android wget curl bash

echo -e "${G}✓ Termux bootstrap complete.${NC}"
sleep 1

# ==============================================================
# STEP 2 — Setup mode selection
# ==============================================================
banner
echo -e "${C}╔══════════════════════════════════════════════╗"
echo    "║              SELECT SETUP MODE               ║"
echo    "╠══════════════════════════════════════════════╣"
echo    "║                                              ║"
echo    "║  0) proot / Native Termux                   ║"
echo    "║     No root required.                       ║"
echo    "║     Runs Linux via proot-distro, or skip    ║"
echo    "║     it entirely with Native Termux.         ║"
echo    "║     Recommended — stable and well tested.   ║"
echo    "║                                              ║"
echo    "║  1) chroot-distro   [EXPERIMENTAL]          ║"
echo    "║     ⚠ Requires ROOT.                        ║"
echo    "║     ⚠ NOT guaranteed to work on your        ║"
echo    "║       device/kernel/root manager.           ║"
echo    "║     Installed via pip. Uses sudo.           ║"
echo    "║     Try proot first if unsure.              ║"
echo    "║                                              ║"
echo -e "╚══════════════════════════════════════════════╝${NC}"
while true; do
    read -p "Select mode (0-1): " SETUP_TYPE
    case $SETUP_TYPE in
        0|1) break ;;
        *) echo -e "${R}Invalid choice. Please try again.${NC}" ;;
    esac
done

# ==============================================================
# STEP 2b — Distro selection
# ==============================================================

# ---- PROOT / NATIVE ----
if [ "$SETUP_TYPE" = "0" ]; then

    pkg install -y proot-distro

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
    while true; do
        read -p "Select a distro (0-17): " distro_choice
        case $distro_choice in
            0)  DISTRO="native";      PKG_TYPE="pkg";    DNAME="Native Termux"  ; break ;;
            1)  DISTRO="debian";      PKG_TYPE="apt";    DNAME="Debian"         ; break ;;
            2)  DISTRO="ubuntu";      PKG_TYPE="apt";    DNAME="Ubuntu"         ; break ;;
            3)  DISTRO="trisquel";    PKG_TYPE="apt";    DNAME="Trisquel"       ; break ;;
            4)  DISTRO="pardus";      PKG_TYPE="apt";    DNAME="Pardus"         ; break ;;
            5)  DISTRO="archlinux";   PKG_TYPE="pacman"; DNAME="Arch Linux"     ; break ;;
            6)  DISTRO="artix";       PKG_TYPE="pacman"; DNAME="Artix Linux"    ; break ;;
            7)  DISTRO="manjaro";     PKG_TYPE="pacman"; DNAME="Manjaro"        ; break ;;
            8)  DISTRO="fedora";      PKG_TYPE="dnf";    DNAME="Fedora"         ; break ;;
            9)  DISTRO="almalinux";   PKG_TYPE="dnf";    DNAME="AlmaLinux"      ; break ;;
            10) DISTRO="oracle";      PKG_TYPE="dnf";    DNAME="Oracle Linux"   ; break ;;
            11) DISTRO="rockylinux";  PKG_TYPE="dnf";    DNAME="Rocky Linux"    ; break ;;
            12) DISTRO="alpine";      PKG_TYPE="apk";    DNAME="Alpine Linux"   ; break ;;
            13) DISTRO="void";        PKG_TYPE="xbps";   DNAME="Void Linux"     ; break ;;
            14) DISTRO="opensuse";    PKG_TYPE="zypper"; DNAME="OpenSUSE"       ; break ;;
            15) DISTRO="chimera";     PKG_TYPE="apk";    DNAME="Chimera Linux"  ; break ;;
            16) DISTRO="adelie";      PKG_TYPE="apk";    DNAME="Adelie Linux"   ; break ;;
            17) DISTRO="deepin";      PKG_TYPE="apt";    DNAME="Deepin"         ; break ;;
            *)  echo -e "${R}Invalid choice. Please try again.${NC}" ;;
        esac
    done

    if [ "$PKG_TYPE" != "pkg" ]; then
        echo -e "${Y}--- [2/6] Installing $DNAME via proot-distro ---${NC}"
        proot-distro install "$DISTRO"
        echo -e "${G}✓ $DNAME installed.${NC}"
    else
        echo -e "${G}✓ Native Termux — no proot needed.${NC}"
    fi

# ---- CHROOT-DISTRO (EXPERIMENTAL) ----
elif [ "$SETUP_TYPE" = "1" ]; then

    check_root

    banner
    echo -e "${R}╔══════════════════════════════════════════════╗"
    echo    "║              ⚠  EXPERIMENTAL  ⚠              ║"
    echo    "╠══════════════════════════════════════════════╣"
    echo    "║  chroot-distro is NOT guaranteed to work on ║"
    echo    "║  your specific device, kernel, or root      ║"
    echo    "║  manager (Magisk/KernelSU/APatch/other).    ║"
    echo    "║  If it fails, restart the script and pick   ║"
    echo    "║  proot / Native Termux instead.             ║"
    echo -e "╚══════════════════════════════════════════════╝${NC}"
    sleep 2

    echo -e "${Y}--- [2/6] Installing chroot-distro ---${NC}"

    echo -e "${Y}  Installing required packages (python, sudo, coreutils, mount-utils)...${NC}"
    pkg update -y
    pkg install coreutils sudo python mount-utils -y

    echo -e "${Y}  Installing chroot-distro via pip...${NC}"
    pip install --upgrade pip
    pip install chroot-distro

    banner
    echo -e "${C}╔══════════════════════════════════════════════╗"
    echo    "║     SELECT CHROOT-DISTRO DISTRIBUTION        ║"
    echo    "║        (same distro family as proot)         ║"
    echo    "╠══════════════════════════════════════════════╣"
    echo    "║                                              ║"
    echo    "║   --- Debian/Ubuntu based ---                ║"
    echo    "║   1)  Debian                                ║"
    echo    "║   2)  Ubuntu 25.10                          ║"
    echo    "║                                              ║"
    echo    "║   --- Arch based ---                        ║"
    echo    "║   3)  Arch Linux                            ║"
    echo    "║                                              ║"
    echo    "║   --- RPM based ---                         ║"
    echo    "║   4)  Fedora                                ║"
    echo    "║                                              ║"
    echo    "║   --- Independent ---                       ║"
    echo    "║   5)  Alpine Linux                          ║"
    echo    "║   6)  OpenSUSE                              ║"
    echo    "║   7)  Void Linux                            ║"
    echo    "║                                              ║"
    echo -e "╚══════════════════════════════════════════════╝${NC}"
    while true; do
        read -p "Select a distro (1-7): " cd_choice
        case $cd_choice in
            1) DISTRO="debian";       PKG_TYPE="apt";    DNAME="Debian"       ; break ;;
            2) DISTRO="ubuntu:25.10"; PKG_TYPE="apt";    DNAME="Ubuntu"       ; break ;;
            3) DISTRO="archlinux";    PKG_TYPE="pacman"; DNAME="Arch Linux"   ; break ;;
            4) DISTRO="fedora";       PKG_TYPE="dnf";    DNAME="Fedora"       ; break ;;
            5) DISTRO="alpine";       PKG_TYPE="apk";    DNAME="Alpine Linux" ; break ;;
            6) DISTRO="opensuse";     PKG_TYPE="zypper"; DNAME="OpenSUSE"     ; break ;;
            7) DISTRO="void";         PKG_TYPE="xbps";   DNAME="Void Linux"   ; break ;;
            *) echo -e "${R}Invalid choice. Please try again.${NC}" ;;
        esac
    done

    # Login name used by chroot-distro (strips the :tag part, e.g. ubuntu:25.10 -> ubuntu)
    DISTRO_LOGIN="${DISTRO%%:*}"

    echo -e "${Y}--- [3/6] Setting up $DNAME via chroot-distro ---${NC}"

    echo -e "${Y}  Downloading rootfs for $DISTRO...${NC}"
    sudo chroot-distro download "$DISTRO"

    echo -e "${Y}  Installing $DISTRO...${NC}"
    sudo chroot-distro install "$DISTRO"

    # Brute-force but reliable check: if the container directory
    # physically exists, the install succeeded — chroot-distro's
    # own "list" command has proven unreliable right after install
    # on some devices/root managers.
    echo -e "${Y}  Verifying installation...${NC}"
    if [ -d "/data/data/com.termux/files/usr/var/lib/chroot-distro/containers/$DISTRO_LOGIN" ] \
       || sudo sh -c "[ -d /var/lib/chroot-distro/containers/$DISTRO_LOGIN ]" 2>/dev/null; then
        echo -e "${G}✓ $DNAME directory verified.${NC}"
    else
        echo -e "${R}✗ Installation failed — container directory not found.${NC}"
        echo -e "${Y}  chroot-distro may not be compatible with this device.${NC}"
        echo -e "${Y}  Try again with proot / Native Termux instead.${NC}"
        exit 1
    fi

    echo -e "${G}✓ $DNAME installed via chroot-distro.${NC}"

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
    echo    "║   ⚠ KDE/GNOME unavailable on Native Termux  ║"
    echo    "║                                              ║"
    echo -e "╚══════════════════════════════════════════════╝${NC}"
    while true; do
        read -p "Select a desktop (1-4): " de_raw
        case $de_raw in
            1) de_choice=1; break ;;
            2) de_choice=2; break ;;
            3) de_choice=4; break ;;
            4) de_choice=5; break ;;
            *) echo -e "${R}Invalid choice. Please try again.${NC}" ;;
        esac
    done
else
    echo -e "${C}╔══════════════════════════════════════════════╗"
    echo    "║       SELECT DESKTOP ENVIRONMENT / WM        ║"
    echo    "╠══════════════════════════════════════════════╣"
    echo    "║                                              ║"
    echo    "║   --- Full Desktop Environments ---          ║"
    echo    "║   1) XFCE4    (Balanced - Recommended)      ║"
    echo    "║   2) LXQt     (Very lightweight, fast)      ║"
    echo    "║   3) MATE     (Classic GNOME 2 style)       ║"
    echo    "║   6) KDE Plasma (Heavier, feature-rich)     ║"
    echo    "║   7) GNOME    (Heaviest, needs more RAM)    ║"
    echo    "║                                              ║"
    echo    "║   --- Lightweight Window Managers ---        ║"
    echo    "║   4) Fluxbox  (Minimal, fastest, stable)    ║"
    echo    "║   5) Openbox  (Minimal, configurable)       ║"
    echo    "║                                              ║"
    echo -e "╚══════════════════════════════════════════════╝${NC}"
    while true; do
        read -p "Select a desktop (1-7): " de_choice
        case $de_choice in
            1|2|3|4|5|6|7) break ;;
            *) echo -e "${R}Invalid choice. Please try again.${NC}" ;;
        esac
    done
fi

# ==============================================================
# Package definitions per package manager + DE
# KEY FIXES:
#  - librsvg* everywhere (SVG icon crash / Wnck signal 6)
#  - adwaita-icon-theme (libwnck fallback icon)
#  - gdk-pixbuf-query-loaders --update-cache after every install
#  - pypanel → tint2 (pypanel abandoned / AUR-only on Arch)
#  - openbox: copy /etc/xdg/openbox/ configs before launching
# ==============================================================
case $PKG_TYPE in

    pkg) # Native Termux
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

    apt) # Debian, Ubuntu, Pardus, Trisquel, Deepin (proot + chroot-distro)
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
            6) DE_PKGS="kde-plasma-desktop dolphin konsole dbus-x11"
               DE_START="dbus-launch --exit-with-session startplasma-x11"
               DE_NAME="KDE Plasma" ;;
            7) DE_PKGS="gnome-core gnome-terminal dbus-x11"
               DE_START="dbus-launch --exit-with-session gnome-session"
               DE_NAME="GNOME" ;;
            *) echo -e "${R}Invalid choice.${NC}"; exit 1 ;;
        esac
        INSTALL_CMD="$UPD && apt install -y $DE_PKGS $EXTRA && gdk-pixbuf-query-loaders --update-cache 2>/dev/null || true"
        APPEAR_CMD="apt install -y $APPEAR_PKGS && gdk-pixbuf-query-loaders --update-cache 2>/dev/null || true"
        ;;

    pacman) # Arch, Artix, Manjaro (proot + chroot-distro)
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
            6) DE_PKGS="plasma-desktop konsole dolphin plasma-nm powerdevil kde-gtk-config dbus"
               DE_START="dbus-launch --exit-with-session startplasma-x11"
               DE_NAME="KDE Plasma" ;;
            7) DE_PKGS="gnome-shell gnome-control-center gnome-terminal nautilus dbus"
               DE_START="dbus-launch --exit-with-session gnome-session"
               DE_NAME="GNOME" ;;
            *) echo -e "${R}Invalid choice.${NC}"; exit 1 ;;
        esac
        INSTALL_CMD="$UPD && pacman -S --noconfirm $DE_PKGS $EXTRA && gdk-pixbuf-query-loaders --update-cache"
        APPEAR_CMD="pacman -S --noconfirm $APPEAR_PKGS && gdk-pixbuf-query-loaders --update-cache"
        ;;

    dnf) # Fedora, AlmaLinux, Oracle, Rocky (proot + chroot-distro)
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
            6) DE_PKGS="@kde-desktop-environment dbus-x11"
               DE_START="dbus-launch --exit-with-session startplasma-x11"
               DE_NAME="KDE Plasma" ;;
            7) DE_PKGS="@gnome-desktop dbus-x11"
               DE_START="dbus-launch --exit-with-session gnome-session"
               DE_NAME="GNOME" ;;
            *) echo -e "${R}Invalid choice.${NC}"; exit 1 ;;
        esac
        INSTALL_CMD="$UPD && dnf install -y $DE_PKGS $EXTRA && (gdk-pixbuf-query-loaders-64 --update-cache 2>/dev/null || gdk-pixbuf-query-loaders --update-cache 2>/dev/null || true)"
        APPEAR_CMD="dnf install -y $APPEAR_PKGS && (gdk-pixbuf-query-loaders-64 --update-cache 2>/dev/null || gdk-pixbuf-query-loaders --update-cache 2>/dev/null || true)"
        ;;

    apk) # Alpine, Chimera, Adelie (proot + chroot-distro)
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
            6) DE_PKGS="plasma-desktop-meta kde-applications-base dbus-x11"
               DE_START="dbus-launch --exit-with-session startplasma-x11"
               DE_NAME="KDE Plasma" ;;
            7) DE_PKGS="gnome gnome-apps-core dbus-x11"
               DE_START="dbus-launch --exit-with-session gnome-session"
               DE_NAME="GNOME" ;;
            *) echo -e "${R}Invalid choice.${NC}"; exit 1 ;;
        esac
        INSTALL_CMD="$UPD && apk add $DE_PKGS $EXTRA && gdk-pixbuf-query-loaders --update-cache 2>/dev/null || true"
        APPEAR_CMD="$UPD && apk add $APPEAR_PKGS && (apk add lxappearance 2>/dev/null || (echo '@testing https://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories && apk update && apk add lxappearance@testing)) && gdk-pixbuf-query-loaders --update-cache 2>/dev/null || true"
        ;;

    xbps) # Void Linux (proot + chroot-distro)
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
            6) DE_PKGS="kde5 kde5-baseapps dbus-x11"
               DE_START="dbus-launch --exit-with-session startplasma-x11"
               DE_NAME="KDE Plasma" ;;
            7) DE_PKGS="gnome dbus-x11"
               DE_START="dbus-launch --exit-with-session gnome-session"
               DE_NAME="GNOME" ;;
            *) echo -e "${R}Invalid choice.${NC}"; exit 1 ;;
        esac
        INSTALL_CMD="$UPD && xbps-install -y $DE_PKGS $EXTRA && gdk-pixbuf-query-loaders --update-cache 2>/dev/null || true"
        APPEAR_CMD="xbps-install -y $APPEAR_PKGS && gdk-pixbuf-query-loaders --update-cache 2>/dev/null || true"
        ;;

    zypper) # OpenSUSE (proot + chroot-distro)
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
            6) DE_PKGS="pattern:kde_plasma dbus-1-x11"
               DE_START="dbus-launch --exit-with-session startplasma-x11"
               DE_NAME="KDE Plasma" ;;
            7) DE_PKGS="pattern:gnome_basic pattern:gnome_x11 dbus-1-x11"
               DE_START="dbus-launch --exit-with-session gnome-session"
               DE_NAME="GNOME" ;;
            *) echo -e "${R}Invalid choice.${NC}"; exit 1 ;;
        esac
        INSTALL_CMD="$UPD && zypper --non-interactive install $DE_PKGS $EXTRA && gdk-pixbuf-query-loaders --update-cache 2>/dev/null || true"
        APPEAR_CMD="zypper --non-interactive install $APPEAR_PKGS && gdk-pixbuf-query-loaders --update-cache 2>/dev/null || true"
        ;;
esac

# ==============================================================
# STEP 4 — Install DE
# For chroot-distro, package-manager commands (apt/dnf/etc) run
# INSIDE the container, which is already root — no sudo needed
# there. Only the outer `chroot-distro login` call needs sudo.
# ==============================================================
echo -e "${G}✓ Selected: $DE_NAME${NC}"
echo -e "${Y}--- [4/6] Installing $DE_NAME in $DNAME ---${NC}"
echo -e "${Y}    (This may take several minutes...)${NC}"

if [ "$PKG_TYPE" = "pkg" ]; then
    bash -c "$INSTALL_CMD"
elif [ "$SETUP_TYPE" = "0" ]; then
    proot-distro login "$DISTRO" -- bash -c "$INSTALL_CMD"
else
    unset LD_PRELOAD
    sudo chroot-distro login "$DISTRO_LOGIN" -- /bin/sh -c "$INSTALL_CMD"
fi

echo -e "${G}✓ $DE_NAME installed.${NC}"
sleep 1

# ==============================================================
# STEP 5 — Appearance packages (optional)
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
read -p "$(echo -e "${Y}")Install recommended appearance packages? [Y/n]: $(echo -e "${NC}")" appear_choice
appear_choice="${appear_choice:-Y}"

if [[ "$appear_choice" =~ ^[Yy]$ ]]; then
    echo -e "${Y}--- [5/6] Installing appearance packages ---${NC}"
    if [ "$PKG_TYPE" = "pkg" ]; then
        bash -c "$APPEAR_CMD"
    elif [ "$SETUP_TYPE" = "0" ]; then
        proot-distro login "$DISTRO" -- bash -c "$APPEAR_CMD"
    else
        unset LD_PRELOAD
        sudo chroot-distro login "$DISTRO_LOGIN" -- /bin/sh -c "$APPEAR_CMD"
    fi
    APPEAR_INSTALLED=true
    echo -e "${G}✓ Appearance packages installed.${NC}"
else
    echo -e "${Y}⚠ Skipping appearance packages.${NC}"
    APPEAR_INSTALLED=false
fi
sleep 1

# ==============================================================
# Fluxbox / Openbox init (embedded in start.sh)
# Openbox: copy default configs BEFORE launching.
# Without rc.xml/menu.xml, openbox-session crashes immediately.
# tint2 replaces pypanel everywhere (pypanel abandoned).
# ==============================================================
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

# ==============================================================
# STEP 6 — Generate ~/start.sh
# ==============================================================
echo -e "${Y}--- [6/6] Creating ~/start.sh launcher ---${NC}"

# ---- Native Termux launcher ----
if [ "$PKG_TYPE" = "pkg" ]; then

cat > ~/start.sh << STARTSCRIPT
#!/data/data/com.termux/files/usr/bin/bash
# Native Termux + $DE_NAME — Termux-X11
R='\033[0;31m'; G='\033[0;32m'; Y='\033[1;33m'; C='\033[0;36m'; NC='\033[0m'

echo -e "\${C}[ Native Termux + $DE_NAME ]\${NC}"

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
elif [ "$SETUP_TYPE" = "0" ]; then

cat > ~/start.sh << STARTSCRIPT
#!/data/data/com.termux/files/usr/bin/bash
# $DNAME proot + $DE_NAME — Termux-X11
R='\033[0;31m'; G='\033[0;32m'; Y='\033[1;33m'; C='\033[0;36m'; NC='\033[0m'

echo -e "\${C}[ $DNAME + $DE_NAME ]\${NC}"

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

# ---- chroot-distro launcher (EXPERIMENTAL) ----
else

cat > ~/start.sh << STARTSCRIPT
#!/data/data/com.termux/files/usr/bin/bash
# $DNAME chroot-distro (EXPERIMENTAL) + $DE_NAME — Termux-X11
R='\033[0;31m'; G='\033[0;32m'; Y='\033[1;33m'; C='\033[0;36m'; NC='\033[0m'

echo -e "\${C}[ $DNAME chroot-distro + $DE_NAME ]\${NC}"

echo -e "\${Y}Stopping old sessions...\${NC}"
pkill -f termux-x11 2>/dev/null
pkill -f pulseaudio 2>/dev/null
pkill -f virgl_test_server 2>/dev/null
rm -rf \$TMPDIR/.X11-unix
sleep 1

echo -e "\${Y}Starting PulseAudio...\${NC}"
pulseaudio --start \
  --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" \
  --exit-idle-time=-1
sleep 1

echo -e "\${Y}Starting VirGL acceleration...\${NC}"
virgl_test_server_android &
sleep 1

echo -e "\${Y}Starting Termux-X11...\${NC}"
termux-x11 :0 -ac &
sleep 3
am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity >/dev/null 2>&1
sleep 1

echo -e "\${G}Entering $DNAME chroot and launching $DE_NAME...\${NC}"
chroot-distro login $DISTRO_LOGIN --bind \$TMPDIR:/tmp -- bash -c 'export DISPLAY=:0 XDG_RUNTIME_DIR=/tmp/runtime-root PULSE_SERVER=127.0.0.1 GALLIUM_DRIVER=virpipe; mkdir -p \$XDG_RUNTIME_DIR; chmod 700 \$XDG_RUNTIME_DIR; ${DE_START}'
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
if [ "$SETUP_TYPE" = "0" ]; then
echo "║  Mode    : proot / Native"
else
echo "║  Mode    : chroot-distro (experimental)"
fi
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
echo "║  To uninstall later, run this script again  ║"
echo "║  and choose option 1 (Uninstall).           ║"
echo "║                                              ║"
echo "╚══════════════════════════════════════════════╝"
echo -e "${NC}"
