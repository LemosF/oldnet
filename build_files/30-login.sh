#!/usr/bin/bash
# Login screen checks. Every image must end up on SDDM with the OldNet theme:
# desktop images get it from 25-sddm.sh, the deck image from Bazzite itself.
set -euo pipefail

fail() { echo "LOGIN CHECK FAILED: $*"; exit 1; }
THEME=/usr/share/sddm/themes/oldnet

# --- SDDM installed and owning display-manager.service
rpm -q sddm >/dev/null || fail "sddm is not installed"
! rpm -q plasma-login-manager >/dev/null 2>&1 || fail "plasma-login-manager is still installed"
dm=$(readlink -f /etc/systemd/system/display-manager.service || true)
[ "$dm" = /usr/lib/systemd/system/sddm.service ] || fail "display-manager.service -> '${dm:-none}', expected sddm.service"
[ "$(systemctl is-enabled plasmalogin.service 2>/dev/null || true)" != enabled ] || fail "plasmalogin.service is enabled"

# --- Desktop images: no Steam Game Mode autologin inherited from Bazzite's deck setup
if [[ "${IMAGE_NAME:-}" != *deck* ]]; then
  [ ! -f /usr/lib/sddm/sddm.conf.d/holo.conf ] || fail "holo.conf (Game Mode relogin) present on a desktop image"
  [ "$(systemctl is-enabled bazzite-autologin.service 2>/dev/null || true)" != enabled ] \
    || fail "bazzite-autologin.service is enabled on a desktop image"
  [ -f /usr/lib/tmpfiles.d/oldnet-desktop-autologin.conf ] || fail "autologin cleanup (tmpfiles) missing"
fi

# --- Theme files present and selected
for f in Main.qml VirtualKeyboard.qml metadata.desktop theme.conf \
         backgrounds/background-a-3840x2160.png backgrounds/background-b-3840x2160.png \
         backgrounds/background-light-3840x2160.png; do
  [ -f "$THEME/$f" ] || fail "theme file missing: $f"
done
# Last Current= wins (conf.d in order, /etc after /usr/lib); it must be ours.
# Only existing files: an empty conf.d leaves the glob unexpanded, and cat failing on it
# would end the script silently under pipefail.
current=
for conf in /usr/lib/sddm/sddm.conf.d/*.conf /etc/sddm.conf.d/*.conf /etc/sddm.conf; do
  [ -f "$conf" ] || continue
  value=$(sed -n 's/^Current=//p' "$conf" | tail -n1)
  [ -z "$value" ] || current=$value
done
[ "$current" = oldnet ] || fail "SDDM theme resolves to '${current:-default}', expected oldnet"

# --- Load the theme with the qml tool and fail on QML errors. The harness stands in for the
# context objects SDDM provides (sddm, userModel, sessionModel, keyboard, config). The
# greeter's own --test-mode is not used: it logs to the journal, so its errors never reached
# this script (an undefined textConstants slipped through that way).
qml_bin=$(command -v qml-qt6 qml6 2>/dev/null | head -n1 || true)
[ -n "$qml_bin" ] || { [ -x /usr/lib64/qt6/bin/qml ] && qml_bin=/usr/lib64/qt6/bin/qml; }
[ -n "$qml_bin" ] || fail "no qml runtime found to test the theme"

work=$(mktemp -d)
cat > "$work/harness.qml" <<EOF
import QtQuick
Item {
    width: 1920; height: 1080
    property QtObject sddm: QtObject {
        property string hostName: "oldnet"
        property bool canSuspend: true; property bool canReboot: true; property bool canPowerOff: true
        signal loginFailed()
        function login(u, p, s) {} function suspend() {} function reboot() {} function powerOff() {}
    }
    property ListModel userModel: ListModel {
        property int lastIndex: 0; property string lastUser: ""
        ListElement { name: "oldnet"; realName: "OldNet" }
    }
    property ListModel sessionModel: ListModel {
        property int lastIndex: 0
        ListElement { name: "Steam Big Picture" }
        ListElement { name: "Plasma" }
    }
    property QtObject keyboard: QtObject { property bool capsLock: true }
    property QtObject config: QtObject { property string palette: "a"; property string defaultSession: "Plasma" }
    Loader { anchors.fill: parent; source: "file://$THEME/Main.qml" }
    Timer { interval: 3000; running: true; onTriggered: Qt.quit() }
}
EOF
set +e
QT_QPA_PLATFORM=offscreen timeout 30 "$qml_bin" "$work/harness.qml" >"$work/log" 2>&1
rc=$?
set -e
cat "$work/log"
# VirtualKeyboard.qml is allowed to fail to load: the Loader stays empty on purpose.
if grep -E '\.qml:[0-9]+|is not a type|is not installed|is not defined|Cannot assign|Cannot read|ReferenceError|TypeError' "$work/log" \
   | grep -v VirtualKeyboard; then
  fail "QML errors in the OldNet SDDM theme (see above)"
fi
[ "$rc" = 0 ] || fail "theme test exited with $rc"
rm -rf "$work"
[ -d /usr/lib64/qt6/qml/SddmComponents ] && echo "SddmComponents: present (translated texts)" \
  || echo "SddmComponents: absent (English texts)"

if [ -d /usr/lib64/qt6/qml/QtQuick/VirtualKeyboard ]; then
  echo "QtVirtualKeyboard: present"
fi
echo "Login: SDDM with the OldNet theme (${IMAGE_NAME:-unknown image})"
