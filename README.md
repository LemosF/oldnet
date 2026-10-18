# OldNet OS

OldNet OS is a public Linux distribution **based on Bazzite** (Fedora Atomic /
Universal Blue), with KDE Plasma 6. It is built for gaming and development, and
also works for streaming, home theatre (HTPC), handhelds and family use. The
desktop has a classic early-2000s layout with a restrained cyberpunk look:
chamfered corners, monospace type, HUD panels, and neon only as an accent.

## Images

| Image | Base | For |
|---|---|---|
| `ghcr.io/lemosf/oldnet` | `bazzite-dx` | AMD / Intel desktops and laptops |
| `ghcr.io/lemosf/oldnet-nvidia` | `bazzite-dx-nvidia` | NVIDIA GPUs |
| `ghcr.io/lemosf/oldnet-deck` | `bazzite-deck` | Steam Deck and other handhelds (no heavy dev tools) |

The images rebuild every day, following upstream. Each image is signed with
cosign.

## Try it (test machine or VM)

To switch an existing Bazzite or Fedora Atomic install:

```sh
rpm-ostree rebase ostree-unverified-registry:ghcr.io/lemosf/oldnet:latest
systemctl reboot
```

An installable ISO is planned.

To verify a signature:

```sh
cosign verify --key cosign.pub ghcr.io/lemosf/oldnet:latest
```

## Repository layout

| Path | Contents |
|---|---|
| `Containerfile` | One file for all three images, selected with `BASE_IMAGE` |
| `build_files/` | Scripts that run during the image build |
| `system_files/` | Files copied as-is into the image root |
| `themes/palettes/palettes.json` | The palettes: Night Market (default), Holo Tablet, Daylight |
| `tools/gen-themes.py` | Generates the theme files from the palettes. Run it after editing them |
| `themes/`, `widgets/`, `apps/`, `branding/` | Sources for the desktop pieces |

## Licensing

The code is under [Apache-2.0](LICENSE). See [NOTICE](NOTICE),
[TRADEMARKS.md](TRADEMARKS.md) for the name, artwork and base-project rules,
and [docs/COMPONENTS.md](docs/COMPONENTS.md) for third-party and proprietary
components (NVIDIA, Steam, firmware).

## Maintainer setup

Generate a cosign key pair (`cosign generate-key-pair`). Store `cosign.key` in
the repo secret `SIGNING_SECRET` and its password in `COSIGN_PASSWORD`, then
commit `cosign.pub`. Never commit the private key.
