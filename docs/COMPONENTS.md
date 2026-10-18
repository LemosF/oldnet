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

Planned fonts: Chakra Petch and IBM Plex Mono. Both are under the SIL Open Font
License 1.1. Their license files will ship with them.
