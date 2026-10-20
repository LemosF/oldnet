# OldNet sounds

Every sound is synthesized from scratch by `synth.py` (numpy + soundfile).
No samples are used, from games, anime, Windows or anywhere else. Licensed
Apache-2.0 like the rest of the repo.

Each event has two variants:

- `-a`: warm chimes and simple melodies
- `-b`: cyberpunk HUD (blips, sweeps, bit-crush, glitch)

## Regenerate

```sh
python -m venv .venv && .venv/bin/pip install numpy soundfile
.venv/bin/python synth.py        # writes out/<event>-a.ogg and out/<event>-b.ogg
```

The output is deterministic (fixed seed). All 32 variants ship in
`/usr/share/oldnet/sounds-candidates/`.

## Variants used by the OldNet sound theme

`system_files/usr/share/sounds/OldNet/stereo/<event>.ogg` is a copy of the
chosen variant:

| Event | Variant |
|---|---|
| bell | b |
| button-pressed | a |
| complete | a |
| desktop-login | b |
| desktop-logout | b |
| desktop-shutdown | b |
| device-added | b |
| device-removed | b |
| dialog-error | b |
| dialog-information | b |
| dialog-warning | a |
| message-new-instant | b |
| oldnet-blackice-alert | b |
| oldnet-jack-in | b |
| oldnet-quickhack | b |
| trash-empty | a |

## Login screen sound

`futuristic-errors/synth_futuristic.py` (also uses `synth.py`) makes the
"lockerr" sound: bip (0.00 s), bip (0.12 s), bzzt (0.26–0.45 s). The SDDM theme
plays it when a login fails, from
`system_files/usr/share/sddm/themes/oldnet/assets/login-failed.wav`. It is a WAV
because Qt's SoundEffect only plays WAV. The theme's animation is timed to it: soft
pulses on the bips, then the panel jolt on the bzzt (`bzztAt` in `Main.qml`).
