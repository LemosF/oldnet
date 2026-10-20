#!/usr/bin/bash
# Default global theme and Konsole profile (theme files come from system_files/).
set -euo pipefail

# Log what the base image sets, so CI shows any upstream override we must handle.
grep -rs 'LookAndFeelPackage\|ColorScheme' /etc/xdg/kdeglobals /usr/share/kde-settings 2>/dev/null || true
# kwriteconfig6 merges into an existing /etc/xdg file instead of replacing it.
kwriteconfig6 --file /etc/xdg/kdeglobals --group KDE --key LookAndFeelPackage org.oldnet.desktop
kwriteconfig6 --file /etc/xdg/konsolerc --group "Desktop Entry" --key DefaultProfile OldNet.profile

# os-release says LOGO=oldnet: the splash after login and "About this System" look it up
# in hicolor, so without this they show a missing-image icon.
install -Dm644 /usr/share/oldnet/branding/logo/mark-dark.svg /usr/share/icons/hicolor/scalable/apps/oldnet.svg

# --- Themes the global theme cannot set on its own (it covers colours, icons, cursor,
# window decoration and splash for new users).
for t in /usr/share/icons/OldNet /usr/share/icons/OldNet-Cursors /usr/share/sounds/OldNet \
         /usr/share/wallpapers/OldNet-BlissNeon; do
  [ -d "$t" ] || { echo "missing theme: $t"; exit 1; }
done

# Sound theme (freedesktop name, read by Plasma's notifications).
kwriteconfig6 --file /etc/xdg/kdeglobals --group Sounds --key Theme OldNet

# Lock screen wallpaper matches the desktop.
kwriteconfig6 --file /etc/xdg/kscreenlockerrc --group Greeter --group Wallpaper \
  --group org.kde.image --group General --key Image "file:///usr/share/wallpapers/OldNet-BlissNeon/"

# Cursor for non-Plasma programs (GTK, X11 apps) that read the "default" icon theme.
mkdir -p /usr/share/icons/default
printf '[Icon Theme]\nInherits=OldNet-Cursors\n' > /usr/share/icons/default/index.theme

# "About this System": Bazzite ships its own name, logo and website here.
case "${IMAGE_NAME:-}" in
  *deck*)   variant="Handheld / HTPC" ;;
  *nvidia*) variant="Desktop (NVIDIA)" ;;
  *)        variant="Desktop" ;;
esac
kwriteconfig6 --file /etc/xdg/kcm-about-distrorc --group General --key Name "OldNet OS"
kwriteconfig6 --file /etc/xdg/kcm-about-distrorc --group General --key LogoPath /usr/share/icons/hicolor/scalable/apps/oldnet.svg
kwriteconfig6 --file /etc/xdg/kcm-about-distrorc --group General --key Website https://github.com/LemosF/oldnet
kwriteconfig6 --file /etc/xdg/kcm-about-distrorc --group General --key Variant "$variant"
# Show os-release VERSION ("2026.10.20 (based on Bazzite 44)", set in build.sh) instead of
# VERSION_ID, which is Fedora's release number.
kwriteconfig6 --file /etc/xdg/kcm-about-distrorc --group General --key UseOSReleaseVersion true
