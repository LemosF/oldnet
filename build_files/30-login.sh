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

# --- Load the theme in the real greeter (test mode, offscreen) and fail on QML errors.
# The greeter sends its log to the journal unless stderr is a terminal, so give it a pseudo
# terminal with Python's pty module (util-linux `script` is not in the image; python3 is).
# `timeout` ends the greeter (exit 124 is the normal outcome).
command -v python3 >/dev/null || fail "python3 not found, cannot test the theme"
work=$(mktemp -d)
set +e
QT_QPA_PLATFORM=offscreen timeout 25 \
  python3 -c 'import pty, sys; pty.spawn(sys.argv[1:])' \
  sddm-greeter-qt6 --test-mode --theme "$THEME" >"$work/log" 2>&1 </dev/null
rc=$?
set -e
tr -d '\r' < "$work/log" > "$work/clean.log"
cat "$work/clean.log"
# Without this the test could pass while seeing nothing, as it once did.
grep -qE 'GREETER|Main\.qml' "$work/clean.log" || fail "greeter output not captured (no greeter log lines)"
# VirtualKeyboard.qml is allowed to fail to load: the Loader stays empty on purpose.
if grep -E '\.qml:[0-9]+|is not a type|is not installed|is not defined|Cannot assign|Cannot read|ReferenceError|TypeError' "$work/clean.log" \
   | grep -v VirtualKeyboard; then
  fail "QML errors in the OldNet SDDM theme (see above)"
fi
[ "$rc" = 124 ] || echo "warning: greeter test exited with $rc (no QML errors found)"
rm -rf "$work"
[ -d /usr/lib64/qt6/qml/SddmComponents ] && echo "SddmComponents: present (translated texts)" \
  || echo "SddmComponents: absent (English texts)"

if [ -d /usr/lib64/qt6/qml/QtQuick/VirtualKeyboard ]; then
  echo "QtVirtualKeyboard: present"
fi
echo "Login: SDDM with the OldNet theme (${IMAGE_NAME:-unknown image})"
