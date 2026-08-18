#!/data/data/com.termux/files/usr/bin/bash

# ==============================================================
#  TERMUX-X11 FULL SETUP SCRIPT v7.0
#  Fresh Termux install safe — no repos needed beforehand
#
#  ACTION 0 — Install a Linux desktop
#    Mode 0: proot / Native Termux (no root, all 18 distros)
#    Mode 1: chroot-distro [EXPERIMENTAL] (requires root, pip-installed)
#    After choosing a full desktop environment (XFCE4, LXQt, MATE,
#    KDE Plasma, GNOME) you are asked Minimal or Full before anything
#    is installed. Fluxbox and Openbox are window managers and skip
#    this step (already minimal by nature).
#
#  ACTION 1 — Uninstall
#    Scans proot-distro containers, chroot-distro containers, and
#    Native Termux for installed desktop environments, lists what
#    it finds, and lets you remove just the DE or the whole system.
#
#  DE/WM: XFCE4, LXQt, MATE(*), KDE Plasma(*), GNOME(*), Fluxbox, Openbox
#  (*) Not available on Native Termux (no such packages exist there)
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
    echo "║   TERMUX-X11 LINUX DESKTOP SETUP v7.0        ║"
    echo "║  proot · Native · chroot-distro  —  TX11     ║"
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
        xfce4)   echo "xfce4-session"   ;;
        lxqt)    echo "startlxqt"       ;;
        mate)    echo "mate-session"    ;;
        kde)     echo "startplasma-x11" ;;
        gnome)   echo "gnome-shell"     ;;
        fluxbox) echo "fluxbox"         ;;
        openbox) echo "openbox"         ;;
    esac
}

de_label() {
    case "$1" in
        xfce4)   echo "XFCE4"       ;;
        lxqt)    echo "LXQt"        ;;
        mate)    echo "MATE"        ;;
        kde)     echo "KDE Plasma"  ;;
        gnome)   echo "GNOME"       ;;
        fluxbox) echo "Fluxbox"     ;;
        openbox) echo "Openbox"     ;;
    esac
}

# Does this DE offer a Minimal/Full choice? (Fluxbox/Openbox are WMs, always minimal)
de_has_variant() {
    case "$1" in
        xfce4|lxqt|mate|kde|gnome) return 0 ;;
        *) return 1 ;;
    esac
}

# Packages to remove per package manager + DE key
# (mirrors the FULL install package lists so removal cleans up either variant)
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
                lxqt)    echo "lxqt lxqt-core" ;;
                mate)    echo "mate-desktop-environment mate-desktop-environment-core" ;;
                kde)     echo "kde-standard kde-plasma-desktop sddm" ;;
                gnome)   echo "task-gnome-desktop gnome-core gdm3" ;;
                fluxbox) echo "fluxbox" ;;
                openbox) echo "openbox openbox-menu tint2" ;;
            esac ;;
        pacman)
            case "$dekey" in
                xfce4)   echo "xfce4 xfce4-goodies" ;;
                lxqt)    echo "lxqt" ;;
                mate)    echo "mate mate-extra" ;;
                kde)     echo "plasma kde-applications" ;;
                gnome)   echo "gnome gnome-extra" ;;
                fluxbox) echo "fluxbox" ;;
                openbox) echo "openbox tint2" ;;
            esac ;;
        dnf)
            case "$dekey" in
                xfce4)   echo "@xfce-desktop-environment" ;;
                lxqt)    echo "@lxqt-desktop-environment" ;;
                mate)    echo "@mate-desktop-environment" ;;
                kde)     echo "@kde-desktop-environment" ;;
                gnome)   echo "@workstation-product-environment gnome-shell gnome-session gnome-terminal nautilus gnome-control-center" ;;
                fluxbox) echo "fluxbox" ;;
                openbox) echo "openbox xfce4-panel" ;;
            esac ;;
        apk)
            case "$dekey" in
                xfce4)   echo "xfce4 xfce4-extras" ;;
                lxqt)    echo "lxqt lxqt-session" ;;
                mate)    echo "marco mate-panel mate-session-manager caja mate-terminal mate-utils" ;;
                kde)     echo "plasma-desktop-meta konsole dolphin plasma-nm" ;;
                gnome)   echo "gnome" ;;
                fluxbox) echo "fluxbox" ;;
                openbox) echo "openbox tint2" ;;
            esac ;;
        xbps)
            case "$dekey" in
                xfce4)   echo "xfce4 xfce4-goodies" ;;
                lxqt)    echo "lxqt" ;;
                mate)    echo "mate" ;;
                kde)     echo "kde-plasma kde-baseapps" ;;
                gnome)   echo "gnome" ;;
                fluxbox) echo "fluxbox" ;;
                openbox) echo "openbox tint2" ;;
            esac ;;
        zypper)
            case "$dekey" in
                xfce4)   echo "patterns-xfce-xfce patterns-xfce-xfce_basis" ;;
                lxqt)    echo "patterns-lxqt-lxqt" ;;
                mate)    echo "patterns-mate-mate" ;;
                kde)     echo "patterns-kde-kde patterns-kde-kde_plasma" ;;
                gnome)   echo "patterns-gnome-gnome patterns-gnome-gnome_basic" ;;
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
read -p "Select an option (0-1): " ACTION

