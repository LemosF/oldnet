#!/usr/bin/bash
# Login screen: the OldNet SDDM theme ships in system_files/ and is selected by
# /usr/lib/sddm/sddm.conf.d/zz-oldnet.conf. Fail early if something it needs is gone.
set -euo pipefail

command -v sddm >/dev/null || { echo "sddm missing from the base image"; exit 1; }
test -f /usr/share/sddm/themes/oldnet/Main.qml

# Logged for CI: the deck image enables the on-screen keyboard in SDDM.
if [ -d /usr/lib64/qt6/qml/QtQuick/VirtualKeyboard ]; then
  echo "QtVirtualKeyboard: present"
else
  echo "QtVirtualKeyboard: absent (on-screen keyboard disabled in the login theme)"
fi
