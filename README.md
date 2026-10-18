# OldNet OS
Public Linux distro based on Bazzite (Fedora Atomic / Universal Blue). KDE Plasma 6.
Images: `oldnet`, `oldnet-nvidia`, `oldnet-deck`.

Status: pipeline skeleton. Next: palette A + global KDE theme.
Rules: all art/fonts/sounds original; no Microsoft, CD Projekt or Bazzite assets/logos.

Setup: generate a cosign key pair (`cosign generate-key-pair`), put `cosign.key` in the
repo secret `SIGNING_SECRET`, commit `cosign.pub`.
