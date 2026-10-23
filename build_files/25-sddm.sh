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

# Bazzite's deck autologin is present here too: bazzite-autologin.service writes a Steam
# Game Mode autologin for uid 1000 into /etc/sddm.conf.d/, and holo.conf relogs into it.
# Plasma Login Manager never read those, SDDM does: on a desktop the machine would boot
# straight into Game Mode (and loop when gamescope cannot start). Desktop images get the
# OldNet login screen instead.
if systemctl cat bazzite-autologin.service >/dev/null 2>&1; then
  systemctl disable bazzite-autologin.service
fi
rm -f /usr/lib/sddm/sddm.conf.d/holo.conf

# No "Return to Gaming Mode" shortcut on the desktop of new users: desktop images do
# not boot into Game Mode. (oldnet-tab removes copies existing users already have.)
rm -f /etc/skel/Desktop/Return.desktop

# The Steam sessions stay available, but a new desktop system starts on Plasma
# (they sort first alphabetically, so SDDM would otherwise preselect Steam).
echo "defaultSession=Plasma" >> /usr/share/sddm/themes/oldnet/theme.conf

cat > /usr/lib/systemd/system-preset/11-oldnet-desktop.preset <<'EOF'
# Desktop images only (written by build_files/25-sddm.sh): no Steam Game Mode autologin.
disable bazzite-autologin.service
EOF

# Systems that already booted a build where the service ran keep its files in /etc.
# Remove exactly those two; autologin set in System Settings (kde_settings.conf) stays.
cat > /usr/lib/tmpfiles.d/oldnet-desktop-autologin.conf <<'EOF'
# Desktop images only (written by build_files/25-sddm.sh).
r /etc/sddm.conf.d/zz-bazzite-autologin.conf
r /etc/sddm.conf.d/zz-holo-autologin.conf
EOF
