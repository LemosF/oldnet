#!/usr/bin/bash
set -euo pipefail

# --- Branding (stage 1: name only; "based on Bazzite" is allowed) ---
OSR=/usr/lib/os-release
sed -i \
  -e 's/^NAME=.*/NAME="OldNet OS"/' \
  -e 's/^PRETTY_NAME=.*/PRETTY_NAME="OldNet OS (based on Bazzite)"/' \
  -e "s/^ID=.*/ID=oldnet/" \
  -e 's/^HOME_URL=.*/HOME_URL="https:\/\/github.com\/LemosF\/oldnet"/' \
  -e 's/^LOGO=.*/LOGO=oldnet/' \
  -e '/^VARIANT_ID=/d' \
  "$OSR"
grep -q '^ID_LIKE=' "$OSR" || echo 'ID_LIKE="fedora"' >> "$OSR"
echo "VARIANT_ID=${IMAGE_NAME}" >> "$OSR"

# --- Default global theme (files come from system_files/) ---
# Log what the base image sets, so CI shows any upstream override we must handle.
grep -rs 'LookAndFeelPackage\|ColorScheme' /etc/xdg/kdeglobals /usr/share/kde-settings 2>/dev/null || true
# kwriteconfig6 merges into an existing /etc/xdg/kdeglobals instead of replacing it.
kwriteconfig6 --file /etc/xdg/kdeglobals --group KDE --key LookAndFeelPackage org.oldnet.desktop
kwriteconfig6 --file /etc/xdg/konsolerc --group "Desktop Entry" --key DefaultProfile OldNet.profile

# --- Fonts (OFL) ---
dnf5 -y install ibm-plex-mono-fonts
dnf5 clean all

# Later: widgets, packages go in numbered scripts called from here.