case $ACTION in
    0|1) ;;
    *) echo -e "${R}Invalid choice. Exiting.${NC}"; exit 1 ;;
esac

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
    FOUND_DEKEY=()    # xfce4/lxqt/mate/kde/gnome/fluxbox/openbox, or "" if base OS only

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
                    FOUND_PKGTYPE+=("")
                    FOUND_DEKEY+=("")
                fi
            done <<< "$PLIST"
        fi
    fi

    # ---- chroot-distro containers ----
    CHROOT_DIR="$HOME/.local/share/chroot-distro"
    if [ -d "$CHROOT_DIR" ]; then
        for cdir in "$CHROOT_DIR"/*; do
            [ ! -d "$cdir" ] && continue
            distro_name=$(basename "$cdir")

            # Guess package manager
            case "$distro_name" in
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
                if [ -x "$cdir/rootfs/usr/bin/$bin" ] 2>/dev/null || [ -x "$cdir/rootfs/usr/local/bin/$bin" ] 2>/dev/null; then
                    FOUND_LABELS+=("chroot-distro: $distro_name — $(de_label "$dekey")")
                    FOUND_SOURCE+=("chroot")
                    FOUND_DISTRO+=("$distro_name")
                    FOUND_PKGTYPE+=("$ptype")
                    FOUND_DEKEY+=("$dekey")
                    FOUND_ANY_DE=1
                fi
            done
            if [ "$FOUND_ANY_DE" = "0" ]; then
                FOUND_LABELS+=("chroot-distro: $distro_name — (base OS, no DE)")
                FOUND_SOURCE+=("chroot")
                FOUND_DISTRO+=("$distro_name")
                FOUND_PKGTYPE+=("")
                FOUND_DEKEY+=("")
            fi
        done
    fi

    echo ""
    if [ ${#FOUND_LABELS[@]} -eq 0 ]; then
        echo -e "${R}✗ No environments found. Nothing to uninstall.${NC}"
        exit 0
    fi

    # ---- Let user choose which to remove ----
    echo "Found:"
    for i in "${!FOUND_LABELS[@]}"; do
        echo "  $i) ${FOUND_LABELS[$i]}"
    done
    echo ""
    read -p "Select which to uninstall (or press Ctrl+C to cancel): " CHOICE

    if ! [[ "$CHOICE" =~ ^[0-9]+$ ]] || [ "$CHOICE" -ge ${#FOUND_LABELS[@]} ]; then
        echo -e "${R}Invalid choice. Exiting.${NC}"
        exit 1
    fi

    TARGET_LABEL="${FOUND_LABELS[$CHOICE]}"
    TARGET_SOURCE="${FOUND_SOURCE[$CHOICE]}"
    TARGET_DISTRO="${FOUND_DISTRO[$CHOICE]}"
    TARGET_PKGTYPE="${FOUND_PKGTYPE[$CHOICE]}"
    TARGET_DEKEY="${FOUND_DEKEY[$CHOICE]}"

    echo ""
    echo -e "${Y}Uninstalling: $TARGET_LABEL${NC}"
    echo ""

    # If it's a base OS (no DE), ask if they want to remove the whole thing
    if [ -z "$TARGET_DEKEY" ]; then
        read -p "Remove the entire system? (y/n) [n]: " REMOVE_SYSTEM
        REMOVE_SYSTEM="${REMOVE_SYSTEM:-n}"
        if [[ "$REMOVE_SYSTEM" =~ ^[Yy]$ ]]; then
            if [ "$TARGET_SOURCE" = "proot" ]; then
                echo -e "${Y}Removing proot container: $TARGET_DISTRO...${NC}"
                proot-distro remove "$TARGET_DISTRO"
                echo -e "${G}✓ Removed.${NC}"
            elif [ "$TARGET_SOURCE" = "chroot" ]; then
                check_root
                echo -e "${Y}Removing chroot container: $TARGET_DISTRO...${NC}"
                sudo chroot-distro remove "$TARGET_DISTRO"
                echo -e "${G}✓ Removed.${NC}"
            fi
            exit 0
        else
            echo -e "${Y}Keeping the system, skipping uninstall.${NC}"
            exit 0
        fi
    fi

    # Otherwise, ask if they want to remove just the DE or the whole container
    read -p "Remove just the desktop or the entire system? (de/system) [de]: " REMOVE_CHOICE
    REMOVE_CHOICE="${REMOVE_CHOICE:-de}"

    case "$REMOVE_CHOICE" in
        system)
            if [ "$TARGET_SOURCE" = "proot" ]; then
                echo -e "${Y}Removing entire proot container: $TARGET_DISTRO...${NC}"
                proot-distro remove "$TARGET_DISTRO"
                echo -e "${G}✓ Removed.${NC}"
            elif [ "$TARGET_SOURCE" = "chroot" ]; then
                check_root
                echo -e "${Y}Removing entire chroot container: $TARGET_DISTRO...${NC}"
                sudo chroot-distro remove "$TARGET_DISTRO"
                echo -e "${G}✓ Removed.${NC}"
            fi
            ;;
        de|*)
            if [ "$TARGET_SOURCE" = "native" ]; then
                REMOVE_CMD=$(de_remove_cmd "$TARGET_PKGTYPE" "$(de_remove_pkgs "$TARGET_PKGTYPE" "$TARGET_DEKEY")")
                echo -e "${Y}Removing $TARGET_DEKEY from Native Termux...${NC}"
                bash -c "$REMOVE_CMD"
                echo -e "${G}✓ Removed.${NC}"
            elif [ "$TARGET_SOURCE" = "proot" ]; then
                PKGS=$(de_remove_pkgs "$TARGET_PKGTYPE" "$TARGET_DEKEY")
                REMOVE_CMD=$(de_remove_cmd "$TARGET_PKGTYPE" "$PKGS")
                echo -e "${Y}Removing $TARGET_DEKEY from proot: $TARGET_DISTRO...${NC}"
                proot-distro login "$TARGET_DISTRO" -- bash -c "$REMOVE_CMD"
                echo -e "${G}✓ Removed.${NC}"
            elif [ "$TARGET_SOURCE" = "chroot" ]; then
                check_root
                PKGS=$(de_remove_pkgs "$TARGET_PKGTYPE" "$TARGET_DEKEY")
                REMOVE_CMD=$(de_remove_cmd "$TARGET_PKGTYPE" "$PKGS")
                echo -e "${Y}Removing $TARGET_DEKEY from chroot-distro: $TARGET_DISTRO...${NC}"
                unset LD_PRELOAD
                sudo chroot-distro login "$TARGET_DISTRO" -- /bin/sh -c "$REMOVE_CMD"
                echo -e "${G}✓ Removed.${NC}"
            fi
            ;;
    esac

    echo ""
    echo -e "${G}Uninstall complete.${NC}"
    exit 0
fi

# ================================================================
# ================================================================
#   ACTION 0 — INSTALL
# ================================================================
# ================================================================

banner

# ---- Step 1: Update Termux & enable x11-repo ----
echo -e "${Y}--- [0/7] Updating Termux and enabling x11-repo ---${NC}"
pkg update -y 2>&1 | tail -5
pkg install -y x11-repo qemu-user-static 2>&1 | tail -3
pkg update -y 2>&1 | tail -5
echo -e "${G}✓ Termux updated, x11-repo enabled, and QEMU emulator installed.${NC}"
sleep 1

# ---- Step 2: Choose setup mode ----
banner
echo -e "${C}╔══════════════════════════════════════════════╗"
echo    "║            SETUP MODE — CHOOSE ONE            ║"
echo    "╠══════════════════════════════════════════════╣"
echo    "║                                              ║"
echo    "║  0) proot / Native Termux [RECOMMENDED]      ║"
echo    "║     (no root required, stable, 18 distros)   ║"
echo    "║                                              ║"
echo    "║  1) chroot-distro [EXPERIMENTAL]             ║"
echo    "║     (root required, faster, limited distros) ║"
echo    "║                                              ║"
echo -e "╚══════════════════════════════════════════════╝${NC}"
read -p "Select setup mode (0-1): " SETUP_TYPE

case $SETUP_TYPE in
    0|1) ;;
    *) echo -e "${R}Invalid choice. Exiting.${NC}"; exit 1 ;;
esac

if [ "$SETUP_TYPE" = "1" ]; then
    check_root
fi

# ---- Step 3a: Choose distro (proot / Native) ----
if [ "$SETUP_TYPE" = "0" ]; then

    banner
    echo -e "${C}╔══════════════════════════════════════════════╗"
    echo    "║          CHOOSE DISTRIBUTION (proot)          ║"
    echo    "╠══════════════════════════════════════════════╣"
    echo    "║                                              ║"
    echo    "║  0) Native Termux [FASTEST]                  ║"
    echo    "║  1) Debian                                   ║"
    echo    "║  2) Ubuntu 25.10                             ║"
    echo    "║  3) Trisquel GNU                             ║"
    echo    "║  4) Pardus                                   ║"
    echo    "║  5) Arch Linux                               ║"
    echo    "║  6) Artix Linux                              ║"
    echo    "║  7) Manjaro                                  ║"
    echo    "║  8) Fedora                                   ║"
    echo    "║  9) AlmaLinux                                ║"
    echo    "║ 10) Oracle Linux                             ║"
    echo    "║ 11) Rocky Linux                              ║"
    echo    "║ 12) Alpine Linux                             ║"
    echo    "║ 13) Void Linux                               ║"
    echo    "║ 14) OpenSUSE                                 ║"
    echo    "║ 15) Chimera Linux                            ║"
    echo    "║ 16) Adelie Linux                             ║"
    echo    "║ 17) Deepin                                   ║"
    echo    "║                                              ║"
    echo -e "╚══════════════════════════════════════════════╝${NC}"
    read -p "Select a distribution (0-17): " DISTRO_CHOICE

    DISTRO_NAMES=("native" "debian" "ubuntu" "trisquel" "pardus" "archlinux" "artix" "manjaro" "fedora" "almalinux" "oracle" "rockylinux" "alpine" "void" "opensuse" "chimera" "adelie" "deepin")

    if ! [[ "$DISTRO_CHOICE" =~ ^[0-9]+$ ]] || [ "$DISTRO_CHOICE" -ge ${#DISTRO_NAMES[@]} ]; then
        echo -e "${R}Invalid choice. Exiting.${NC}"
        exit 1
    fi

    DISTRO="${DISTRO_NAMES[$DISTRO_CHOICE]}"
    if [ "$DISTRO" = "native" ]; then
        PKG_TYPE="pkg"
        DNAME="Native Termux"
    else
        PKG_TYPE=$(case "$DISTRO" in
            debian|ubuntu|trisquel|pardus|deepin) echo "apt" ;;
            archlinux|artix|manjaro) echo "pacman" ;;
            fedora|almalinux|oracle|rockylinux) echo "dnf" ;;
            alpine|chimera|adelie) echo "apk" ;;
            void) echo "xbps" ;;
            opensuse) echo "zypper" ;;
        esac)
        DNAME=$(echo "$DISTRO" | sed 's/^\w/\U&/')
    fi

# ---- Step 3b: Choose distro (chroot-distro) ----
else

    banner
    echo -e "${C}╔══════════════════════════════════════════════╗"
    echo    "║    CHOOSE DISTRIBUTION (chroot-distro)       ║"
    echo    "╠══════════════════════════════════════════════╣"
    echo    "║                                              ║"
    echo    "║  0) Debian                                   ║"
    echo    "║  1) Ubuntu 25.10                             ║"
    echo    "║  2) Arch Linux                               ║"
    echo    "║  3) Fedora                                   ║"
    echo    "║  4) Alpine Linux                             ║"
    echo    "║  5) OpenSUSE                                 ║"
    echo    "║  6) Void Linux                               ║"
    echo    "║                                              ║"
    echo -e "╚══════════════════════════════════════════════╝${NC}"
    read -p "Select a distribution (0-6): " DISTRO_CHOICE

    DISTRO_NAMES=("debian" "ubuntu" "archlinux" "fedora" "alpine" "opensuse" "void")

    if ! [[ "$DISTRO_CHOICE" =~ ^[0-9]+$ ]] || [ "$DISTRO_CHOICE" -ge ${#DISTRO_NAMES[@]} ]; then
        echo -e "${R}Invalid choice. Exiting.${NC}"
        exit 1
    fi

    DISTRO="${DISTRO_NAMES[$DISTRO_CHOICE]}"
    PKG_TYPE=$(case "$DISTRO" in
        debian|ubuntu) echo "apt" ;;
        archlinux) echo "pacman" ;;
        fedora) echo "dnf" ;;
        alpine) echo "apk" ;;
        opensuse) echo "zypper" ;;
        void) echo "xbps" ;;
    esac)
    DNAME=$(echo "$DISTRO" | sed 's/^\w/\U&/')
    DISTRO_LOGIN="$DISTRO"

fi

# ---- Step 4: Choose desktop environment ----
banner
echo -e "${C}╔══════════════════════════════════════════════╗"
echo    "║       CHOOSE DESKTOP ENVIRONMENT (DE)         ║"
echo    "╠══════════════════════════════════════════════╣"
echo    "║                                              ║"
echo    "║  0) XFCE4 [RECOMMENDED]                      ║"
echo    "║  1) LXQt                                      ║"
if [ "$DISTRO" != "native" ]; then
echo    "║  2) MATE                                       ║"
echo    "║  3) KDE Plasma                                ║"
echo    "║  4) GNOME                                     ║"
else
echo    "║  2) MATE [NOT AVAILABLE ON NATIVE TERMUX]    ║"
echo    "║  3) KDE Plasma [NOT AVAILABLE ON NATIVE]     ║"
echo    "║  4) GNOME [NOT AVAILABLE ON NATIVE TERMUX]   ║"
fi
echo    "║  5) Fluxbox                                   ║"
echo    "║  6) Openbox                                   ║"
echo    "║                                              ║"
echo -e "╚══════════════════════════════════════════════╝${NC}"
read -p "Select a desktop environment (0-6): " DE_CHOICE

case "$DE_CHOICE" in
    0) DE_KEY="xfce4" ;;
    1) DE_KEY="lxqt" ;;
    2)
        if [ "$DISTRO" = "native" ]; then
            echo -e "${R}✗ MATE not available on Native Termux. Exiting.${NC}"
            exit 1
        fi
        DE_KEY="mate"
        ;;
    3)
        if [ "$DISTRO" = "native" ]; then
            echo -e "${R}✗ KDE Plasma not available on Native Termux. Exiting.${NC}"
            exit 1
        fi
        DE_KEY="kde"
        ;;
    4)
        if [ "$DISTRO" = "native" ]; then
            echo -e "${R}✗ GNOME not available on Native Termux. Exiting.${NC}"
            exit 1
        fi
        DE_KEY="gnome"
        ;;
    5) DE_KEY="fluxbox" ;;
    6) DE_KEY="openbox" ;;
    *) echo -e "${R}Invalid choice. Exiting.${NC}"; exit 1 ;;
esac

DE_NAME=$(de_label "$DE_KEY")

case "$DE_KEY" in
    xfce4)   DE_START="dbus-launch --exit-with-session xfce4-session" ;;
    lxqt)    DE_START="dbus-launch --exit-with-session startlxqt" ;;
    mate)    DE_START="dbus-launch --exit-with-session mate-session" ;;
    kde)     DE_START="dbus-launch --exit-with-session startplasma-x11" ;;
    gnome)   DE_START="dbus-launch --exit-with-session env XDG_CURRENT_DESKTOP=GNOME XDG_SESSION_TYPE=x11 gnome-shell --x11" ;;
    fluxbox) DE_START="dbus-launch --exit-with-session fluxbox" ;;
    openbox) DE_START="dbus-launch --exit-with-session openbox-session" ;;
esac

# ---- Step 4b: Minimal or Full? (only for real desktop environments) ----
VARIANT="minimal"
if de_has_variant "$DE_KEY"; then
    banner
    echo -e "${C}╔══════════════════════════════════════════════╗"
    echo    "║      $DE_NAME — MINIMAL OR FULL INSTALL?      "
    echo    "╠══════════════════════════════════════════════╣"
    echo    "║                                              ║"
    echo    "║  0) Minimal                                  ║"
    echo    "║     Essential session only — lighter, faster ║"
    echo    "║                                              ║"
    echo    "║  1) Full                                     ║"
    echo    "║     Adds themes, applets and extra apps      ║"
    echo    "║                                              ║"
    echo -e "╚══════════════════════════════════════════════╝${NC}"
    read -p "Select install size (0-1): " VARIANT_CHOICE
    case "$VARIANT_CHOICE" in
        0) VARIANT="minimal" ;;
        1) VARIANT="full" ;;
        *) echo -e "${R}Invalid choice. Exiting.${NC}"; exit 1 ;;
    esac
fi

# ---- Step 5: Install packages ----
echo -e "${Y}--- [1/7] Installing Termux-X11 and base tools ---${NC}"

if [ "$PKG_TYPE" = "pkg" ]; then
    pkg install -y termux-x11-nightly pulseaudio virgl-android dbus >/dev/null 2>&1
    echo -e "${G}✓ Base tools installed (Termux).${NC}"
elif [ "$SETUP_TYPE" = "0" ]; then
    proot-distro login "$DISTRO" -- bash -c "apt-get update && apt-get install -y dbus libxfce4ui-2-dev 2>/dev/null || dnf install -y dbus 2>/dev/null || pacman -Sy dbus 2>/dev/null || apk add dbus 2>/dev/null || xbps-install -Sy dbus 2>/dev/null || zypper install -y dbus 2>/dev/null" >/dev/null 2>&1
    echo -e "${G}✓ Base tools installed (proot).${NC}"
else
    unset LD_PRELOAD
    sudo chroot-distro login "$DISTRO_LOGIN" -- /bin/sh -c "apt-get update && apt-get install -y dbus 2>/dev/null || dnf install -y dbus 2>/dev/null || pacman -Sy dbus 2>/dev/null || apk add dbus 2>/dev/null || xbps-install -Sy dbus 2>/dev/null || zypper install -y dbus 2>/dev/null" >/dev/null 2>&1
    echo -e "${G}✓ Base tools installed (chroot-distro).${NC}"
fi
sleep 1

echo -e "${Y}--- [2/7] Installing desktop environment ($VARIANT) ---${NC}"

# Define DE install commands per package manager + variant (minimal/full)
de_install_cmd() {
    local pkgtype="$1" dekey="$2" variant="$3"
    case "$pkgtype" in
        pkg)
            case "$dekey" in
                xfce4)
                    if [ "$variant" = "full" ]; then echo "pkg install -y xfce4 xfce4-goodies dbus"
                    else echo "pkg install -y xfce4 dbus"; fi ;;
                lxqt)    echo "pkg install -y lxqt" ;;
                fluxbox) echo "pkg install -y fluxbox" ;;
                openbox) echo "pkg install -y openbox openbox-menu tint2 xorg-xsetroot" ;;
            esac ;;
        apt)
            case "$dekey" in
                xfce4)
                    if [ "$variant" = "full" ]; then echo "apt-get update && apt-get install -y xfce4 xfce4-goodies"
                    else echo "apt-get update && apt-get install -y xfce4"; fi ;;
                lxqt)
                    if [ "$variant" = "full" ]; then echo "apt-get update && apt-get install -y lxqt"
                    else echo "apt-get update && apt-get install -y lxqt-core"; fi ;;
                mate)
                    if [ "$variant" = "full" ]; then echo "apt-get update && apt-get install -y mate-desktop-environment"
                    else echo "apt-get update && apt-get install -y mate-desktop-environment-core"; fi ;;
                kde)
                    if [ "$variant" = "full" ]; then echo "apt-get update && apt-get install -y kde-standard"
                    else echo "apt-get update && apt-get install -y kde-plasma-desktop"; fi ;;
                gnome)
                    if [ "$variant" = "full" ]; then echo "apt-get update && apt-get install -y task-gnome-desktop"
                    else echo "apt-get update && apt-get install -y gnome-core"; fi ;;
                fluxbox) echo "apt-get update && apt-get install -y fluxbox" ;;
                openbox) echo "apt-get update && apt-get install -y openbox openbox-menu tint2" ;;
            esac ;;
        pacman)
            case "$dekey" in
                xfce4)
                    if [ "$variant" = "full" ]; then echo "pacman -Sy --noconfirm xfce4 xfce4-goodies"
                    else echo "pacman -Sy --noconfirm xfce4"; fi ;;
                lxqt)    echo "pacman -Sy --noconfirm lxqt" ;;
                mate)
                    if [ "$variant" = "full" ]; then echo "pacman -Sy --noconfirm mate mate-extra"
                    else echo "pacman -Sy --noconfirm mate"; fi ;;
                kde)
                    if [ "$variant" = "full" ]; then echo "pacman -Sy --noconfirm plasma kde-applications"
                    else echo "pacman -Sy --noconfirm plasma"; fi ;;
                gnome)
                    if [ "$variant" = "full" ]; then echo "pacman -Sy --noconfirm gnome gnome-extra"
                    else echo "pacman -Sy --noconfirm gnome"; fi ;;
                fluxbox) echo "pacman -Sy --noconfirm fluxbox" ;;
                openbox) echo "pacman -Sy --noconfirm openbox tint2" ;;
            esac ;;
        dnf)
            case "$dekey" in
                xfce4)
                    if [ "$variant" = "full" ]; then echo "dnf group install -y --with-optional xfce-desktop-environment"
                    else echo "dnf install -y @xfce-desktop-environment"; fi ;;
                lxqt)
                    if [ "$variant" = "full" ]; then echo "dnf group install -y --with-optional lxqt-desktop-environment"
                    else echo "dnf install -y @lxqt-desktop-environment"; fi ;;
                mate)
                    if [ "$variant" = "full" ]; then echo "dnf group install -y --with-optional mate-desktop-environment"
                    else echo "dnf install -y @mate-desktop-environment"; fi ;;
                kde)
                    if [ "$variant" = "full" ]; then echo "dnf group install -y --with-optional kde-desktop-environment"
                    else echo "dnf install -y @kde-desktop-environment"; fi ;;
                gnome)
                    # Fedora has no reliable minimal-only GNOME group (only the full
                    # Workstation product group), so minimal installs explicit core
                    # packages by name instead of a group.
                    if [ "$variant" = "full" ]; then echo "dnf group install -y --with-optional workstation-product-environment"
                    else echo "dnf install -y gnome-shell gnome-session gnome-terminal nautilus gnome-control-center"; fi ;;
                fluxbox) echo "dnf install -y fluxbox" ;;
                openbox) echo "dnf install -y openbox xfce4-panel" ;;
            esac ;;
        apk)
            case "$dekey" in
                xfce4)
                    if [ "$variant" = "full" ]; then echo "apk add xfce4 xfce4-extras"
                    else echo "apk add xfce4"; fi ;;
                lxqt)    echo "apk add lxqt lxqt-session" ;;
                mate)
                    if [ "$variant" = "full" ]; then echo "apk add marco mate-panel mate-session-manager caja mate-terminal mate-utils"
                    else echo "apk add marco mate-panel mate-session-manager caja"; fi ;;
                kde)
                    if [ "$variant" = "full" ]; then echo "apk add plasma-desktop-meta konsole dolphin plasma-nm"
                    else echo "apk add plasma-desktop-meta"; fi ;;
                gnome)   echo "apk add gnome" ;;
                fluxbox) echo "apk add fluxbox" ;;
                openbox) echo "apk add openbox tint2" ;;
            esac ;;
        xbps)
            case "$dekey" in
                xfce4)
                    if [ "$variant" = "full" ]; then echo "xbps-install -Sy xfce4 xfce4-goodies"
                    else echo "xbps-install -Sy xfce4"; fi ;;
                lxqt)    echo "xbps-install -Sy lxqt" ;;
                mate)    echo "xbps-install -Sy mate" ;;
                kde)
                    if [ "$variant" = "full" ]; then echo "xbps-install -Sy kde-plasma kde-baseapps"
                    else echo "xbps-install -Sy kde-plasma"; fi ;;
                gnome)   echo "xbps-install -Sy gnome" ;;
                fluxbox) echo "xbps-install -Sy fluxbox" ;;
                openbox) echo "xbps-install -Sy openbox tint2" ;;
            esac ;;
        zypper)
            case "$dekey" in
                xfce4)
                    if [ "$variant" = "full" ]; then echo "zypper --non-interactive install patterns-xfce-xfce"
                    else echo "zypper --non-interactive install patterns-xfce-xfce_basis"; fi ;;
                lxqt)    echo "zypper --non-interactive install patterns-lxqt-lxqt" ;;
                mate)    echo "zypper --non-interactive install patterns-mate-mate" ;;
                kde)
                    if [ "$variant" = "full" ]; then echo "zypper --non-interactive install patterns-kde-kde"
                    else echo "zypper --non-interactive install patterns-kde-kde_plasma"; fi ;;
                gnome)
                    if [ "$variant" = "full" ]; then echo "zypper --non-interactive install patterns-gnome-gnome"
                    else echo "zypper --non-interactive install patterns-gnome-gnome_basic"; fi ;;
                fluxbox) echo "zypper --non-interactive install fluxbox" ;;
                openbox) echo "zypper --non-interactive install openbox lxpanel" ;;
            esac ;;
    esac
}

DE_INSTALL_CMD=$(de_install_cmd "$PKG_TYPE" "$DE_KEY" "$VARIANT")

if [ "$PKG_TYPE" = "pkg" ]; then
    bash -c "$DE_INSTALL_CMD" >/dev/null 2>&1
elif [ "$SETUP_TYPE" = "0" ]; then
    proot-distro login "$DISTRO" -- bash -c "$DE_INSTALL_CMD" >/dev/null 2>&1
else
    unset LD_PRELOAD
    sudo chroot-distro login "$DISTRO_LOGIN" -- /bin/sh -c "$DE_INSTALL_CMD" >/dev/null 2>&1
fi
echo -e "${G}✓ Desktop environment installed.${NC}"
sleep 1

# ---- Icon themes & dependencies fix ----
echo -e "${Y}--- [3/7] Installing icon themes and dependencies ---${NC}"

icon_theme_cmd() {
    local pkgtype="$1"
    case "$pkgtype" in
        pkg)    echo "pkg install -y librsvg adwaita-icon-theme" ;;
        apt)    echo "apt-get update && apt-get install -y librsvg2-2 adwaita-icon-theme && gdk-pixbuf-query-loaders --update-cache" ;;
        pacman) echo "pacman -Sy --noconfirm librsvg adwaita-icon-theme && gdk-pixbuf-query-loaders --update-cache" ;;
        dnf)    echo "dnf install -y librsvg2 adwaita-icon-theme && gdk-pixbuf-query-loaders --update-cache" ;;
        apk)    echo "apk add librsvg adwaita-icon-theme && gdk-pixbuf-query-loaders --update-cache" ;;
        xbps)   echo "xbps-install -Sy librsvg adwaita-icon-theme && gdk-pixbuf-query-loaders --update-cache" ;;
        zypper) echo "zypper --non-interactive install librsvg adwaita-icon-theme && gdk-pixbuf-query-loaders --update-cache" ;;
    esac
}

ICON_CMD=$(icon_theme_cmd "$PKG_TYPE")

if [ "$PKG_TYPE" = "pkg" ]; then
    bash -c "$ICON_CMD" >/dev/null 2>&1
elif [ "$SETUP_TYPE" = "0" ]; then
    proot-distro login "$DISTRO" -- bash -c "$ICON_CMD" >/dev/null 2>&1
else
    unset LD_PRELOAD
    sudo chroot-distro login "$DISTRO_LOGIN" -- /bin/sh -c "$ICON_CMD" >/dev/null 2>&1
fi
echo -e "${G}✓ Icon themes and dependencies installed.${NC}"
sleep 1

# ---- Appearance packages (optional) ----
echo -e "${Y}--- [4/7] Appearance packages (optional) ---${NC}"

appear_theme_cmd() {
    local pkgtype="$1"
    case "$pkgtype" in
        pkg)    echo "pkg install -y arc-theme papirus-icon-theme google-noto-emoji qt5ct lxappearance" ;;
        apt)    echo "apt-get update && apt-get install -y arc-theme papirus-icon-theme fonts-noto-color-emoji qt5ct lxappearance" ;;
        pacman) echo "pacman -Sy --noconfirm arc-gtk-theme papirus-icon-theme noto-fonts-emoji qt5ct lxappearance" ;;
        dnf)    echo "dnf install -y arc-theme papirus-icon-theme google-noto-color-emoji-fonts qt5ct lxappearance" ;;
        apk)    echo "apk add arc-theme papirus-icon-theme font-noto-emoji qt5ct lxappearance" ;;
        xbps)   echo "xbps-install -Sy arc-theme papirus-icon-theme noto-fonts-emoji qt5ct lxappearance" ;;
        zypper) echo "zypper --non-interactive install arc-theme papirus-icon-theme google-noto-coloremoji-fonts qt5ct lxappearance" ;;
    esac
}

APPEAR_CMD=$(appear_theme_cmd "$PKG_TYPE")

read -p "Install appearance packages (Arc theme, Papirus icons, etc)? (y/n) [Y]: " appear_choice
appear_choice="${appear_choice:-Y}"

if [[ "$appear_choice" =~ ^[Yy]$ ]]; then
    echo -e "${Y}--- [5/7] Installing appearance packages ---${NC}"
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
# STEP 7 — Generate ~/start.sh
# ==============================================================
echo -e "${Y}--- [6/7] Creating ~/start.sh launcher ---${NC}"

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
if de_has_variant "$DE_KEY"; then
    if [ "$VARIANT" = "full" ]; then
        echo "║  Variant : Full"
    else
        echo "║  Variant : Minimal"
    fi
fi
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
