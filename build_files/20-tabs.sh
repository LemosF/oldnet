#!/usr/bin/bash
# OldNet Tabs: each tab is a KDE activity (Desktop, Mail, Messages, Games, Code),
# managed by /usr/bin/oldnet-tab. Meta+1..5 switch tabs. The widget itself is copied
# from widgets/ by the Containerfile.
set -euo pipefail

SHORTCUTS=/etc/xdg/kglobalshortcutsrc
TABS=(Desktop Mail Messages Games Code)

chmod 0755 /usr/bin/oldnet-tab

# The apps that own the Mail and Messages tabs (Option 3, step 1; our own apps come later).
dnf5 -y install thunderbird neochat
dnf5 clean all
# oldnet-tab looks for these desktop file names; fail early if the packages renamed them.
found_mail=""
for f in org.mozilla.Thunderbird thunderbird net.thunderbird.Thunderbird; do
  [ -f "/usr/share/applications/$f.desktop" ] && found_mail=$f
done
[ -n "$found_mail" ] || { echo "Thunderbird desktop file not found"; exit 1; }
[ -f /usr/share/applications/org.kde.neochat.desktop ] || { echo "NeoChat desktop file not found"; exit 1; }
echo "Tab apps: Mail=$found_mail.desktop Messages=org.kde.neochat.desktop"

# KWin script that opens them full screen on their tabs (see its main.js).
kwriteconfig6 --file /etc/xdg/kwinrc --group Plugins --key oldnet-tab-appsEnabled true

for i in "${!TABS[@]}"; do
  n=$((i + 1))
  # The task manager claims Meta+1..9 by default; give Meta+1..5 to the tabs.
  kwriteconfig6 --file "$SHORTCUTS" --group plasmashell --key "activate task manager entry $n" \
    "none,Meta+$n,Activate Task Manager Entry $n"

  # A hidden launcher per tab; kglobalaccel binds X-KDE-Shortcuts like Konsole's Ctrl+Alt+T.
  cat > "/usr/share/applications/oldnet-tab-$n.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=OldNet Tab $n: ${TABS[$i]}
Exec=/usr/bin/oldnet-tab switch $n
Icon=oldnet-tabs
NoDisplay=true
X-KDE-Shortcuts=Meta+$n
EOF
done

rm -f /usr/share/plasma/plasmoids/.gitkeep
