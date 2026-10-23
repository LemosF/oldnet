#!/usr/bin/bash
# Boot splash: make the OldNet Plymouth theme the default and rebuild the initramfs,
# which is where Plymouth reads its theme from at boot. Same dracut call as Bazzite's
# build-initramfs. Runs last, after every other change that could land in the initramfs.
set -euo pipefail

THEME=/usr/share/plymouth/themes/oldnet
for f in oldnet.plymouth oldnet.script logo-mark.png logo-wordmark.png progress-frame.png \
         progress-block-on.png progress-block-off.png; do
  [ -f "$THEME/$f" ] || { echo "Plymouth theme file missing: $f"; exit 1; }
done

# The theme uses Plymouth's script module.
rpm -q plymouth-plugin-script >/dev/null || dnf5 -y install plymouth-plugin-script
dnf5 clean all

plymouth-set-default-theme oldnet
[ "$(plymouth-set-default-theme)" = oldnet ] || { echo "Plymouth theme not set"; exit 1; }

# One kernel in the image; build its initramfs like Bazzite does.
kver=$(ls /usr/lib/modules)
[ "$(wc -w <<<"$kver")" = 1 ] || { echo "expected one kernel, got: $kver"; exit 1; }
/usr/bin/dracut --no-hostonly --kver "$kver" --reproducible --zstd -v --add ostree --add fido2 \
  -f "/usr/lib/modules/$kver/initramfs.img" 2>&1 | tail -n 5
chmod 0600 "/usr/lib/modules/$kver/initramfs.img"

# The new initramfs must carry the OldNet theme. (List to a file first: grep -q on a
# pipe would end lsinitrd with SIGPIPE and fail under pipefail.)
lsinitrd "/usr/lib/modules/$kver/initramfs.img" > /tmp/initramfs.list
grep -q 'plymouth/themes/oldnet/oldnet.script' /tmp/initramfs.list \
  || { echo "OldNet Plymouth theme is not in the initramfs"; exit 1; }
rm -f /tmp/initramfs.list
echo "Plymouth: OldNet theme in the initramfs ($kver)"
