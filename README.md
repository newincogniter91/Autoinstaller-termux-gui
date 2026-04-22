# Autoinstaller-termux-gui
simple .sh file that allows those less experienced with termux to configure a gui 
# Autoinstaller Termux GUI

This script automates the installation of a Linux Desktop Environment (XFCE4, LXQt, OPENBOX, FLUXBOX or MATE) inside Termux using `proot-distro`, `termux-x11`, and `VirGL` for hardware acceleration.

NEEDED:
termux and termux x11 on your phone, downloaded by fdroid(recommended) or github

## How to install

To copy the installer to your Termux home and start the setup, simply copy and paste the following command into your Termux terminal:

```bash
pkg install wget -y && wget [https://raw.githubusercontent.com/newincogniter91/Autoinstaller-termux-gui/main/setup.sh](https://raw.githubusercontent.com/newincogniter91/Autoinstaller-termux-gui/main/setup.sh) && chmod +x setup.sh && ./setup.sh
