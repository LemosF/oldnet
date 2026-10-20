# Third-party components

The OldNet OS images are built on top of Bazzite, so they inherit everything
Bazzite ships. This list is not complete. Each package is licensed by its
authors. On an installed system, you can look a package up with
`rpm -qi <package>`.

## Proprietary or non-free components

| Component | Images | Notes |
|---|---|---|
| NVIDIA driver (user-space libraries, firmware) | `oldnet-nvidia` | NVIDIA license. The kernel module is open, but the user-space driver is proprietary. |
| Steam client | all | Valve Steam Subscriber Agreement. The client installs and updates itself. |
| Device firmware (`linux-firmware` and similar) | all | Redistributable binary blobs. Each one has its own license. |
| Media codecs | all | Covered by the licenses of the base image's packages. Patent rules differ by country. |

Flatpak apps from the optional packs on the welcome screen come from Flathub.
Each one carries its own license, and Flathub shows that license before install.

## Components added by OldNet OS

| Component | License |
|---|---|
| OldNet scripts, themes, widgets, apps | Apache-2.0 (this repo) |
| OldNet artwork, wallpapers, sounds | Apache-2.0 (this repo), see TRADEMARKS.md for the name and logo |

## Login manager: SDDM on every image

Fedora 44 KDE, and so Bazzite's desktop images, use Plasma Login Manager. OldNet
removes it from `oldnet` and `oldnet-nvidia` and installs SDDM (`sddm`,
`sddm-wayland-plasma`, `sddm-kcm`) instead. `oldnet-deck` already uses SDDM through
Bazzite. Bazzite does the same swap for its own deck image.

**Why:** Plasma Login Manager cannot load a custom QML login theme. The OldNet login
screen (chamfered HUD panel, palettes, power icons) only exists as an SDDM theme.
We accept the cost: each Fedora or Bazzite release must be checked to make sure the
swap still builds. `build_files/30-login.sh` fails the build if it does not.

| Piece | Where |
|---|---|
| Swap (remove PLM, install SDDM, enable `sddm.service`) | `build_files/25-sddm.sh` |
| Theme selection, cursor | `/usr/lib/sddm/sddm.conf.d/zz-oldnet.conf` (a theme chosen in System Settings, in `/etc`, still wins) |
| First-boot presets | `/usr/lib/systemd/system-preset/10-oldnet.preset` |
| Fallback after a rebase from PLM | `/usr/lib/systemd/system-generators/oldnet-display-manager` |
| Build checks | `build_files/30-login.sh` |

**Steam Game Mode autologin.** The Bazzite base also carries its deck autologin:
`bazzite-autologin.service` writes `/etc/sddm.conf.d/zz-bazzite-autologin.conf`
(user uid 1000) and `zz-holo-autologin.conf` (Game Mode session), and
`/usr/lib/sddm/sddm.conf.d/holo.conf` relogs into it. Plasma Login Manager ignored
those files, but SDDM reads them. On desktop images they would skip the login screen
and boot straight into Game Mode, and loop if gamescope cannot start (seen in a
VirtualBox VM). So on `oldnet` and `oldnet-nvidia`, `25-sddm.sh` disables the service
(also in a first-boot preset) and removes `holo.conf`. A tmpfiles rule deletes those two
generated files from `/etc` on systems that already booted with them. `oldnet-deck` keeps
the Game Mode autologin.

Coming from an image with Plasma Login Manager: `/etc/plasmalogin.conf*` and
`/var/lib/plasmalogin` stay on disk unused, and they are harmless. Automatic login set up
in Plasma Login Manager does not carry over. Set it again in System Settings, under
Login Screen (SDDM). See `docs/TESTING.md`.

## Fonts

| Font | Source | License |
|---|---|---|
| Chakra Petch | google/fonts, pinned commit and SHA-256 checked (`build_files/05-fonts.sh`) | SIL OFL 1.1, `/usr/share/licenses/chakra-petch/OFL.txt` |
| IBM Plex Mono | Fedora package `ibm-plex-mono-fonts` | SIL OFL 1.1 |
