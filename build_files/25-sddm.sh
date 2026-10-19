#!/usr/bin/bash
# Desktop images: replace Plasma Login Manager (Fedora KDE default) with SDDM so the
# OldNet login theme is used. The deck image already ships SDDM and is left alone.
# Same swap Bazzite does for its deck image.
set -euo pipefail

if ! rpm -q plasma-login-manager >/dev/null 2>&1; then
  echo "No Plasma Login Manager here (deck image): login manager unchanged"
  exit 0
fi

# Remove first: its %preun drops the display-manager.service alias, so SDDM can take it.
# Also removes kcm-plasmalogin; sddm-kcm replaces it in System Settings.
dnf5 -y remove plasma-login-manager
dnf5 -y install sddm sddm-kcm   # pulls sddm-wayland-plasma (greeter on KWin Wayland)
dnf5 clean all

systemctl enable --force sddm.service

# Fedora Kinoite workaround that adds plasmalogin entries to /etc/shadow; without
# Plasma Login Manager it would only leave orphan entries. Also disabled in the
# first-boot preset (usr/lib/systemd/system-preset/10-oldnet.preset).
if systemctl cat fedora-kinoite-plasmalogin-workaround.service >/dev/null 2>&1; then
  systemctl disable fedora-kinoite-plasmalogin-workaround.service
fi
