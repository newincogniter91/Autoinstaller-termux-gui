#!/data/data/com.termux/files/usr/bin/bash

# 1. Environment Preparation & Core TX11 Packages
echo "--- Updating system and installing Termux-X11 suite ---"
pkg update -y && pkg upgrade -y
pkg install -y termux-x11-repo x11-repo
# Specifically installing the TX11 nightly and X11 tools
pkg install -y termux-x11-nightly x11-utils pulseaudio virglrenderer-android proot-distro wget

# 2. Distribution Selection
echo "------------------------------------------------"
echo " WHICH DISTRIBUTION DO YOU WANT TO INSTALL?"
echo " 1) Debian (Stable & Recommended)"
echo " 2) Ubuntu (Popular)"
echo " 3) Arch Linux (For advanced users)"
echo "------------------------------------------------"
read -p "Select a distro (1-3): " distro_choice

case $distro_choice in
    1) DISTRO="debian"; PKG_MGR="apt";;
    2) DISTRO="ubuntu"; PKG_MGR="apt";;
    3) DISTRO="archlinux"; PKG_MGR="pacman -Sy --noconfirm";;
    *) echo "Invalid choice. Exiting."; exit 1;;
esac

echo "--- Installing $DISTRO via proot-distro ---"
proot-distro install $DISTRO

# 3. Desktop Environment Selection
echo "------------------------------------------------"
echo " WHICH DESKTOP ENVIRONMENT (DE) DO YOU WANT?"
echo " 1) XFCE4 (Balanced - Recommended)"
echo " 2) LXQt (Ultra lightweight)"
echo " 3) MATE (Classic style)"
echo "------------------------------------------------"
read -p "Select a desktop (1-3): " de_choice

# Define packages and start command based on Distro and DE
if [ "$PKG_MGR" == "apt" ]; then
    case $de_choice in
        1) DE_PKGS="xfce4 xfce4-goodies"; START_CMD="startxfce4";;
        2) DE_PKGS="lxqt"; START_CMD="startlxqt";;
        3) DE_PKGS="mate-desktop-environment"; START_CMD="mate-session";;
    esac
    INSTALL_CMD="apt update && apt install -y $DE_PKGS dbus-x11"
else
    case $de_choice in
        1) DE_PKGS="xfce4 xfce4-goodies"; START_CMD="startxfce4";;
        2) DE_PKGS="lxqt"; START_CMD="startlxqt";;
        3) DE_PKGS="mate"; START_CMD="mate-session";;
    esac
    INSTALL_CMD="pacman -Syu --noconfirm $DE_PKGS dbus"
fi

echo "--- Installing Desktop Environment inside $DISTRO ---"
proot-distro login $DISTRO -- bash -c "$INSTALL_CMD"

# 4. Create the Automatic Startup Script (Optimized for TX11)
cat <<EOF > start.sh
#!/data/data/com.termux/files/usr/bin/bash

# Kill previous sessions to avoid Display :0 conflicts
pkill -f termux-x11
pkill -f pulseaudio
pkill -f virgl

# 1. Start Termux-X11
termux-x11 :0 &

# 2. Start Audio
pulseaudio --start --exit-idle-time=-1

# 3. Start Hardware Acceleration Server
virgl_test_server_android &

echo "TX11 and VirGL started. Please open the Termux-X11 App."
sleep 3

# 4. Launch the Linux Session
proot-distro login $DISTRO --shared-tmp -- bash -c "
    export DISPLAY=:0
    export GALLIUM_DRIVER=virpipe
    export PULSE_SERVER=127.0.0.1
    dbus-launch --exit-with-session $START_CMD
"
EOF

chmod +x start.sh

echo "------------------------------------------------"
echo " SETUP FINISHED!"
echo "------------------------------------------------"
echo " 1. Make sure you have the Termux-X11 APK installed."
echo " 2. Run './start.sh' to boot your Linux desktop."
echo "------------------------------------------------"

