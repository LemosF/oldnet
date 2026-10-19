#!/usr/bin/bash
# Login screen. Bazzite desktop images (Fedora KDE) use Plasma Login Manager;
# only the deck image installs SDDM, which uses the OldNet SDDM theme shipped in
# system_files/ and selected by /usr/lib/sddm/sddm.conf.d/zz-oldnet.conf.
set -euo pipefail

if command -v sddm >/dev/null; then
  echo "Login manager: SDDM (OldNet theme)"
  test -f /usr/share/sddm/themes/oldnet/Main.qml
  if [ -d /usr/lib64/qt6/qml/QtQuick/VirtualKeyboard ]; then
    echo "QtVirtualKeyboard: present"
  else
    echo "QtVirtualKeyboard: absent (on-screen keyboard disabled in the login theme)"
  fi
elif rpm -q plasma-login-manager >/dev/null 2>&1; then
  echo "Login manager: Plasma Login Manager (OldNet SDDM theme unused)"
else
  echo "Login manager: unknown"
fi
