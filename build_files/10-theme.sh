#!/usr/bin/bash
# Default global theme, Konsole profile and fonts (theme files come from system_files/).
set -euo pipefail

# Log what the base image sets, so CI shows any upstream override we must handle.
grep -rs 'LookAndFeelPackage\|ColorScheme' /etc/xdg/kdeglobals /usr/share/kde-settings 2>/dev/null || true
# kwriteconfig6 merges into an existing /etc/xdg file instead of replacing it.
kwriteconfig6 --file /etc/xdg/kdeglobals --group KDE --key LookAndFeelPackage org.oldnet.desktop
kwriteconfig6 --file /etc/xdg/konsolerc --group "Desktop Entry" --key DefaultProfile OldNet.profile

# Fonts (OFL)
dnf5 -y install ibm-plex-mono-fonts
dnf5 clean all
