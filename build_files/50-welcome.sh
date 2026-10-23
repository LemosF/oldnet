#!/usr/bin/bash
# OldNet welcome app (PySide6 + QML): replaces Bazzite's portal on first login.
set -euo pipefail

dnf5 -y install python3-pyside6
dnf5 clean all
chmod 0755 /usr/bin/oldnet-welcome

# New users no longer get Bazzite's portal autostart; ours runs from /etc/xdg/autostart.
# (main.py --first-run removes the copy existing users already have.)
rm -f /etc/skel/.config/autostart/bazzite-portal.desktop

for f in /usr/lib/oldnet-welcome/main.py /usr/lib/oldnet-welcome/Main.qml \
         /usr/share/oldnet/welcome/packs.json /usr/share/oldnet/welcome/header-a-1920x480.png; do
  [ -f "$f" ] || { echo "welcome app file missing: $f"; exit 1; }
done
python3 -c 'import json; json.load(open("/usr/share/oldnet/welcome/packs.json"))'

# Load the interface offscreen and fail on QML errors (Qt prints them to stderr).
log=$(mktemp)
set +e
HOME=$(mktemp -d) QT_QPA_PLATFORM=offscreen timeout 30 /usr/bin/oldnet-welcome --check >"$log" 2>&1
rc=$?
set -e
cat "$log"
if grep -E '\.qml:[0-9]+|is not a type|is not installed|is not defined|ReferenceError|TypeError|failed to load|Traceback' "$log"; then
  echo "WELCOME CHECK FAILED: errors in the welcome app (see above)"; exit 1
fi
[ "$rc" = 0 ] || { echo "WELCOME CHECK FAILED: exit code $rc"; exit 1; }
rm -f "$log"
echo "Welcome app: loads cleanly"
