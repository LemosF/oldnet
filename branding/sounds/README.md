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
